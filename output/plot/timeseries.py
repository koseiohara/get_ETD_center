import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from matplotlib.ticker import MaxNLocator, MultipleLocator
import matplotlib.ticker as mticker
import datetime
from levels import p as lev

lat = np.arange(-90., 91.25, 1.25)


def input(ifile):
    #data_all = np.loadtxt(ifile, delimiter=' ', dtype='str')
    data_all = np.loadtxt(ifile, dtype='str')
    date_ini = data_all[:,3]
    time_ini = data_all[:,4]
    date_fin = data_all[:,5]
    time_fin = data_all[:,6]
    lat      = np.array(data_all[:,7] , dtype='float64')
    pres     = np.array(data_all[:,8] , dtype='float64')
    st       = np.array(data_all[:,9] , dtype='float64')
    pt       = np.array(data_all[:,10], dtype='float64')

    datetime_ini = []
    datetime_fin = []
    for i in range(date_ini.size):
        datetime_ini.append(datetime.datetime.strptime(date_ini[i]+time_ini[i], '%Y/%m/%d%H:%M:%S'))
        datetime_fin.append(datetime.datetime.strptime(date_fin[i]+time_fin[i], '%Y/%m/%d%H:%M:%S'))
        datetime_fin[i] = datetime_fin[i] - datetime.timedelta(hours=6)

    return datetime_ini, datetime_fin, lat, pres, st, pt


def mkgrph_lat(fig, ax, title, label, x, y, ymin, ymax, ytick):
    ax.plot(x, y, label=label, color='blue', zorder=2)

    if (title != ''):
        ax.set_title(title, fontsize=13)

    if (label != ''):
        ax.legend(loc='upper right', fontsize=12)

    ax.xaxis.set_minor_locator(MultipleLocator(1))
    ax.set_yticks(ytick)
    ax.yaxis.set_major_formatter(mticker.FormatStrFormatter(f'%2.2f'))
    #ax.yaxis.set_major_locator(MultipleLocator(5.00))
    ax.yaxis.set_minor_locator(MultipleLocator(1.25))

    ax.grid(which='major', axis='both', linewidth=0.5)
    ax.grid(which='minor', axis='both', linewidth=0.2)
    
    if (ymin != ymax):
        ax.set_ylim(ymin, ymax)

    ax.axhline(y=41.25, color='red', zorder=1, linewidth=0.5)


def mkgrph_lev(fig, ax, title, label, x, y, ymin, ymax, ytick):
    ax.plot(x, y, label=label, color='blue')

    if (title != ''):
        ax.set_title(title, fontsize=13)

    if (label != ''):
        ax.legend(loc='upper right', fontsize=12)

    ax.xaxis.set_minor_locator(MultipleLocator(1))
    ax.set_yticks(ytick)

    ax.grid(which='major', axis='both', linewidth=0.5)
    ax.grid(which='minor', axis='x'   , linewidth=0.2)
    
    if (ymin != ymax):
        ax.set_ylim(ymin, ymax)


def mkgrph_pt(fig, ax, title, label, x, y, ymin, ymax, ytick):
    ax.plot(x, y, label=label, color='blue')

    if (title != ''):
        ax.set_title(title, fontsize=13)

    if (label != ''):
        ax.legend(loc='upper right', fontsize=12)

    ax.xaxis.set_minor_locator(MultipleLocator(1))
    ax.yaxis.set_major_locator(MaxNLocator(nbins=7, min_n_ticks=5))

    ax.grid(which='major', axis='both', linewidth=0.5)
    ax.grid(which='minor', axis='x'   , linewidth=0.2)
    
    if (ymin != ymax):
        ax.set_ylim(ymin, ymax)


def mkgrph_st(fig, ax, title, label, x, y, ymin, ymax, ytick):
    ax.plot(x, y, label=label, color='blue')

    if (title != ''):
        ax.set_title(title, fontsize=13)

    if (label != ''):
        ax.legend(loc='upper right', fontsize=12)

    ax.xaxis.set_minor_locator(MultipleLocator(1))
    ax.yaxis.set_major_locator(MaxNLocator(nbins=7, min_n_ticks=5))

    ax.grid(which='major', axis='both', linewidth=0.5)
    ax.grid(which='minor', axis='x'   , linewidth=0.2)
    
    if (ymin != ymax):
        ax.set_ylim(ymin, ymax)


