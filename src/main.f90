program main
    
    use globals, only : kp, p, WARN_FILE
    use namelist, only : set_params
    use find_center, only : Tmean_ETD_center

    implicit none

    integer :: WARN_UNIT
    logical :: OPEN_STATUS

    call set_params()

    call Tmean_ETD_center('../output/JRA3Q/maxst_daily_default.dat'                             , &
                        & '../output/JRA3Q/maxst_daily_interp.dat'                              , &
                        & '../output/JRA3Q/daily_mean_field.grd'                                , &
                        & '/mnt/hail8/kosei/mim/JRA3Q/mymim35DJF/output/JRA3Q_1949_2022_DJF.grd', &
                        & 30._kp, p(1), 'daily')

    write(*,*)

    call Tmean_ETD_center('../output/JRA3Q/maxst_halfmonthly_default.dat'                       , &
                        & '../output/JRA3Q/maxst_halfmonthly_interp.dat'                        , &
                        & '../output/JRA3Q/halfmonthly_mean_field.grd'                          , &
                        & '/mnt/hail8/kosei/mim/JRA3Q/mymim35DJF/output/JRA3Q_1949_2022_DJF.grd', &
                        & 30._kp, p(1), 'halfmonthly')

    write(*,*)

    call Tmean_ETD_center('../output/JRA3Q/maxst_monthly_default.dat'                           , &
                        & '../output/JRA3Q/maxst_monthly_interp.dat'                            , &
                        & '../output/JRA3Q/monthly_mean_field.grd'                              , &
                        & '/mnt/hail8/kosei/mim/JRA3Q/mymim35DJF/output/JRA3Q_1949_2022_DJF.grd', &
                        & 30._kp, p(1), 'monthly')

    write(*,*)

    call Tmean_ETD_center('../output/JRA3Q/maxst_DJF_default.dat'                               , &
                        & '../output/JRA3Q/maxst_DJF_interp.dat'                                , &
                        & '../output/JRA3Q/DJF_mean_field.grd'                                  , &
                        & '/mnt/hail8/kosei/mim/JRA3Q/mymim35DJF/output/JRA3Q_1949_2022_DJF.grd', &
                        & 30._kp, p(1), 'DJF')

    INQUIRE(FILE=trim(WARN_FILE), &
          & OPENED=OPEN_STATUS  , &
          & NUMBER=WARN_UNIT      )
    if (OPEN_STATUS) then
        close(WARN_UNIT)
    endif
    
end program main

