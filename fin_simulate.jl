# fin_simulate.jl
# Function to run the provider simulation. 
# 
# Inputs: 
# day_of_entry: array containing, for each patient, when the patient is admitted. 
# rday_of_surgery_completion: array containing, for each patient, how many days after the day_of_entry did the patient complete surgery. 
# rday_of_discharge: array containing, for each patient, how many days after the day_of_entry did the patient get discharged.
# predict_0: array containing, for each patient, the risk prediction (probability between 0 and 1) for the patient available on the day of surgery completion.
# predict_1: array containing, for each patient, the risk prediction (probability between 0 and 1) for the patient available 1 day after the day of surgery completion.
# predict_2: array containing, for each patient, the risk prediction (probability between 0 and 1) for the patient available 2 days or more after the day of surgery completion.
# endpoint: array containing, for each patient, a 0/1 to indicate whether the patient is readmitted or not.
# HCUP_cost: array containing, for each patient, the cost of that patient's readmission based on HCUP data from Bailey et al. (see paper for more details).
# dayofweek: array containing, for each day in the simulation, the day of the week, numbered from 1 (Monday) to 7 (Sunday).
# day_list: array containing the days in the simulation. (This array must be formatted as n, n+1, ..., n + k, where n is an integer and k is the duration of the simulation. For example,
# day_list could be [45, 46, 47, 48, 49, 50, 51], so 45 would be the first day in the simulation.)
# visit_days: array containing a subset of the values [1,2,3,4,5,6,7], indicating the provider's schedule (e.g., visit_days = [1,3] corresponds to a Monday/Wednesday schedule.)
# capacity_per_day: integer that represents the maximum number of patients the provider can see on any day in the schedule encoded by visit_days. 
# atdischarge: boolean, indicating whether the provider can only see patients who are being discharged on the current day or not. 
# 
# Outputs: (see paper for definitions)
# PS: patients seen metric
# RA: readmissions anticipated 
# ERC: expected readmission cost savings
# This function takes the above data and runs the provider simulation. 


function fin_simulate(day_of_entry, rday_of_surgery_completion, rday_of_discharge, predict_0, predict_1, predict_2, endpoint, HCUP_cost, dayofweek, day_list, 
						visit_days, capacity_per_day, atdischarge)

	num_patients = length(endpoint) # Determine number of patients 
	is_seen = zeros(Bool, num_patients) # For each patient, track whether they have been seen by the provider yet, or not.
	num_days = length(day_list) # Determine the number of days in the simulation from day_list. 

	# Iterate through each day in the simulation
	for i in 1:num_days
		day = day_list[i] # Retrieve the day ID 

		if (dayofweek[i] in visit_days) # Check if the day of the week of this day falls in the provider's schedule

			# Has the patient completed surgery by this day? 
			cond1 = (day_of_entry + rday_of_surgery_completion .- 1) .<= day
			if (atdischarge)
				# If atdischarge is true, has the patient been discharged yet? 
				cond1 = day .>= (day_of_entry + rday_of_discharge .- 1)
			end

			# Is this day on or before the patient's day of discharge?
			cond2 = day .<= (day_of_entry + rday_of_discharge .- 1)

			# Has the patient not yet been selected by the provider?
			cond3 = .!is_seen

			# Find all patients satisfying these three criteria; these are the eligible patients.
			eligible_patients = findall(cond1 .& cond2 .& cond3)

			if (!isempty(eligible_patients))

				# For these eligible patients, compute what their current risk prediction is. 
				# The conditional in the loop below ensures that we use the most recent risk prediction.
				risk = zeros(length(eligible_patients))

				for j in 1:length(eligible_patients)
					p = eligible_patients[j]
					if (day == (day_of_entry[p] + rday_of_surgery_completion[p] - 1) )
						risk[j] = predict_0[p]
					elseif (day == (day_of_entry[p] + rday_of_surgery_completion[p] - 1 + 1))
						risk[j] = predict_1[p]
					elseif (day >= (day_of_entry[p] + rday_of_surgery_completion[p] - 1 + 2) )
						risk[j] = predict_2[p]
					else
						error("Weird issue with day; check!")
					end
				end

				# Order the patients from highest to lowest risk. 
				priority_order = sortperm(risk, rev = true )

				# Determine how many patients will be seen; this is the lower of the capacity_per_day,
				# or however many patients are eligible 
				min_capacity_available = min(length(eligible_patients), capacity_per_day)

				# Flag the top patients
				for j in 1:min_capacity_available
					p = eligible_patients[ priority_order[j] ]
					is_seen[p] = true
				end
			end
		end
	end




	# Add up how many patients have been flagged
	PS = sum(is_seen)

	# Add up the 0/1 binary variable for the endpoint, in order to obtain RA
	RA = sum(endpoint[ is_seen ])

	# Add up the HCUP cost for those patients that go on to be readmitted, and 
	# our provider had selected them. 
	ERC = sum(  HCUP_cost[ (endpoint .== 1) .& is_seen ])

	return PS, RA, ERC 
end