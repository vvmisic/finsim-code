# fin_example.jl 
# Script to provide example of how the simulation method runs. 

using Statistics

include("fin_simulate.jl")

Random.seed!(111)


# Generate a random set of patients, with varying admission times over a horizon of 30 weeks ( = 210 days). 
num_patients = 5000
num_days = 7 * 30;

day_of_entry = rand(1:(num_days-15), num_patients)
rday_of_surgery_completion = rand(1:3, num_patients)
rday_of_discharge = rday_of_surgery_completion + rand(1:5, num_patients)


# Generate the endpoint (0/1 binary variable indicating if the patient is readmitted 
# or not); here roughly 5% of patients will be readmitted.
endpoint = rand( num_patients ) .>= 0.95

# Generate predictions. 
# Note that the predictions below are random; here, we would read the predictions from a CSV or 
# some other source which would contain the predictions that our model would make on each patient.
# Note that as defined, predictions on the readmissions (endpoint = 1) are Uniform(0,0.9)
# random variables, and on the non-readmissions (endpoint = 0) are Uniform(0,0.4). 
predict_0 = zeros(num_patients)
predict_0[endpoint] = 0.9*rand( sum(endpoint))
predict_0[!endpoint] = 0.4*rand( sum(!endpoint))

# predict_1 and predict_2 are arrays of predictions for the patients for 1 day, and 2 or more days after the completion of surgery,
# respectively. Here, we will just us the same predictions as the ones from the day of surgery completion. However,
# we can put different values in these arrays in case we wish to allow for the predictions to be updated during the patient's stay.
predict_1 = copy(predict_0)
predict_2 = copy(predict_1)

HCUP_cost = 14000 * ones(length(endpoint)) 

day_list = collect(1:num_days)

dayofweek = repeat( collect(1:7), 30) 

# Assume Monday (=1), Wednesday (=3) schedule with 8 patients per day.
visit_days = [1,3]
capacity_per_day = 8

# Assume that the provider is *not* restricted to only seeing
# patients on the day they are being discharged.
atdischarge = false

# Run the simulation
PS, RA, ERC  = fin_simulate(day_of_entry, rday_of_surgery_completion, rday_of_discharge, predict_0, predict_1, predict_2, endpoint, HCUP_cost, dayofweek, day_list, visit_days, capacity_per_day, atdischarge)


# Calculate the provider cost.
provider_wage_per_hour = 75.0
PC = ceil( num_days / 7) * capacity_per_day * length(visit_days) * provider_wage_per_hour
if ( length(visit_days) * capacity_per_day >= 20)	
	PC *= 1.25
end

# Calculate expected readmission cost savings, and expected net cost savings.
effectiveness_constant = 0.10
ERCS = effectiveness_constant * ERC
ENCS = ERCS - PC 

# Display all the metrics:
@show PS, RA, ERC, ERCS, PC, ENCS


# Example of bootstrapping
Random.seed!(200)

boot_samples = Array{Int64,1}[]
nB = 1000
for b in 1:nB
	push!(boot_samples, rand(1:length(endpoint), length(endpoint)))
end

PS_vec = zeros(nB)
RA_vec = zeros(nB)
ERC_vec = zeros(nB)

for b in 1:nB
	println("bootstrap example; b = ", b)
	bs = boot_samples[b]
	PS, RA, ERC = fin_simulate(day_of_entry[bs], rday_of_surgery_completion[bs], rday_of_discharge[bs], predict_0[bs], predict_1[bs], predict_2[bs], endpoint[bs], HCUP_cost[bs], dayofweek, day_list, 
							visit_days, capacity_per_day, atdischarge)
	PS_vec[b] = PS
	RA_vec[b] = RA
	ERC_vec[b] = ERC
end

PS_025, PS_975 = quantile(PS_vec, [0.025, 0.975])
RA_025, RA_975 = quantile(RA_vec, [0.025, 0.975])
ERC_025, ERC_975 = quantile(ERC_vec, [0.025, 0.975])



