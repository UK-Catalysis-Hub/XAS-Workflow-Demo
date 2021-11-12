# Larch Libraries
# managing athena files
from larch.io import create_athena, read_athena, extract_athenagroup
# calculate pre-edge and post edge for normalisation
from larch.xafs import pre_edge
# perform background removal
from larch.xafs import autobk
# calculate fourier transform
from larch.xafs import xftf

from larch import Interpreter

# File handling
from pathlib import Path

#plotting library
import matplotlib.pyplot as plt

# subprocess library used to run perl script
import subprocess

#library for writing to log
import logging

# Library with the functions that handle athena files
import lib.manage_athena as athenamgr  

# Library with the functions that execute 
# Atoms and FEFF to generate scattering paths
import lib.atoms_feff as feff_runner   

# Set parameters          
# library containign functions tho manage fit, at read, write 
# GDS parameters, and scattering paths. 
import lib.manage_fit as fit_manager  

# managing parameters
import sys

# for converting text list to python list
import ast

# library to handle ini file 
import configparser

# Custom Functions
#
# Functions (methods) for processing XAS files.
#
# set_logger: intialises the logging.
# get_files_list: returns a list of files in the directory matching the given file pattern.

 #######################################################
# |                Initialise log file                | #
# V  provide the path and name of the log file to use V #
 #######################################################
    
def set_logger(log_file):
    logger = logging.getLogger()
    fhandler = logging.FileHandler(filename=log_file, mode='a')
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    fhandler.setFormatter(formatter)
    logger.addHandler(fhandler)
    # prevent matplotlib font manager from writing to log
    logging.getLogger('matplotlib.font_manager').disabled = True
    logger.setLevel(logging.DEBUG)

 #######################################################
# |                  Get a list of files              | #
# V       provide the path and pattern to match       V #
 #######################################################
    
#reading all files with the same extension files from a dir
def get_files_list(source_dir, f_pattern):
    i_counter = 0
    files_list = []
    for filepath in sorted(source_dir.glob(f_pattern)):
        i_counter += 1
        files_list.append(filepath)
    return files_list


def single_file_task(a_file, gds_parms_f, sel_paths_f, fit_vars, out_pattern):
    # session object
    session = Interpreter()
    # read the gds parameters from input file
    gds = fit_manager.read_gds(gds_parms_f, session)
    logging.info("GDS Parameters read OK")
    project_name = a_file.name
    data_prj = read_athena(a_file)
    group_keys = list(data_prj._athena_groups.keys())
    athena_group = extract_athenagroup(data_prj._athena_groups[group_keys[0]])

    # create the path for storing results
    base_path = Path("./" , out_pattern+"_fit")
    Path(base_path).mkdir(parents=True, exist_ok=True) 

    # recalculate norm, background removal and fourier transform 
    # with defaults
    data_group = athenamgr.calc_with_defaults(athena_group)
    # read the selected paths list to access relevant paths 
    # generated from FEFF
    ##################################################################
    # for building the workflow !!!!
    # the csv file needs to point to the correct output directory 
    ##################################################################
    selected_paths = fit_manager.read_selected_paths_list(sel_paths_f, session)
    logging.info("Selected Paths read from " + sel_paths_f + " OK")
    # run fit
    trans, dset, out = fit_manager.run_fit(data_group, gds, selected_paths, fit_vars, session)
    show_graph = True
    if show_graph:    
        # plot normalised mu on energy
        # plot mu vs flat normalised mu for selected groups
        plt = athenamgr.plot_normalised(data_group)
        #plt.show()
        fig_file = Path("./",base_path,group_keys[0]+"_fit_nme.png")
        plt.savefig(fig_file)
        # overlapped chi(k) and chi(R) plots (similar to Demeter's Rmr plot)
        rmr_p = fit_manager.plot_rmr(dset,fit_vars['rmin'],fit_vars['rmax'])
        #rmr_p.show()
        fig_file = Path("./",base_path,group_keys[0]+"_fit_rmr.png")
        rmr_p.savefig(fig_file)
        # separate chi(k) and chi(R) plots
        chikr_p = fit_manager.plot_chikr(dset,fit_vars['rmin'],fit_vars['rmax'],fit_vars['kmin'],fit_vars['kmax'])
        #chikr_p.show()
        fig_file = Path("./",base_path,group_keys[0]+"_fit_chikr.png")
        chikr_p.savefig(fig_file)

            
    #save the fit report to a text file
    fit_file = Path("./",base_path,group_keys[0]+"_fit_rep.txt")
    fit_manager.save_fit_report(out, fit_file, session)

    logging.info("Processed file: "+  group_keys[0])


def read_ini(ini_file_path):
    try:
        ini_file = Path(ini_file_path)
        if ini_file.exists():
            #read parameter values from config file
            print ("reading from",ini_file)
            fit_config = configparser.ConfigParser()
            fit_config.read(ini_file)
            # Input parameters (variables)
            # variables that can be changed to process different datasets
            #top_count = int(fit_config['DEFAULT']["top_count"])
            show_graph = False # False to prevent showing graphs
                          
            # read variables for fit from config file
            fit_vars = {}
            fit_vars['fitspace']=fit_config['DEFAULT']["fitspace"]
            fit_vars['kmin']= int(fit_config['DEFAULT']["kmin"])
            fit_vars['kmax']=int(fit_config['DEFAULT']["kmax"])
            fit_vars['kw']=int(fit_config['DEFAULT']["kw"])
            fit_vars['dk']=int(fit_config['DEFAULT']["dk"])
            fit_vars['window']=fit_config['DEFAULT']["window"]
            fit_vars['rmin']=float(fit_config['DEFAULT']["rmin"])
            fit_vars['rmax']=float(fit_config['DEFAULT']["rmax"])
        else:
            print("invalid or non existent ini file")
            raise NameError('IniFileError')            
    except:
        print("provide a valid ini file (including path)")
    return show_graph, fit_vars
        
# do not run if only importing function(s)
if __name__ == '__main__':
  ## start_task(sys.argv[1:])
  ini_file = sys.argv[1]
  file_name = Path(sys.argv[2])
  out_pattern = sys.argv[3]
  gds_file = sys.argv[4]  
  selpaths_file = sys.argv[5]
  print (ini_file)
  # read ini values
  show_graph, fit_vars = read_ini(ini_file) 
  print("GDS:", gds_file, "PATHS:", selpaths_file, fit_vars)
  # the task needs to be further split into two because feff 
  # needs to run only once so 
  #  task 02.01  run feff
  #  task 02.02  run fit for each prj file
  # feff must have already, the crystal files list is not used here
  # run for one file using the feef output
  single_file_task(file_name, gds_file, selpaths_file, fit_vars, out_pattern)

