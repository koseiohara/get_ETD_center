module globals

    implicit none

    integer, parameter :: kp = 4
    !logical, parameter :: lat_interp = .True.

    !integer, parameter :: rec_step = 6
    integer, parameter :: rec_step = 57
    integer, parameter :: st_rec = 5
    integer, parameter :: pt_rec = 3
    integer, parameter :: epy_rec = 8
    integer, parameter :: epz_form_rec = 10
    integer, parameter :: epz_uv_rec = 12
    integer, parameter :: epz_uw_rec = 14
    integer, parameter :: epz_rec = 16

    !integer, parameter :: nt = 11192       ! for 1979-2010
    !integer, parameter :: nt = 18412        ! for 1959-2010
    integer, parameter :: nt = 22024        ! for 1959-2020
    integer :: ny
    integer :: nz

    real(kp) :: step

    real(kp), allocatable :: p(:)
    real(kp), allocatable :: lat(:)

    !real(kp) :: st(ny,nz)
    !real(kp) :: pt(ny,nz)
    !real(kp) :: lat(ny)

    integer, parameter :: hstep = 6

    integer :: year_ini
    integer :: month_ini
    integer :: day_ini
    integer :: hour_ini

    integer :: year_fin

    character(128), parameter :: WARN_FILE='../output/WARN_FILE.txt'


    type finfo
        integer :: unit
        character(256) :: file
        character(16) :: action
        integer :: recl
        integer :: record
    end type finfo

    type datetime
        integer :: year
        integer :: month
        integer :: day
        integer :: hour
    end type datetime

end module globals

