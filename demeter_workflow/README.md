# Demeter XAS Workflow
This folder contains the Demeter (perl) and input files needed to reproduce the
basic 
[XAS fitting example](https://github.com/bruceravel/XAS-Education/tree/master/Examples/FeS2).
from Bruce Ravel. The aim of this workflow is to demonstrate that the tasks of 
the basic workflow can be scripted (automated) producing equivalent results.

In addition to the documentation, the presentations from Bruce Ravel on XAS 
processing at Diamond Light Source were also used as reference 
([Bruce Ravel XAS course 2011](https://www.diamond.ac.uk/Instruments/Spectroscopy/Techniques/XAS.html)
November 2011). 
The first part this workflow was developed following examples from the Demeter 
[Programing guide](https://bruceravel.github.io/demeter/documents/DPG/index.html), 
while the second part is a modified version of the [FeS2 worked example](https://github.com/bruceravel/demeter/tree/master/examples/recipes/FeS2). 


The table below outlines the scripts, tasks, inputs and outputs of the workflow.
The fists script (demeter_01.pl) perfoms the create athena project and normalise
data task. This task  has three subtasks which are implemented in a text 
inteface.
The second script (demeter_02.pl) performs the curve fitting. This task consists 
of eight sub-tasks. Curve fitting is an iterative task in which the researcher 
needs to look at the results of the initial fit and then adjust the parameters. 
This is implemented as a loop encompassing tasks  2.4 to 2.8 . A text interface 
is used for presenting visual feedback in the form of data and diagrams which 
are intended to help the research in fine tunning the fitting.

## Tasks

|Script| Task                            | Input                                         | Output
|------| -------------                   |-------------                                  | -----  
|demeter_01.pl| 1.   Create Athena project      |                                               | 
|| 1.1. Import data                |File: fes2_rt01_mar02.xmu                      | 
|| 1.2. Normalisation              |Parameters: Pre-edge range = -117.00 to 30.000 |
|| 1.3. Save Athena Project        |                                               |File: FeS2_01.prj
|demeter_02.pl| 2.   Curve fitting||
|| 2.1. Import data                |File: FeS2_01.prj                              |
|| 2.2. Import Crystal data        |File: FeS2.inp                                 |
|| 2.3. Calculate Paths(Atoms+FEFF)||
|| 2.4. Set path parameters        | Parameters:                                   |
||                                 |    amp  = 1                                   |
||                                 |    enot = 0                                   |
||                                 |    delr = 0                                   |
||                                 |    ss   = 0.003                               |
|| 2.5. Select Paths ||
|| 2.6. Run Fit                    |                                               |
|| 2.7. Save project               ||
|| 2.8. Verify fit results         ||
|| 2.8.1. If not OK revise parameners and refit (go to 2.4)||
|| 2.8.2. If OK Save project and outputs|                                           |Files: FeS2_01_fit.dpj
|| | | FeS2_01.fit
|| | | FeS2_01_fit.log

## Automation
The batch files included in this repository allow automated processing of large
sets of files. Task_01.bat runs task one of the workflow on a set of files, 
producing a directory with the same number of Athena project files. Task_02.bat 
runs task 2 of the workflow (curve fitting) of the workflow over a set of Athena 
project files. 
Running Task_01.bat requires providing three arguments: (1) the common prefix
for the group of files, (2) the directory where the input files are located, and
(3) the number of files to process. 

```
C:\> task_01.bat rh4co ..\nexusdata\rh4co_ox_53\37123_Rh_4_CO_Oxidation_45_7_ascii\*.dat 5
```

Running Task_02.bat requires providing three arguments: (1) the common prefix
for the group of files, (2) the path to the crystal file to be used, and
(3) the number of files to process. 

```
C:\>task_02.bat rh4co ..\cif_files\C12O12Rh4.cif 5
```

