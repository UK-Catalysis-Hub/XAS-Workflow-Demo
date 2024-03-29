# Library with the functions that rplicate those provided by athena
# normalisation, merging, re-binning, LCF
# and visualisation (plotting)# Library with the functions that rplicate those provided by athena
# normalisation, merging, re-binning, LCF
# and visualisation (plotting)
import lib.manage_athena as athenamgr  

# File handling
from pathlib import Path

#plotting library
import matplotlib.pyplot as plt
# inline: shows plot in notebook
# tk: shows plot in popup


# import custom plot functions (replicate plots in paper)
import paper01_plots as c_plots


#######################################################

# calculate pre-edge and post edge for normalisation
from larch.xafs import pre_edge

# math library contants the lcf function 
from larch import math

# numpy
import numpy as np

def local_lcf_group(a_group, fit_components=[], fit_limits=[-np.inf, np.inf], 
              diff_e0 = False, fit_space = 'norm'):
    if fit_components == []:
        print ("need a list of component groups to fit")
    
    #lcfr = math.lincombo_fit(a_group, lcf_components)#, vary_e0=diff_e0)
    lcfr = math.lincombo_fit(a_group, fit_components, 
                             xmin=fit_limits[0],xmax=fit_limits[1], 
                             vary_e0 = diff_e0, weights=[0.5,0.5], arrayname=fit_space)
    #lcfr = math.lincombo_fit(a_group, fit_components, 
    #                         weights=[0.5,0.5], arrayname=fit_space,
    #                         xmin=fit_limits[0],xmax=fit_limits[1], 
    #                         vary_e0 = diff_e0)
    names_lbl = ""
    lcfr.energy = lcfr.xdata
    lcfr.mu = lcfr.ydata
    lcfr.norm = lcfr.ydata
    #lcfr = fit_pre_post_edge(lcfr)
    
    names_lbl = ""
    array_label = ""
    for a_w in lcfr.weights:
        names_lbl += a_w + " " 
        array_label += a_w + ": " + '%.2f' % (lcfr.weights[a_w]*100.0) + "% "
    lcfr.filename = names_lbl
    
    lcfr.arrayname = array_label
    
    return lcfr

def fit_pre_post_edge(xas_data, pre_lower=-150, pre_upper=-60):
    pre_edge(energy = xas_data.energy,
             mu = xas_data.mu ,
             group = xas_data,
             pre1 = pre_lower,
             pre2 = pre_upper)
    return xas_data

def shift_energy(a_group, shift_delta):
    a_group.energy = a_group.energy[:] + (shift_delta)
    return a_group

def diff_ranges(r_list):
    min_diff = max_diff = avg_diff = 0
    for d_i, d_val in enumerate(r_list):
        
        if d_i + 1 < len(r_list):
            tmp_diff = r_list[d_i+1] - d_val
            avg_diff += tmp_diff
            if min_diff == 0 or tmp_diff < min_diff:
                min_diff = tmp_e_diff
            if max_diff == 0 or tmp_diff > max_diff:
                max_diff = tmp_diff
                
    avg_diff = avg_diff/len(r_list)
    return min_diff, max_diff, avg_diff


def retrieve_data(data_mappings,column_labels,source_path):
    merged_results={}
    # read all samples, merge and then normalise
    for a_sample in data_mappings:
        files_list = athenamgr.get_files_list(source_path, data_mappings[a_sample])

        # read the files for each sample
        sample_list = []
        for i_count, a_file  in enumerate(files_list):
            file_name = a_file.name
            f_suffix = str(i_count).zfill(4) 
            p_name = f_prefix+f_suffix
            p_path = Path(out_path , p_name + ".prj")
            a_group = athenamgr.read_text(a_file, column_labels)
            sample_list.append(a_group)
            
        # merge readings for sample
        merged_xas = athenamgr.merge_readings(sample_list)

        # rename group (same as the file name)
        merged_xas.filename = a_sample
        merged_results[a_sample] = merged_xas
        # calculate pre-edge and post edge and add them to group
        # using defaults
        xas_data = athenamgr.fit_pre_post_edge(merged_xas)
    return merged_results

