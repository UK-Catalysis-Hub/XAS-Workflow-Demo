# Larch XAS Workflow
This folder contains the Nextflow-Larch workflow, consisting of three python scripts
(Python 3.6) and input files needed to reproduce the steps of the 
[XAS fitting example](https://github.com/bruceravel/XAS-Education/tree/master/Examples/FeS2)
from Bruce Ravel. The aim of this workflow is to demonstrate that the tasks of 
the basic workflow can be managed using Nextflow and Larch producing faster results.

The three python files are described as follows
- Task 01 process files in "data direcory" using **xas01_athena.py** and copy output *.prj files into "output directory"
- Task 02.01 generate paths from "crystal files" using **xas02.01_feff.py** and output to dirs in "output directory"
- Task 02.02 fit paths to XAS spectra using **xas02.02_fit.py**" and writing the outputs to "output directory"

These tasks are coordinated by a NextFlow workflow which is defined in xas_main.nf. The workflow configuaration file 
nextflow.config indicates the location of the python scripts, the input files and directories, and the output paths.

The required python configuration ofr running this workflow is installed in a singularity image which is stored in 
the snglrty directory. This includes the full installation of the required larch libraries. Instead of saving the 
1.32GB singularity image, this repository only stores the singularity definition file used to create the image.

The repo also contains the shell script for scheduling the execution of the workflow, runwrkfl.sh
