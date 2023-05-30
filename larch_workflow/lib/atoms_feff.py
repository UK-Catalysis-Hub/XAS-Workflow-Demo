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

# pymatgen used to generate the feff.inp file 
from pymatgen.io.cif import CifParser, CifWriter
from pymatgen.io.feff.inputs import Atoms, Potential, Header

# FEFF to generate scattering paths
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

def inp_from_cif(crystal_f, feff_dir, feff_inp, absorbing,c_radius):
    crystal_f = Path(crystal_f)
    c_parser = CifParser(crystal_f)
    c_structure = c_parser.get_structures()[0]
    header_file = Path(feff_dir,"inp_header.txt")
    potentials_file = Path(feff_dir,"inp_potential.txt")
    atoms_file = Path(feff_dir,"inp_atoms.txt")
    
    # create inp contents from cif
    inp_header = Header.from_cif_file(crystal_f, source=crystal_f, comment="")
    inp_atoms = Atoms(c_structure,absorbing_atom=absorbing, radius=c_radius)
    inp_potential = Potential(c_structure,absorbing_atom=absorbing)
    
    # wirite individual inp content
    inp_header.write_file(header_file)
    inp_potential.write_file(potentials_file)
    inp_atoms.write_file(atoms_file)
    
    feff_file = Path(feff_dir, feff_inp)
    
    # join files into single inp file
    with open(feff_file, 'w' ) as result_file:
        # write header
        for line in open( header_file, 'r' ):
            result_file.write( line )
        # write RMAX
        result_file.write("\nRMAX      "+str(float(c_radius)) + "\n")
        # write potentials
        result_file.write("\n")
        for line in open( potentials_file, 'r' ):
            result_file.write( line )
        # write atoms
        result_file.write("\n")
        for line in open( atoms_file, 'r' ):
            result_file.write( line )
    return True

def copy_to_feff_dir(crystal_f, feff_file):
    print ("copying", crystal_f.name, " to ", feff_file)
    shutil.copy(crystal_f, feff_file)
    return True

def create_feff_dir(feff_dir, feff_inp):
    feff_file = Path(feff_dir, feff_inp)
    feff_file.parent.mkdir(parents=True, exist_ok=True) 

def run_feff(input_files, absorbing= [], radius = 0.0):
    feff_dir_list = []
    for inp_file, a_athom in zip(input_files, absorbing):
        crystal_f = Path(inp_file)
        # use the name of the input file to define the
        # names of the feff directory and inp file
        feff_dir = crystal_f.name[:-4]+"_feff"
        feff_inp = crystal_f.name[:-4]+"_feff.inp"
        # if file is not .inp 
        # create the folder for the outputs
        create_feff_dir(feff_dir, feff_inp)
        # run atoms to generate input for feff
        print(crystal_f.name[-3:])
        if crystal_f.name[-3:] != "inp":
            atoms_ok = inp_from_cif(str(crystal_f), feff_dir, feff_inp, a_athom, radius)
        else:
            atoms_ok = copy_to_feff_dir(crystal_f, Path(feff_dir, feff_inp))
        if atoms_ok:
            # run feff to generate the scattering paths 
            feff6l(folder = feff_dir, feffinp=feff_inp)
            feff_dir_list.append(feff_dir)
    return feff_dir_list
