# set parameters 
# example Using Larch with python3

import larch_plugins as lp
# library containign functions that read and write to csv files
import lib.handle_csv as csvhandler
# regular expression matching
import re
# display editable spreadsheet
import ipysheet
# File handling
from pathlib import Path
#library for writing to log
import logging

# plotting library
import matplotlib.pyplot as plt

# read parameters from csv file
# each line contains a parameter defined as follows
##############################
# id,name,value,expr,vary
# 1,alpha,1e-07,,True
# 2,ss2,0.003,,True
# 3,ss3,0.003,ss2,False
# 4,ssfe,0.003,,True
##############################
def read_gds(gds_file, session):
    gds_pars, _ = csvhandler.read_csv_data(gds_file)
    dgs_group = dict_to_gds(gds_pars, session)
    return dgs_group

# save parameters from csv file
# each line contains a parameter defined as follows
##############################
# id,name,value,expr,vary
# 1,alpha,1e-07,,True
# 2,ss2,0.003,,True
# 3,ss3,0.003,ss2,False
# 4,ssfe,0.003,,True
##############################
def save_gds(gds_group, gds_file):
    # convert gds group to dictionary
    gds_data = gds_to_dict(gds_group)
    csvhandler.write_csv_data(gds_data,gds_file)

# take gds group data and convert it to a dictionary
def gds_to_dict(gds_group):
    gds_params = gds_group.__params__
    gds_count = 1
    data_dict = {}
    for par in gds_params:
        data_dict[gds_count] = {'id': gds_count,
                               'name':par,
                               'value':gds_params[par].value,
                               'expr':gds_params[par].expr,
                               'vary':gds_params[par].vary
                              }
        gds_count += 1
    return data_dict

# take data from dictionary and create a gds group
def dict_to_gds(data_dict, session):
    dgs_group = lp.fitting.param_group(_larch=session)
    for par_idx in data_dict:
        #gds file structure:
        gds_name = data_dict[par_idx]['name']
        gds_val = 0.0
        gds_expr = ""
        try:
            gds_val = float(data_dict[par_idx]['value'])
        except ValueError:
            #print("Not a float value")
            gds_val = 0.00
        gds_expr = data_dict[par_idx]['expr']
        gds_vary = True if str(data_dict[par_idx]['vary']).strip().capitalize() =='True' else False
        one_par = None
        if gds_vary:
            # equivalent to a guess parameter in Demeter
            one_par = lp.fitting.guess(name=gds_name ,value=gds_val, vary=gds_vary, expr=gds_expr)
        else:
            # equivalent to a defined parameter in Demeter
            one_par = lp.fitting.param(name=gds_name ,value=gds_val, vary=gds_vary, expr=gds_expr)
        if one_par != None:
            dgs_group.__setattr__(gds_name,one_par)
    return dgs_group

# take gds group data and convert it to a list of lists
def gds_to_list(gds_group):
    gds_params = gds_group.__params__
    gds_count = 1
    data_list = [['id','name','value','expr','vary']]
    for par in gds_params:
        new_par = [gds_count, par, gds_params[par].value,
                   gds_params[par].expr, gds_params[par].vary]
        data_list.append(new_par)
        gds_count += 1
    return data_list

# show gds parameters in a spreadsheet on jupyter
def show_gds(gds_group):
    gds_list = gds_to_list(gds_group)
    #print(gds_list)
    #add 10 more rows in case we need more parameters
    for i in range(10):
        gds_list.append([(len(gds_list)-1)+1,None,None,None,None])
    a_sheet = ipysheet.sheet(rows=len(gds_list), columns=len(gds_list[0]))
    ipysheet.cell_range(gds_list)
    display(a_sheet)
    return a_sheet

# get data from spreadsheet and build a gds group on jupyter
def spreadsheet_to_gds(a_sheet, session):
    df_sheet = ipysheet.to_dataframe(a_sheet).transpose()
    data_dict = {}
    gds_count = 1
    for col in df_sheet:
        if df_sheet[col][0] != 'id':
            if (not df_sheet[col][1] in [None,""]) and (not df_sheet[col][2] in [None,""]) and (not df_sheet[col][4] in [None,""]):
                #print(df_sheet[col][0],df_sheet[col][1],df_sheet[col][2],df_sheet[col][3],df_sheet[col][4])
                data_dict[gds_count] = {'id': df_sheet[col][0],
                                       'name':df_sheet[col][1],
                                       'value':df_sheet[col][2],
                                       'expr':df_sheet[col][3],
                                       'vary':df_sheet[col][4]
                                      }
            gds_count+=1
    #print(data_dict)
    gds_gp = dict_to_gds(data_dict, session)
    return gds_gp


