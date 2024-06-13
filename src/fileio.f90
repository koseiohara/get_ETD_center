module fileio

    use globals, only : kp, ny, nz, finfo

    implicit none

    private
    public :: file_set, file_open, file_close, fwrite, fread

    interface fwrite
        module procedure &
            & fwrite1d, &
            & fwrite2d
    end interface fwrite

    interface fread
        module procedure &
            & fread1d, &
            & fread2d
    end interface fread


    contains


    subroutine file_set(ftype, file, action, recl, record)
        type(finfo), intent(out) :: ftype
        !integer, intent(in) :: unit
        character(*), intent(in) :: file
        character(*), intent(in) :: action
        integer, intent(in) :: recl
        integer, intent(in) :: record

        if (recl == ny*nz .or. recl == ny .or. recl == nz) then
            write(*,*)
            write(*,*) "WARNING : recl may not be multiplied datum size"
            write(*,*)
        endif

        !ftype%unit = unit
        ftype%file = file
        ftype%action = action
        ftype%recl = recl
        ftype%record = record

    end subroutine file_set


    subroutine file_open(ftype)
        type(finfo), intent(inout) :: ftype
        integer :: stat
        
        open(newunit=ftype%unit, file=ftype%file, action=ftype%action, form="unformatted", access="direct", recl=ftype%recl, iostat=stat)
        if (stat/=0) then
            write(*,*) "Failed to open " // trim(ftype%file)
            error stop
        endif

    end subroutine file_open


    subroutine file_close(ftype)
        type(finfo), intent(in) :: ftype

        close(ftype%unit)

    end subroutine file_close


    subroutine fwrite1d(ftype, data)
        type(finfo), intent(inout) :: ftype
        real(kp), intent(in) :: data(:)

        call open_check(ftype)

        write(ftype%unit, rec=ftype%record) data(:)
        ftype%record = ftype%record + 1

    end subroutine fwrite1d


    subroutine fwrite2d(ftype, data)
        type(finfo), intent(inout) :: ftype
        real(kp), intent(in) :: data(:,:)

        call open_check(ftype)

        write(ftype%unit, rec=ftype%record) data(:,:)
        ftype%record = ftype%record + 1

    end subroutine fwrite2d


    subroutine fread1d(ftype, container, recstep)
        type(finfo), intent(inout) :: ftype
        real(kp), intent(out) :: container(:)
        integer, intent(in) :: recstep

        call open_check(ftype)

        read(ftype%unit, rec=ftype%record) container(:)
        ftype%record = ftype%record + recstep

    end subroutine fread1d


    subroutine fread2d(ftype, container, recstep)
        type(finfo), intent(inout) :: ftype
        real(kp), intent(out) :: container(ny,nz)
        integer, intent(in) :: recstep
        
        call open_check(ftype)

        read(ftype%unit, rec=ftype%record) container(1:ny,1:nz)
        ftype%record = ftype%record + recstep

        call toYobv(container)

    end subroutine fread2d


    subroutine toYobv(data)
        real(kp), intent(inout) :: data(ny,nz)

        data(1:ny,1:nz) = data(ny:1:-1,1:nz)

    end subroutine toYobv


    subroutine toZobv(data)
        real(kp), intent(inout) :: data(ny,nz)

        data(1:ny,1:nz) = data(1:ny,nz:1:-1)

    end subroutine toZobv


    subroutine open_check(ftype)
        type(finfo) , intent(in) :: ftype
        logical                  :: open_status

        INQUIRE(UNIT=ftype%unit , &
              & OPENED=open_status)

        if (.NOT. open_status) then
            write(*,*) 'READ/WRITE ERROR -----------------------------------------'
            write(*,*) '|   ' // trim(ftype%file) // ' is not opened'
            write(*,*) '----------------------------------------------------------'
            error stop
        endif

    end subroutine open_check


end module fileio

