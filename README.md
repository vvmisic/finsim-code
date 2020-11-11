# A Framework for Evaluating Healthcare Machine Learning Models: Application and Analysis Using Hospital Readmission

This repository contains code to perform the provider-based simulation in the paper 

> V. V. Mišić, K. Rajaram and E. Gabel (2020). A Framework for Evaluating Healthcare Machine Learning Models: Application and Analysis Using Hospital Readmission. Working paper. 

## Citation

If you use the code and/or data in this repository in your own research, please cite the above paper as follows:

```
@article{misic2020framework,
	title={A Framework for Evaluating Healthcare Machine Learning Models: Application and Analysis Using Hospital Readmission},
	author={Mi\v{s}i\'{c}, Velibor V., and Rajaram, Kumar and Gabel, Eilon}},
	journal={Working paper},
	year={2020}
  }
```

## License 

This code is available under the MIT License.

Copyright (C) 2020 Velibor Misic

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.



## Software Requirements

To run the code, you need to have:
+ Julia version 1.5.0 or later


## Repository Structure

This repository contains two files. 

The file `fin_simulate.jl` contains code for the function `fin_simulate` which performs the provider simulation using input data that specifies the time horizon; the provider schedule and capacity; the predicted risk score of each patient (on the day of surgery completion; one day after surgery completion; and 2 or more days after surgery completion); the cost of readmission of each patient; the day on which each patient is admitted; how many days after admission does the patient complete surgery; and how many days after admission does the patient get discharged. 

The file `fin_example.jl` contains a script that uses the function `fin_simulate` with synthetic/artificially generated data to perform an example of the simulation. (Due to institutional restrictions, the real patient data used to perform the simulation in the paper is not included in this repository or in this script.) It additionally includes an example of code to compute bootstrap based confidence intervals for the main result metrics. It can be run by typing 

```
> julia fin_example.jl
```

in a terminal window. 
