module field_expansion

    use globals, only : kp
    
    implicit none

    private
    public :: coordinate_field

    contains


    subroutine coordinate_field(n, axis, nx, ny, axis_field)
        integer , intent(in)  :: n
        real(kp), intent(in)  :: axis(n)
        integer , intent(in)  :: nx
        integer , intent(in)  :: ny
        real(kp), intent(out) :: axis_field(nx,ny)

        integer               :: ii

        if (n == nx) then
            do ii = 1, ny
                axis_field(1:nx,ii) = axis(1:nx)
            enddo
        else if (n == ny) then
            do ii = 1, ny
                axis_field(1:nx,ii) = axis(ii)
            enddo
        else
            write(*,'(a)')    'ERROR in coordinate_field ----------------------------'
            write(*,'(a)')    '|   n must be same as nx or ny'
            write(*,'(a,i0)') '|   n  = ', n
            write(*,'(a,i0)') '|   nx = ', nx
            write(*,'(a,i0)') '|   ny = ', ny
            write(*,'(a)')    '------------------------------------------------------'
        endif

    end subroutine coordinate_field


end module field_expansion

