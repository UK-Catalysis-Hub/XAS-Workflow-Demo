# Basic XAS Workflow
This folder contains the Athena, Artemis and input files needed to reproduce the basic 
[XAS fitting example](https://github.com/bruceravel/XAS-Education/tree/master/Examples/FeS2).
from Bruce Ravel.
In addition to the documentation, the presentations from Bruce Ravel on XAS processing at Diamond
Light Source were also used as reference 
([Bruce Ravel XAS course 2011](https://www.diamond.ac.uk/Instruments/Spectroscopy/Techniques/XAS.html)
November 2011).

The following table outlines the software, tasks, inputs and outputs. Curve fitting is an iterative process,
the researcher looks at the results of the initial fit and then adjusts the parameters. This loop happens
between steps 2.4 and 2.8 and requires presenting visual feedback in the form of data and diagrams which are 
used to determine if the fit is adequate.



|Software | Task                            | Input                                         | Output
|-------  | -------------                   |-------------                                  | -----  
|Athena   | 1.1. Import data                |File: fes2_rt01_mar02.xmu                      | 
|         | 1.2. Normalisation              |Parameters: Pre-edge range = -117.00 to 30.000 |
|         | 1.3. Save Athena Project        |                                               |File: FeS2_01.prj
|Artemis  | 2.1. Import data                |File: FeS2_01.prj                              |
|         | 2.2. Import Crystal data        |File: FeS2.inp                                 |
|   	  | 2.3. Calculate Paths(Atoms+FEFF)||
|         | 2.4. Set path parameters        | Parameters:                                   |
|         |                                 |    amp  = 1                                   |
|         |                                 |    enot = 0                                   |
|         |                                 |    delr = 0                                   |
|         |                                 |    ss   = 0.003                               |
|         | 2.5. Select Paths               |                                               |
|         | 2.6. Run Fit                    |                                               |
|         | 2.7. Save project               ||
|         | 2.8. Verify fit results         ||
|         | 2.8.1 If not OK revise parameners and refit (go to 2.4)||
|         | 2.8.2 If OK Save project and outputs|                                           |File: FeS2_01.fpj
		 