# show the paths stored in path files in the FEFF directory.
# These paths are stored by feff in the files.dat file
def show_feff_paths(var = "FeS2.inp"):
    crystal_f = Path(var)
    feff_dir = crystal_f.name[:-4]+"_feff"
    feff_inp = crystal_f.name[:-4]+"_feff.inp"
    feff_files = "files.dat"
    input_file = Path(feff_dir, feff_files)
    
    #check if feff dir exists
    if input_file.parent.exists() and input_file.exists():
        logging.info(str(input_file.parent) + " path and "+ str(input_file)+ " found")
    else:
        logging.info(str(input_file.parent) + " path not found, run feff before running select paths")
        return False
    count = 0
    # the .dat data is stored in fixed width strings 
    field_widths = [[0,13],[14,21],[22,31],[32,41],[42,48],[49,61]]
    is_meta = True
    data_headers = []
    path_count = 0
    paths_data = []
    # get the list of paths info to assing labels to paths
    paths_info = get_path_labels(Path(feff_dir, 'paths.dat'))
    logging.info("Reading from: "+ str(input_file))
    with open(input_file) as datfile:
        dat_lines = datfile.readlines()
        for a_line in dat_lines:
            count += 1
            if re.match('-*', a_line.strip()).group(0)!= '':
                is_meta = False
                logging.info("{}: {}".format(count, a_line.strip()))
            elif is_meta:
                logging.info("{}: {}".format(count, a_line.strip()))
            elif data_headers == []:
                data_headers = [a_line[s:e].strip().replace(' ','_') for s,e in field_widths]
                logging.info("headers:"+ str(data_headers))
                data_headers.append('label')
                data_headers.append('select')
                paths_data.append(data_headers)
            else:
                path_count += 1
                data_values = [a_line[s:e].strip() for s,e in field_widths]
                path_id = str(int(data_values[0][-8:-4]))
                data_values.append(paths_info[path_id]['label']+'.'+path_id)                    
                data_values.append(0)
                data_values[0] = feff_dir+"/"+data_values[0]
                paths_data.append(data_values)
    # use data to populate spreadsheet
    
    path_sheet = ipysheet.sheet(rows=path_count+1, columns=8)
    ipysheet.cell_range(paths_data)
    return path_sheet

# get labels from the feff/paths.dat file
def get_path_labels(paths_file):
    is_meta = True
    count = 0
    a_path = {}
    all_paths={}           
    with open(paths_file) as datfile:
        dat_lines = datfile.readlines()
        for a_line in dat_lines:
            count += 1
            if re.match('-{15}', a_line.strip())!= None:
                is_meta = False
                #print("{}: {}".format(count, a_line.strip()))
            elif not is_meta:
                if re.match("\s*\d*\s{4}\d*\s{3}", a_line) != None:
                    if a_path != {}:
                        all_paths[a_path['index']] = a_path
                    line_data = a_line.split()
                    a_path ={'index':line_data[0],'nleg':line_data[1],'degeneracy':line_data[2]}
                elif re.match("\s{6}x\s{11}y\s{5}", a_line) == None: # ignore the intermediate headings
                    line_data = a_line.split()
                    if not 'label' in a_path:
                        a_path['label'] = line_data[4].replace("'","")
                    else:
                        a_path['label'] += '.'+line_data[4].replace("'","")
                #print(a_line.split())
    if a_path != {} and 'index' in a_path:
        all_paths[a_path['index']] = a_path
    return all_paths



def show_selected_paths(pats_sheet):
    df_sheet = ipysheet.to_dataframe(pats_sheet)
    files = []
    for f_name, p_label, selected in zip(df_sheet["A"], df_sheet["G"], df_sheet["H"]):
        if selected == '1':
            files.append([f_name, p_label])   
    new_row_count = len(files)
    sel_paths_data = [['' for col in range(6)] for row in range(new_row_count)]
    sel_paths_data[:0]=[['file','label','s02','e0','sigma2','deltar']]
    ps_row = 1
    for a_name in files:
        sel_paths_data[ps_row][0] = a_name[0]
        sel_paths_data[ps_row][1] = a_name[1]
        ps_row += 1
    sp_sheet = ipysheet.sheet(rows=len(files)+1, columns=6)
    ipysheet.cell_range(sel_paths_data)
    display(sp_sheet)
    return sp_sheet

# use data frame to create selected paths list
def build_selected_paths_list(sp_sheet, session):
    df_sheet = ipysheet.to_dataframe(sp_sheet).transpose()
    sp_list = []
    for col in df_sheet:
        if df_sheet[col][0] != 'file':
            new_path = lp.xafs.FeffPathGroup(filename = df_sheet[col][0],
                                             label    = df_sheet[col][1],
                                             s02      = df_sheet[col][2],
                                             e0       = df_sheet[col][3],
                                             sigma2   = df_sheet[col][4],
                                             deltar   = df_sheet[col][5],
                                             _larch   = session)
            sp_list.append(new_path)
    return sp_list

