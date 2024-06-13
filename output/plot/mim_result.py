import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
from read_direct import read_direct as read_direct
from levels import p as p


class filein:
    def __init__(self, file, shape, recl, rec, kind, endian, recstep):
        self.file    = file
        self.shape   = shape
        self.recl    = recl
        self.rec     = rec
        self.kind    = kind
        self.endian  = endian
        self.recstep = recstep

    def fread(self):
        output = read_direct(self.file, self.shape, self.recl, self.rec, self.kind, self.endian)
        self.rec = self.rec + self.recstep

        return output


def masking(field, mask):
    output = field[mask]
    output = np.reshape(output, [int(output.size/ny),ny])

    return output

def plot(ofile, st, title):

    #MASK = np.where(p <= 1010 and p >= 99)
    #print(p[MASK])

    lat = np.arange(-90., 91.25, 1.25)
    lat_field, p_field = np.meshgrid(lat, p)

    MASK = (p_field >= 99)
    lat_masked = masking(lat_field, MASK)
    p_masked   = masking(  p_field, MASK)
    st_masked  = masking(       st, MASK)

    fig = plt.figure(figsize=[6,6])
    ax = fig.add_subplot(111)
    ax.invert_yaxis()

    ax.set_yscale('log')
    ax.get_yaxis().set_major_formatter(mticker.ScalarFormatter())
    ax.yaxis.set_major_locator(mticker.MultipleLocator(100))

    ax.set_xticks([-90, -60, -30, 0, 30, 60, 90])
    ax.set_xticklabels(['90S', '60S', '30S', 'EQ', '30N', '60N', '90N'])

    ax.tick_params(axis='both', labelsize=14)
    ax.set_title(title, fontsize=16)

    cmin = -3.0e11
    cmax =  3.0e11
    cint =  0.3e11
    levs = np.arange(cmin, cmax+cint, cint)

    ax.contourf(lat_masked, p_masked, st_masked, levels=levs, cmap='bwr'   )
    ax.contour( lat_masked, p_masked, st_masked, levels=levs, colors='black')

    fig.savefig(ofile, dpi=350, bbox_inches='tight')


def plot_all(period):

    print(f'PERIOD : {period}')

    fname = '../JRA3Q/{}_mean_field.grd'.format(period)

    st_input = np.empty([nz,ny])
    st_file = open(fname, 'rb')
    st_type = filein(st_file, np.shape(st_input), 4*ny*nz, 1, 4, 'LITTLE', 2)

    months = [12, 1, 2]
    months_str = ['December', 'January', 'February']
    halfs  = ['Early', 'Late']
    for year in range(year_ini, year_fin):

        print(f'YEAR : {year}')

        if (period == 'DJF'):
            st = st_type.fread()
            ofile = '{}/{}_{}.png'.format(opath, period, year+1)
            plot(ofile, st, f'{year}')

        else:
            ys = [year, year+1, year+1]
            for m in range(3):
                if (period == 'monthly'):
                    st = st_type.fread()
                    ofile = '{}/{}_{}_{:02d}.png'.format(opath, period, ys[m], months[m])
                    plot(ofile, st, f'{ys[m]} {months_str[m]}')

                else:
                    for h in range(2):
                        st = st_type.fread()
                        ofile = '{}/{}_{}_{:02d}_{}.png'.format(opath, period, ys[m], months[m], halfs[h])
                        plot(ofile, st, f'{ys[m]} {halfs[h]} {months_str[m]}')



#MASK = (p >= 99)
#print(p[MASK])
#print(p[p >= 99])

year_ini = 1949
year_fin = 2022
#year_num = year_fin - year_ini
#month_num = year_num * 3
#half_num = month_num << 1
#print(month_num)

opath = './fig'
ny = 145
nz = 45

plot_all('halfmonthly')
plot_all('monthly')
plot_all('DJF')

