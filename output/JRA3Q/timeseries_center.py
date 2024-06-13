import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import matplotlib.ticker as mticker
import datetime


year_ini = 1949
year_fin = 2020

year = np.arange(year_ini+1, year_fin+1, 1)
    

def plotPrs_shorter(begin, end, p, pmean, searchtype):
        cycle = 6
	fig = plt.figure(figsize=[10,6])
	ax = fig.add_subplot(111)
	ax.invert_yaxis()
	ax.plot(year, p[0::cycle], label="{}-{}".format(begin[0], end[0]), color="blue", linewidth=0.8)
	ax.plot(year, p[1::cycle], label="{}-{}".format(begin[1], end[1]), color="red", linewidth=0.8)
	ax.plot(year, p[2::cycle], label="{}-{}".format(begin[2], end[2]), color="green", linewidth=0.8)
	ax.plot(year, p[3::cycle], label="{}-{}".format(begin[3], end[3]), color="black", linewidth=0.8)
	#pltformat(fig, ax, "Pressure at the Center of ETD Circulation in Boreal Winter", "Pressure")
	pltformat(fig, ax, "", r"Pressure ($\mathrm{hPa}$)")
	fname = "./timeseries/monthly_{}_{}_pressure_{}.png".format(year_ini, year_fin, searchtype)
	#fig.savefig("./center_of_boreal_ETD/monthly_{}_{}_pressure.png".format(year_ini, year_fin), dpi=350)
	fig.savefig(fname, dpi=350)
	print(fname)


def plotPrs_monthly(p, pmean, searchtype):
	fig = plt.figure(figsize=[10,6])
	ax = fig.add_subplot(111)
	ax.invert_yaxis()
	ax.plot(year, p[0::3], label="December", color="blue", linewidth=0.8)
	ax.plot(year, p[1::3], label="January", color="red", linewidth=0.8)
	ax.plot(year, p[2::3], label="February", color="green", linewidth=0.8)
	ax.plot(year,   pmean, label="DJF Mean", color="black", linewidth=1.5)
	#pltformat(fig, ax, "Pressure at the Center of ETD Circulation in Boreal Winter", "Pressure")
	pltformat(fig, ax, "", r"Pressure ($\mathrm{hPa}$)")
	fname = "./timeseries/monthly_{}_{}_pressure_{}.png".format(year_ini, year_fin, searchtype)
	#fig.savefig("./center_of_boreal_ETD/monthly_{}_{}_pressure.png".format(year_ini, year_fin), dpi=350)
	fig.savefig(fname, dpi=350)
	print(fname)


def plotLat_monthly(lat, latmean, searchtype):
	fig = plt.figure(figsize=[10,6])
	ax = fig.add_subplot(111)
	ax.plot(year, lat[0::3], label="December", color="blue", linewidth=0.8)
	ax.plot(year, lat[1::3], label="January", color="red", linewidth=0.8)
	ax.plot(year, lat[2::3], label="February", color="green", linewidth=0.8)
	ax.plot(year,   latmean, label="DJF Mean", color="black", linewidth=1.5)
	#pltformat(fig, ax, "Latitude at the Center of ETD Circulation in Boreal Winter", "Latitude")
	pltformat(fig, ax, "", "Latitude")
	#fig.savefig("./center_of_boreal_ETD/monthly_{}_{}_latitude.png".format(year_ini, year_fin), dpi=350)
	fname = "./timeseries/monthly_{}_{}_latitude_{}.png".format(year_ini, year_fin, searchtype)
	fig.savefig(fname, dpi=350)
	print(fname)


def plotPt_monthly(pt, ptmean, searchtype):
	fig = plt.figure(figsize=[10,6])
	ax = fig.add_subplot(111)
	ax.plot(year, pt[0::3], label="December", color="blue", linewidth=0.8)
	ax.plot(year, pt[1::3], label="January", color="red", linewidth=0.8)
	ax.plot(year, pt[2::3], label="February", color="green", linewidth=0.8)
	ax.plot(year,   ptmean, label="DJF Mean", color="black", linewidth=1.5)
	#pltformat(fig, ax, "Potential Temperature at the Center of ETD Circulation in Boreal Winter", "Potential Temperature")
	pltformat(fig, ax, "", r"Potential Temperature ($\mathrm{K}$)")
	#fig.savefig("./center_of_boreal_ETD/monthly_{}_{}_potentialTemperature.png".format(year_ini, year_fin), dpi=350)
	fname = "./timeseries/monthly_{}_{}_potentialTemperature_{}.png".format(year_ini, year_fin, searchtype)
	fig.savefig(fname, dpi=350)
	print(fname)


