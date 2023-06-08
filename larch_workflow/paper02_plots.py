#plotting library
import matplotlib.pyplot as plt

from scipy import sparse
from scipy.sparse.linalg import spsolve

import numpy as np

'''
 # Whittaker filter / smoothing adapted from several sources based on:
 "A perfect smoother"
 Paul H. C. Eilers 
 Anal. Chem. 2003, 75, 3631-3636
 DOI: https://doi.org/10.1021/ac034173t
 # Whittaker paper 
 "On a new method of gradutation"
 E. T. Whittaker
 Proceedings of the Edinburgh Mathematical Society 1922, 41, 63-75
 DOI: https://doi.org/10.1017/S0013091500077853
 # open more than one datat set under windows: 
 open powershell: baseline.py (Get-ChildItem *.txt -Name)
'''

#Whittaker filter (smoothing)
def whittaker(y,lmd = 2, d = 2):
    #lmd: smoothing parameter lambda,
    #the suggested value of lambda = 1600 seems way to much for Raman spectra
    #d: order of differences in penalty (2)
    L = len(y)
    E = sparse.csc_matrix(np.diff(np.eye(L), d))
    W = sparse.spdiags(np.ones(L), 0, L, L)
    Z = W + lmd * E.dot(E.transpose())
    z = spsolve(Z, np.ones(L)*y)
    return z

# plot magnitude of chi(R)
def plot_chir_magnitude(athena_groups = {}, include_groups = [], offset = 0.5, aspect = (6,8), legend_x = 7140, xlim=[]):

    # plot using the xas data for Fe    
    plt.figure(figsize=(6, 8))
    offset = 3.0
    include_groups = ["Fe Metal", "A", "B", "C", "D"]
    for g_indx ,a_group in enumerate(athena_groups):
        if a_group.filename in include_groups:
            # get index of energy value closer to where the label shoud be placed
            idx = np.abs(a_group.r - legend_x).argmin()
            plt.plot(a_group.r, a_group.chir_mag - (g_indx*offset) )
            plt.text(a_group.r[idx], a_group.chir_mag[idx] - (g_indx*offset)+1.0, a_group.filename)
    plt.ylabel("$|\chi(R)| (\mathrm{\AA}^{-3})$")
    plt.xlabel("$R(\mathrm{\AA})$")
    plt.xlim(xlim)
    frame1 = plt.gca()
    frame1.axes.yaxis.set_ticklabels([])
    return plt


# plot normalised spectrum
def plot_normailised(athena_groups = {}, include_groups = [], aspect = (6,8), xlim=[],ylim=[]):
    plt.figure(figsize=aspect)
    for g_indx ,a_group in enumerate(athena_groups):
        if a_group.filename in include_groups:
            plt.plot(a_group.energy, a_group.norm, label=a_group.filename ) 

    frame1 = plt.gca()
    #frame1.axes.yaxis.set_ticklabels([])
    #frame1.axes.yaxis.set_ticklabels([])
    plt.ylabel("Normalized XANES (a.u.)")
    plt.xlabel("Energy (eV)")
    plt.xlim(xlim)
    plt.ylim(ylim)
    plt.legend()
    plt.show()

    return plt

# plot normalised spectrum with an offset
def plot_normailised_offset(athena_groups = {}, include_groups = [], offset = 0.5, aspect = (6,8), legend_x = 7140, xlim=[]):
    plt.figure(figsize=aspect)
    idx = np.abs(athena_groups[1].energy - legend_x).argmin()

    include_groups = ["Fe Metal", "A", "B", "C", "D", "FeBr"]

    for g_indx ,a_group in enumerate(athena_groups):
        if a_group.filename in include_groups:
            # get index of energy value closer to where the label shoud be placed
            idx = np.abs(a_group.energy - legend_x).argmin()
            plt.text(a_group.energy[idx], a_group.norm[idx] - (g_indx*offset)+.1, a_group.filename)
            plt.plot(a_group.energy, a_group.norm - (g_indx*offset) )

    frame1 = plt.gca()
    frame1.axes.yaxis.set_ticklabels([])
    plt.ylabel("Normalized XANES (a.u.)")
    plt.xlabel("Energy (eV)")
    plt.xlim(xlim)

    return plt

# plot first derivative wiht an offset
def plot_norm_deriv_offset(athena_groups = {}, include_groups = [], offset = 0.5, aspect = (6,8), legend_x = 7125, xlim=[]):
    plt.figure(figsize=aspect)
    for g_indx ,a_group in enumerate(athena_groups):
        if a_group.filename in include_groups:
            # get index of energy value closer to where the label shoud be placed
            idx = np.abs(a_group.energy - legend_x).argmin()
            plt.text(a_group.energy[idx], a_group.dmude[idx]-(g_indx*offset)+0.1, a_group.filename)
            plt.plot(a_group.energy, a_group.dmude - (g_indx*offset), label=a_group.filename ) 

    frame1 = plt.gca()
    frame1.axes.yaxis.set_ticklabels([])

    plt.xlim(xlim)
    return plt