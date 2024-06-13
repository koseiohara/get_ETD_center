module search_max

    use globals, only : kp

    implicit none

    private
    public :: max_index

    contains


    subroutine max_index(nl, np, field, lat, pressure, threshold_south, threshold_low, index_lat, index_p)
        integer, intent(in) :: nl
        integer, intent(in) :: np
        real(kp), intent(in) :: field(nl,np)
        real(kp), intent(in) :: lat(nl)
        real(kp), intent(in) :: pressure(np)
        real(kp), intent(in) :: threshold_south
        real(kp), intent(in) :: threshold_low
        integer, intent(out) :: index_lat
        integer, intent(out) :: index_p
        real(kp) :: lat_field(nl,np)
        real(kp) :: pres_field(nl,np)
        integer :: location(2)

        call make_field(nl, np, nl, lat(1:nl), lat_field(1:nl,1:np))
        call make_field(nl, np, np, pressure(1:np), pres_field(1:nl,1:np))

        location(1:2) = maxloc(field(1:nl,1:np), mask=(lat_field>threshold_south .and. pres_field<threshold_low))

        index_lat = location(1)
        index_p   = location(2)

    end subroutine max_index


    subroutine make_field(nl, np, n, axis, field)
        integer, intent(in) :: nl
        integer, intent(in) :: np
        integer, intent(in) :: n
        real(kp), intent(in) :: axis(n)
        real(kp), intent(out) :: field(nl,np)
        integer :: i

        if (n == nl) then
            do i = 1, np
                field(1:nl,i) = axis(1:nl)
            enddo
        else if (n == np) then
            do i = 1, np
                field(1:nl,i) = axis(i)
            enddo
        else
            write(*,*) 'Invalid array size in subroutine make_field'
            write(*,*) 'axis size must be equal to nl or np'
            error stop
        endif

    end subroutine make_field


end module search_max

