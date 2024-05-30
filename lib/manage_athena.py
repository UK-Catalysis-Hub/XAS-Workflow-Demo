# managing athena files
from larch.io import create_athena, read_athena, extract_athenagroup, read_ascii, merge_groups

# calculate pre-edge and post edge for normalisation
from larch.xafs import pre_edge
# perform background removal
from larch.xafs import autobk
# calculate fourier transform
from larch.xafs import xftf

# rebin mu 
from larch.xafs import rebin_xafs

# math library contants the lcf function 
from larch import math

# plotting library
import matplotlib.pyplot as plt

# interpolate to produce smoother graphs
import numpy as np
from scipy.interpolate import make_interp_spline, BSpline

# File handling
from pathlib import Path

#library for writing to log
import logging

# create new instances of objects with deepcopy
import copy

 #######################################################
# | Create an output dir, point to the input file(s)  | #
# V              and set the logger                   V #
 #######################################################
def files_setup(out_prefix, in_path):
    # create the path for storing results
    out_path = Path("./" , out_prefix)
    Path(out_path).mkdir(parents=True, exist_ok=True)
    # set path for log
    log_file = Path("./",out_path,"process.log")
    #print("Log will be saved to:", log_file)
    #set_logger(log_file)
    source_path = Path(in_path)
    return source_path, out_path

 #######################################################
# |              initialise log file                  | #
# V                                                   V #
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
    #logging.info("Started processing")


 #######################################################
# |    Build a list of all files matching the given   | #
# V                     pattern                       V #
 #######################################################
def get_files_list(source_dir, f_pattern):
    i_counter = 0
    files_list = []
    if "/" in f_pattern:
        last_delimiter = f_pattern.rfind('/')
        source_dir = Path(str(source_dir), f_pattern[0:last_delimiter])
        f_pattern = f_pattern[last_delimiter+1:]
    print(source_dir)
    for filepath in sorted(source_dir.glob(f_pattern)):
        i_counter += 1
        print(filepath)
        files_list.append(filepath)
    return files_list


 #######################################################
# |    Read mu data from a text file, use labels      | #
# V         parameter to name columns                 V #
 #######################################################
def read_text(a_file, use_labels = "energy mu"):
    #logging.info ("Processing: " + a_file.name)
    #logging.info ("Path: "+ str(a_file))
    a_group = read_ascii(a_file, labels=use_labels)
    return a_group

 #######################################################
# |         Read data from Athena project file        | #
# V              returns a project object             V #
 #######################################################
def read_project(project_file):
    return read_athena(project_file)

 #######################################################
# |          Read groups from Athena project          | #
# V              returns a list of groups             V #
 #######################################################
def get_groups(athena_project):
    athena_groups = []
    group_keys=list(athena_project._athena_groups.keys())
    for group_key in group_keys:
        gr_0 = extract_athenagroup(athena_project._athena_groups[group_key])
        athena_groups.append(gr_0)
    return athena_groups

 #######################################################
# |          Read groups from Athena project          | #
# V              returns a list of groups             V #
 #######################################################
def get_group(athena_project, label):
    g = extract_athenagroup(athena_project._athena_groups[label])
    g = calc_with_defaults(g)
    return g

 #######################################################
# |              Merge readings in list               | #
# V                                                   V #
 #######################################################
def merge_readings(groups_list):
    return merge_groups (groups_list)

 #######################################################
# |                Recalibrate energy                 | #
# V             move E0 to match standard             V #
 #######################################################
def recalibrate_energy(a_group, recalibrate_to):
    a_group.energy = a_group.energy[:] + (recalibrate_to-a_group.e0)
    a_group.e0 = recalibrate_to
    return a_group

 #######################################################
# |                Rebin signal with                  | #
# V                     defaults                      V #
 #######################################################
def rebin_group(a_group):
    xr = copy.deepcopy(a_group)
    rebin_xafs(xr)#,group=xr,exafs1=50,xanes_step =0.5)
    xr.energy = copy.deepcopy(xr.rebinned.energy) 
    xr.mu = copy.deepcopy(xr.rebinned.mu)
    xr.e0 = copy.deepcopy(xr.rebinned.e0)
    xr.filename += " Rebinned"
    xr = fit_pre_post_edge(xr)
    return xr


 #######################################################
# |             Lineal Combination Fitting            | #
# V                group + standards                  V #
 #######################################################
def lcf_group(a_group, lcf_components=[]):
    if lcf_components == []:
        print ("need a list of component groups to fit")
    lcfr = math.lincombo_fit(a_group, lcf_components)#, vary_e0=True)
    names_lbl = ""

    lcfr.energy = lcfr.xdata
    lcfr.mu = lcfr.ydata
    lcfr = fit_pre_post_edge(lcfr)
    
    names_lbl = ""
    array_label = ""
    for a_w in lcfr.weights:
        names_lbl += a_w + " " 
        array_label += a_w + ": " + '%.2f' % (lcfr.weights[a_w]*100.0) + "% "
    lcfr.filename = names_lbl
    
  
    lcfr.arrayname = array_label
    
    return lcfr

 #######################################################
