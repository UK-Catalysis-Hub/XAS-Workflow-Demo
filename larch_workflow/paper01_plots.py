from matplotlib import pyplot as plt
import matplotlib.cm as cm

# individaul LCF plots
def make_subplot(a_subplt, group1, group2):
    a_subplt.plot(group1.energy, group1.norm, label=group1.filename, linewidth=4,color='blue')
    a_subplt.plot(group2.energy, group2.norm, label=group2.filename, linewidth=2, color='orange',linestyle='--')
    a_subplt.grid(color='black', linestyle=':', linewidth=1) #show and format grid
    a_subplt.set_title(group2.arrayname, fontsize=8)
    a_subplt.legend() # show legend
     
    a_subplt.set_xlim([29190, 29230])
    #a_subplt.set_ylim([0, 1.5])
    #a_subplt.tick_params(axis='both', which='major', labelsize=9)
    #xlabels = a_subplt.get_xticklabels()
    #a_subplt.set_xticks(xlabels, rotation = 90)
    return a_subplt

# compare LCF plots
def compare_lcf_plot(lcf_1, lcf_2, lcf_3):
    fig, axes = plt.subplots(1,3, constrained_layout=True)
    axes[0] = make_subplot(axes[0], lcf_1[0], lcf_1[1])
    axes[1] = make_subplot(axes[1], lcf_2[0], lcf_2[1])
    axes[2] = make_subplot(axes[2], lcf_3[0], lcf_3[1])
    return fig

#chik plots

# using markers
def plot_markers(data_set,rmin,rmax,kmin,kmax, datalabel="data"):
    fig = plt.figure()#figsize=(10, 8))
    ax1 = fig.add_subplot(211)
    ax2 = fig.add_subplot(212)
    # Creating the chifit plot from scratch
    #from .xlarch.wxlibafsplots import plot_chifit
    #plot_chifit(dset, _larch=session)
    
    ax1.plot(data_set.data.k, data_set.data.chi*data_set.data.k**2, marker='$\u25CC$', markerfacecolor='b', 
                markeredgecolor='b', markersize=4, linestyle='none', label=datalabel)
    
    ax1.plot(data_set.model.k, data_set.model.chi*data_set.data.k**2 , color='r', label='fit')
    ax1.set_xlim(kmin, kmax)
    ax1.set_ylim(-1, 2)
    ax1.set_xlabel("$k (\mathrm{\AA})^{-1}$")
    ax1.set_ylabel("$k^2$ $\chi (k)(\mathrm{\AA})^{-2}$")
    ax1.legend()
    
    ax2.plot(data_set.data.r, data_set.data.chir_mag, marker='$\u25CC$', markerfacecolor='b', 
                markeredgecolor='b', markersize=4, linestyle='none', label=datalabel)
 
    ax2.plot(data_set.model.r, data_set.model.chir_mag, color='r', label='fit')
    ax2.set_xlim(rmin,rmax)
    ax2.set_xlabel("$R(\mathrm{\AA})$")
    ax2.set_ylabel("$|\chi(R)|(\mathrm{\AA}^{-3})$")
    ax2.legend(loc='upper right')

    return plt

# using lines
def plot_fit(data_set,rmin,rmax,kmin,kmax, datalabel="data"):
    fig = plt.figure()#figsize=(10, 8))
    ax1 = fig.add_subplot(211)
    ax2 = fig.add_subplot(212)
    # Creating the chifit plot from scratch
    #from .xlarch.wxlibafsplots import plot_chifit
    #plot_chifit(dset, _larch=session)
    ax1.plot(data_set.data.k, data_set.data.chi*data_set.data.k**2, color='b', label=datalabel)
    ax1.plot(data_set.model.k, data_set.model.chi*data_set.data.k**2 , color='r', label='fit')
    ax1.set_xlim(kmin, kmax)
    ax1.set_ylim(-1, 2)
    ax1.set_xlabel("$k (\mathrm{\AA})^{-1}$")
    ax1.set_ylabel("$k^2$ $\chi (k)(\mathrm{\AA})^{-2}$")
    ax1.legend()

    ax2.plot(data_set.data.r, data_set.data.chir_mag, color='b', label=datalabel)
    ax2.plot(data_set.model.r, data_set.model.chir_mag, color='r', label='fit')
    ax2.set_xlim(rmin,rmax)
    ax2.set_xlabel("$R(\mathrm{\AA})$")
    ax2.set_ylabel("$|\chi(R)|(\mathrm{\AA}^{-3})$")
    ax2.legend(loc='upper right')

    return plt

# using circles
def plot_circles(data_set,rmin,rmax,kmin,kmax, datalabel="data"):
    fig = plt.figure()#figsize=(10, 8))
    ax1 = fig.add_subplot(211)
    ax2 = fig.add_subplot(212)
    # Creating the chifit plot from scratch
    #from .xlarch.wxlibafsplots import plot_chifit
    #plot_chifit(dset, _larch=session)
    
    ax1.plot(data_set.data.k, data_set.data.chi*data_set.data.k**2, color='cyan', label=datalabel)
    c_size = 0.07
    for a, b, in zip(data_set.data.k, data_set.data.chi*data_set.data.k**2):
        circle = plt.Circle((a, b), c_size, fill=False)
        ax1.add_artist(circle)
    
    ax1.plot(data_set.model.k, data_set.model.chi*data_set.data.k**2 , color='r', label='fit')
    ax1.set_xlim(kmin, kmax)
    ax1.set_ylim(-1, 2)
    ax1.set_xlabel("$k (\mathrm{\AA})^{-1}$")
    ax1.set_ylabel("$k^2$ $\chi (k)(\mathrm{\AA})^{-2}$")
    ax1.legend()
    
    ax2.plot(data_set.data.r, data_set.data.chir_mag, color='cyan', label=datalabel)
    c_size = 0.025
    for a, b, in zip(data_set.data.r, data_set.data.chir_mag):
        circle = plt.Circle((a, b), c_size, fill=False)
        ax2.add_artist(circle)
    ax2.plot(data_set.model.r, data_set.model.chir_mag, color='r', label='fit')
    ax2.set_xlim(rmin,rmax)
    ax2.set_xlabel("$R(\mathrm{\AA})$")
    ax2.set_ylabel("$|\chi(R)|(\mathrm{\AA}^{-3})$")
    ax2.legend(loc='upper right')

    return plt
