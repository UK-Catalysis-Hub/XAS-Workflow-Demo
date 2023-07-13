import lib.manage_athena as athenamgr  

import numpy as np
from larch.xafs import xftf

#plotting library
import matplotlib.pyplot as plt

def get_groups(data_file, data_mappings):
    data_prj = athenamgr.read_project(data_file)
    data_groups = {}
    for a_mapping in data_mappings:
        data_groups[a_mapping] = athenamgr.calc_with_defaults(athenamgr.get_group(data_prj, data_mappings[a_mapping]))
        data_groups[a_mapping].filename =  a_mapping
    return data_groups

def forward_ft(a_group, ft_vals):
    # perform a forward XAFS Fourier transform, from chi(k) to chi(R), using common XAFS conventions.
    xftf(a_group.k, a_group.chi,
         kmin=ft_vals['kmin'], kmax=ft_vals['kmax'], window=ft_vals['window'], 
         kweight = ft_vals['kweight'], rmin=ft_vals['rmin'],
         rmax=ft_vals['rmax'],dk=ft_vals['dk'], 
         group=a_group)

# plot magnitude of chi(R)
def plot_chir_magnitude(athena_groups = {}, include_groups = [], 
                        offset = 0.5, aspect = (6,8), 
                        legend_x = 7140, xlim=[], kweight=1,
                        h_boxes = [], h_text = [],
                       ):
    # plot using the xas data for Fe    
    plt.figure(figsize=aspect)
    for g_indx ,a_group in enumerate(include_groups):
        # get index of energy value closer to where the label shoud be placed
        idx = np.abs(athena_groups[a_group].r - legend_x).argmin()
        plt.plot(athena_groups[a_group].r, athena_groups[a_group].chir_mag - (g_indx*offset),
                color=include_groups[a_group][0])
        plt.text(athena_groups[a_group].r[idx], 
                 athena_groups[a_group].chir_mag[idx] - (g_indx*offset), 
                 athena_groups[a_group].filename)
    plt.ylabel("$|\chi(R)| (\mathrm{\AA}^{-"+str(kweight+1)+"})$")
    plt.xlabel("$R(\mathrm{\AA})$")
    plt.xlim(xlim)
    frame1 = plt.gca()
    frame1.axes.yaxis.set_ticklabels([])
    
    for a_shape in h_boxes:
        plt.plot(a_shape[0],a_shape[1], color=a_shape[2],alpha=a_shape[3])
    for a_lbl in h_text:
        plt.text(a_lbl[0],a_lbl[1], a_lbl[2])   
    
    return plt

# using dashes for fit
def plot_dashed_fit(data_set,rmin,rmax,kmin,kmax, datalabel="data"):
    fig = plt.figure()#figsize=(10, 8))
    ax1 = fig.add_subplot(211)
    ax2 = fig.add_subplot(212)
    # Creating the chifit plot from scratch
    #from .xlarch.wxlibafsplots import plot_chifit
    #plot_chifit(dset, _larch=session)
    
    ax1.plot(data_set.data.k, data_set.data.chi*data_set.data.k**2, color= "black",  label=datalabel)
    
    ax1.plot(data_set.model.k, data_set.model.chi*data_set.data.k**2 , color='orange', linestyle='--',label='fit')
    ax1.set_xlim(kmin, kmax)
    ax1.set_ylim(-1, 2)
    ax1.set_xlabel("$k (\mathrm{\AA})^{-1}$")
    ax1.set_ylabel("$k^2$ $\chi (k)(\mathrm{\AA})^{-2}$")
    ax1.legend()
    
    ax2.plot(data_set.data.r, data_set.data.chir_mag, color= "black", label=datalabel)
 
    ax2.plot(data_set.model.r, data_set.model.chir_mag, linestyle='--', color='orange', label='fit')
    ax2.set_xlim(rmin,rmax)
    ax2.set_xlabel("$R(\mathrm{\AA})$")
    ax2.set_ylabel("$|\chi(R)|(\mathrm{\AA}^{-3})$")
    ax2.legend(loc='upper right')

    return plt
