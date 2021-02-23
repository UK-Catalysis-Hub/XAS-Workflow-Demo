# Larch XAS Workflow
This folder contains the Larch workflow, consisting of two jupyter notebooks
(Python 3.6) and input files needed to reproduce the basic 
[XAS fitting example](https://github.com/bruceravel/XAS-Education/tree/master/Examples/FeS2).
from Bruce Ravel. The aim of this workflow is to demonstrate that the tasks of 
the basic workflow can be scripted using Larch producing equivalent results.

In addition to the documentation, the presentations from Bruce Ravel on XAS 
processing at Diamond Light Source were also used as reference 
([Bruce Ravel XAS course 2011](https://www.diamond.ac.uk/Instruments/Spectroscopy/Techniques/XAS.html)
November 2011). 
The first part this workflow was developed following examples from the Demeter 
[Programing guide](https://bruceravel.github.io/demeter/documents/DPG/index.html), 
while the second part is a modified version of the [FeS2 worked example](https://github.com/bruceravel/demeter/tree/master/examples/recipes/FeS2). 

The table below outlines the notebooks, tasks, inputs and outputs of the workflow.
The fists notebook (larch_task01.ipynb.pl) perfoms the create athena project and normalise
data task. This task  has three subtasks which are implemented in a text 
inteface.
The second notebook (larch_task01.ipynb.pl) performs the curve fitting. This task consists 
of eight sub-tasks. Curve fitting is an iterative task in which the researcher 
needs to look at the results of the initial fit and then adjust the parameters. 
This is implemented as a loop encompassing tasks  2.4 to 2.7. 
The use of notebooks allows presenting visual feedback in the form of data and
diagrams which can help the research in fine tunning the fitting.

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
|| 2.8.1 If not OK revise parameners and refit (go to 2.4)||
|| 2.8.2 If OK Save project and outputs|                                           |File: FeS2_01.fpj
