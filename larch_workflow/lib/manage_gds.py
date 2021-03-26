# set parameters 
# example Using Larch with python3
from larch import Interpreter
import larch_plugins as lp
# library containign functions that read and write to csv files
import lib.handle_csv as csvhandler
# regular expression matching
import re
# display editable spreadsheet
import ipysheet
# File handling

#start a larch session
session = Interpreter()

# read parameters from csv file
# each line contains a parameter defined as follows
##############################
# id,name,value,expr,vary
# 1,alpha,1e-07,,True
# 2,ss2,0.003,,True
# 3,ss3,0.003,ss2,False
# 4,ssfe,0.003,,True
##############################
def read_gds(gds_file):
    gds_pars, _ = csvhandler.read_csv_data(gds_file)
    dgs_group = dict_to_gds(gds_pars)
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
def dict_to_gds(data_dict):
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

# show gds parameters in a spreadsheet
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

# get data from spreadsheet and build a gds group
def spreadsheet_to_gds(a_sheet):
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
    gds_gp = dict_to_gds(data_dict)
    return gds_gp