def halfMonthly_mkfgr(year, timeseries, title, figname, yinv, ytick):
    ynum = timeseries[::6].size

    minval = np.min(timeseries)
    maxval = np.max(timeseries)
    variety_range = maxval - minval
    minval = minval - variety_range*0.01
    maxval = maxval + variety_range*0.01

    fig = plt.figure(figsize=[6,9])
    fig.subplots_adjust(hspace=0.3, top=0.95, bottom=0.05)
    ax0 = fig.add_subplot(611)
    ax1 = fig.add_subplot(612)
    ax2 = fig.add_subplot(613)
    ax3 = fig.add_subplot(614)
    ax4 = fig.add_subplot(615)
    ax5 = fig.add_subplot(616)

    mkgrph(fig, ax0, '', 'Early December', year[0:ynum], timeseries[0::6], minval, maxval, ytick)
    mkgrph(fig, ax1, '', 'Late December' , year[0:ynum], timeseries[1::6], minval, maxval, ytick)
    mkgrph(fig, ax2, '', 'Early January' , year[0:ynum], timeseries[2::6], minval, maxval, ytick)
    mkgrph(fig, ax3, '', 'Late January'  , year[0:ynum], timeseries[3::6], minval, maxval, ytick)
    mkgrph(fig, ax4, '', 'Early February', year[0:ynum], timeseries[4::6], minval, maxval, ytick)
    mkgrph(fig, ax5, '', 'Late February' , year[0:ynum], timeseries[5::6], minval, maxval, ytick)

    if (yinv):
        ax0.invert_yaxis()
        ax1.invert_yaxis()
        ax2.invert_yaxis()
        ax3.invert_yaxis()
        ax4.invert_yaxis()
        ax5.invert_yaxis()

    fig.suptitle(title, fontsize=14)
    fig.savefig(figname, dpi=350, bbox_inches='tight')


def halfMonthly_mkfgr_lat(year, timeseries, title, figname, ytick):
    ynum = timeseries[::6].size

    minval = np.min(timeseries)
    maxval = np.max(timeseries)
    variety_range = maxval - minval
    minval = minval - variety_range*0.01
    maxval = maxval + variety_range*0.01

    fig = plt.figure(figsize=[18,6])
    fig.subplots_adjust(hspace=0.1, wspace=0.13, top=0.93, bottom=0.05)
    ax0 = fig.add_subplot(231)
    ax1 = fig.add_subplot(234)
    ax2 = fig.add_subplot(232)
    ax3 = fig.add_subplot(235)
    ax4 = fig.add_subplot(233)
    ax5 = fig.add_subplot(236)

    mkgrph_lat(fig, ax0, '', 'Early December', year[0:ynum], timeseries[0::6], minval, maxval, ytick)
    mkgrph_lat(fig, ax1, '', 'Late December' , year[0:ynum], timeseries[1::6], minval, maxval, ytick)
    mkgrph_lat(fig, ax2, '', 'Early January' , year[0:ynum], timeseries[2::6], minval, maxval, ytick)
    mkgrph_lat(fig, ax3, '', 'Late January'  , year[0:ynum], timeseries[3::6], minval, maxval, ytick)
    mkgrph_lat(fig, ax4, '', 'Early February', year[0:ynum], timeseries[4::6], minval, maxval, ytick)
    mkgrph_lat(fig, ax5, '', 'Late February' , year[0:ynum], timeseries[5::6], minval, maxval, ytick)

    fig.suptitle(title, fontsize=16)
    fig.savefig(figname, dpi=350, bbox_inches='tight')


