'reinit'

'open interped_field_monthly.ctl'
'open interped_field_DJF.ctl'

tmonthly = 1
tDJF = 1
tfin = 153
y = 1959
month.1 = '12'
month.2 = '01'
month.3 = '02'
while (y < 2010)
    year.1 = y
    year.2 = y+1
    year.3 = y+1
    m = 1
    while (m <= 3)

        'set xlab off'
        'set ylab off'
        fname = 'fig/monthly_'year.m'_'month.m'.png'
        'set t 'tmonthly
        'set clab forced'
        'd st.1'
        'd pt.1'

        centerinfo = read('../output/maxst_monthly_interp.dat')
        center = sublin(centerinfo, 2)
        centerp = subwrd(center, 9)
        centerlat = subwrd(center, 8)
        'q ll2xy 'centerlat' 'centerp
        centerlat = subwrd(result, 1)
        canterp = subwrd(result, 2)
        'set line 1'
        'draw mark 6 'centerlat' 'centerp' 0.3'

        'gxprint 'fname

        'clear'
*        'd st.2'
*        'd pt.2'
*        'gxprint 't'_focus.png'
*        'gxprint 't'.png'
*        'clear'
        say 't = 'tmonthly', 'fname
        tmonthly = tmonthly + 1
        m = m + 1
    endwhile
    y = y + 1

    'set xlab off'
    'set ylab off'
    fname = 'fig/DJF_'y'.png'
    'set t 'tDJF
    'set clab forced'
    'd st.2'
    'd pt.2'

    centerinfo = read('../output/maxst_DJF_interp.dat')
    center = sublin(centerinfo, 2)
    centerp = subwrd(center, 9)
    centerlat = subwrd(center, 8)
    'q ll2xy 'centerlat' 'centerp
    centerlat = subwrd(result, 1)
    canterp = subwrd(result, 2)
    'set line 1'
    'draw mark 6 'centerlat' 'centerp' 0.3'

    'gxprint 'fname

    'clear'
    say 't = 'tDJF', 'fname

    tDJF = tDJF + 1

endwhile