def plot_normal_and_deriv(include_results,merged_results,norm_lim, deriv_lim):
    for a_sample in merged_results:
        if merged_results[a_sample].filename in include_groups:
            plt = athenamgr.plot_normalised(merged_results[a_sample])
        
    plt.xlim(norm_lim)
    plt.show()

    for a_sample in merged_results:
        if merged_results[a_sample].filename in include_groups:
            plt = athenamgr.plot_derivative(merged_results[a_sample])
        
    plt.xlim(deriv_lim)
    plt.show()

def compare_groups(group_1, group_2, g1_label, g2_label, sample_name):
    print ("Comparing", sample_name) 
    print ("Energy")
    print ("%s \tlen %i\tmin %.6f\tmax %.6f\tE0 %.6f"% (g1_label, len(group_1.energy), min(group_1.energy), max(group_1.energy), group_1.e0))
    print ("%s \tlen %i\tmin %.6f\tmax %.6f\tE0 %.6f"% (g2_label, len(group_2.energy), min(group_2.energy), max(group_2.energy), group_2.e0))  
    print ("Diff\tlen %i\tmin %.6f\tmax %.6f\tE0 %.6f"% (len (group_2.energy)-len(group_1.energy), 
            min(group_2.energy)-min(group_1.energy), max(group_2.energy)-max(group_1.energy), group_2.e0 - group_1.e0))
    
    #min_e_diff, max_e_diff, avg_e_diff = diff_ranges (sd_group.energy)
    #print ("\tE diff \tavg", avg_e_diff, "\tmin", min_e_diff, "\tmax", max_e_diff)

    idx_e01 = np.where(np.isclose(group_1.energy, group_1.e0))[0][0]
    idx_e02 = np.where(np.isclose(group_1.energy, group_1.e0))[0][0]    
    #min_e_diff, max_e_diff, avg_e_diff = diff_ranges (re_group.energy)
    #print ("\tE diff \tavg", avg_e_diff, "\tmin", min_e_diff, "\tmax", max_e_diff)
    print ("Mu")
    print ("%s \tlen %i\tmin %.9f\tmax %.9f\tMu@e0 %.9f"%(g1_label, len(group_1.mu), min(group_1.mu), max(group_1.mu), group_1.mu[idx_e01]))
    print ("%s \tlen %i\tmin %.9f\tmax %.9f\tMu@e0 %.9f"%(g2_label, len(group_2.mu), min(group_2.mu), max(group_2.mu), group_2.mu[idx_e02]))


# lcf_components List of groups to use as components
# fit_limits list of lower and upper fitting limits relative to e0
# fit_groups dictionary of groups to use as signals for LCF (first should have e0) 

def lcf_compare(lcf_components = [], fit_limits = [], fit_groups = {}, vary_e0 = True):
    results = {}
    min_lim = fit_limits[0]
    max_lim = fit_limits[1]
    if lcf_components == []:
        print("need to provide list of componets")
        return results
    if fit_groups == {}:
        print("need to dictionary of fit_groups")
        return results


    for a_group_id in fit_groups:
        results[a_group_id] = local_lcf_group(fit_groups[a_group_id], lcf_components, fit_limits=[min_lim, max_lim], diff_e0 = vary_e0)

    return results



#########################################################

# variables that can be changed to process different datasets
data_path = "./wf_data/pub_037/XAFS_prj/Sn K-edge/ascii"

data_mappings={"PtSn":  "*_PtSn_OC_A*",
               "H2":  "*_PtSn_OCH_A*",
               "Ar":  "*_PtSn_OCA_A*",
               "Air":  "*_PtSn_OCO_A*",
               "PtSn H":  "*_PtSn_OC_H*", 
               "H2 H":  "*_PtSn_OCH_H*",
               "Ar H":  "*_PtSn_OCA_H*",
               "Air H":  "*_PtSn_OCO_H*",
              }

f_prefix = "PtSn_KEdge"
column_labels = "energy time I0 It Iref  mu lnItIref"

