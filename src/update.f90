module update

    use globals, only : hstep, datetime
    use calendar, only : daynum

    implicit none

    private
    public :: datetime_update_hourly, set_datetime, check_datetime

    contains


    ! Update datetime data for hourly data
    subroutine datetime_update_hourly(dt)
        type(datetime), intent(inout) :: dt
        integer :: carry
        integer :: daynumList(12)

        call daynum(dt%year, daynumList)

        dt%hour = dt%hour + hstep
        carry = dt%hour/24
        dt%hour = dt%hour - carry*24
        
        dt%day = dt%day + carry
        if (dt%day == daynumList(dt%month)) then
            carry = 0
        else
            carry = dt%day/daynumList(dt%month)
        endif
        dt%day = dt%day - carry*(daynumList(dt%month))

        dt%month = dt%month + carry
        if (dt%month == 12) then
            carry = 0
        else
            carry = dt%month/12
        endif
        dt%month = dt%month - carry*12

        dt%year = dt%year + carry

    end subroutine datetime_update_hourly


    subroutine set_datetime(new, year, month, day, hour)
        type(datetime), intent(out) :: new
        integer, intent(in) :: year
        integer, intent(in) :: month
        integer, intent(in) :: day
        integer, intent(in) :: hour
        integer :: list(12)

        call daynum(year, list(1:12))

        if (year < 1) then
            error stop 'Invalid year value'
        else if (month < 1 .or. month > 12) then
            error stop 'Invalid month value'
        else if (day < 1 .or. day > list(month)) then
            error stop 'Invalid day value'
        else if (hour < 0 .or. hour >= 24) then
            error stop 'Invalid hour value'
        endif

        new%year = year
        new%month = month
        new%day = day
        new%hour = hour

    end subroutine set_datetime


    subroutine check_datetime(present, year, month, day, hour)
        type(datetime), intent(in) :: present
        integer, intent(in) :: year
        integer, intent(in) :: month
        integer, intent(in) :: day
        integer, intent(in) :: hour

        if (present%year/=year .or. present%month/=month .or. present%day/=day .or. present%hour/=hour) then
            write(*,*) 'present datetime is ', present%year, present%month, present%day, present%hour
            write(*,*) 'Unexpexted datetime value'
            error stop
        endif

    end subroutine check_datetime


end module update

