dset ^DJF_mean_field.grd
title Streamfunction and Potential Temperature

undef 9.999e+20

options little_endian

xdef 1 linear 1 1
ydef 145 linear -90.0 1.25
zdef 37 levels
1000, 975, 950, 925, 900, 875, 850, 825, 800, 775, 750, 700, 650, 600, 550, 500, 450, 400, 350, 300, 250, 225, 200, 175, 150, 125, 100, 70, 50, 30, 20, 10, 7, 5, 3, 2, 1
tdef 61 linear 00Z01DEC1959 1yr

VARS 2
st 37 99 Streamfunction
pt 37 99 Pote tial Temperature
ENDVARS

