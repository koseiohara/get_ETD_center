module namelist

    use globals, only : kp, ny, nz, step, lat, p, year_ini, month_ini, day_ini, hour_ini, year_fin
    use calendar, only : daynum

    implicit none

    private
    public :: set_params

    contains


    subroutine set_params()
        integer, parameter :: grid_unit = 10
        character(128), parameter :: grid_fname = '../nml/grid.nml'
        integer, parameter :: levels_unit = 11
        character(128), parameter :: levels_fname = '../nml/levels.nml'
        integer, parameter :: datetime_unit = 12
        character(128), parameter :: datetime_fname = '../nml/datetime.nml'
        integer :: is

        integer :: latitude_gridnum
        integer :: vertical_gridnum
        real(kp) :: horizontal_resolution

        real(kp), allocatable :: p_info(:)

        integer :: i

        namelist / grid / latitude_gridnum, vertical_gridnum, horizontal_resolution
        namelist / levels / p_info
        namelist / datetime / year_ini, month_ini, day_ini, hour_ini, year_fin

        latitude_gridnum = 0
        vertical_gridnum = 0
        horizontal_resolution = 0._kp
        year_ini = 0
        month_ini = 0
        day_ini = 0
        hour_ini = 0
        year_fin = 0

        open(grid_unit, file=grid_fname, action='read', iostat=is)
        if (is /= 0) then
            write(*,*) 'Failed to open ' // trim(grid_fname)
            error stop
        endif
        read(grid_unit,nml=grid)
        close(grid_unit)

        call check_grid(latitude_gridnum, vertical_gridnum, horizontal_resolution)

        ny = latitude_gridnum
        nz = vertical_gridnum
        step = horizontal_resolution

        allocate(p_info(nz), source=0._kp)

        open(levels_unit, file=levels_fname, action='read', iostat=is)
        if (is /= 0) then
            write(*,*) 'Failed to open ' // trim(levels_fname)
            error stop
        endif
        read(levels_unit, nml=levels)
        close(levels_unit)

        call check_levels(p_info)


        open(datetime_unit, file=datetime_fname, action='read', iostat=is)
        if (is /= 0) then
            write(*,*) 'Failed to open ' // trim(datetime_fname)
            error stop
        endif
        read(datetime_unit, nml=datetime)
        close(datetime_unit)

        call check_datetime(year_ini, month_ini, day_ini, hour_ini, year_fin)


        allocate(p(nz), source=p_info)
        allocate(lat(ny))
        lat(1:ny) = [(-90._kp + step*i, i=0, ny-1)]

        deallocate(p_info)

    end subroutine set_params

        
    subroutine check_grid(latitude_gridnum, vertical_gridnum, horizontal_resolution)
        integer, intent(in) :: latitude_gridnum
        integer, intent(in) :: vertical_gridnum
        real(kp), intent(in) :: horizontal_resolution

        if (latitude_gridnum <= 0) then
            error stop 'Invalid latitude_gridnum input from namelist'
        else if (latitude_gridnum > 1000) then
            write(*,*) 'WARNING : too large latitude_gridnum input from namelist'
        endif

        if (vertical_gridnum <= 0) then
            error stop 'Invalid vertical_gridnum input from namelist'
        else if (vertical_gridnum > 100) then
            write(*,*) 'WARNING : too large vertical_gridnum input from namelist'
        endif

        if (horizontal_resolution < 0) then
            error stop 'Invalid horizontal_resolution input from namelist'
        endif

    end subroutine check_grid


    subroutine check_levels(p_info)
        real(kp), intent(inout) :: p_info(nz)

        if (p_info(nz) < 0.01_kp) then
            write(*,*) 'Invalid p_info input from namelist'
            write(*,*) 'Number of p_info levels may not match vertical_gridnum'
            error stop
        endif

        if (p_info(1) < p_info(nz)) then
            p_info(1:nz) = p_info(nz:1:-1)
        endif

        if (p_info(1) > 1100._kp .or. p_info(1) < 800._kp) then
            error stop 'Invalid p_info : surface pressure is too large or small'
        endif

    end subroutine check_levels


    subroutine check_datetime(year_ini, month_ini, day_ini, hour_ini, year_fin)
        integer, intent(in) :: year_ini
        integer, intent(in) :: month_ini
        integer, intent(in) :: day_ini
        integer, intent(in) :: hour_ini
        integer, intent(in) :: year_fin
        integer :: days(12)

        call daynum(year_ini, days(1:12))

        if (year_ini < 1900 .or. year_ini > 2100) then
            error stop 'Invalid year_ini value input from namelist'
        endif

        if (month_ini < 1 .or. month_ini > 12) then
            error stop 'Invalid month_ini value input from namelist'
        endif

        if (day_ini < 1 .or. day_ini > days(month_ini)) then
            error stop 'Invalid day_ini value input from namelist'
        endif

        if (hour_ini < 0 .or. hour_ini > 24) then
            error stop 'Invalid hour_ini value input from namelist'
        endif

        if (year_fin < 1900 .or. year_fin > 2100) then
            error stop 'Invalid year_fin value input from namelist'
        endif

    end subroutine check_datetime


end module namelist

