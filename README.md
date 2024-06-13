# get_ETD_center

This program is to find the center of the ETD circulation in boreal winter.

## Options
Options are setted in main.f90 in the arguments of Tmean_ETD_center().  
The first argument is the output file.  
Here are the arguments:
1. Output file name. Data was not interpolated when searching the center of the ETD circulation
2. Output file name. Data was interpolated in p-direction by a cubic function first, then in lat-direction by a quadratic function.
3. Output file name. MIM-field averaged by time. the first variable is mass streamfunction and the second is potential temperature.
4. Input file name.
5. Threshold of latitude.
6. Threshold of pressure.
7. Mean type. daily/halfmonthly/monthly/DJF
