# managing athena files
from larch.io import create_athena, read_athena, extract_athenagroup

# plotting library
import matplotlib.pyplot as plt

 #######################################################
# |         Read data from Athena project file        | #
# V              returns a project object             V #
 #######################################################
def read_project(project_file):
    return read_athena(project_file)

 #######################################################
# |         Extract groups from Athena project        | #
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
    pre_edge(xafs_group, pre1=xafs_group.bkg_params.pre1, pre2=xafs_group.bkg_params.pre2)
    #pre_edge(xafs_group)
    # perform background removal
    autobk(xafs_group) # using defaults so no additional parameters are passed
    # calculate fourier transform
    xftf(xafs_group)#, kweight=0.5, kmin=3.0, kmax=12.871, dk=1, kwindow='Hanning')
    return xafs_group

 #######################################################
# |       The code for plotting Nmu vs E repeats      | #
# |   so it is useful to have a plotting function     | #
# V            to reduce duplicated code              V #
 #######################################################
def plot_normalised(xafs_group):
        plt.plot(xafs_group.energy, xafs_group.mu, label=xafs_group.filename) # plot mu in blue
        plt.grid(color='r', linestyle=':', linewidth=1) #show and format grid
        plt.xlabel('Energy (eV)') # label y graph
        plt.ylabel('x$\mu$(E)') # label y axis
        plt.title("pre-edge and post_edge fitting to $\mu$")
        plt.legend() # show legend
        return plt