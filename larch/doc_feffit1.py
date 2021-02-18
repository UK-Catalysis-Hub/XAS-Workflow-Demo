## examples/feffit/doc_feffit1.lar

# import needed for python:
from larch.io import read_ascii
from larch.fitting import param, guess, param_group
from larch.xafs import autobk, feffpath, feffit_transform, feffit_dataset, feffit, feffit_report
from larch.wxlib.xafsplots import plot_chifit

# read data
cu_data  = read_ascii('../xafsdata/cu_metal_rt.xdi')
autobk(cu_data.energy, cu_data.mutrans, group=cu_data, rbkg=1.0, kw=2)

# define fitting parameter group
pars = param_group(amp    = param(1.0, vary=True),
                   del_e0 = param(0.0, vary=True),
                   sig2   = param(0.0, vary=True),
                   del_r  = guess(0.0, vary=True) )

# define a Feff Path, give expressions for Path Parameters
path1 = feffpath('feffcu01.dat',
                 s02    = 'amp',
                 e0     = 'del_e0',
                 sigma2 = 'sig2',
                 deltar = 'del_r')

# set tranform / fit ranges
trans = feffit_transform(kmin=3, kmax=17, kw=2, dk=4, window='kaiser', rmin=1.4, rmax=3.0)

# define dataset to include data, pathlist, transform
dset = feffit_dataset(data=cu_data, pathlist=[path1], transform=trans)

# perform fit!
out = feffit(pars, dset)
print(feffit_report(out))
 
try:
    fout = open('doc_feffit1.out', 'w')
    fout.write("%s\n" % feffit_report(out))
    fout.close()
except:
    print('could not write doc_feffit1.out')
#endtry
# 
plot_chifit(dset)

## end examples/feffit/doc_feffit1.lar