def plotSt_monthly(st, stmean, searchtype):
	fig = plt.figure(figsize=[10,6])
	ax = fig.add_subplot(111)
	ax.plot(year, st[0::3], label="December", color="blue", linewidth=0.8)
	ax.plot(year, st[1::3], label="January", color="red", linewidth=0.8)
	ax.plot(year, st[2::3], label="February", color="green", linewidth=0.8)
	ax.plot(year,   stmean, label="DJF Mean", color="black", linewidth=1.5)
	#pltformat(fig, ax, "Mass Streamfunction at the Center of ETD Circulation in Boreal Winter", "Mass Streamfunction")
	pltformat(fig, ax, "", r"Mass Streamfunction ($\mathrm{kg \; s^{-1}}$)")
	#fig.savefig("./center_of_boreal_ETD/monthly_{}_{}_streamFunction.png".format(year_ini, year_fin), dpi=350)
	fname = "./timeseries/monthly_{}_{}_streamFunction_{}.png".format(year_ini, year_fin, searchtype)
	fig.savefig(fname, dpi=350)
	print(fname)


def plotPrs_djf(p, searchtype):
	fig = plt.figure(figsize=[8,6])
	ax = fig.add_subplot(111)
	ax.invert_yaxis()
	ax.plot(year, p, label="DJF Mean", color="blue")
	#pltformat(fig, ax, "Pressure at the Center of ETD Circulation in Boreal Winter", "Pressure")
	pltformat(fig, ax, '', r"Pressure ($\mathrm{hPa}$)")
	#fig.savefig("./center_of_boreal_ETD/DJF_{}_{}_pressure.png".format(year_ini, year_fin), dpi=350)
	fname = "./timeseries/DJF_{}_{}_pressure_{}.png".format(year_ini, year_fin, searchtype)
	fig.savefig(fname, dpi=350)
	print(fname)


def plotLat_djf(lat, searchtype):
	fig = plt.figure(figsize=[8,6])
	ax = fig.add_subplot(111)
	ax.plot(year, lat, label="DJF Mean", color="blue")
	#pltformat(fig, ax, "Latitude at the Center of ETD Circulation in Boreal Winter", "Latitude")
	pltformat(fig, ax, '', "Latitude")
	#fig.savefig("./center_of_boreal_ETD/DJF_{}_{}_latitude.png".format(year_ini, year_fin), dpi=350)
	fname = "./timeseries/DJF_{}_{}_latitude_{}.png".format(year_ini, year_fin, searchtype)
	fig.savefig(fname, dpi=350)
	print(fname)


def plotPt_djf(pt, searchtype):
	fig = plt.figure(figsize=[8,6])
	ax = fig.add_subplot(111)
	ax.plot(year, pt, label="DJF Mean", color="blue")
	#pltformat(fig, ax, "Potential Temperature at the Center of ETD Circulation in Boreal Winter", "Potential Temperature")
	pltformat(fig, ax, '', r"Potential Temperature ($\mathrm{K}$)")
	#fig.savefig("./center_of_boreal_ETD/DJF_{}_{}_potentialTemperature.png".format(year_ini, year_fin), dpi=350)
	fname = "./timeseries/DJF_{}_{}_potentialTemperature_{}.png".format(year_ini, year_fin, searchtype)
	fig.savefig(fname, dpi=350)
	print(fname)


def plotSt_djf(st, searchtype):
	fig = plt.figure(figsize=[8,6])
	ax = fig.add_subplot(111)
	ax.plot(year, st, label="DJF Mean", color="blue")
	#pltformat(fig, ax, "Mass Streamfunction at the Center of ETD Circulation in Boreal Winter", "Mass Streamfunction")
	pltformat(fig, ax, '', r"Mass Streamfunction ($\mathrm{kg \; s^{-1}}$)")
	#fig.savefig("./center_of_boreal_ETD/DJF_{}_{}_streamFunction.png".format(year_ini, year_fin), dpi=350)
	fname = "./timeseries/DJF_{}_{}_streamFunction_{}.png".format(year_ini, year_fin, searchtype)
	fig.savefig(fname, dpi=350)
	print(fname)


