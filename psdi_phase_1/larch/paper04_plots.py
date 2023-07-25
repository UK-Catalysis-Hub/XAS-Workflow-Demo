#plotting library
import matplotlib.pyplot as plt

#larch libraries for preprocessing
from larch.xafs import pre_edge
from larch.xafs import autobk
from larch.xafs import xftf

#plot chi magnitude (FT)  
def plot_chi_magnitude(athena_groups = {}, include_groups = {}, 
                       aspect = [], xlim=[],ylim=[], 
                       shading = [], plt_lbls=[]):
    if aspect!=[]:
        plt.figure(figsize=aspect)
    for g_indx, a_group in enumerate(include_groups):
        if athena_groups[a_group].filename in include_groups:
                plt.plot(athena_groups[a_group].r, 
                         athena_groups[a_group].chir_mag, 
                         label=athena_groups[a_group].filename,
                         color = include_groups[a_group][0],
                         linestyle = include_groups[a_group][1]
                        ) 

    frame1 = plt.gca()
    plt.xlabel("$R(\mathrm{\AA})$")
    plt.ylabel("$|\chi(R)|(\mathrm{\AA}^{-4})$")
    if xlim!=[]:
        plt.xlim(xlim)
    if ylim!=[]:
        plt.ylim(ylim)
    plt.legend()
    
    for a_shape in shading:
        plt.fill(a_shape[0],a_shape[1], color=a_shape[2],alpha=a_shape[3])
    for a_lbl in plt_lbls:
        plt.text(a_lbl[0],a_lbl[1], a_lbl[2])   
    return plt
    
def forward_ft(a_group, ft_vals):
    # Pre-edge subtraction and normalization. 
    pre_edge(a_group)
    # Determine the post-edge background function mu0(E) and corresponding chi(k).
    autobk(a_group)
    # perform a forward XAFS Fourier transform, from chi(k) to chi(R), using common XAFS conventions.
    xftf(a_group.k, a_group.chi,
         kmin=ft_vals['kmin'], kmax=ft_vals['kmax'], window=ft_vals['window'], 
         kweight = ft_vals['kweight'], rmin=ft_vals['rmin'],
         rmax=ft_vals['rmax'],dk=ft_vals['dk'], 
         group=a_group)