# start processing createa an output dir and sets the logger
source_path, out_path = athenamgr.files_setup(f_prefix, data_path)
print("Source:", source_path, "Output:", out_path)


merged_results=retrieve_data(data_mappings, column_labels, source_path)

# results in the paper are recalibrated to 29204
recalibrate_e0_to = 29204

#for a_sample in merged_results:
#    merged_results[a_sample] = athenamgr.recalibrate_energy(merged_results[a_sample], recalibrate_e0_to)

# save merge to athena project in output dir    
merge_project = Path(out_path,f_prefix+"_merge.prj")

athenamgr.save_groups(merged_results.values(), merge_project)

athena_projects = { 
    'PtSn': {
        'file_name': 'PtSn_OC.prj',  
        'groups':['PtSn_OC_MERGE_CALIBRATE', 'PtSn_OC_MERGE_CALIBRATE_rebinned',]},
    'H2': {
        'file_name':  'PtSn_OCH.prj', 'groups':['PtSn_OCH', 'PtSn_OCH_rebinned',]},
    'Ar': {
        'file_name': 'PtSn_OCA.prj',
        'groups': ['PtSn_OCA', 'PtSn_OCA_rebinned',]},
    'Air': {
        'file_name':  'PtSn_OCO.prj', 'groups':['PtSn_OCO', 'PtSn_OCO_rebinned', ]},
    'PtSn H': {
        'file_name':  'PtSn_OC_H2.prj', 'groups':['PtSn_OC', 'PtSn_OC_rebinned', ]},
    'H2 H': {
        'file_name':  'PtSn_OCH_H2.prj', 'groups': ['PtSn_OCH', 'PtSn_OCH_DEGLITCHED', 'PtSn_OCH_rebinned']},
    'Ar H': {
        'file_name':  'PtSn_OCA_H2.prj', 
        'groups':['PtSn_OCA', 'PtSn_OCA_rebinned',]},
    'Air H': {
        'file_name':  'PtSn_OCO_H2.prj', 'groups':['PtSn_OCO', 'PtSn_OCO_rebinned',]}, 
        }

athena_path = Path('./wf_data/pub_037/XAFS_prj/Sn K-edge')
    
#for x in Path('./wf_data/pub_037/XAFS_prj/Sn K-edge').glob('*'):
#    print (x)

print("*"*80)
print("Compare Energy and Mu from Athena and Larch projects lenghts, e0, min/max ")
print("*"*80)
   
for a_project in athena_projects:
    athena_file = Path(athena_path, athena_projects[a_project]['file_name'])
    source_prj = athenamgr.read_project(athena_file)
    #print(dir(source_prj))
    sd_group = source_prj[athena_projects[a_project]['groups'][0]]
    sd_group.e0 = sd_group.athena_params.bkg.e0
    re_group = merged_results[a_project]
    compare_groups(sd_group, re_group, "Athena", "Larch", a_project)

# get the Sn foil standard from project:
# project is made up of the references from the individual samples

sn_foil = "./wf_data/pub_037/XAFS_prj/Sn foil.prj"
# read the input file 
sn_foil_prj = athenamgr.read_project(sn_foil)

sn_foil_group = athenamgr.get_group(sn_foil_prj, 'merge')
sn_foil_group.filename = "Sn Foil"
#sn_foil_group = athenamgr.recalibrate_energy(sn_foil_group, recalibrate_e0_to)
merged_results["Sn Foil"] = sn_foil_group

# get the Sn O2 standard from project:
sno2 = "./wf_data/pub_037/XAFS_prj/SnO2 0.9 2.6-13.5 gbkg.prj"
# read the input file 
sno2_prj = athenamgr.read_project(sno2)

sno2_group = athenamgr.get_group(sno2_prj, "SnO2_0_9_2_6_13_5_0_8_1_0_with_theory")#'SnO2_0_9')
sno2_group.filename = "SnO2"
sno2_group = athenamgr.recalibrate_energy(sno2_group, recalibrate_e0_to)
merged_results["SnO2"] = sno2_group


