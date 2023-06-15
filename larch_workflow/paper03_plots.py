#plotting library
import matplotlib.pyplot as plt

# plot normalised spectrum wir custom colors and line styles
def plot_normalised(athena_groups = {}, include_groups = {}, aspect = (6,8), xlim=[],ylim=[]):
    plt.figure(figsize=aspect)
    for g_indx, a_group in enumerate(include_groups):
        if athena_groups[a_group].filename in include_groups:
                plt.plot(athena_groups[a_group].energy, 
                         athena_groups[a_group].norm, 
                         label=athena_groups[a_group].filename,
                         color = include_groups[a_group][0],
                         linestyle = include_groups[a_group][1]
                        ) 

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


# individaul normal plots
def normal_subplot(a_subplt, athena_groups = {}, include_groups = {}, xlim=[],ylim=[], s_legend = True):
    for g_indx, a_group in enumerate(include_groups):
        a_subplt.plot(athena_groups[a_group].energy,
                      athena_groups[a_group].norm, 
                      label=athena_groups[a_group].filename,
                      color = include_groups[a_group][0],
                      linestyle = include_groups[a_group][1]
                     )                 
    if s_legend:
        a_subplt.legend() # show legend
        a_subplt.set_ylabel("Normalized Absorption (a.u.)")
        a_subplt.set_xlabel("Energy (eV)")
    a_subplt.set_xlim(xlim)
    a_subplt.set_ylim(ylim)
    a_subplt.tick_params(axis='both', which='major', labelsize=9)
    return a_subplt

# normal plot with inset closeup
def plot_normal_w_inset(athena_groups = {}, include_groups = {}, aspect=(6,8),
                        lp_xlim=[], lp_ylim=[], 
                        sp_xlim=[],  sp_ylim=[]):
    fig, ax1 = plt.subplots(figsize=aspect)
    # These are in unitless percentages of the figure size. (0,0 is bottom left)
    left, bottom, width, height = [0.55, 0.2, 0.3, 0.3]
    ax2 = fig.add_axes([left, bottom, width, height])

    ax1 = normal_subplot(ax1, athena_groups, include_groups,lp_xlim,lp_ylim)
    ax2 = normal_subplot(ax2, athena_groups, include_groups, sp_xlim,sp_ylim, False)
    return plt


#plot the derivative       
def plot_derivative(athena_groups = {}, include_groups = {}, aspect = (6,8), xlim=[],ylim=[]):
    plt.figure(figsize=aspect)
    for g_indx, a_group in enumerate(include_groups):
        if athena_groups[a_group].filename in include_groups:
                plt.plot(athena_groups[a_group].energy, 
                         athena_groups[a_group].dmude, 
                         label=athena_groups[a_group].filename,
                         color = include_groups[a_group][0],
                         linestyle = include_groups[a_group][1]
                        ) 

    frame1 = plt.gca()
    #frame1.axes.yaxis.set_ticklabels([])
    #frame1.axes.yaxis.set_ticklabels([])
    plt.ylabel("Normalized Absorption (a.u.)")
    plt.xlabel("Energy (eV)")
    plt.xlim(xlim)
    plt.ylim(ylim)
    plt.legend()
    plt.show()

    return plt

#plot chi magnitude (FT)
        
def plot_chi_magnitude(athena_groups = {}, include_groups = {}, aspect = (6,8), xlim=[],ylim=[]):
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
    #frame1.axes.yaxis.set_ticklabels([])
    #frame1.axes.yaxis.set_ticklabels([])
    plt.xlabel("$R(\mathrm{\AA})$")
    plt.ylabel("$|\chi(R)|(\mathrm{\AA}^{-3})$")
    plt.xlim(xlim)
    plt.ylim(ylim)
    plt.legend()
    plt.show()

    return plt
    