# |         Athena recalculates everything so we      | #
# |      need to create a function that calculates    | #
# V               all for each new group              V #
 #######################################################
def calc_with_defaults(xafs_group):
    # calculate mu and normalise with background extraction
    # should let the user specify the colums for i0, it, mu, iR. 
    if not hasattr(xafs_group, 'mu'):
        xafs_group = get_mu(xafs_group)
    # calculate pre-edge and post edge and add them to group
    # need to read parameters for pre-edge before background calculation with  
    # defaul values undo the work of previous step (setting pre-edge limits).
    pre_edge(xafs_group, pre1=xafs_group.athena_params.bkg.pre1, pre2=xafs_group.athena_params.bkg.pre2)
    #pre_edge(xafs_group)
    # perform background removal
    autobk(xafs_group) # using defaults so no additional parameters are passed
    # calculate fourier transform
    xftf(xafs_group)#, kweight=0.5, kmin=3.0, kmax=12.871, dk=1, kwindow='Hanning')
    return xafs_group

 #######################################################
# | Calculate pre-edge and post edge and add them to  | #
# V             group using given parameters          V #
 #######################################################

def fit_pre_post_edge(xas_data, pre_lower=-150, pre_upper=-60):
    pre_edge(energy=xas_data.energy, mu=xas_data.mu , group=xas_data, pre1 = pre_lower, pre2=pre_upper)
    return xas_data

 #######################################################
# |        Save data as an athena project             | #
# V                                                   V #
 #######################################################

def save_athena(xas_data, out_file):
    #logging.info ("project path: "+ str(out_file))
    xas_project = create_athena(out_file)
    xas_project.add_group(xas_data)
    xas_project.save() 


 #######################################################
# |      Save groups as an athena project             | #
# V                                                   V #
 #######################################################

def save_groups(xas_groups, out_file):
    #logging.info ("project path: "+ str(out_file))
    xas_project = create_athena(out_file)
    for xas_data in xas_groups:
        xas_project.add_group(xas_data)
    xas_project.save() 
    


 #######################################################
# |              Plot mu on energy                    | #
# V                                                   V #
 #######################################################
def plot_mu(xafs_group, plot_title = ""):
    plt.plot(xafs_group.energy, xafs_group.mu, label=xafs_group.filename) # plot mu in blue
    plt.grid(color='black', linestyle=':', linewidth=1) #show and format grid
    plt.xlabel('Energy (eV)') # label y graph
    plt.ylabel('x$\mu$(E)') # label y axis
    plt.title("$\mu$ " + plot_title) if not hasattr(xafs_group,"filename") else plt.title("$\mu$ " + xafs_group.filename)
    plt.legend() # show legend
    return plt

 
 #######################################################
# |      Plot pre-edge and post-edge fitting          | #
# V                                                   V #
 #######################################################      
def plot_edge_fit(xafs_group):
        plt.plot(xafs_group.energy, xafs_group.pre_edge, 'g', label='pre-edge') # plot pre-edge in green
        plt.plot(xafs_group.energy, xafs_group.post_edge, 'r', label='post-edge')# plot post-edge in red
        plt.plot(xafs_group.energy, xafs_group.mu, 'b', label=xafs_group.filename) # plot mu in blue
        plt.grid(color='r', linestyle=':', linewidth=1) #show and format grid
        plt.xlabel('Energy (eV)') # label y graph
        plt.ylabel('x$\mu$(E)') # label y axis
        plt.title("pre-edge and post_edge fitting to $\mu$")
        plt.legend() # show legend
        return plt

 #######################################################
# |                 Plot normalised mu                | #
# V                                                   V #
 #######################################################      
    
# show plot of normalised data
def plot_normalised(xafs_group):
    plt.plot(xafs_group.energy, xafs_group.norm, label=xafs_group.filename)
    plt.grid(color='r', linestyle=':', linewidth=1) #show and format grid
    plt.xlabel('Energy (eV)') # label y graph
    plt.ylabel('x$\mu$(E)') # label y axis
    plt.title("normalised to $\mu$")
    plt.legend() # show legend
    return plt

 #######################################################
# |                 Plot normalised mu                | #
# V                                                   V #
 #######################################################      
    
# show plot of normalised data
def plot_derivative(xafs_group):
    plt.plot(xafs_group.energy, xafs_group.dmude, label=xafs_group.filename)
    plt.grid(color='r', linestyle=':', linewidth=1) #show and format grid
    plt.xlabel('Energy (eV)') # label y graph
    plt.ylabel('Deriv normalised x$\mu$(E)') # label y axis
    plt.title("Derivative normalised to $\mu$")
    plt.legend() # show legend
    return plt



    

    
    