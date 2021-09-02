 ########################################################
# |                Get scattering paths                | #
# | larch does not include a means for running atoms   | #
# | need to get input for feff and calculate paths     | #
# | currently the fastest option is to run Artemis to  | #
# | obtain the input (.inp) file for feff from a '.cif'| #
# V or '.inp' file                                     V #
 ########################################################

# get subprocess to run perl script
import subprocess

# run feff and get the paths
from larch.xafs.feffrunner import feff6l

# File handling
from pathlib import Path
import shutil


def run_atoms(crystal_f, feff_dir, feff_inp):  
    result = False
    retcode = subprocess.call(["perl", "./perl_lib/feff_inp.pl", crystal_f, feff_dir, feff_inp])
    if retcode == 0:
        result = True
    else:
        result = False
    return result

def copy_to_feff_dir(crystal_f, feff_file):
    # create dir if it does not exist
    feff_file.parent.mkdir(parents=True, exist_ok=True) 
    print ("copying", crystal_f.name, " to ", feff_file)
    shutil.copy(crystal_f, feff_file)
    return True

def run_feff(input_files):
    feff_dir_list = []
    for inp_file in input_files:
        crystal_f = Path(inp_file)
        # use the name of the input file to define the
        # names of the feff directory and inp file
        feff_dir = crystal_f.name[:-4]+"_feff"
        feff_inp = crystal_f.name[:-4]+"_feff.inp"
        # if file is not .inp 
        # run atoms to generate input for feff
        print(crystal_f.name[-3:])
        if crystal_f.name[-3:] != "inp":
            atoms_ok = run_atoms(str(crystal_f), feff_dir, feff_inp)
        else:
            atoms_ok = copy_to_feff_dir(crystal_f, Path(feff_dir, feff_inp))
        if atoms_ok:
            # run feff to generate the scattering paths 
            feff6l(folder = feff_dir, feffinp=feff_inp)
            feff_dir_list.append(feff_dir)
    return feff_dir_list
