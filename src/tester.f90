program tester

    use interp

    implicit none

    integer, parameter :: kp = 4
    integer, parameter :: nl = 3
    integer, parameter :: np = 4
    integer, parameter :: ml = 21
    integer, parameter :: mp = 31
    real(kp) :: testp(nl,np)
    real(kp) :: testl(nl,np)
    real(kp) :: intp(nl,mp)
    real(kp) :: intl(ml,np)
    real(kp) :: p(np)
    real(kp) :: newp(mp)
    real(kp) :: lat(nl)
    real(kp) :: newlat(ml)
    real(kp) :: tmp(nl,np)
    integer :: i, j
    
    lat = [(40.+1.25*i, i=1, nl)]
    p = [800, 775, 750, 300]

    call random_seed()
    call random_number(testp)
    call random_number(tmp)
    testp = testp * 10**(tmp*15)
    testl = testp

    open(10, file='ini_p1.dat')
    do i = 1, np
        write(10,*) p(i), testp(1,i)
    enddo
    close(10)

    open(11, file='ini_l1.dat')
    do i = 1, nl
        write(11,*) lat(i), testl(i,1)
    enddo
    close(11)
    
    open(12, file='ini_p2.dat')
    do i = 1, np
        write(12,*) p(i), testp(2,i)
    enddo
    close(12)

    open(13, file='ini_l2.dat')
    do i = 1, nl
        write(13,*) lat(i), testl(i,2)
    enddo
    close(13)

    open(14, file='ini_p3.dat')
    do i = 1, np
        write(14,*) p(i), testp(3,i)
    enddo
    close(14)

    open(15, file='ini_l3.dat')
    do i = 1, nl
        write(15,*) lat(i), testl(i,3)
    enddo
    close(15)

    open(16, file='ini_l4.dat')
    do i = 1, nl
        write(16,*) lat(i), testl(i,4)
    enddo
    close(16)


    call interp_p(p, nl, testp, mp, intp, newp)
    call interp_lat(lat, np, testl, ml, intl, newlat)
    write(*,*) newlat
    
    
    open(50, file='res_p1.dat')
    do i = 1, mp
        write(50,*) newp(i), intp(1,i)
    enddo
    close(50)

    open(51, file='res_l1.dat')
    do i = 1, ml
        write(51,*) newlat(i), intl(i,1)
    enddo
    close(51)

    open(52, file='res_p2.dat')
    do i = 1, mp
        write(52,*) newp(i), intp(2,i)
    enddo
    close(52)

    open(53, file='res_l2.dat')
    do i = 1, ml
        write(53,*) newlat(i), intl(i,2)
    enddo
    close(53)

    open(54, file='res_p3.dat')
    do i = 1, mp
        write(54,*) newp(i), intp(3,i)
    enddo
    close(54)

    open(55, file='res_l3.dat')
    do i = 1, ml
        write(55,*) newlat(i), intl(i,3)
    enddo
    close(55)

    open(56, file='res_l4.dat')
    do i = 1, ml
        write(56,*) newlat(i), intl(i,4)
    enddo
    close(56)

end program tester