def halfMonthly_mkfgr_lev(year, timeseries, title, figname, ytick):
    ynum = timeseries[::6].size

    minval = np.min(timeseries)
    maxval = np.max(timeseries)
    variety_range = maxval - minval
    minval = minval - variety_range*0.01
    maxval = maxval + variety_range*0.01

    fig = plt.figure(figsize=[6,9])
    fig.subplots_adjust(hspace=0.3, top=0.95, bottom=0.05)
    ax0 = fig.add_subplot(611)
    ax1 = fig.add_subplot(612)
    ax2 = fig.add_subplot(613)
    ax3 = fig.add_subplot(614)
    ax4 = fig.add_subplot(615)
    ax5 = fig.add_subplot(616)

    mkgrph_lev(fig, ax0, '', 'Early December', year[0:ynum], timeseries[0::6], minval, maxval, ytick)
    mkgrph_lev(fig, ax1, '', 'Late December' , year[0:ynum], timeseries[1::6], minval, maxval, ytick)
    mkgrph_lev(fig, ax2, '', 'Early January' , year[0:ynum], timeseries[2::6], minval, maxval, ytick)
    mkgrph_lev(fig, ax3, '', 'Late January'  , year[0:ynum], timeseries[3::6], minval, maxval, ytick)
    mkgrph_lev(fig, ax4, '', 'Early February', year[0:ynum], timeseries[4::6], minval, maxval, ytick)
    mkgrph_lev(fig, ax5, '', 'Late February' , year[0:ynum], timeseries[5::6], minval, maxval, ytick)

    ax0.invert_yaxis()
    ax1.invert_yaxis()
    ax2.invert_yaxis()
    ax3.invert_yaxis()
    ax4.invert_yaxis()
    ax5.invert_yaxis()

    fig.suptitle(title, fontsize=14)
    fig.savefig(figname, dpi=350, bbox_inches='tight')


def halfMonthly_mkfgr_st(year, timeseries, title, figname, ytick):
    ynum = timeseries[::6].size

    minval = np.min(timeseries)
    maxval = np.max(timeseries)
    variety_range = maxval - minval
    minval = minval - variety_range*0.01
    maxval = maxval + variety_range*0.01

    fig = plt.figure(figsize=[6,9])
    fig.subplots_adjust(hspace=0.3, top=0.95, bottom=0.05)
    ax0 = fig.add_subplot(611)
    ax1 = fig.add_subplot(612)
    ax2 = fig.add_subplot(613)
    ax3 = fig.add_subplot(614)
    ax4 = fig.add_subplot(615)
    ax5 = fig.add_subplot(616)

    mkgrph_st(fig, ax0, '', 'Early December', year[0:ynum], timeseries[0::6], minval, maxval, ytick)
    mkgrph_st(fig, ax1, '', 'Late December' , year[0:ynum], timeseries[1::6], minval, maxval, ytick)
    mkgrph_st(fig, ax2, '', 'Early January' , year[0:ynum], timeseries[2::6], minval, maxval, ytick)
    mkgrph_st(fig, ax3, '', 'Late January'  , year[0:ynum], timeseries[3::6], minval, maxval, ytick)
    mkgrph_st(fig, ax4, '', 'Early February', year[0:ynum], timeseries[4::6], minval, maxval, ytick)
    mkgrph_st(fig, ax5, '', 'Late February' , year[0:ynum], timeseries[5::6], minval, maxval, ytick)

    fig.suptitle(title, fontsize=14)
    fig.savefig(figname, dpi=350, bbox_inches='tight')


def halfMonthly_mkfgr_pt(year, timeseries, title, figname, ytick):
    ynum = timeseries[::6].size

    minval = np.min(timeseries)
    maxval = np.max(timeseries)
    variety_range = maxval - minval
    minval = minval - variety_range*0.01
    maxval = maxval + variety_range*0.01

    fig = plt.figure(figsize=[6,9])
    fig.subplots_adjust(hspace=0.3, top=0.95, bottom=0.05)
    ax0 = fig.add_subplot(611)
    ax1 = fig.add_subplot(612)
    ax2 = fig.add_subplot(613)
    ax3 = fig.add_subplot(614)
    ax4 = fig.add_subplot(615)
    ax5 = fig.add_subplot(616)

    mkgrph_pt(fig, ax0, '', 'Early December', year[0:ynum], timeseries[0::6], minval, maxval, ytick)
    mkgrph_pt(fig, ax1, '', 'Late December' , year[0:ynum], timeseries[1::6], minval, maxval, ytick)
    mkgrph_pt(fig, ax2, '', 'Early January' , year[0:ynum], timeseries[2::6], minval, maxval, ytick)
    mkgrph_pt(fig, ax3, '', 'Late January'  , year[0:ynum], timeseries[3::6], minval, maxval, ytick)
    mkgrph_pt(fig, ax4, '', 'Early February', year[0:ynum], timeseries[4::6], minval, maxval, ytick)
    mkgrph_pt(fig, ax5, '', 'Late February' , year[0:ynum], timeseries[5::6], minval, maxval, ytick)

    fig.suptitle(title, fontsize=14)
    fig.savefig(figname, dpi=350, bbox_inches='tight')


