import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import matplotlib.ticker as mticker
import datetime


year_ini = 1959
year_fin = 2020


def plotPrs_monthly(year, p, pmean, searchtype):
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


def plotLat_monthly(year, lat, latmean, searchtype):
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


def plotPt_monthly(year, pt, ptmean, searchtype):
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


def plotSt_monthly(year, st, stmean, searchtype):
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


def plotPrs_djf(year, p, searchtype):
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


def plotLat_djf(year, lat, searchtype):
	fig = plt.figure(figsize=[8,6])
	ax = fig.add_subplot(111)
	ax.plot(year, lat, label="DJF Mean", color="blue")
	#pltformat(fig, ax, "Latitude at the Center of ETD Circulation in Boreal Winter", "Latitude")
	pltformat(fig, ax, '', "Latitude")
	#fig.savefig("./center_of_boreal_ETD/DJF_{}_{}_latitude.png".format(year_ini, year_fin), dpi=350)
	fname = "./timeseries/DJF_{}_{}_latitude_{}.png".format(year_ini, year_fin, searchtype)
	fig.savefig(fname, dpi=350)
	print(fname)


def plotPt_djf(year, pt, searchtype):
	fig = plt.figure(figsize=[8,6])
	ax = fig.add_subplot(111)
	ax.plot(year, pt, label="DJF Mean", color="blue")
	#pltformat(fig, ax, "Potential Temperature at the Center of ETD Circulation in Boreal Winter", "Potential Temperature")
	pltformat(fig, ax, '', r"Potential Temperature ($\mathrm{K}$)")
	#fig.savefig("./center_of_boreal_ETD/DJF_{}_{}_potentialTemperature.png".format(year_ini, year_fin), dpi=350)
	fname = "./timeseries/DJF_{}_{}_potentialTemperature_{}.png".format(year_ini, year_fin, searchtype)
	fig.savefig(fname, dpi=350)
	print(fname)


def plotSt_djf(year, st, searchtype):
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


def mkgrph(fname_monthly, fname_DJF, searchtype):

    monthly = np.loadtxt(fname_monthly, dtype='str')
    djf = np.loadtxt(fname_DJF, dtype='str')

    year = np.arange(year_ini+1, year_fin+1, 1)

    lat_monthly = np.array(monthly[:,7], dtype='float64')
    pres_monthly = np.array(monthly[:,8], dtype='float64')
    st_monthly = np.array(monthly[:,9], dtype='float64')
    pt_monthly = np.array(monthly[:,10], dtype='float64')

    lat_djf = np.array(djf[:,7], dtype='float64')
    pres_djf = np.array(djf[:,8], dtype='float64')
    st_djf = np.array(djf[:,9], dtype='float64')
    pt_djf = np.array(djf[:,10], dtype='float64')

    plotLat_monthly(year, lat_monthly, lat_djf, searchtype)
    plotPrs_monthly(year, pres_monthly, pres_djf, searchtype)
    plotSt_monthly(year, st_monthly, st_djf, searchtype)
    plotPt_monthly(year, pt_monthly, pt_djf, searchtype)

    plotLat_djf(year, lat_djf, searchtype)
    plotPrs_djf(year, pres_djf, searchtype)
    plotSt_djf(year, st_djf, searchtype)
    plotPt_djf(year, pt_djf, searchtype)

mkgrph('maxst_monthly_default.dat', 'maxst_DJF_default.dat', 'default')
mkgrph('maxst_monthly_interp.dat' , 'maxst_DJF_interp.dat' ,  'interp')

