'reinit'

rc = gsfallow("on")

*say Marker1
*rc = gsfpath('/mnt/hail7/kosei/GrADS')
*say Marker2

'open /mnt/hail7/kosei/mim/mymim_st/output/DJF_1959_2010.ctl'

'set grads off'
'set lat -90.0 90.0'
'set lev 1000 100'
'set zlog on'
'set xlopts 1 5 0.15'
'set ylopts 1 5 0.20'

yearini = 1959
yearfin = 2010
months.1 = 12
months.2 = 1
months.3 = 2
monthpadded.1 = '12'
monthpadded.2 = '01'
monthpadded.3 = '02'

dir = '/mnt/hail7/kosei/mim/st_analysis/output/fig/'
cmin = -2.1e+11
cmax =  2.1e+11
cint =  3.0e+10


y = yearini
tfirst = 1

while (y < yearfin)
    years.1 = y
    years.2 = y+1
    years.3 = y+1

    m = 1
    while (m <= 3)
        year = years.m
        month = months.m
        days = daynum(year, month)
        tnum = days * 4
        tlast = tfirst + tnum - 1
        say year' 'month' 'days' 'tfirst' 'tlast
        'sttm = ave(st, t='tfirst', t='tlast')'
*        'pttm = ave(pt, t='tfirst', t='tlast')'
    
        monthstr = monthname(month)

        'set display color white'
        'set grads off'

        'set gxout shaded'
        'color 'cmin' 'cmax' 'cint
        'display 'sttm
        'xcbar -edge triangle -foffset center -fskip 2'

        'set gxout contour'
        'set cmin 'cmin
        'set cmax 'cmax
        'set cint 'cint
        'set clab off'
        'set ccolor 1'
        'display 'sttm

        centerinfo = read('maxst_interp.dat')
        center = sublin(centerinfo, 2)
        centerp = subwrd(center, 9)
        centerlat = subwrd(center, 8)
        'q ll2xy 'centerlat' 'centerp
        centerlat = subwrd(result, 1)
        centerp = subwrd(result, 2)
        say centerlat' 'centerp
        say 'draw mark 3 'centerlat' 'centerp' 1'
        'set line 1'
        'draw mark 6 'centerlat' 'centerp' 0.3'


        'draw title 'year' 'monthstr' Mean Mass Streamfunction'
        'draw ylab Pressure'

        outname = dir'mimMonthly_'year''monthpadded.m'.png'
        say outname
        'gxprint 'outname
        'clear'

        say
        tfirst = tlast + 1
        m = m + 1
    endwhile

    y = y + 1

endwhile

