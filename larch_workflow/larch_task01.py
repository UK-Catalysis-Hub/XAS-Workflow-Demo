# Larch Libraries
# library to read ascii files
from larch.io import read_ascii
# libraries to handle data groups
from larch.utils import group2dict, dict2group
# library to normalise data
from larch.xafs import pre_edge
# import the larch.io libraries for managing athena files
from larch.io import create_athena, read_athena, extract_athenagroup

# File handling
from pathlib import Path

#plotting library
import matplotlib.pyplot as plt

#library for writing to log
import logging

# Custom Functions
# The functions defined (methods) for processing XAS files.
# - set_logger: intialises the logging. 
# - get_files_list: returns a list of files in the directory matching the given file pattern.
# - rename_cols: renames the energy and mu columns (col1 and col2 in the dat files).
##- plot_normalised: shows the plot of normalised data


# initialise log file
def set_logger(log_file):
    logger = logging.getLogger()
    fhandler = logging.FileHandler(filename=log_file, mode='a')
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    fhandler.setFormatter(formatter)
    logger.addHandler(fhandler)
    # prevent matplotlib font manager from writing to log
    logging.getLogger('matplotlib.font_manager').disabled = True
    logger.setLevel(logging.DEBUG)

#reading all with the same extension files from a dir
def get_files_list(source_dir, f_pattern):
    i_counter = 0
    files_list = []
    for filepath in sorted(source_dir.glob(f_pattern)):
        i_counter += 1
        files_list.append(filepath)
    return files_list

# Rename columns 
def rename_cols(xafs_group):
    # energy
    engy = xafs_group.col1
    # mu
    mu_e = xafs_group.col2
    # get a dictionary from te group
    xafs_dict = group2dict(xafs_group)
    # add mu and energy to the dictionary
    xafs_dict['energy'] = engy
    xafs_dict['mu'] = mu_e
    xafs_group = dict2group(xafs_dict)
    return xafs_group

# show plot of normalised data
def plot_normalised(xafs_group):
        plt.plot(xafs_group.energy, xafs_group.pre_edge, 'g', label='pre-edge') # plot pre-edge in green
        plt.plot(xafs_group.energy, xafs_group.post_edge, 'r', label='post-edge')# plot post-edge in green
        plt.plot(xafs_group.energy, xafs_group.mu, 'b', label=xafs_group.filename) # plot mu in blue
        plt.grid(color='r', linestyle=':', linewidth=1) #show and format grid
        plt.xlabel('Energy (eV)') # label y graph
        plt.ylabel('x$\mu$(E)') # label y axis
        plt.title("pre-edge and post_edge fitting to $\mu$")
        plt.legend() # show legend
        plt.show()

# variables that can be changed to process different datasets
data_path = "..\\nexusdata\\rh4co_ox_53\\37123_Rh_4_CO_Oxidation_45_7_ascii\\"
file_pattern = "*.dat"
f_prefix = "rh4copy" #make names for results folder and files
top_count = 40
show_graph = True # False to prevent showing graphs

def main_function():
  # create the path for storing results
  base_path = Path("./" , f_prefix)
  Path(base_path).mkdir(parents=True, exist_ok=True)

  log_file = Path("./",base_path,"process.log")
  print(log_file)
  # set path for log
  set_logger(log_file)

  source_path = Path(data_path)
  files_list = get_files_list(source_path, file_pattern)
  xas_data = {}
  logging.info("Started processing")

  # counter for break
  i_count = 0
  for a_file in files_list:
      file_name = a_file.name
      
      logging.info ("Processing: " + file_name)
      logging.info ("Path: "+ str(a_file))
      f_suffix = str(i_count).zfill(6) 
      p_name = f_prefix+f_suffix
      logging.info ("project name: "+ p_name)
      p_path = Path(base_path , p_name + ".prj")
      logging.info ("project path: "+ str(p_path))
      xas_data = read_ascii(a_file)
      # using vars(fe_xas) we see that the object has the following properties: 
      # path, filename, header, data, attrs, energy, xmu, i0
      # print(vars(xas_data))

      # rename columns and group
      xas_data = rename_cols(xas_data)
      # the group is the same as the file name
      xas_data.filename = p_name
      
      # calculate pre-edge and post edge and add them to group
      # using defaults
      pre_edge(energy=xas_data.energy, mu=xas_data.mu , group=xas_data)
      # Show graph if needed
      if show_graph:
          plot_normalised(xas_data)
      
      xas_project = create_athena(p_path)
      xas_project.add_group(xas_data)
      xas_project.save()
      
      i_count +=1
      if i_count == top_count:
          break
         
  logging.info("Finished processing")

# To avoid running if the intention was only to import a function
if __name__ == '__main__':
  main_function()
