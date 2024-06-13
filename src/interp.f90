module interp
    
    use LAPACK95       , only : GETRF, GETRS, GETRI
    use inverse        , only : gauss_method
    use globals        , only : kp, datetime, WARN_FILE
    use field_expansion, only : coordinate_field

    implicit none

    private
    public :: interp_surface, interp_linear_1dim

    contains


    subroutine interp_surface(program_clock, &
                            & nl_old, np_old, lat_old, pres_old, field_old, &
                            & nl_new, np_new, lat_new, pres_new, field_new  )
        type(datetime), intent(in) :: program_clock
        integer , intent(in)       :: nl_old
        integer , intent(in)       :: np_old
        real(kp), intent(in)       :: lat_old(nl_old)
        real(kp), intent(in)       :: pres_old(np_old)
        real(kp), intent(in)       :: field_old(nl_old,np_old)
        integer , intent(in)       :: nl_new
        integer , intent(in)       :: np_new
        real(kp), intent(in)       :: lat_new(nl_new)
        real(kp), intent(in)       :: pres_new(np_new)
        real(kp), intent(out)      :: field_new(nl_new,np_new)

        integer                    :: insnum

        insnum = (nl_new-1) / (nl_old-1)
        if (nl_new-1 /= (nl_old-1)*insnum) then
            write(*,*)
            write(*,'(a)')    'ERROR in interp_surface ---------------------------'
            write(*,'(a)')    '|   Invarid nl_old or nl_new'
            write(*,'(a)')    '|   nl_new-1 must be a multiple of nl_old-1'
            write(*,'(a,i0)') '|   nl_old : ', nl_old
            write(*,'(a,i0)') '|   nl_new : ', nl_new
            write(*,'(a)')    '---------------------------------------------------'
            error stop
        endif

        insnum = (np_new-1) / (np_old-1)
        if (np_new-1 /= (np_old-1)*insnum) then
            write(*,*)
            write(*,'(a)')    'ERROR in interp_surface ---------------------------'
            write(*,'(a)')    '|   Invarid np_old or np_new'
            write(*,'(a)')    '|   np_new-1 must be a multiple of np_old-1'
            write(*,'(a,i0)') '|   np_old : ', np_old
            write(*,'(a,i0)') '|   np_new : ', np_new
            write(*,'(a)')    '---------------------------------------------------'
            error stop
        endif

        call interp_surface_separate(nl_old                      , &  !! IN
                                   & np_old                      , &  !! IN
                                   & lat_old(1:nl_old)           , &  !! IN
                                   & pres_old(1:np_old)          , &  !! IN
                                   & field_old(1:nl_old,1:np_old), &  !! IN
                                   & nl_new                      , &  !! IN
                                   & np_new                      , &  !! IN
                                   & lat_new(1:nl_new)           , &  !! IN
                                   & pres_new(1:np_new)          , &  !! IN
                                   & field_new(1:nl_new,1:np_new)  )  !! OUT

        !call interp_surface_simul_LAPACK95(nl_old                      , &  !! IN
        !                                 & np_old                      , &  !! IN
        !                                 & lat_old(1:nl_old)           , &  !! IN
        !                                 & pres_old(1:np_old)          , &  !! IN
        !                                 & field_old(1:nl_old,1:np_old), &  !! IN
        !                                 & nl_new                      , &  !! IN
        !                                 & np_new                      , &  !! IN
        !                                 & lat_new(1:nl_new)           , &  !! IN
        !                                 & pres_new(1:np_new)          , &  !! IN
        !                                 & field_new(1:nl_new,1:np_new)  )  !! OUT

        !call interp_surface_simul_gauss(nl_old                      , &  !! IN
        !                              & np_old                      , &  !! IN
        !                              & lat_old(1:nl_old)           , &  !! IN
        !                              & pres_old(1:np_old)          , &  !! IN
        !                              & field_old(1:nl_old,1:np_old), &  !! IN
        !                              & nl_new                      , &  !! IN
        !                              & np_new                      , &  !! IN
        !                              & lat_new(1:nl_new)           , &  !! IN
        !                              & pres_new(1:np_new)          , &  !! IN
        !                              & field_new(1:nl_new,1:np_new)  )  !! OUT

        call check_error_2dim(program_clock               , &  !! IN
                            & nl_old                      , &  !! IN
                            & np_old                      , &  !! IN
                            & field_old(1:nl_old,1:np_old), &  !! IN
                            & nl_new                      , &  !! IN
                            & np_new                      , &  !! IN
                            & field_new(1:nl_new,1:np_new), &  !! IN
                            & 'interp_surface'              )  !! IN

    end subroutine interp_surface


    subroutine interp_surface_simul_gauss(nl_old, np_old, lat_old, pres_old, field_old, &
                                           & nl_new, np_new, lat_new, pres_new, field_new  )
        integer , intent(in)  :: nl_old
        integer , intent(in)  :: np_old
        real(kp), intent(in)  :: lat_old(nl_old)
        real(kp), intent(in)  :: pres_old(np_old)
        real(kp), intent(in)  :: field_old(nl_old,np_old)
        integer , intent(in)  :: nl_new
        integer , intent(in)  :: np_new
        real(kp), intent(in)  :: lat_new(nl_new)
        real(kp), intent(in)  :: pres_new(np_new)
        real(kp), intent(out) :: field_new(nl_new,np_new)

        integer, parameter    :: matkp = 4
        integer, parameter    :: matsize = 8
        integer               :: latIndex_order(matsize)
        integer               :: presIndex_order(matsize)
        real(matkp)           :: coordinate_matrix(matsize,matsize)
        real(matkp)           :: variable_matrix(matsize)
        real(matkp)           :: coefficients(matsize)
        real(matkp)           :: scale_corrector(matsize)
        !integer               :: coordinate_matrix_max
        !integer               :: PIVOT(matsize)
        !integer               :: LAPACK_STAT
        integer               :: ii

        !real(kp)              :: field_new_line(nl_new*np_new)
        real(kp)              :: lat_field(nl_new,np_new)
        real(kp)              :: pres_field(nl_new,np_new)
        ! integer               :: lat_counter
        ! integer               :: pres_counter
        ! real(kp)              :: terms_local(matsize)
        !real(kp)              :: coordinate_matrix_orid(matsize,matsize)
        !real(kp)              :: unitmat(matsize,matsize)

        latIndex_order(1:matsize)  = [1, 3, 2, 2, 2, 2, 3, 1]
        presIndex_order(1:matsize) = [2, 3, 1, 2, 3, 4, 2, 3]


        call generate_coordinate_matrix()

        scale_corrector(1:matsize) = [1d-3, 1d-1, 1d-8, 1d-5, 1d-2, 1d-4, 1d-7, 1d-0]

        do ii = 1, matsize
            coordinate_matrix(1:matsize,ii) = coordinate_matrix(1:matsize,ii) * scale_corrector(ii)
        enddo
        
        call generate_field_varmat()

        call Gauss_Method(matsize                               , &
                        & coordinate_matrix(1:matsize,1:matsize), &
                        & coefficients(1:matsize)               , &
                        & variable_matrix(1:matsize)              )

        coefficients(1:matsize) = coefficients(1:matsize) * scale_corrector(1:matsize)
        
        call coordinate_field(nl_new                     , &  !! IN
                            & lat_new(1:nl_new)          , &  !! IN
                            & nl_new                     , &  !! IN
                            & np_new                     , &  !! IN
                            & lat_field(1:nl_new,1:np_new) )  !! OUT

        call coordinate_field(np_new                     , &  !! IN
                            & pres_new(1:nl_new)         , &  !! IN
                            & nl_new                     , &  !! IN
                            & np_new                     , &  !! IN
                            & pres_field(1:nl_new,1:np_new))  !! OUT


        field_new(1:nl_new,1:np_new) &
            & = real(coefficients(1), kind=kp) * (lat_field(1:nl_new,1:np_new)**2) &
            & + real(coefficients(2), kind=kp) *  lat_field(1:nl_new,1:np_new) &
            & + real(coefficients(3), kind=kp) *(pres_field(1:nl_new,1:np_new)**3) &
            & + real(coefficients(4), kind=kp) *(pres_field(1:nl_new,1:np_new)**2) &
            & + real(coefficients(5), kind=kp) * pres_field(1:nl_new,1:np_new) &
            & + real(coefficients(6), kind=kp) *  lat_field(1:nl_new,1:np_new)* pres_field(1:nl_new,1:np_new) &
            & + real(coefficients(7), kind=kp) *  lat_field(1:nl_new,1:np_new)*(pres_field(1:nl_new,1:np_new)**2) &
            & + real(coefficients(8), kind=kp)


        contains


        subroutine generate_coordinate_matrix()
            real(matkp) :: lat_profile(matsize)
            real(matkp) :: pres_profile(matsize)
            integer  :: ii

            do ii = 1, matsize
                lat_profile(ii)  = anint( lat_old( latIndex_order(ii)) * 100._kp, kind=matkp) / 100._matkp
                pres_profile(ii) = anint(pres_old(presIndex_order(ii)) * 100._kp, kind=matkp) / 100._matkp
            enddo

            coordinate_matrix(1:matsize,1) =  lat_profile(1:matsize)**2
            coordinate_matrix(1:matsize,2) =  lat_profile(1:matsize)
            coordinate_matrix(1:matsize,3) = pres_profile(1:matsize)**3
            coordinate_matrix(1:matsize,4) = pres_profile(1:matsize)**2
            coordinate_matrix(1:matsize,5) = pres_profile(1:matsize)
            coordinate_matrix(1:matsize,6) =  lat_profile(1:matsize) *  pres_profile(1:matsize)
            coordinate_matrix(1:matsize,7) =  lat_profile(1:matsize) * (pres_profile(1:matsize)**2)
            coordinate_matrix(1:matsize,8) = 1._matkp

        end subroutine generate_coordinate_matrix


        subroutine generate_field_varmat()
            integer :: ii

            do ii = 1, matsize
                variable_matrix(ii) = real(field_old(latIndex_order(ii),presIndex_order(ii)), kind=matkp)
            enddo

        end subroutine generate_field_varmat


    end subroutine interp_surface_simul_gauss


    subroutine interp_surface_simul_LAPACK95(nl_old, np_old, lat_old, pres_old, field_old, &
                                           & nl_new, np_new, lat_new, pres_new, field_new  )
        integer , intent(in)  :: nl_old
        integer , intent(in)  :: np_old
        real(kp), intent(in)  :: lat_old(nl_old)
        real(kp), intent(in)  :: pres_old(np_old)
        real(kp), intent(in)  :: field_old(nl_old,np_old)
        integer , intent(in)  :: nl_new
        integer , intent(in)  :: np_new
        real(kp), intent(in)  :: lat_new(nl_new)
        real(kp), intent(in)  :: pres_new(np_new)
        real(kp), intent(out) :: field_new(nl_new,np_new)

        integer, parameter    :: matkp = 4
        integer, parameter    :: matsize = 8
        integer               :: latIndex_order(matsize)
        integer               :: presIndex_order(matsize)
        real(matkp)           :: coordinate_matrix(matsize,matsize)
        real(matkp)           :: field_matrix(matsize)
        real(matkp)           :: coefficients(matsize)
        real(matkp)           :: scale_corrector(matsize)
        integer               :: coordinate_matrix_max
        integer               :: PIVOT(matsize)
        integer               :: LAPACK_STAT
        integer               :: ii

        !real(kp)              :: field_new_line(nl_new*np_new)
        real(kp)              :: lat_field(nl_new,np_new)
        real(kp)              :: pres_field(nl_new,np_new)
        ! integer               :: lat_counter
        ! integer               :: pres_counter
        ! real(kp)              :: terms_local(matsize)
        !real(kp)              :: coordinate_matrix_orid(matsize,matsize)
        !real(kp)              :: unitmat(matsize,matsize)

        latIndex_order(1:matsize)  = [1, 1, 2, 2, 2, 2, 3, 3]
        presIndex_order(1:matsize) = [2, 3, 1, 2, 3, 4, 2, 3]


        !insnum_lat  = (nl_new-1) / (nl_old-1)
        !insnum_pres = (np_new-1) / (np_old-1)
        write(*,*)
        write(*,*) 'Original Latitude :'
        write(*,'(7x,*(es10.3,:,2x))') lat_new(1:nl_new:(nl_new-1) / (nl_old-1))
        write(*,*)
        write(*,*) 'Original Pressure :'
        do ii = np_new, 1, -(np_new-1) / (np_old-1)
            write(*,'(7x,*(es10.3,:,2x))') pres_new(ii)
        enddo

        write(*,*)
        write(*,*) 'Field before interpolation'
        write(*,'(100f10.2)') 0., lat_old(1:nl_old)
        do ii = np_old, 1, -1
            write(*,'(f10.1,100es10.2)') pres_old(ii), field_old(1:nl_old,ii)
        enddo

        call generate_coordinate_matrix()

        write(*,*)
        write(*,*) 'Work Matrix'
        do ii = 1, matsize
            write(*,'(100(es0.7,2x))') coordinate_matrix(ii,1:matsize)
        enddo

        scale_corrector(1:matsize) = [1d-3, 1d-1, 1d-8, 1d-5, 1d-2, 1d-4, 1d-7, 1d-0]
        !scale_corrector(1:matsize) = 1._matkp

        !coordinate_matrix_max = maxval(variable_matrix(matsize/2,1:matsize))
        !scale_corrector(1:matsize) = coordinate_matrix(matsize/2,1:matsize) / variable_matrix_max

        do ii = 1, matsize
            coordinate_matrix(1:matsize,ii) = coordinate_matrix(1:matsize,ii) * scale_corrector(ii)
        enddo
        
        ! write(*,*) 'coordinate_matrix_maxcolumn : ', variable_matrix_maxcolumn 
        ! write(*,*) 'coordinate_matrix(1,variable_matrix_maxcolumn) : ', variable_matrix(1,variable_matrix_maxcolumn)
        
        call generate_field_varmat()

        write(*,*)
        write(*,*) 'Work Matrix (dimensionless)'
        do ii = 1, matsize
            write(*,'(100(es0.7,2x))') coordinate_matrix(ii,1:matsize)
        enddo

        write(*,*)
        do ii = 1, matsize
            write(*,'(100es0.2)') coefficients(ii)
        enddo
        
        !! DELETE THIS LINE
        !coordinate_matrix_orid(1:matsize,1:matsize) = coordinate_matrix(1:matsize,1:matsize)
        !! DELETE THIS 3 LINEs
        !do ii = 1, matsize
        !    !coordinate_matrix_orid(1:matsize,ii) = coordinate_matrix_orid(1:matsize,ii) / scale_corrector(ii)
        !enddo

        call GETRF(coordinate_matrix(1:matsize,1:matsize), &  !! INOUT
                 & PIVOT(1:matsize)                      , &  !! OUT
                 & LAPACK_STAT                             )  !! OUT
        if (LAPACK_STAT /= 0) then
            write(*,*)
            write(*,'(a)')          'ERROR in interp_surface_simul -----------------------'
            write(*,'(a)')          '|   Failed to compute LU factorized matrix in GETRF'
            write(*,'(a,i0,a)')     '|   LAPACK95 returned ', LAPACK_STAT, ' as status'
            if (LAPACK_STAT < 0) then
                write(*,'(a,i0)')   '|   Failed to compute line ', -LAPACK_STAT
            else if (LAPACK_STAT > 0) then
                write(*,'(a,i0,a)') '|   Diagonal element in line ', LAPACK_STAT, ' is zero'
                write(*,'(a)')      '|   Cannot compute inverse of matrix'
            endif
            write(*,'(a)')          '-----------------------------------------------------'
            error stop
        endif

        write(*,*)
        write(*,*) 'Work Matrix (LU Factorized Matrix)'
        do ii = 1, matsize
            write(*,'(100(es0.7,2x))') coordinate_matrix(ii,1:matsize)
        enddo

        !! SWITCH to GETRS
        ! call GETRI(coordinate_matrix(1:matsize,1:matsize), &  !! INOUT
        !          & PIVOT(1:matsize)                      , &  !! IN
        !          & LAPACK_STAT                             )  !! OUT
        ! if (LAPACK_STAT /= 0) then
        !     write(*,*)
        !     write(*,'(a)')          'ERROR in interp_surface_simul -----------------------'
        !     write(*,'(a)')          '|   Failed to compute inverse matrix in GETRI'
        !     write(*,'(a,i0,a)')     '|   LAPACK95 returned ', LAPACK_STAT, ' as status'
        !     if (LAPACK_STAT < 0) then
        !         write(*,'(a,i0)')   '|   Failed to compute line ', -LAPACK_STAT
        !     else if (LAPACK_STAT > 0) then
        !         write(*,'(a,i0,a)') '|   Diagonal element in line ', LAPACK_STAT, ' is zero'
        !         write(*,'(a)')      '|   Cannot compute inverse of matrix'
        !     endif
        !     write(*,'(a)')          '-----------------------------------------------------'
        !     error stop
        ! endif
        ! !! DELETE THIS LINE
        ! coefficients(1:matsize) = matmul(coordinate_matrix(1:matsize,1:matsize), field_matrix(1:matsize))

        !! DELETE THIS LINE
        !do ii = 1, matsize
            !coordinate_matrix(ii,1:matsize) = coordinate_matrix(ii,1:matsize) * scale_corrector(ii)
        !enddo
        
        !! DELETE THIS LINE
        ! unitmat(1:matsize,1:matsize) = matmul(coordinate_matrix, coordinate_matrix_orid)
        ! write(*,*) 'Unit Matrix :'
        ! do ii = 1, matsize
        !     write(*,'(2x,*(es12.2))') unitmat(ii,1:matsize)
        ! enddo


        call GETRS(coordinate_matrix(1:matsize,1:matsize), &  !! IN
                 & PIVOT(1:matsize)                      , &  !! IN
                 & coefficients(1:matsize)               , &  !! INOUT
                 & 'N'                                   , &  !! IN
                 & LAPACK_STAT                             )  !! OUT
        if (LAPACK_STAT /= 0) then
            write(*,'(a)')      'ERROR in interp_surface_simul -----------------------'
            write(*,'(a)')      '|   Failed to compute solution of linear_equation in GETRS'
            write(*,'(a,i0,a)') '|   LAPACK95 returned ', LAPACK_STAT, ' as status'
            write(*,'(a,i0)')   '|   Failed to compute line ', -LAPACK_STAT
            write(*,'(a)')      '-----------------------------------------------------'
            error stop
        endif

        write(*,*)
        write(*,*) 'Coefficients a to h (before scale correction)'
        do ii = 1, matsize
            write(*,'(100es0.2)') coefficients(ii)
        enddo

        coefficients(1:matsize) = coefficients(1:matsize) * scale_corrector(1:matsize)

        write(*,*)
        write(*,*) 'Coefficients a to h (scale corrected)'
        do ii = 1, matsize
            write(*,'(100es0.2)') coefficients(ii)
        enddo
        !call generate_coordinate_matrix()
        !coefficients = matmul(coordinate_matrix,coefficients)
        ! write(*,*)
        ! do ii = 1, matsize
        !     write(*,'(100es0.2)') coefficients(ii)
        ! enddo


        call coordinate_field(nl_new                     , &  !! IN
                            & lat_new(1:nl_new)          , &  !! IN
                            & nl_new                     , &  !! IN
                            & np_new                     , &  !! IN
                            & lat_field(1:nl_new,1:np_new) )  !! OUT

        call coordinate_field(np_new                     , &  !! IN
                            & pres_new(1:nl_new)         , &  !! IN
                            & nl_new                     , &  !! IN
                            & np_new                     , &  !! IN
                            & pres_field(1:nl_new,1:np_new))  !! OUT

        ! do LAPACK_STAT = 1, np_new
        !     write(*,'(10000f10.2)') pres_field(1:nl_new,LAPACK_STAT)
        ! enddo
        ! stop

        field_new(1:nl_new,1:np_new) &
            & = real(coefficients(1), kind=kp) * (lat_field(1:nl_new,1:np_new)**2) &
            & + real(coefficients(2), kind=kp) *  lat_field(1:nl_new,1:np_new) &
            & + real(coefficients(3), kind=kp) *(pres_field(1:nl_new,1:np_new)**3) &
            & + real(coefficients(4), kind=kp) *(pres_field(1:nl_new,1:np_new)**2) &
            & + real(coefficients(5), kind=kp) * pres_field(1:nl_new,1:np_new) &
            & + real(coefficients(6), kind=kp) *  lat_field(1:nl_new,1:np_new)* pres_field(1:nl_new,1:np_new) &
            & + real(coefficients(7), kind=kp) *  lat_field(1:nl_new,1:np_new)*(pres_field(1:nl_new,1:np_new)**2) &
            & + real(coefficients(8), kind=kp)


        contains


        subroutine generate_terms(lat, pres, terms)
            real(matkp), intent(in)  :: lat
            real(matkp), intent(in)  :: pres
            real(matkp), intent(out) :: terms(matsize)

            terms(1:matsize) = [lat * lat         , &
                              & lat               , &
                              & pres * pres * pres, &
                              & pres * pres       , &
                              & pres              , &
                              & lat * pres        , &
                              & lat * pres * pres , &
                              & 1._matkp               ]
        
        end subroutine generate_terms


        subroutine generate_coordinate_matrix()
            real(matkp) :: lat_profile(matsize)
            real(matkp) :: pres_profile(matsize)
            integer  :: ii

            ! lat_profile(1:2) = lat_old(1)
            ! lat_profile(3:6) = lat_old(2)
            ! lat_profile(7:8) = lat_old(3)
            ! pres_profile(1)  = pres_old(2)
            ! pres_profile(2)  = pres_old(3)
            ! pres_profile(3)  = pres_old(1)
            ! pres_profile(4)  = pres_old(2)
            ! pres_profile(5)  = pres_old(3)
            ! pres_profile(6)  = pres_old(4)
            ! pres_profile(7)  = pres_old(2)
            ! pres_profile(8)  = pres_old(3)

            do ii = 1, matsize
                ! lat_profile(ii)  =  lat_old( latIndex_order(ii))
                ! pres_profile(ii) = pres_old(presIndex_order(ii))
                lat_profile(ii)  = anint( lat_old( latIndex_order(ii)) * 100._kp, kind=matkp) / 100._matkp
                pres_profile(ii) = anint(pres_old(presIndex_order(ii)) * 100._kp, kind=matkp) / 100._matkp
                ! call generate_terms(lat_old(latIndex_order(ii)  , &  !! IN
                !                   & pres_old(presIndex_order(ii), &  !! IN
                !                   & coordinate_matrix(ii,1:matsize) )  !! OUT
            enddo

            coordinate_matrix(1:matsize,1) =  lat_profile(1:matsize)**2
            coordinate_matrix(1:matsize,2) =  lat_profile(1:matsize)
            coordinate_matrix(1:matsize,3) = pres_profile(1:matsize)**3
            coordinate_matrix(1:matsize,4) = pres_profile(1:matsize)**2
            coordinate_matrix(1:matsize,5) = pres_profile(1:matsize)
            coordinate_matrix(1:matsize,6) =  lat_profile(1:matsize) *  pres_profile(1:matsize)
            coordinate_matrix(1:matsize,7) =  lat_profile(1:matsize) * (pres_profile(1:matsize)**2)
            ! coordinate_matrix(1:matsize,7) = variable_matrix(1:matsize,6) * pres_profile(1:matsize)
            coordinate_matrix(1:matsize,8) = 1._matkp

        end subroutine generate_coordinate_matrix


        subroutine generate_field_varmat()
            integer :: ii

            do ii = 1, matsize
                coefficients(ii) = real(field_old(latIndex_order(ii),presIndex_order(ii)), kind=matkp)
            enddo

        end subroutine generate_field_varmat


    end subroutine interp_surface_simul_LAPACK95

        
    subroutine interp_surface_separate(nl_old, np_old, lat_old, pres_old, field_old, &
                                     & nl_new, np_new, lat_new, pres_new, field_new  )
        integer , intent(in)  :: nl_old
        integer , intent(in)  :: np_old
        real(kp), intent(in)  :: lat_old(nl_old)
        real(kp), intent(in)  :: pres_old(np_old)
        real(kp), intent(in)  :: field_old(nl_old,np_old)
        integer , intent(in)  :: nl_new
        integer , intent(in)  :: np_new
        real(kp), intent(in)  :: lat_new(nl_new)
        real(kp), intent(in)  :: pres_new(np_new)
        real(kp), intent(out) :: field_new(nl_new,np_new)

        real(kp)              :: work_pinterped(nl_old,np_new)

        call interp_p  (pres_old(1:np_old)               , &  !! IN
                      & nl_old                           , &  !! IN
                      & field_old(1:nl_old,1:np_old)     , &  !! IN
                      & np_new                           , &  !! IN
                      & work_pinterped(1:nl_old,1:np_new), &  !! OUT
                      & pres_new(1:np_new)                 )  !! IN

        call interp_lat(lat_old(1:nl_old)                , &  !! IN
                      & np_new                           , &  !! IN
                      & work_pinterped(1:nl_old,1:np_new), &  !! IN
                      & nl_new                           , &  !! IN
                      & field_new(1:nl_new,1:np_new)     , &  !! OUT
                      & lat_new(1:nl_new)                  )  !! IN
    
    end subroutine interp_surface_separate

    
    subroutine interp_p(p, nl, input, np_out, interped, newp)
        integer, parameter :: np_in = 4
        real(kp), intent(in) :: p(np_in)
        integer, intent(in) :: nl
        real(kp), intent(in) :: input(nl,np_in)
        integer, intent(in) :: np_out
        real(kp), intent(out) :: interped(nl,np_out)
        real(kp), intent(in) :: newp(np_out)
        real(kp) :: a
        real(kp) :: b
        real(kp) :: c
        real(kp) :: d
        real(kp) :: temporary_a
        real(kp) :: temporary_b
        real(kp) :: temporary_c
        integer :: lat_counter
        !integer :: p_counter
        !integer :: ins_num

        !ins_num = (np_out-1) / (np_in-1)
        !if (np_out-1 /= (np_in-1)*ins_num) then
        !    error stop 'Invalid interpolated grid number in vertical direction'
        !endif

        !do p_counter = 1, np_in-1
        !    call linear_interp(ins_num, p(p_counter), p(p_counter+1), &
        !                                                & newp((p_counter-1)*ins_num+1:p_counter*ins_num))
        !enddo
        !newp(np_out) = p(np_in)
        !write(*,*) newp(1:np_out)
        
        !!! Temporary variables for coefficients !!!
        temporary_c = (p(1)*p(1)*p(1) - p(4)*p(4)*p(4))/(p(1)-p(4))

        temporary_b = ( temporary_c - &
                    &   (p(3)*p(3)*p(3) - p(4)*p(4)*p(4))/(p(3)-p(4)) ) / (p(1)-p(3))

        temporary_a = temporary_b - &
                    & ( (p(2)*p(2)*p(2) - p(4)*p(4)*p(4))/(p(2)-p(4)) - &
                    &   (p(3)*p(3)*p(3) - p(4)*p(4)*p(4))/(p(3)-p(4)) ) / (p(2)-p(3))
        !!!--------------------------------------!!!

        do lat_counter = 1, nl
            a = ( (input(lat_counter,1)-input(lat_counter,4))/(p(1)-p(4)) - &
              &   (input(lat_counter,3)-input(lat_counter,4))/(p(3)-p(4)) ) / (p(1)-p(3)) - &
              & ( (input(lat_counter,2)-input(lat_counter,4))/(p(2)-p(4)) - &
              &   (input(lat_counter,3)-input(lat_counter,4))/(p(3)-p(4)) ) / (p(2)-p(3))
            a = a / temporary_a

            b = ( (input(lat_counter,1)-input(lat_counter,4))/(p(1)-p(4)) - &
              &   (input(lat_counter,3)-input(lat_counter,4))/(p(3)-p(4)) ) / (p(1)-p(3)) - &
              & temporary_b * a

            c = (input(lat_counter,1)-input(lat_counter,4))/(p(1)-p(4)) - temporary_c*a - (p(1)+p(4))*b

            d = input(lat_counter,1) - p(1)*p(1)*p(1)*a - p(1)*p(1)*b - p(1)*c

            !write(*,*) 'a,b,c,d=',a, b, c, d

            interped(lat_counter,1:np_out) = a*newp(1:np_out)*newp(1:np_out)*newp(1:np_out) + &
                                           & b*newp(1:np_out)*newp(1:np_out) + &
                                           & c*newp(1:np_out) + &
                                           & d
        enddo

    end subroutine interp_p


    subroutine interp_lat(lat, np, input, nl_out, interped, newlat)
        integer, parameter :: nl_in = 3
        real(kp), intent(in) :: lat(nl_in)
        integer, intent(in) :: np
        real(kp), intent(in) :: input(nl_in,np)
        integer, intent(in) :: nl_out
        real(kp), intent(out) :: interped(nl_out,np)
        real(kp), intent(in) :: newlat(nl_out)
        real(kp) :: a
        real(kp) :: b
        real(kp) :: c
        !integer :: lat_counter
        integer :: p_counter
        !integer :: ins_num

        do p_counter = 1, np
            a = (input(2,p_counter)-input(3,p_counter)) / (lat(2)-lat(3)) - &
              & (input(1,p_counter)-input(3,p_counter)) / (lat(1)-lat(3))
            a = a / (lat(2)-lat(1))

            b = (input(2,p_counter)-input(3,p_counter)) / (lat(2)-lat(3)) - (lat(2)+lat(3))*a

            c = input(1,p_counter) - lat(1)*lat(1)*a - lat(1)*b

            interped(1:nl_out,p_counter) = a*newlat(1:nl_out)*newlat(1:nl_out) + b*newlat(1:nl_out) + c
        enddo

    end subroutine interp_lat


    subroutine interp_linear_1dim(n_old, points_old, n_new, points_new)
        integer , intent(in)  :: n_old
        real(kp), intent(in)  :: points_old(n_old)
        integer , intent(in)  :: n_new
        real(kp), intent(out) :: points_new(n_new)
        
        integer               :: ii
        integer               :: insnum
        integer               :: interp_start
        integer               :: interp_end
        
        insnum = (n_new-1) / (n_old-1)
        if (n_new-1 /= (n_old-1)*insnum) then
            write(*,'(a)')    'ERROR in interp_linear_1dim -----------------------'
            write(*,'(a)')    '|   Invarid n_old or n_new'
            write(*,'(a)')    '|   n_new-1 must be a multiple of n_old-1'
            write(*,'(a,i0)') '|   n_old : ', n_old
            write(*,'(a,i0)') '|   n_new : ', n_new
            write(*,'(a)')    '---------------------------------------------------'
            error stop
        endif

        interp_start = 1
        do ii = 1, n_old-1
            interp_end = interp_start + insnum - 1
            call interp_linear_part(insnum                           , &  !! IN
                                  & points_old(ii)                   , &  !! IN
                                  & points_old(ii+1)                 , &  !! IN
                                  & points_new(interp_start:interp_end))  !! OUT
            interp_start = interp_end + 1
        enddo

        points_new(n_new) = points_old(n_old)

    end subroutine interp_linear_1dim


    subroutine interp_linear_part(n, min, max, interped)
        integer, intent(in) :: n
        real(kp), intent(in) :: min
        real(kp), intent(in) :: max
        real(kp), intent(out) :: interped(n)
        real(kp) :: step
        integer :: i

        step = (max - min) / real(n, kind=kp)

        interped(1:n) = [(min + step*real(i, kind=kp), i=0, n-1)]

    end subroutine interp_linear_part


    subroutine check_error_2dim(program_clock, &
                              & nl_old, np_old, field_old, &
                              & nl_new, np_new, field_new, &
                              & routine_name               )
        type(datetime), intent(in) :: program_clock
        integer , intent(in)     :: nl_old
        integer , intent(in)     :: np_old
        real(kp), intent(in)     :: field_old(nl_old,np_old)
        integer , intent(in)     :: nl_new
        integer , intent(in)     :: np_new
        real(kp), intent(in)     :: field_new(nl_new,np_new)
        character(*), intent(in) :: routine_name

        real(kp)                 :: error(nl_old,np_old)
        real(kp)                 :: error_sum
        real(kp), parameter      :: threshold = 1e-3
        integer                  :: insnum_lat
        integer                  :: insnum_pres
        integer                  :: ii
        character(16), parameter :: fmt='(a,*(es0.3,:,2x))'

        integer                  :: WARN_UNIT
        logical                  :: OPEN_STATUS
        integer                  :: new_pindex

        insnum_lat  = (nl_new-1) / (nl_old-1)
        insnum_pres = (np_new-1) / (np_old-1)

        error(1:nl_old,1:np_old) = field_new(1:nl_new:insnum_lat,1:np_new:insnum_pres) / field_old(1:nl_old,1:np_old) - 1
        error_sum = sum(abs(error(1:nl_old,1:np_old)))
        if (error_sum > threshold) then

            INQUIRE(FILE=trim(WARN_FILE), &
                  & OPENED=OPEN_STATUS  , &
                  & NUMBER=WARN_UNIT      )
            if (.NOT. OPEN_STATUS) then
                OPEN(NEWUNIT=WARN_UNIT, FILE=WARN_FILE, ACTION='WRITE')
            endif

            !write(WARN_UNIT,'()') 'Mean to ', program_clock%year
            write(WARN_UNIT,'(a,es0.3)') 'SUM OF ERROR : ', error_sum
            do ii = np_old, 1, -1
                new_pindex = np_new-(np_old-ii)*insnum_pres
                !write(*,*) new_pindex
                write(WARN_UNIT,'(*(3es11.3,:,5x))') field_old(1:nl_old,ii), &
                                                   & field_new(1:nl_new:insnum_lat,new_pindex), &
                                                   & error(1:nl_old,ii)
            enddo
            write(WARN_UNIT,*)

            !write(*,*)
            !write(*,'(a)')       'WARNING in check_error -------------------------------'
            !write(*,'(a)')       '|   Error occured in ' // trim(routine_name)
            !write(*,'(a)')       '|   Sum of interpolation error exceeded threshold'
            !write(*,'(a)')       '|   Failed to interpolate field'
            !write(*,'(a)')       '|'
            !write(*,'(a,es0.3)') '|   threshold    : ', threshold
            !write(*,'(a,es0.3)') '|   sum of error : ', error_sum
            !write(*,'(a)')       '----------------------------------------------------'
            !error stop
        endif

    end subroutine check_error_2dim


end module interp