def pltformat(fig, ax, ylabel, title):
	#ax.xaxis.set_major_locator(mdates.YearLocator(base=5, month=1))
	#ax.xaxis.set_minor_locator(mdates.YearLocator(base=1, month=1))
	#ax.xaxis.set_major_formatter(mdates.DateFormatter("%Y%b"))

	ax.set_xlim(year_ini+1, year_fin)

	ax.yaxis.set_major_formatter(mticker.ScalarFormatter(useMathText=True))
	ax.ticklabel_format(style='sci', axis='y')
	ax.minorticks_on()
	ax.tick_params(which='major', axis='both', labelsize=14)
	ax.tick_params(which='minor', axis='both')

	if (title != ''):
		ax.set_title(title, fontsize=17)

	if (ylabel != ''):
		ax.set_ylabel(ylabel, fontsize=17)

	ax.legend(loc="upper right", fontsize=15)
	ax.grid(which='major', linewidth=1.)
	ax.grid(which='minor', linewidth=0.3)


def movave(var, n):
	operator = np.ones(n) / n
	result = np.convolve(var, operator, mode='valid')
	#result = var[avedini:avedfin]
	return result


def mkgrph(fname_shorter, fname_monthly, fname_DJF, searchtype):

    shorter = np.loadtxt(fname_shorter, dtype='str')
    monthly = np.loadtxt(fname_monthly, dtype='str')
    djf = np.loadtxt(fname_DJF, dtype='str')

    #start_shorter_work = np.array(shorter[:,3], dtype='str')
    #end_shorter_work   = np.array(shorter[:,5], dtype='str')
    #start_shorter = [0]*start_shorter_work.size
    #end_shorter   = [0]*end_shorter_work.size
    #for ii in range(start_shorter_work.size):
    #    start_shorter[ii] = datetime.datetime.strptime(start_shorter_work[ii], '%Y/%m/%d')
    #    end_shorter[ii]   = datetime.datetime.strptime(  end_shorter_work[ii], '%Y/%m/%d')
    #del start_shorter_work
    #del end_shorter_work
    start_shorter = np.array(shorter[:,3], dtype='str')
    end_shorter   = np.array(shorter[:,5], dtype='str')
    lat_shorter   = np.array(shorter[:,7], dtype='float64')
    pres_shorter  = np.array(shorter[:,8], dtype='float64')
    st_shorter    = np.array(shorter[:,9], dtype='float64')
    pt_shorter    = np.array(shorter[:,10], dtype='float64')
    #print(start_shorter)
    #print(end_shorter)

    lat_monthly = np.array(monthly[:,7], dtype='float64')
    pres_monthly = np.array(monthly[:,8], dtype='float64')
    st_monthly = np.array(monthly[:,9], dtype='float64')
    pt_monthly = np.array(monthly[:,10], dtype='float64')

    lat_djf = np.array(djf[:,7], dtype='float64')
    pres_djf = np.array(djf[:,8], dtype='float64')
    st_djf = np.array(djf[:,9], dtype='float64')
    pt_djf = np.array(djf[:,10], dtype='float64')

    plotLat_monthly(lat_monthly, lat_djf, searchtype)
    plotPrs_monthly(pres_monthly, pres_djf, searchtype)
    plotSt_monthly(st_monthly, st_djf, searchtype)
    plotPt_monthly(pt_monthly, pt_djf, searchtype)

    plotLat_djf(lat_djf, searchtype)
    plotPrs_djf(pres_djf, searchtype)
    plotSt_djf(st_djf, searchtype)
    plotPt_djf(pt_djf, searchtype)

mkgrph('maxst_halfmonthly_default.dat', 'maxst_monthly_default.dat', 'maxst_DJF_default.dat', 'default')
mkgrph('maxst_halfmonthly_interp.dat' , 'maxst_monthly_interp.dat' , 'maxst_DJF_interp.dat' ,  'interp')