def monthly_mkfgr(year, timeseries, title, figname, yinv, ytick):
    ynum = timeseries[::3].size

    minval = np.min(timeseries)
    maxval = np.max(timeseries)
    variety_range = maxval - minval
    minval = minval - variety_range*0.01
    maxval = maxval + variety_range*0.01

    fig = plt.figure(figsize=[6,6])
    fig.subplots_adjust(hspace=0.2, top=0.935, bottom=0.05)
    ax0 = fig.add_subplot(311)
    ax1 = fig.add_subplot(312)
    ax2 = fig.add_subplot(313)

    mkgrph(fig, ax0, '', 'December', year[0:ynum], timeseries[0::3], minval, maxval, ytick)
    mkgrph(fig, ax1, '', 'January' , year[0:ynum], timeseries[1::3], minval, maxval, ytick)
    mkgrph(fig, ax2, '', 'February', year[0:ynum], timeseries[2::3], minval, maxval, ytick)

    if (yinv):
        ax0.invert_yaxis()
        ax1.invert_yaxis()
        ax2.invert_yaxis()

    fig.suptitle(title, fontsize=14)
    fig.savefig(figname, dpi=350, bbox_inches='tight')


def monthly_mkfgr_lat(year, timeseries, title, figname, ytick):
    ynum = timeseries[::3].size

    minval = np.min(timeseries)
    maxval = np.max(timeseries)
    variety_range = maxval - minval
    minval = minval - variety_range*0.01
    maxval = maxval + variety_range*0.01

    fig = plt.figure(figsize=[6,6])
    fig.subplots_adjust(hspace=0.2, top=0.935, bottom=0.05)
    ax0 = fig.add_subplot(311)
    ax1 = fig.add_subplot(312)
    ax2 = fig.add_subplot(313)

    mkgrph_lat(fig, ax0, '', 'December', year[0:ynum], timeseries[0::3], minval, maxval, ytick)
    mkgrph_lat(fig, ax1, '', 'January' , year[0:ynum], timeseries[1::3], minval, maxval, ytick)
    mkgrph_lat(fig, ax2, '', 'February', year[0:ynum], timeseries[2::3], minval, maxval, ytick)

    fig.suptitle(title, fontsize=14)
    fig.savefig(figname, dpi=350, bbox_inches='tight')


def monthly_mkfgr_lev(year, timeseries, title, figname, ytick):
    ynum = timeseries[::3].size

    minval = np.min(timeseries)
    maxval = np.max(timeseries)
    variety_range = maxval - minval
    minval = minval - variety_range*0.01
    maxval = maxval + variety_range*0.01

    fig = plt.figure(figsize=[6,6])
    fig.subplots_adjust(hspace=0.2, top=0.935, bottom=0.05)
    ax0 = fig.add_subplot(311)
    ax1 = fig.add_subplot(312)
    ax2 = fig.add_subplot(313)

    mkgrph_lev(fig, ax0, '', 'December', year[0:ynum], timeseries[0::3], minval, maxval, ytick)
    mkgrph_lev(fig, ax1, '', 'January' , year[0:ynum], timeseries[1::3], minval, maxval, ytick)
    mkgrph_lev(fig, ax2, '', 'February', year[0:ynum], timeseries[2::3], minval, maxval, ytick)

    ax0.invert_yaxis()
    ax1.invert_yaxis()
    ax2.invert_yaxis()

    fig.suptitle(title, fontsize=14)
    fig.savefig(figname, dpi=350, bbox_inches='tight')


def monthly_mkfgr_st(year, timeseries, title, figname, ytick):
    ynum = timeseries[::3].size

    minval = np.min(timeseries)
    maxval = np.max(timeseries)
    variety_range = maxval - minval
    minval = minval - variety_range*0.01
    maxval = maxval + variety_range*0.01

    fig = plt.figure(figsize=[6,6])
    fig.subplots_adjust(hspace=0.2, top=0.935, bottom=0.05)
    ax0 = fig.add_subplot(311)
    ax1 = fig.add_subplot(312)
    ax2 = fig.add_subplot(313)

    mkgrph_st(fig, ax0, '', 'December', year[0:ynum], timeseries[0::3], minval, maxval, ytick)
    mkgrph_st(fig, ax1, '', 'January' , year[0:ynum], timeseries[1::3], minval, maxval, ytick)
    mkgrph_st(fig, ax2, '', 'February', year[0:ynum], timeseries[2::3], minval, maxval, ytick)

    fig.suptitle(title, fontsize=14)
    fig.savefig(figname, dpi=350, bbox_inches='tight')