#save the selected paths list to a csv file (using the prefix of crystal)
def save_selected_paths_list(sp_sheet, file_name):
    # it is easier to transpose as dataframes main objects are columns
    df_sheet = ipysheet.to_dataframe(sp_sheet).transpose()
    sp_list = {}
    path_count = 1
    for col in df_sheet:
        if df_sheet[col][0] != 'file':
            sp_list[path_count] = {'id': path_count,
                                   'filename':df_sheet[col][0],
                                   'label':df_sheet[col][1],
                                   's02':df_sheet[col][2],
                                   'e0':df_sheet[col][3],
                                   'sigma2':df_sheet[col][4],
                                   'deltar':df_sheet[col][5]}
            path_count += 1
    csvhandler.write_csv_data(sp_list,file_name)

# read selected paths from file
def read_selected_paths_list(file_name, session):
    sp_dict, _ = csvhandler.read_csv_data(file_name)
    sp_list=[]
    for path_id in sp_dict:
        new_path = lp.xafs.FeffPathGroup(filename = sp_dict[path_id]['filename'],
                                         label    = sp_dict[path_id]['label'],
                                         s02      = sp_dict[path_id]['s02'],
                                         e0       = sp_dict[path_id]['e0'],
                                         sigma2   = sp_dict[path_id]['sigma2'],
                                         deltar   = sp_dict[path_id]['deltar'],
                                         _larch   = session)
        sp_list.append(new_path)
    return sp_list

# run fit
# data_group: the data group extracted from the athena file
# gds: list of defined parameters defined
# selected_paths: paths selected for the fit
# fv: dictionary with the fit varialbes
# session: current larch session
def run_fit(data_group, gds, selected_paths, fv, session):
    # create the transform grup (prepare the fit space).
    trans = lp.xafs.TransformGroup(fitspace=fv['fitspace'],kmin=fv['kmin'],
                                   kmax=fv['kmax'],kw=fv['kw'], dk=fv['dk'], 
                                   window=fv['window'], rmin=fv['rmin'],
                                   rmax=fv['rmax'], _larch=session)

    dset = lp.xafs.FeffitDataSet(data=data_group, pathlist=selected_paths, transform=trans, _larch=session)

    out = lp.xafs.feffit(gds, dset, _larch=session)
    return trans, dset, out

#Overlap plot k-weighted χ(k) and χ(R) for fit to feffit dataset

def plot_rmr(data_set,rmin,rmax):
    fig = plt.figure()
    plt.plot(data_set.data.r, data_set.data.chir_mag, color='b')
    plt.plot(data_set.data.r, data_set.data.chir_re, color='b', label='expt.')
    plt.plot(data_set.model.r, data_set.model.chir_mag, color='r')
    plt.plot(data_set.model.r, data_set.model.chir_re, color='r', label='fit')
    plt.ylabel("Magnitude of Fourier Transform of $k^2 \cdot \chi$/$\mathrm{\AA}^{-3}$")
    plt.xlabel("Radial distance/$\mathrm{\AA}$")
    plt.xlim(0, 5)

    plt.fill([rmin, rmin, rmax, rmax],[-rmax, rmax, rmax, -rmax], color='g',alpha=0.1)
    plt.text(rmax-0.65, -rmax+0.5, 'fit range')
    plt.legend()
    return plt

def plot_chikr(data_set,rmin,rmax,kmin,kmax):
    fig = plt.figure(figsize=(16, 4))
    ax1 = fig.add_subplot(121)
    ax2 = fig.add_subplot(122)
    # Creating the chifit plot from scratch
    #from .xlarch.wxlibafsplots import plot_chifit
    #plot_chifit(dset, _larch=session)
    ax1.plot(data_set.data.k, data_set.data.chi*data_set.data.k**2, color='b', label='expt.')
    ax1.plot(data_set.model.k, data_set.model.chi*data_set.data.k**2 , color='r', label='fit')
    ax1.set_xlim(0, 15)
    ax1.set_xlabel("$k (\mathrm{\AA})^{-1}$")
    ax1.set_ylabel("$k^2$ $\chi (k)(\mathrm{\AA})^{-2}$")
    
    ax1.fill([kmin, kmin, kmax, kmax],[-rmax, rmax, rmax, -rmax], color='g',alpha=0.1)
    ax1.text(kmax-1.65, -rmax+0.5, 'fit range')
    ax1.legend()

    ax2.plot(data_set.data.r, data_set.data.chir_mag, color='b', label='expt.')
    ax2.plot(data_set.model.r, data_set.model.chir_mag, color='r', label='fit')
    ax2.set_xlim(0, 5)
    ax2.set_xlabel("$R(\mathrm{\AA})$")
    ax2.set_ylabel("$|\chi(R)|(\mathrm{\AA}^{-3})$")
    ax2.legend(loc='upper right')
    
    ax2.fill([rmin, rmin, rmax, rmax],[-rmax, rmax, rmax, -rmax], color='g',alpha=0.1)
    ax2.text(rmax-0.65, -rmax+0.5, 'fit range')
    return plt



def get_fit_report(fit_out, session):
    return lp.xafs.feffit_report(fit_out, _larch=session)

def save_fit_report(fit_out, file_name, session):
    fit_report = lp.xafs.feffit_report(fit_out, _larch=session)
    f = open(file_name, "a")
    f.write(fit_report)
    f.close()
    
