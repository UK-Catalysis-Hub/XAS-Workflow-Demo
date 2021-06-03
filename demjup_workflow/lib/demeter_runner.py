 ########################################################
# |            Code for running Demeter                | #
# | Use the jupyter interface instead of the command   | #
# | line to run the Demeter workflow tasks.            | #
# V                                                    V #
 ########################################################

# get subprocess to run perl script
import subprocess

# File handling
from pathlib import Path


def run_atoms(crystal_f, feff_dir, feff_inp):  
    result = False
    retcode = subprocess.call(["perl", "./perl_lib/feff_inp.pl", crystal_f, feff_dir, feff_inp])
    if retcode == 0:
        result = True
    else:
        result = False
    return result
    
# run from command line with:
#   perl demeter_task01.pl data_file(.dat,.txt) group_name demeter_project(.prj) auto_flag(Y/N)
def run_task_01(data_file, group_name, demeter_project, auto_flag='N'):  
    result = False
    retcode = subprocess.call(["perl", "./perl_lib/demeter_task01.pl", data_file, group_name, demeter_project, auto_flag])
    if retcode == 0:
        result = True
    else:
        result = False
    return result

# run from command line with:
#   perl demeter_task02.pl athena_file(.prj) crystal_file(.inp/.cif) artemis_file(.fpj)
def run_task_02(athena_file, crystal_file, artemis_file, auto_flag='N'):  
    result = False
    retcode = subprocess.call(["perl", "./perl_lib/demeter_task02.pl", athena_file, crystal_file, artemis_file, auto_flag])
    if retcode == 0:
        result = True
    else:
        result = False
    return result
    
def run_feff(input_files):
    feff_dir_list = []
    for inp_file in input_files:
        crystal_f = Path(inp_file)
        # use the name of the input file to define the
        # names of the feff directory and inp file
        feff_dir = crystal_f.name[:-4]+"_feff"
        feff_inp = crystal_f.name[:-4]+"_feff.inp"
        # run atoms to generate input for feff
        atoms_ok = run_atoms(str(crystal_f), feff_dir, feff_inp)
        if atoms_ok:
            # run feff to generate the scattering paths 
            feff6l(folder = feff_dir, feffinp=feff_inp)
            feff_dir_list.append(feff_dir)
    return feff_dir_list