def monthly_mkfgr_pt(year, timeseries, title, figname, ytick):
    ynum = timeseries[::3].size

    minval = np.min(timeseries)
    maxval = np.max(timeseries)
    variety_range = maxval - minval
    minval = minval - variety_range*0.01
    maxval = maxval + variety_range*0.01

    fig = plt.figure(figsize=[6,6])
    fig.subplots_adjust(hspace=0.2, top=0.935, bottom=0.05)
    ax0 = fig.add_subplot(311)
    ax1 = fig.add_subplot(312)
    ax2 = fig.add_subplot(313)

    mkgrph_pt(fig, ax0, '', 'December', year[0:ynum], timeseries[0::3], minval, maxval, ytick)
    mkgrph_pt(fig, ax1, '', 'January' , year[0:ynum], timeseries[1::3], minval, maxval, ytick)
    mkgrph_pt(fig, ax2, '', 'February', year[0:ynum], timeseries[2::3], minval, maxval, ytick)

    fig.suptitle(title, fontsize=14)
    fig.savefig(figname, dpi=350, bbox_inches='tight')



def DJF_mkfgr(year, timeseries, title, figname, yinv, ytick):
    ynum = timeseries.size

    minval = np.min(timeseries)
    maxval = np.max(timeseries)
    variety_range = maxval - minval
    minval = minval - variety_range*0.01
    maxval = maxval + variety_range*0.01

    fig = plt.figure(figsize=[6,4])
    #fig.subplots_adjust(hspace=0.3, top=0.95, bottom=0.05)
    ax = fig.add_subplot(111)

    mkgrph(fig, ax, '', '', year[0:ynum], timeseries[:], minval, maxval, ytick)

    if (yinv):
        ax.invert_yaxis()

    ax.set_title(title, fontsize=14)
    fig.savefig(figname, dpi=350, bbox_inches='tight')


def DJF_mkfgr_lat(year, timeseries, title, figname, ytick):
    ynum = timeseries.size

    minval = np.min(timeseries)
    maxval = np.max(timeseries)
    variety_range = maxval - minval
    minval = minval - variety_range*0.01
    maxval = maxval + variety_range*0.01

    fig = plt.figure(figsize=[6,4])
    #fig.subplots_adjust(hspace=0.3, top=0.95, bottom=0.05)
    ax = fig.add_subplot(111)

    mkgrph_lat(fig, ax, '', '', year[0:ynum], timeseries[:], minval, maxval, ytick)

    ax.set_title(title, fontsize=14)
    fig.savefig(figname, dpi=350, bbox_inches='tight')


def DJF_mkfgr_lev(year, timeseries, title, figname, ytick):
    ynum = timeseries.size

    minval = np.min(timeseries)
    maxval = np.max(timeseries)
    variety_range = maxval - minval
    minval = minval - variety_range*0.01
    maxval = maxval + variety_range*0.01

    fig = plt.figure(figsize=[6,4])
    #fig.subplots_adjust(hspace=0.3, top=0.95, bottom=0.05)
    ax = fig.add_subplot(111)

    mkgrph_lev(fig, ax, '', '', year[0:ynum], timeseries[:], minval, maxval, ytick)

    ax.invert_yaxis()

    ax.set_title(title, fontsize=14)
    fig.savefig(figname, dpi=350, bbox_inches='tight')


def DJF_mkfgr_st(year, timeseries, title, figname, ytick):
    ynum = timeseries.size

    minval = np.min(timeseries)
    maxval = np.max(timeseries)
    variety_range = maxval - minval
    minval = minval - variety_range*0.01
    maxval = maxval + variety_range*0.01

    fig = plt.figure(figsize=[6,4])
    #fig.subplots_adjust(hspace=0.3, top=0.95, bottom=0.05)
    ax = fig.add_subplot(111)

    mkgrph_st(fig, ax, '', '', year[0:ynum], timeseries[:], minval, maxval, ytick)

    ax.set_title(title, fontsize=14)
    fig.savefig(figname, dpi=350, bbox_inches='tight')