include_groups = ["Air", "Ar", "H2", "Sn Foil", "SnO2"]

plot_normal_and_deriv(include_groups,merged_results,[29180, 29400], [29190, 29210])


lcf_components = [merged_results["Sn Foil"],merged_results["SnO2"]] # List of groups to use as components 

lower_limit = -20
upper_limit = 20

min_lim = recalibrate_e0_to + lower_limit
max_lim = recalibrate_e0_to + upper_limit

fit_groups ={"H2": merged_results["H2"], "Ar": merged_results["Ar"], "Air": merged_results["Air"]} 

lcf_fit_rs = lcf_compare(lcf_components, [min_lim, max_lim], fit_groups)

c_plots.compare_lcf_plot([merged_results["H2"],lcf_fit_rs['H2']], 
                         [merged_results["Ar"],lcf_fit_rs['Ar']], 
                         [merged_results["Air"],lcf_fit_rs['Air']], 
                         x_limits=[min_lim, max_lim])

plt.show()

print("*"*80)
print(" "*20, "results using non calibrated/energy shifted data")
print("*"*80)
print('H2', lcf_fit_rs['H2'].arrayname)
print('Ar', lcf_fit_rs['Ar'].arrayname)
print('Air', lcf_fit_rs['Air'].arrayname)

print("*"*80)
print(" "*20, "Results from energy shift groups")
print("*"*80)

# test shift
shift_list = ["Air", "Ar", "H2","PtSn H"]
for a_group in merged_results:
    if a_group in shift_list:
        delta_shift = 15.360
        print ("Shift ", a_group, "energy to ", delta_shift)
        shift_energy(merged_results[a_group], delta_shift)
   
include_groups = ["Air", "Ar", "H2", "Sn Foil", "SnO2"]

plot_normal_and_deriv(include_groups,merged_results,[29180, 29400], [29190, 29210])

lcf_components = [merged_results["Sn Foil"],merged_results["SnO2"]] # List of groups to use as components 

lower_limit = -20
upper_limit = 20

min_lim = recalibrate_e0_to + lower_limit
max_lim = recalibrate_e0_to + upper_limit

lcf_fit_rs = lcf_compare(lcf_components, [min_lim, max_lim], fit_groups)

c_plots.compare_lcf_plot([merged_results["H2"],lcf_fit_rs['H2']], 
                         [merged_results["Ar"],lcf_fit_rs['Ar']], 
                         [merged_results["Air"],lcf_fit_rs['Air']], 
                         x_limits=[min_lim, max_lim])

plt.show()



print('H2', lcf_fit_rs['H2'].arrayname)
print('Ar', lcf_fit_rs['Ar'].arrayname)
print('Air', lcf_fit_rs['Air'].arrayname)

lcf_components = [merged_results["PtSn H"],merged_results["SnO2"]] # List of groups to use as components 

lcf_fit_rs = lcf_compare(lcf_components, [min_lim, max_lim], fit_groups, False)

c_plots.compare_lcf_plot([merged_results["H2"],lcf_fit_rs['H2']], 
                         [merged_results["Ar"],lcf_fit_rs['Ar']], 
                         [merged_results["Air"],lcf_fit_rs['Air']], 
                         x_limits=[min_lim, max_lim])

plt.show()



print('H2', lcf_fit_rs['H2'].arrayname)
print('Ar', lcf_fit_rs['Ar'].arrayname)
print('Air', lcf_fit_rs['Air'].arrayname)



# Rebin Ar, Air and H2 Samples 
print("*"*80)
print("Results from rebinned groups")

rebin_labels = ["H2", "Ar", "Air","PtSn H"]
rebinned_groups = {}
rebinned_gr=None
for a_sample in merged_results:
    if a_sample in rebin_labels:
        rebinned_gr = athenamgr.rebin_group(merged_results[a_sample])
        rebinned_gr.arrayname = a_sample+" Rebbined"
        rebinned_groups[a_sample+" Rebbined"] = rebinned_gr
        print(a_sample, "rebinned to" , len(rebinned_gr.energy),"from", len(merged_results["Ar"].energy))


