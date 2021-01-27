# Basic XAS Workflow
This folder contains the Athena, Artemis and input files needed to reproduce the basic 
[XAS fitting example](https://github.com/bruceravel/XAS-Education/tree/master/Examples/FeS2).
from Bruce Ravel.
In addition to the documentation, the presentations from Bruce Ravel on XAS processing at Diamond
Light Source were also used as reference 
([Bruce Ravel XAS course 2011](https://www.diamond.ac.uk/Instruments/Spectroscopy/Techniques/XAS.html)
November 2011).

Software | Task                            | Input                                         | Output
-------  | -------------                   |-------------                                  | -----  
Athena   | 1.1. Import data                |File: fes2_rt01_mar02.xmu                      | 
         | 1.2. Normalisation              |Parameters: Pre-edge range = -117.00 to 30.000 |
         | 1.3. Save Athena Project        |                                               |File: FeS2_01.prj
Artemis  | 2.1. Import data                |File: FeS2_01.prj                              |
         | 2.2. Import Crystal data        |File: FeS2.inp                                 |
		 | 2.3. Calculate Paths(Atoms+FEFF)||
		 | 2.4. Set path parameters        | Parameters:                                   |
		 |                                 |    amp  = 1                                   |
		 |                                 |    enot = 0                                   |
		 |                                 |    delr = 0                                   |
		 |                                 |    ss   = 0.003                               |
		 | 2.5. Run Fit                    |                                               |
		 | 2.6. Save project               ||
		 | 2.7. Verify fit results         ||
		 | 2.7.1 If not OK revise parameners and refit (go to 2.4)||
		 | 2.7.2 If OK Save project and outputs|                                           |File: FeS2_01.fpj
		 
## Acknowledgements and Funding
For more details about the of the motivation for the development of the resources
in this repository see:
[UK Catalysis Hub Core Theme](https://ukcatalysishub.co.uk/core/).

UK Catalysis Hub supports the development of this repository, funded by
EPSRC grants:  EP/R026939/1, EP/R026815/1, EP/R026645/1, EP/R027129/1,
and EP/M013219/1(biocatalysis))