def DJF_mkfgr_pt(year, timeseries, title, figname, ytick):
    ynum = timeseries.size

    minval = np.min(timeseries)
    maxval = np.max(timeseries)
    variety_range = maxval - minval
    minval = minval - variety_range*0.01
    maxval = maxval + variety_range*0.01

    fig = plt.figure(figsize=[6,4])
    #fig.subplots_adjust(hspace=0.3, top=0.95, bottom=0.05)
    ax = fig.add_subplot(111)

    mkgrph_pt(fig, ax, '', '', year[0:ynum], timeseries[:], minval, maxval, ytick)

    ax.set_title(title, fontsize=14)
    fig.savefig(figname, dpi=350, bbox_inches='tight')


def halfMonthly():
    ifile125='../JRA3Q/maxst_halfmonthly_default.dat'
    ini125, fin125, lat125, p125, st125, pt125 = input(ifile125)

    ynum = len(ini125[::6])
    year = np.empty(ynum, dtype=int)
    for i in range(year.size):
        year[i] = int(datetime.datetime.strftime(ini125[i*6], '%Y')) + 1

    # halfMonthly_mkfgr(Horizontal Axis, Vertical Axis, Title of Graph, Name of Figure)
    halfMonthly_mkfgr_lat(year, \
                      lat125, \
                      '15-Day Average Center Latitude', \
                      'timeseries/halfMonthly_lat125.png', \
                      lat[::4])
    halfMonthly_mkfgr_lev(year, \
                      p125, \
                      '15-Day Average Center Pressure (hPa)', \
                      'timeseries/halfMonthly_p125.png', \
                      lev)
    halfMonthly_mkfgr_st(year, \
                      st125/1e11, \
                      r'15-Day Average Center Streamfunction ($10^{11} \:\mathrm{kg\:s^{-1}}$)', \
                      'timeseries/halfMonthly_st125.png', \
                      '')
    halfMonthly_mkfgr_pt(year, \
                      pt125, \
                      '15-Day Average Center Potential Temperature (K)', \
                      'timeseries/halfMonthly_pt125.png', \
                      '')


def monthly():
    ifile125='../JRA3Q/maxst_monthly_default.dat'
    ini125, fin125, lat125, p125, st125, pt125 = input(ifile125)

    ynum = len(ini125[::3])
    year = np.empty(ynum, dtype=int)
    for i in range(year.size):
        year[i] = int(datetime.datetime.strftime(ini125[i*3], '%Y')) + 1
    
    # halfMonthly_mkfgr(Horizontal Axis, Vertical Axis, Title of Graph, Name of Figure)
    monthly_mkfgr_lat(year, \
                  lat125, \
                  'Monthly Mean Center Latitude', \
                  'timeseries/Monthly_lat125.png', \
                  lat)
    monthly_mkfgr_lev(year, \
                  p125, \
                  'Monthly Mean Center Pressure (hPa)', \
                  'timeseries/Monthly_p125.png', \
                  lev)
    monthly_mkfgr_st(year, \
                  st125/1e11, \
                  r'Monthly Mean Center Streamfunction ($10^{11} \:\mathrm{kg\:s^{-1}}$)', \
                  'timeseries/Monthly_st125.png', \
                  '')
    monthly_mkfgr_pt(year, \
                  pt125, \
                  'Monthly Mean Center Potential Temperature (K)', \
                  'timeseries/Monthly_pt125.png', \
                  '')


def DJF():
    ifile125='../JRA3Q/maxst_DJF_default.dat'
    ini125, fin125, lat125, p125, st125, pt125 = input(ifile125)

    ynum = len(ini125)
    year = np.empty(ynum, dtype=int)
    for i in range(year.size):
        year[i] = int(datetime.datetime.strftime(ini125[i], '%Y')) + 1
    
    # halfMonthly_mkfgr(Horizontal Axis, Vertical Axis, Title of Graph, Name of Figure)
    DJF_mkfgr_lat(year, \
              lat125, \
              'DJF Mean Center Latitude', \
              'timeseries/DJF_lat125.png', \
              lat)
    DJF_mkfgr_lev(year, \
              p125, \
              'DJF Mean Center Pressure (hPa)', \
              'timeseries/DJF_p125.png', \
              lev)
    DJF_mkfgr_st(year, \
              st125/1e11, \
              r'DJF Mean Center Streamfunction ($10^{11} \:\mathrm{kg\:s^{-1}}$)', \
              'timeseries/DJF_st125.png', \
              '')
    DJF_mkfgr_pt(year, \
              pt125, \
              'DJF Mean Center Potential Temperature (K)', \
              'timeseries/DJF_pt125.png', \
              '')


halfMonthly()
#monthly()
#DJF()


