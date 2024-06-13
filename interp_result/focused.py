import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def validrange(lat, pres, centerlat, centerpres):
    validlat  = np.empty(2)
    validpres = np.empty(2)

    # print(lat)
    # print(pres)

    centerlat_index  = np.argmin(np.abs( lat[:] -  centerlat))
    centerpres_index = np.argmin(np.abs(pres[:] - centerpres))

    increased_grid_lat  = int(( lat.size - 1) / 2)
    increased_grid_pres = int((pres.size - 1) / 3)

    validlat[0] = (centerlat + lat[centerlat_index - increased_grid_lat]) / 2
    validlat[1] = (centerlat + lat[centerlat_index + increased_grid_lat]) / 2
    #validlat[0] = validlat[np.argmin(validlat[:]-centerlat)]
    #validlat[1] = centerlat
    #if (validlat[0] > validlat[1]):
    #    swap = validlat[0]
    #    validlat[0] = validlat[1]
    #    validlat[1] = swap
    
    validpres[0] = (centerpres + pres[centerpres_index - increased_grid_pres]) / 2
    validpres[1] = (centerpres + pres[centerpres_index + increased_grid_pres]) / 2
    validpres[0] = validpres[np.argmin(validpres[:]-centerpres)]
    validpres[1] = centerpres
    if (validpres[0] > validpres[1]):
        swap = validpres[0]
        validpres[0] = validpres[1]
        validpres[1] = swap

    return validlat, validpres
	

def plot(st, pt, lat, pres, outname, title, center_lat, center_pres, validlat, validpres):
    fig = plt.figure(figsize=[6,6])
    ax = fig.add_subplot(111)

    ax.invert_yaxis()

    ax.set_xlim(lat[0], lat[-1])
    ax.set_ylim(pres[0], pres[-1])

    # ax.axvline(x=validlat[0])
    # ax.axvline(x=validlat[1])
    # ax.axhline(y=validpres[0])
    # ax.axhline(y=validpres[1])

    range = patches.Rectangle(xy=(validlat[0], validpres[0]), \
						      width=validlat[1] - validlat[0], \
						      height=validpres[1] - validpres[0], \
						      fc='lightgray', \
						      fill=True, \
						      zorder=1)
    ax.add_patch(range)
    
    lat, pres = np.meshgrid(lat, pres)

    st_c = ax.contour(lat, pres, st, np.arange(  0., 2.e+11, 1.e+9), colors='black', zorder=2)
    pt_c = ax.contour(lat, pres, pt, np.arange(260.,   300.,   0.5), colors='blue' , zorder=3)

    ax.clabel(st_c, inline=True, fontsize=9, fmt='%.2e')
    ax.clabel(pt_c, inline=True, fontsize=9, fmt='%.1f')

    ax.scatter(center_lat, center_pres, marker='x', color='black', s=40, zorder=10)

    ax.set_xlabel('Latitude', fontsize=15)
    ax.set_ylabel('Pressure (hPa)', fontsize=15)

    ax.set_title(title, fontsize=17)

    fig.savefig(outname, dpi=400)


def input(inname):
    tmp = np.loadtxt(inname)
    lat = tmp[0,1:]
    pres = tmp[1:,0]
    var = tmp[1:,1:]

    return var, lat, pres


def get_center_position(fname):
    info = np.loadtxt(fname, dtype='str')
    lat = info[:,7]
    pres = info[:,8]

    lat = np.array(lat, dtype=np.float64)
    pres = np.array(pres, dtype=np.float64)

    return lat, pres


def halfMonthly():
    center_lat_default, center_p_default = get_center_position('../output/JRA3Q/maxst_halfmonthly_default.dat')
    center_lat_interp , center_p_interp  = get_center_position('../output/JRA3Q/maxst_halfmonthly_interp.dat')
    #print(center_lat_default)
    year_ini = 1949
    year_fin = 2020
    periods = ['12_1', '12_2', '01_1', '01_2', '02_1', '02_2']
    t = 0
    for y in range(year_ini, year_fin):
        years = [str(y), str(y), str(y+1), str(y+1), str(y+1), str(y+1)]
        for m in range(len(periods)):
            inname_st = 'data/halfmonthly_' + years[m] + '_' + periods[m] + '_st.dat'
            inname_pt = 'data/halfmonthly_' + years[m] + '_' + periods[m] + '_pt.dat'
            outname   = 'fig/halfmonthly_' + years[m] + '_' + periods[m] + '.png'
            print('line = {:3d} : {} {} -> {}'.format(t+1, inname_st, inname_pt, outname))

            st, lat, pres = input(inname_st)
            pt, lat, pres = input(inname_pt)

            #print(lat)
            #print(pres)
            #print(center_lat_default[t])
            #print(center_p_default[t])

            validlat, validpres = validrange(lat, pres, center_lat_default[t], center_p_default[t])
            plot(st, pt, lat, pres, outname, 'Half-Monthly Mean : '+years[m]+'/'+periods[m], center_lat_interp[t], center_p_interp[t], validlat, validpres)

            t = t + 1


def monthly():
    center_lat_default, center_p_default = get_center_position('../output/JRA3Q/maxst_monthly_default.dat')
    center_lat_interp, center_p_interp = get_center_position('../output/JRA3Q/maxst_monthly_interp.dat')
    year_ini = 1949
    year_fin = 2020
    months = ['12', '01', '02']
    t = 0
    for y in range(year_ini, year_fin):
        years = [str(y), str(y+1), str(y+1)]
        for m in range(3):
	    
            inname_st = 'data/monthly_' + years[m] + '_' + months[m] + '_st.dat'
            inname_pt = 'data/monthly_' + years[m] + '_' + months[m] + '_pt.dat'
            outname= 'fig/monthly_' + years[m] + '_' + months[m] + '.png'
            print('line = {:3d} : {} {} -> {}'.format(t+1, inname_st, inname_pt, outname))

            st, lat, pres = input(inname_st)
            pt, lat, pres = input(inname_pt)
            
            validlat, validpres = validrange(lat, pres, center_lat_default[t], center_p_default[t])

            plot(st, pt, lat, pres, outname, 'Monthly Mean : '+years[m]+'/'+months[m], center_lat_interp[t], center_p_interp[t], validlat, validpres)

            t = t + 1


def DJF():
    center_lat_default, center_p_default = get_center_position('../output/JRA3Q/maxst_DJF_default.dat')
    center_lat_interp, center_p_interp = get_center_position('../output/JRA3Q/maxst_DJF_interp.dat')
    year_ini = 1949
    year_fin = 2020
    t = 0
    for y in range(year_ini+1, year_fin+1):
        inname_st = 'data/DJF_{}_st.dat'.format(y)
        inname_pt = 'data/DJF_{}_pt.dat'.format(y)
        outname = 'fig/DJF_{}.png'.format(y)
        print('line = {:3d} : {} {} -> {}'.format(t+1, inname_st, inname_pt, outname))

        st, lat, pres = input(inname_st)
        pt, lat, pres = input(inname_pt)
        
        validlat, validpres = validrange(lat, pres, center_lat_default[t], center_p_default[t])

        plot(st, pt, lat, pres, outname, 'DJF Mean : {}'.format(y), center_lat_interp[t], center_p_interp[t], validlat, validpres)

        t = t + 1


halfMonthly()
monthly()
DJF()