plot_normal_and_deriv(include_groups,merged_results,[29180, 29400], [29190, 29210])

lcf_components = [merged_results["Sn Foil"],merged_results["SnO2"]] # List of groups to use as components 

fit_groups ={"H2": rebinned_groups["H2 Rebbined"], "Ar":rebinned_groups["Ar Rebbined"], "Air": rebinned_groups["Air Rebbined"]}

lcf_fit_rs = lcf_compare(lcf_components, [min_lim, max_lim], fit_groups, False)

c_plots.compare_lcf_plot([fit_groups["H2"],lcf_fit_rs['H2']], 
                         [fit_groups["Ar"],lcf_fit_rs['Ar']], 
                         [fit_groups["Air"],lcf_fit_rs['Air']], 
                         x_limits=[min_lim, max_lim])

plt.show()

print('H2', lcf_fit_rs['H2'].arrayname)
print('Ar', lcf_fit_rs['Ar'].arrayname)
print('Air', lcf_fit_rs['Air'].arrayname)


lcf_components = [rebinned_groups["PtSn H Rebbined"],merged_results["SnO2"]] # List of groups to use as components 

fit_groups ={"H2": rebinned_groups["H2 Rebbined"], "Ar":rebinned_groups["Ar Rebbined"], "Air": rebinned_groups["Air Rebbined"]}
lcf_fit_rs = lcf_compare(lcf_components, [min_lim, max_lim], fit_groups, True)

c_plots.compare_lcf_plot([fit_groups["H2"],lcf_fit_rs['H2']], 
                         [fit_groups["Ar"],lcf_fit_rs['Ar']], 
                         [fit_groups["Air"],lcf_fit_rs['Air']], 
                         x_limits=[min_lim, max_lim])

plt.show()

print('H2', lcf_fit_rs['H2'].arrayname)
print('Ar', lcf_fit_rs['Ar'].arrayname)
print('Air', lcf_fit_rs['Air'].arrayname)

# set e0 for all data used:
print("*"*80)
print("Results from resetting e0")

set_e0_to = 29204

for a_group in merged_results:
    print("%s changed E0 from %.4f to %.4f" %(a_group, merged_results[a_group].e0, set_e0_to))
    merged_results[a_group].e0 = set_e0_to


lcf_components = [merged_results["Sn Foil"],merged_results["SnO2"]] # List of groups to use as components 


fit_groups ={"H2": merged_results["H2"], "Ar": merged_results["Ar"], "Air": merged_results["Air"]} 
lcf_fit_rs = lcf_compare(lcf_components, [min_lim, max_lim], fit_groups, False)

c_plots.compare_lcf_plot([fit_groups["H2"],lcf_fit_rs['H2']], 
                         [fit_groups["Ar"],lcf_fit_rs['Ar']], 
                         [fit_groups["Air"],lcf_fit_rs['Air']], 
                         x_limits=[min_lim, max_lim])

plt.show()

print('H2', lcf_fit_rs['H2'].arrayname)
print('Ar', lcf_fit_rs['Ar'].arrayname)
print('Air', lcf_fit_rs['Air'].arrayname)

lcf_components = [merged_results["PtSn H"],merged_results["SnO2"]] # List of groups to use as components 


fit_groups ={"H2": merged_results["H2"], "Ar": merged_results["Ar"], "Air": merged_results["Air"]} 
lcf_fit_rs = lcf_compare(lcf_components, [min_lim, max_lim], fit_groups, False)

c_plots.compare_lcf_plot([fit_groups["H2"],lcf_fit_rs['H2']], 
                         [fit_groups["Ar"],lcf_fit_rs['Ar']], 
                         [fit_groups["Air"],lcf_fit_rs['Air']], 
                         x_limits=[min_lim, max_lim])

plt.show()

print('H2', lcf_fit_rs['H2'].arrayname)
print('Ar', lcf_fit_rs['Ar'].arrayname)
print('Air', lcf_fit_rs['Air'].arrayname)

