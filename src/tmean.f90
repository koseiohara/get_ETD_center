module tmean

    use, intrinsic ::  ieee_arithmetic
    use globals, only : kp, ny, nz, hstep, finfo, datetime
    use fileio, only : fread
    use update, only : datetime_update_hourly

    implicit none

    private
    public :: dailyMean, halfMonthlyMean, monthlyMean, DJFMean

    contains


    subroutine dailyMean(ftype, newdate, mean, recstep)
        type(finfo)   , intent(inout) :: ftype
        type(datetime), intent(inout) :: newdate
        real(kp)      , intent(out)   :: mean(ny,nz)
        integer       , intent(in)    :: recstep

        real(kp) :: data_reader(ny,nz)
        integer :: datanum
        integer :: day_ini

        day_ini = newdate%day

        datanum = 0
        do while (newdate%day == day_ini)
            datanum = datanum + 1
            call fread(ftype                 , &
                     & data_reader(1:ny,1:nz), &
                     & recstep                 )

            if (any(IEEE_IS_NAN(data_reader))) then
                write(*,*)
                write(*,'(a)') 'WARNING in dailyMean ----------------------------'
                write(*,'(a)') '|   NaN is found'
                write(*,'(a,i4,2("/",i0.2)," ",i0.2)') '|   Date : ', newdate%year, newdate%month, newdate%day, newdate%hour
                write(*,'(a)') '-------------------------------------------------------'
            endif
            
            mean(1:ny,1:nz) = mean(1:ny,1:nz) + data_reader(1:ny,1:nz)

            call datetime_update_hourly(newdate)

        enddo

        mean(1:ny,1:nz) = mean(1:ny,1:nz) / real(datanum, kind=kp)

    end subroutine dailyMean


    subroutine halfMonthlyMean(ftype, newdate, mean, recstep)
        type(finfo)   , intent(inout) :: ftype
        type(datetime), intent(inout) :: newdate
        real(kp)      , intent(out)   :: mean(ny,nz)
        integer       , intent(in)    :: recstep

        integer , parameter :: daynum = 15
        real(kp)            :: data_reader(ny,nz)
        integer             :: datanum
        integer             :: recnum
        !integer             :: hour_count
        !integer             :: day_count
        integer             :: daily_datanum
        integer             :: ii
        
        mean(1:ny,1:nz) = 0._kp
        datanum = 0
        daily_datanum = 24 / hstep
        recnum = daynum * daily_datanum

        do ii = 1, recnum
            datanum = datanum + 1
            call fread(ftype                 , &
                     & data_reader(1:ny,1:nz), &
                     & recstep                 )
            if (any(IEEE_IS_NAN(data_reader))) then
                write(*,*)
                write(*,'(a)') 'WARNING in halfMonthlyMean ----------------------------'
                write(*,'(a)') '|   NaN is found'
                write(*,'(a,i4,2("/",i0.2)," ",i0.2)') '|   Date : ', newdate%year, newdate%month, newdate%day, newdate%hour
                write(*,'(a)') '-------------------------------------------------------'
            endif

            mean(1:ny,1:nz) = mean(1:ny,1:nz) + data_reader(1:ny,1:nz)

            call datetime_update_hourly(newdate)

        enddo

        mean(1:ny,1:nz) = mean(1:ny,1:nz) / real(datanum, kind=kp)

    end subroutine halfMonthlyMean


    subroutine monthlyMean(ftype, newdate, mean, recstep)
        type(finfo), intent(inout) :: ftype
        type(datetime), intent(inout) :: newdate
        real(kp), intent(out) :: mean(ny,nz)
        integer, intent(in) :: recstep
        real(kp) :: temporary(ny,nz)
        integer :: datanum
        integer :: fyear
        integer :: fmonth
        integer :: fday
        integer :: fhour

        datanum = 0
        fyear = newdate%year
        fmonth = newdate%month
        fday = newdate%day
        fhour = newdate%hour

        mean(1:ny,1:nz) = 0._kp

        if (newdate%day /= 1 .or. newdate%hour /= 0) then
            write(*,'(a,10i0)') "Invalid datetime at ", newdate%year, newdate%month, newdate%day, newdate%hour
            error stop
        endif

        do while(newdate%month == fmonth)
            datanum = datanum + 1
            call fread(ftype, temporary(1:ny,1:nz), recstep)
            if (any(ieee_is_nan(temporary))) then
                write(*,'(a,i0.4,10(a,i0.2))') 'Warning : NaN is found on ', &
                                             & newdate%year, '/', newdate%month, '/', newdate%day, ' ', newdate%hour
            endif
            mean(1:ny,1:nz) = mean(1:ny,1:nz) + temporary(1:ny,1:nz)
            call datetime_update_hourly(newdate)
        enddo

        mean(1:ny,1:nz) = mean(1:ny,1:nz) / real(datanum, kind=kp)

        !write(*,'(a15,i0.4,a,i0.2,a,i0.2,a,i0.2,a,i0.4,a,i0.2,a,i0.2,a,i0.2,a)') &
        !            & 'Monthly Mean : ', fyear, '/', fmonth, '/', fday, ' ', fhour, ' - ', &
        !            & newdate%year, '/', newdate%month, '/', newdate%day, ' ', newdate%hour

    end subroutine monthlyMean


    subroutine DJFMean(ftype, newdate, mean, recstep)
        type(finfo), intent(inout) :: ftype
        type(datetime), intent(inout) :: newdate
        real(kp), intent(out) :: mean(ny,nz)
        integer, intent(in) :: recstep
        real(kp) :: temporary(ny,nz)
        integer :: datanum
        integer :: fyear
        integer :: fmonth
        integer :: fday
        integer :: fhour

        datanum = 0
        fyear = newdate%year
        fmonth = newdate%month
        fday = newdate%day
        fhour = newdate%hour

        mean(1:ny,1:nz) = 0._kp

        if (newdate%month /= 12 .or. newdate%day /= 1 .or. newdate%hour /= 0) then
            write(*,'(a,i0,10i0)') "Invalid datetime at ", newdate%year, newdate%month, newdate%day, newdate%hour
            error stop
        endif

        do while(newdate%month/=3)
            datanum = datanum + 1
            call fread(ftype, temporary(1:ny,1:nz), recstep)
            if (any(ieee_is_nan(temporary))) then
                write(*,'(a,i0.4,10(a,i0.2))') 'Warning : NaN is found on ', &
                                             & newdate%year, '/', newdate%month, '/', newdate%day, ' ', newdate%hour
            endif
            mean(1:ny,1:nz) = mean(1:ny,1:nz) + temporary(1:ny,1:nz)
            call datetime_update_hourly(newdate)
        enddo

        mean(1:ny,1:nz) = mean(1:ny,1:nz) / real(datanum, kind=kp)

    end subroutine DJFMean


end module tmean

