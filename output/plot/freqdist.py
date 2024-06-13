import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
from levels import p as lev

latstep = 1.25
lat = np.arange(-90., 90.+latstep, latstep)
lev = lev[::-1]
#print(lev)

def mkhst(var, axis, title, figname, xtickstep):

    maxval = np.max(var)
    minval = np.min(var)
    #print(maxval)
    #print(minval)
    left  = np.argmin(np.abs(axis-minval))
    right = np.argmin(np.abs(axis-maxval))

    bins = (axis[:-1] + axis[1:]) * 0.5
    #if (bins[0] > bins[-1]):
    #    bins[:] = bins[::-1]
    #print(bins)
    fig = plt.figure(figsize=[8,6])
    ax = fig.add_subplot(111)
    
    ax.hist(var, bins, rwidth=0.8, color='blue', zorder=10)
    #ax.hist(var, bins, color='blue', zorder=10)

    ax.set_xlim(np.min([axis[left-1], axis[right+1]]), np.max([axis[left-1], axis[right+1]]))
    #print(np.min([axis[left-1], axis[right+1]]))
    #print(np.max([axis[left-1], axis[right+1]]))
    ax.xaxis.set_minor_locator(mticker.MultipleLocator(1.25))
    ax.xaxis.set_major_locator(mticker.MultipleLocator(xtickstep))
    #ax.xaxis.set_major_formatter(mticker.StrMethodFormatter('{:axis}N'))
    ax.xaxis.set_major_formatter(mticker.FormatStrFormatter(f'%2.2fN'))

    #ax.yaxis.set_minor_locator(mticker.MultipleLocator( 5))
    #ax.yaxis.set_major_locator(mticker.MultipleLocator(25))

    ax.grid(which='major', axis='both', linewidth=1.0, zorder=0)
    ax.grid(which='minor', axis='both', linewidth=0.3, zorder=0)

    ax.tick_params(axis='both', labelsize=15)
    ax.set_title(title, fontsize=16)

    fig.savefig(figname, dpi=350, bbox_inches='tight')


def plot(period):

    if (period == 'halfmonthly'):
        xtickstep = 5.
    elif (period == 'monthly'):
        xtickstep = 2.5
    elif (period == 'DJF'):
        xtickstep = 1.25
    else:
        print('UNEXPECTED PERIOD')
        exit(1)

    ifile = f'../JRA3Q/maxst_{period}_default.dat'
    ofile = f'hists/JRA3Q_1949_2022_lat_hist_{period}.png'
    input = np.loadtxt(ifile, dtype='str')

    centerlat = np.array(input[:,7], dtype=np.float32)
    centerlev = np.array(input[:,8], dtype=np.float32)

    mkhst(centerlat, lat, 'Center Latitude of ETD Circulation in Boreal Winter', ofile, xtickstep)
    print(f'output : {ofile}')


plot('halfmonthly')
plot('monthly')
plot('DJF')

