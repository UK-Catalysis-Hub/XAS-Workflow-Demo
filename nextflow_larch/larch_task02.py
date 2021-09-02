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
import larch_plugins as lp

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


# session object
session = Interpreter()

def start_task(argv):
    print('Argument List:', argv)
    try:
        if len (argv) < 1:
            print ("Need to provide configuration file name")
            print ("Arguments passed:", argv)
        else:
            ini_file =  Path(argv[0])
            if ini_file.exists():
                #read parameter values from config file
                print ("reading from",ini_file)
                fit_config = configparser.ConfigParser()
                fit_config.read(ini_file)
                # Input parameters (variables)
                # variables that can be changed to process different datasets
                data_path = fit_config['DEFAULT']["data_path"]
                file_pattern = fit_config['DEFAULT']["file_pattern"]
                f_prefix = fit_config['DEFAULT']["f_prefix"]
                crystal_files = ast.literal_eval(fit_config['DEFAULT']["crystal_files"])
                gds_parms_f = str(fit_config['DEFAULT']["gds_parms_f"])
                sel_paths_f = fit_config['DEFAULT']["sel_paths_f"]
                top_count = int(fit_config['DEFAULT']["top_count"])
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
    except:
        print("provide a valid ini file (including path)")
            
    # create the path for storing results
    base_path = Path("./" , f_prefix+"_fit")
    Path(base_path).mkdir(parents=True, exist_ok=True)

    log_file = Path("./",base_path,"process.log")
    print(log_file)
    # set path for log
    set_logger(log_file)

    # get the list of files to process
    source_path = Path(data_path)
    files_list = get_files_list(source_path, file_pattern)
    xas_data = {}


    logging.info("Started processing")
    logging.info("input files")
    logging.info("\tdata_path    = " + data_path)
    logging.info("\tfile_pattern = " + file_pattern)
    logging.info("\tf_prefix     = " + f_prefix)
    logging.info("\tcrystal_files = " + str(crystal_files))
    logging.info("\tGDS parameters = " + str(gds_parms_f))
    logging.info("\tSelected paths = " + str(sel_paths_f))
    logging.info("\ttop_count    = " + str(top_count))
    logging.info("fit variables")
    logging.info("\tfit space  = " + str(fit_vars['fitspace']))
    logging.info("\tkmin  = " + str(fit_vars['kmin']))
    logging.info("\tkmax  = " + str(fit_vars['kmax']))
    logging.info("\tkw  = " + str(fit_vars['kw']))
    logging.info("\tdk  = " + str(fit_vars['dk']))
    logging.info("\twindow  = " + str(fit_vars['window']))
    logging.info("\trmin  = " + str(fit_vars['rmin']))
    logging.info("\trmax  = " + str(fit_vars['rmax']))

    # run feff on crystal file to generate scattering paths
    feff_runner.run_feff(crystal_files)
    logging.info("Completed FEFF")
    
    # counter for break
    i_count = 0
    for a_file in files_list:
        # read the gds parameters from input file
        gds = fit_manager.read_gds(gds_parms_f, session)
        logging.info("GDS Parameters read OK")
        project_name = a_file.name
        data_prj = read_athena(a_file)
        group_keys = list(data_prj._athena_groups.keys())
        athena_group = extract_athenagroup(data_prj._athena_groups[group_keys[0]])
        # recalculate norm, background removal and fourier transform 
        # with defaults
        data_group = athenamgr.calc_with_defaults(athena_group)

        # read the selected paths list to access relevant paths 
        # generated from FEFF
        selected_paths = fit_manager.read_selected_paths_list(sel_paths_f, session)
        logging.info("Selected Paths read from " + sel_paths_f + " OK")
        # run fit
        trans, dset, out = fit_manager.run_fit(data_group, gds, selected_paths, fit_vars, session)

        if show_graph:    
            # plot normalised mu on energy
            # plot mu vs flat normalised mu for selected groups
            plt = athenamgr.plot_normalised(data_group)
            plt.show()
            # overlapped chi(k) and chi(R) plots (similar to Demeter's Rmr plot)
            rmr_p = fit_manager.plot_rmr(dset,fit_vars['rmin'],fit_vars['rmax'])
            rmr_p.show()
            # separate chi(k) and chi(R) plots
            chikr_p = fit_manager.plot_chikr(dset,fit_vars['rmin'],fit_vars['rmax'],fit_vars['kmin'],fit_vars['kmax'])
            chikr_p.show()
            
        #save the fit report to a text file
        fit_file = Path("./",base_path,group_keys[0]+"_fit_rep.txt")
        fit_manager.save_fit_report(out, fit_file, session)

        i_count +=1
        
        logging.info("Processed file: "+ str(i_count) +" " + group_keys[0])
        
        if i_count == top_count:
            break
       
    logging.info("Finished processing")            

        
# To avoid running if the intention was only to import a function
if __name__ == "__main__":
   start_task(sys.argv[1:])
