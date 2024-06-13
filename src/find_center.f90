module find_center

    use globals, only : kp, rec_step, st_rec, pt_rec, epy_rec, epz_form_rec, epz_uv_rec, epz_uw_rec, epz_rec, &
                      & ny, nz, p, lat, &
                      & year_ini, month_ini, day_ini, hour_ini, year_fin, finfo, datetime 
    use fileio, only : file_set, file_open, file_close, fwrite
    use update, only : datetime_update_hourly, set_datetime, check_datetime
    use tmean, only : dailyMean, halfMonthlyMean, monthlyMean, DJFMean
    !use interp, only : interp_p, interp_lat
    use interp, only : interp_surface, interp_linear_1dim
    use search_max, only : max_index

    implicit none

    type center_info
        real(kp) :: latitude
        real(kp) :: pressure
        real(kp) :: st
        real(kp) :: pt
    end type center_info

    private
    public :: Tmean_ETD_center

    contains


    subroutine Tmean_ETD_center(output_fname_default, output_fname_interp, output_fname_field, &
                              & input_fname, latrange_min, prange_max, timescale)
        character(*), intent(in) :: output_fname_default
        character(*), intent(in) :: output_fname_interp
        character(*), intent(in) :: output_fname_field
        character(*), intent(in) :: input_fname
        real(kp), intent(in) :: latrange_min
        real(kp), intent(in) :: prange_max
        character(*), intent(in) :: timescale
        real(kp) :: st(ny,nz)
        real(kp) :: pt(ny,nz)
        real(kp) :: epy(ny,nz)
        real(kp) :: epz_form(ny,nz)
        real(kp) :: epz_uv(ny,nz)
        real(kp) :: epz_uw(ny,nz)
        real(kp) :: epz(ny,nz)

        type(center_info) :: center_default
        type(center_info) :: center_interp

        integer :: index_lat
        integer :: index_pres
        
        integer, parameter :: ny_f = 3
        integer, parameter :: nz_f = 4

        integer, parameter :: ny_interped = 41
        integer, parameter :: nz_interped = 61

        integer :: year
        integer :: month
        integer :: monthly_counter
        integer            :: year_lst(3)
        integer, parameter :: month_lst(3) = [12, 1, 2]

        integer, save :: output_default = 1000
        integer, save :: output_interp = 2000

        type(datetime) :: present_st
        type(datetime) :: present_pt
        type(datetime) :: present_epy
        type(datetime) :: present_epz_form
        type(datetime) :: present_epz_uv
        type(datetime) :: present_epz_uw
        type(datetime) :: present_epz

        type(finfo) :: st_file
        type(finfo) :: pt_file
        type(finfo) :: epy_file
        type(finfo) :: epz_form_file
        type(finfo) :: epz_uv_file
        type(finfo) :: epz_uw_file
        type(finfo) :: epz_file
        type(finfo) :: tmean_file
        !integer, save :: st_unit = 100
        !integer, save :: pt_unit = 101
        !integer, save :: tmean_unit = 102

        character(128) :: fname_interped_field_st
        character(128) :: fname_interped_field_pt
        character(32)  :: period


        call file_set(st_file      ,        input_fname,  'read', kp*ny*nz, st_rec      )
        call file_set(pt_file      ,        input_fname,  'read', kp*ny*nz, pt_rec      )
        call file_set(epy_file     ,        input_fname,  'read', kp*ny*nz, epy_rec     )
        call file_set(epz_form_file,        input_fname,  'read', kp*ny*nz, epz_form_rec)
        call file_set(epz_uv_file  ,        input_fname,  'read', kp*ny*nz, epz_uv_rec  )
        call file_set(epz_uw_file  ,        input_fname,  'read', kp*ny*nz, epz_uw_rec  )
        call file_set(epz_file     ,        input_fname,  'read', kp*ny*nz, epz_rec     )
        call file_set(tmean_file   , output_fname_field, 'write', kp*ny*nz, 1           )

        call file_open(st_file      )
        call file_open(pt_file      )
        call file_open(epy_file     )
        call file_open(epz_form_file)
        call file_open(epz_uv_file  )
        call file_open(epz_uw_file  )
        call file_open(epz_file     )
        call file_open(tmean_file   )

        call set_datetime(present_st      , year_ini, month_ini, day_ini, hour_ini)
        call set_datetime(present_pt      , year_ini, month_ini, day_ini, hour_ini)
        call set_datetime(present_epy     , year_ini, month_ini, day_ini, hour_ini)
        call set_datetime(present_epz_form, year_ini, month_ini, day_ini, hour_ini)
        call set_datetime(present_epz_uv  , year_ini, month_ini, day_ini, hour_ini)
        call set_datetime(present_epz_uw  , year_ini, month_ini, day_ini, hour_ini)
        call set_datetime(present_epz     , year_ini, month_ini, day_ini, hour_ini)

        open(newunit=output_default, file=output_fname_default, action='write')
        open(newunit=output_interp , file=output_fname_interp , action='write')


        if (timescale == 'daily') then

            do year = year_ini, year_fin-1

                !year_lst(1:3) = [year, year+1, year+1]

                !call set_datetime(present_st    , &  !! OUT
                !                & year          , &  !! IN
                !                & 12            , &  !! IN
                !                & present_st%day, &  !! IN
                !                & present_st%hour )  !! IN
                !call set_datetime(present_pt    , &  !! OUT
                !                & year          , &  !! IN
                !                & 12            , &  !! IN
                !                & present_pt%day, &  !! IN
                !                & present_pt%hour )  !! IN

                call datetime_reset()

                do while(present_st%month /= 3)
               
                    fname_interped_field_st = ''
                    fname_interped_field_pt = ''

                    write(*,'(a)',advance='no') 'Daily Mean : '
                    call write_datetime(present_st, 6)

                    write(output_default,'(a)',advance='no') 'Daily Mean : '
                    write(output_interp ,'(a)',advance='no') 'Daily Mean : '
                    call write_datetime(present_st, output_default)
                    call write_datetime(present_st, output_interp )

                    call dailyMean(st_file      , present_st      , st(1:ny,1:nz)      , rec_step)
                    !call dailyMean(pt_file      , present_pt      , pt(1:ny,1:nz)      , rec_step)
                    !call dailyMean(epy_file     , present_epy     , epy(1:ny,1:nz)     , rec_step)
                    !call dailyMean(epz_form_file, present_epz_form, epz_form(1:ny,1:nz), rec_step)
                    !call dailyMean(epz_uv_file  , present_epz_uv  , epz_uv(1:ny,1:nz)  , rec_step)
                    call dailyMean(epz_uw_file  , present_epz_uw  , epz_uw(1:ny,1:nz)  , rec_step)
                    call dailyMean(epz_file     , present_epz     , epz(1:ny,1:nz)     , rec_step)
                    epz_uw(1:ny,1:nz) = epz_uw(1:ny,1:nz) + epz_uv(1:ny,1:nz)

                    call subprocess(.False.)
                enddo

            enddo

        else if (timescale == 'halfmonthly') then

            do year = year_ini, year_fin-1

                year_lst(1:3) = [year, year+1, year+1]

                !call set_datetime(present_st    , &  !! OUT
                !                & year          , &  !! IN
                !                & 12            , &  !! IN
                !                & present_st%day, &  !! IN
                !                & present_st%hour )  !! IN
                !call set_datetime(present_pt    , &  !! OUT
                !                & year          , &  !! IN
                !                & 12            , &  !! IN
                !                & present_st%day, &  !! IN
                !                & present_pt%hour )  !! IN

                call datetime_reset()

                do month = 1, 3
                    do monthly_counter = 1, 2
                        fname_interped_field_st = '../interp_result/data/' // trim(timescale)
                        write(period,'(i0.4,"_",i0.2,"_",i1)') year_lst(month), month_lst(month), monthly_counter
                        fname_interped_field_st = trim(fname_interped_field_st) // '_' // trim(period)
                        fname_interped_field_pt = trim(fname_interped_field_st)
                        fname_interped_field_st = trim(fname_interped_field_st) // '_st.dat'
                        fname_interped_field_pt = trim(fname_interped_field_pt) // '_pt.dat'

                        write(*,'(a)',advance='no') 'HalfMonthly Mean : '
                        call write_datetime(present_st, 6)

                        write(output_default,'(a)',advance='no') 'HalfMonthly Mean : '
                        write(output_interp ,'(a)',advance='no') 'HalfMonthly Mean : '
                        call write_datetime(present_st, output_default)
                        call write_datetime(present_st, output_interp )

                        call halfMonthlyMean(st_file      , present_st      , st(1:ny,1:nz)      , rec_step)
                        call halfMonthlyMean(pt_file      , present_pt      , pt(1:ny,1:nz)      , rec_step)
                        call halfMonthlyMean(epy_file     , present_epy     , epy(1:ny,1:nz)     , rec_step)
                        call halfMonthlyMean(epz_form_file, present_epz_form, epz_form(1:ny,1:nz), rec_step)
                        call halfMonthlyMean(epz_uv_file  , present_epz_uv  , epz_uv(1:ny,1:nz)  , rec_step)
                        call halfMonthlyMean(epz_uw_file  , present_epz_uw  , epz_uw(1:ny,1:nz)  , rec_step)
                        call halfMonthlyMean(epz_file     , present_epz     , epz(1:ny,1:nz)     , rec_step)
                        epz_uw(1:ny,1:nz) = epz_uw(1:ny,1:nz) + epz_uv(1:ny,1:nz)

                        call subprocess(.True.)
                    enddo
                enddo

                do while(present_st%month /= 3)
                    call datetime_update_hourly(present_st)
                    call datetime_update_hourly(present_pt)
                    call datetime_update_hourly(present_epy)
                    call datetime_update_hourly(present_epz_form)
                    call datetime_update_hourly(present_epz_uv)
                    call datetime_update_hourly(present_epz_uw)
                    call datetime_update_hourly(present_epz)
                    st_file%record = st_file%record + rec_step
                    pt_file%record = pt_file%record + rec_step
                    epy_file%record = epy_file%record + rec_step
                    epz_form_file%record = epz_form_file%record + rec_step
                    epz_uv_file%record = epz_uv_file%record + rec_step
                    epz_uw_file%record = epz_uw_file%record + rec_step
                    epz_file%record = epz_file%record + rec_step
                enddo

            enddo

        else if (timescale == 'monthly') then

            do year = year_ini, year_fin-1

                !call set_datetime(present_st, year, 12, present_st%day, present_st%hour)
                !call set_datetime(present_pt, year, 12, present_pt%day, present_pt%hour)

                call datetime_reset()

                do month = 1, 3

                    fname_interped_field_st = '../interp_result/data/' // trim(timescale)
                    write(period,'(i0.4,a,i0.2)') present_st%year, '_', month_lst(month)
                    fname_interped_field_st = trim(fname_interped_field_st) // '_' // trim(period)
                    fname_interped_field_pt = trim(fname_interped_field_st)
                    fname_interped_field_st = trim(fname_interped_field_st) // '_st.dat'
                    fname_interped_field_pt = trim(fname_interped_field_pt) // '_pt.dat'

                    ! Standard output datetime information
                    write(*,'(a)',advance='no') 'Monthly Mean : '
                    call write_datetime(present_st, 6)

                    ! File output datetime information
                    write(output_default,'(a)',advance='no') 'Monthly Mean : '
                    write(output_interp, '(a)',advance='no') 'Monthly Mean : '
                    call write_datetime(present_st, output_default)
                    call write_datetime(present_st, output_interp)

                    call monthlyMean(st_file      , present_st      , st(1:ny,1:nz)      , rec_step)
                    call monthlyMean(pt_file      , present_pt      , pt(1:ny,1:nz)      , rec_step)
                    call monthlyMean(epy_file     , present_epy     , epy(1:ny,1:nz)     , rec_step)
                    call monthlyMean(epz_form_file, present_epz_form, epz_form(1:ny,1:nz), rec_step)
                    call monthlyMean(epz_uv_file  , present_epz_uv  , epz_uv(1:ny,1:nz)  , rec_step)
                    call monthlyMean(epz_uw_file  , present_epz_uw  , epz_uw(1:ny,1:nz)  , rec_step)
                    call monthlyMean(epz_file     , present_epz     , epz(1:ny,1:nz)     , rec_step)
                    epz_uw(1:ny,1:nz) = epz_uw(1:ny,1:nz) + epz_uv(1:ny,1:nz)

                    call subprocess(.True.)

                enddo

            enddo

        else if (timescale == 'DJF') then

            do year = year_ini, year_fin-1

                !call set_datetime(present_st, year, 12, present_st%day, present_st%hour)
                !call set_datetime(present_pt, year, 12, present_pt%day, present_pt%hour)

                call datetime_reset()

                fname_interped_field_st = '../interp_result/data/' // trim(timescale)
                write(period,'(i0.4)') present_st%year+1
                fname_interped_field_st = trim(fname_interped_field_st) // '_' // trim(period)
                fname_interped_field_pt = trim(fname_interped_field_st)
                fname_interped_field_st = trim(fname_interped_field_st) // '_st.dat'
                fname_interped_field_pt = trim(fname_interped_field_pt) // '_pt.dat'

                ! Standard output datetime information
                write(*,'(a)',advance='no') 'DJF Mean : '
                call write_datetime(present_st, 6)

                ! File output datetime information
                write(output_default,'(a)',advance='no') 'DJF Mean : '
                write(output_interp, '(a)',advance='no') 'DJF Mean : '
                call write_datetime(present_st, output_default)
                call write_datetime(present_st, output_interp)

                call DJFMean(st_file      , present_st      , st(1:ny,1:nz)      , rec_step)
                call DJFMean(pt_file      , present_pt      , pt(1:ny,1:nz)      , rec_step)
                call DJFMean(epy_file     , present_epy     , epy(1:ny,1:nz)     , rec_step)
                call DJFMean(epz_form_file, present_epz_form, epz_form(1:ny,1:nz), rec_step)
                call DJFMean(epz_uv_file  , present_epz_uv  , epz_uv(1:ny,1:nz)  , rec_step)
                call DJFMean(epz_uw_file  , present_epz_uw  , epz_uw(1:ny,1:nz)  , rec_step)
                epz_uw(1:ny,1:nz) = epz_uw(1:ny,1:nz) + epz_uv(1:ny,1:nz)
                call DJFMean(epz_file     , present_epz     , epz(1:ny,1:nz)     , rec_step)

                call subprocess(.True.)

            enddo

        else
            error stop 'Invalid timescale : timescale must be "monthly" or "DJF"'
        endif

        ! Close binary files and update unit numbers
        call file_close(st_file)
        call file_close(pt_file)
        call file_close(epy_file)
        call file_close(epz_form_file)
        call file_close(epz_uv_file)
        call file_close(epz_uw_file)
        call file_close(epz_file)
        call file_close(tmean_file)
        !st_unit = st_unit + 3
        !pt_unit = pt_unit + 3
        !tmean_unit = tmean_unit + 3

        close(output_default)
        close(output_interp)
        !output_default = output_default + 1
        !output_interp  = output_interp  + 1


        contains


        subroutine datetime_reset()
            
            call set_datetime(present_st      , year, 12, present_st%day      , present_st%hour      )
            call set_datetime(present_pt      , year, 12, present_pt%day      , present_pt%hour      )
            call set_datetime(present_epy     , year, 12, present_epy%day     , present_epy%hour     )
            call set_datetime(present_epz_form, year, 12, present_epz_form%day, present_epz_form%hour)
            call set_datetime(present_epz_uv  , year, 12, present_epz_uv%day  , present_epz_uv%hour  )
            call set_datetime(present_epz_uw  , year, 12, present_epz_uw%day  , present_epz_uw%hour  )
            call set_datetime(present_epz     , year, 12, present_epz%day     , present_epz%hour     )

        end subroutine datetime_reset


        subroutine subprocess(field_out)
            logical, intent(in) :: field_out

            call fwrite(tmean_file, st(1:ny,1:nz))
            call fwrite(tmean_file, pt(1:ny,1:nz))

            call get_interped_center(present_st             , &
                                   & present_pt             , &
                                   & ny_interped            , &  !! IN
                                   & nz_interped            , &  !! IN
                                   & st(1:ny,1:nz)          , &  !! IN
                                   & pt(1:ny,1:nz)          , &  !! IN
                                   & latrange_min           , &  !! IN
                                   & prange_max             , &  !! IN
                                   & center_default         , &  !! OUT
                                   & center_interp          , &  !! OUT
                                   & fname_interped_field_st, &  !! IN
                                   & fname_interped_field_pt, &  !! IN
                                   & field_out                )  !! IN

            ! Standard output datetime information
            call write_datetime(present_st, 6)
            write(*,*)

            ! File output datetime information
            call write_datetime(present_st, output_default)
            call write_datetime(present_st, output_interp)

            write(output_default,'(f13.6,f13.3,es20.7,f13.3)') center_default%latitude, &
                                                                          & center_default%pressure, &
                                                                          & center_default%st, &
                                                                          & center_default%pt

            write(output_interp,'(f13.6,f13.3,es20.7,f13.3)')  center_interp%latitude, &
                                                                          & center_interp%pressure, &
                                                                          & center_interp%st, &
                                                                          & center_interp%pt

            !write(output_default,'(2(2x,a,:,","))') trim(fname_interped_field_st), trim(fname_interped_field_pt)
            !write(output_interp ,'(2(2x,a,:,","))') trim(fname_interped_field_st), trim(fname_interped_field_pt)

        end subroutine subprocess

    
    end subroutine Tmean_ETD_center
                

    subroutine get_interped_center(present_st, present_pt, &
                                 & ny_interped, nz_interped, st, pt, &
                                 & latrange_min, prange_max, &
                                 & center_default, center_interp, &
                                 & fname_interped_field_st, fname_interped_field_pt, &
                                 & field_out)
        type(datetime), intent(in) :: present_st
        type(datetime), intent(in) :: present_pt
        integer, intent(in) :: ny_interped
        integer, intent(in) :: nz_interped
        real(kp), intent(in) :: st(ny,nz)
        real(kp), intent(in) :: pt(ny,nz)
        real(kp), intent(in) :: latrange_min
        real(kp), intent(in) :: prange_max
        type(center_info), intent(out) :: center_default
        type(center_info), intent(out) :: center_interp
        character(*), intent(in) :: fname_interped_field_st
        character(*), intent(in) :: fname_interped_field_pt
        logical, intent(in) :: field_out

        integer :: index_lat
        integer :: index_p

        integer, parameter :: ny_f = 3
        integer, parameter :: nz_f = 4
        real(kp) :: lat_focused(ny_f)
        real(kp) :: pres_focused(nz_f)
        real(kp) :: st_focused(ny_f,nz_f)
        real(kp) :: pt_focused(ny_f,nz_f)

        real(kp) :: lat_interped(ny_interped)
        real(kp) :: pres_interped(nz_interped)
        real(kp) :: st_interped(ny_interped,nz_interped)
        real(kp) :: pt_interped(ny_interped,nz_interped)

        ! real(kp) :: temporary_st(ny_f,nz_interped)
        ! real(kp) :: temporary_pt(ny_f,nz_interped)

        integer :: unit_st
        integer :: unit_pt
        integer :: outcounter

        character(32), parameter :: fmt = '(1000es20.7)'

        call max_index(ny, nz, st(1:ny,1:nz), lat(1:ny), p(1:nz), latrange_min, prange_max, index_lat, index_p)

        center_default%latitude = lat(index_lat)
        center_default%pressure = p(index_p)
        center_default%st       = st(index_lat,index_p)
        center_default%pt       = pt(index_lat,index_p)

        lat_focused(1:ny_f) = lat(index_lat-1:index_lat+1)

        ! Choose grids
        if (st(index_lat,index_p-1) >= st(index_lat,index_p+1)) then
            pres_focused(1:nz_f) = p(index_p-2:index_p+1)
            st_focused(1:ny_f,1:nz_f) = st(index_lat-1:index_lat+1,index_p-2:index_p+1)
            pt_focused(1:ny_f,1:nz_f) = pt(index_lat-1:index_lat+1,index_p-2:index_p+1)

        else if (st(index_lat,index_p-1) < st(index_lat,index_p+1)) then
            pres_focused(1:nz_f) = p(index_p-1:index_p+2)
            st_focused(1:ny_f,1:nz_f) = st(index_lat-1:index_lat+1,index_p-1:index_p+2)
            pt_focused(1:ny_f,1:nz_f) = pt(index_lat-1:index_lat+1,index_p-1:index_p+2)

        else
            write(*,*) 'Unexpected Streamfunction'
            write(*,*) 'Streamfunction may be NaN'
            error stop
        endif

        call interp_linear_1dim(ny_f                      , &  !! IN
                              & lat_focused(1:ny_f)       , &  !! IN
                              & ny_interped               , &  !! IN
                              & lat_interped(1:ny_interped) )  !! OUT

        call interp_linear_1dim(nz_f                      , &  !! IN
                              & pres_focused(1:nz_f)      , &  !! IN
                              & nz_interped               , &  !! IN
                              & pres_interped(1:nz_interped))  !! OUT

        call interp_surface(present_st                            , &  !! IN
                          & ny_f                                  , &  !! IN 
                          & nz_f                                  , &  !! IN
                          & lat_focused(1:ny_f)                   , &  !! IN
                          & pres_focused(1:nz_f)                  , &  !! IN
                          & st_focused(1:ny_f,1:nz_f)             , &  !! IN
                          & ny_interped                           , &  !! IN
                          & nz_interped                           , &  !! IN
                          & lat_interped(1:ny_interped)           , &  !! IN
                          & pres_interped(1:nz_interped)          , &  !! IN
                          & st_interped(1:ny_interped,1:nz_interped))  !! OUT

        call interp_surface(present_pt                            , &  !! IN
                          & ny_f                                  , &  !! IN 
                          & nz_f                                  , &  !! IN
                          & lat_focused(1:ny_f)                   , &  !! IN
                          & pres_focused(1:nz_f)                  , &  !! IN
                          & pt_focused(1:ny_f,1:nz_f)             , &  !! IN
                          & ny_interped                           , &  !! IN
                          & nz_interped                           , &  !! IN
                          & lat_interped(1:ny_interped)           , &  !! IN
                          & pres_interped(1:nz_interped)          , &  !! IN
                          & pt_interped(1:ny_interped,1:nz_interped))  !! OUT

        !! Interpolate Streamfunction in vertical direction
        !call interp_p(pres_focused(1:nz_f), ny_f, st_focused(1:ny_f,1:nz_f), &
        !                & nz_interped, temporary_st(1:ny_f,1:nz_interped), pres_interped(1:nz_interped))
        !! Interpolate Potential Temperature in vertical direction
        !call interp_p(pres_focused(1:nz_f), ny_f, pt_focused(1:ny_f,1:nz_f), &
        !                & nz_interped, temporary_pt(1:ny_f,1:nz_interped), pres_interped(1:nz_interped))

        !! Interpolate Streamfunction in latitudinal direction
        !call interp_lat(lat_focused(1:ny_f), nz_interped, temporary_st(1:ny_f,1:nz_interped), &
        !                & ny_interped, st_interped(1:ny_interped,1:nz_interped), lat_interped(1:ny_interped))
        !! Interpolate Potential Temperature in latitudinal direction
        !call interp_lat(lat_focused(1:ny_f), nz_interped, temporary_pt(1:ny_f,1:nz_interped), &
        !                & ny_interped, pt_interped(1:ny_interped,1:nz_interped), lat_interped(1:ny_interped))

        ! Search max st from interpolated field
        call max_index(ny_interped, nz_interped, st_interped(1:ny_interped,1:nz_interped), &
                        &  lat_interped(1:ny_interped), pres_interped(1:nz_interped), lat(1), p(1), &
                        &  index_lat, index_p)

        center_interp%latitude = lat_interped(index_lat)
        center_interp%pressure = pres_interped(index_p)
        center_interp%st       = st_interped(index_lat,index_p)
        center_interp%pt       = pt_interped(index_lat,index_p)

        if (field_out) then
            OPEN(NEWUNIT=unit_st, &
               & FILE=fname_interped_field_st, &
               & ACTION='write')

            OPEN(NEWUNIT=unit_pt, &
               & FILE=fname_interped_field_pt, &
               & ACTION='write')

            write(unit_st,fmt) 0, lat_interped(1:ny_interped)
            write(unit_pt,fmt) 0, lat_interped(1:ny_interped)
            do outcounter = 1, nz_interped
                write(unit_st,fmt) pres_interped(outcounter), st_interped(1:ny_interped,outcounter)
                write(unit_pt,fmt) pres_interped(outcounter), pt_interped(1:ny_interped,outcounter)
            enddo

            CLOSE(unit_st)
            CLOSE(unit_pt)
        endif

    end subroutine get_interped_center


    subroutine write_datetime(present_datetime, unit)
        type(datetime), intent(in) :: present_datetime
        integer, intent(in) :: unit

        write(unit,'(i0.4,a,i0.2,a,i0.2,a,i0.2,a)',advance='no') &
                    & present_datetime%year, '/', present_datetime%month, '/', present_datetime%day, ' ', &
                    & present_datetime%hour, ':00:00  '

    end subroutine write_datetime


end module find_center

