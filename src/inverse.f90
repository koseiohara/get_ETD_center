module inverse

    implicit none

    contains

    subroutine gauss_method(Msize, M, x, y)
        integer, intent(in) :: Msize
        real(4), intent(inout) :: M(Msize,Msize)
        real(4), intent(out) :: x(Msize)
        real(4), intent(inout) :: y(Msize)
        !character(300) :: ifile
        integer :: i, j
        integer :: ios
        !real(kp) :: l(Msize), p(Msize), st(1:Msize)
        !real(kp) :: M2(1:Msize,1:Msize)

        !ifile="trouble_maker.txt"
        !open(10, file=trim(ifile), action="read", status="old")
        !do i = 1, Msize
        !    read(10, *, iostat=ios) (M(i,j), j=1,Msize), y(i)
        !    if (ios < 0) then
        !        print *, "Msize is not match the Matrix_Data"
        !        stop
        !    endif
        !enddo
        !close(10)
        !M2(1:Msize,1:Msize) = M(1:Msize,1:Msize)
        !st(1:Msize) = y(1:Msize)

        !write(*,*)
        !write(*,'(A)') 'INPUT MATRIX : M'
        !do i = 1, Msize
        !    write(*,'(*(es0.3,:,2x))') M(i,:)
        !enddo

        !write(*,*)
        !write(*,'(A)') 'Y :'
        !do i = 1, Msize
        !    write(*,'(es0.5)') y(i)
        !enddo

        !write(*,*)
        !以降の処理の前に対角成分が0出ないように整形しておく必要がある
        do j = 1, Msize, 1
            y(j) = y(j) / M(j,j)
            M(j,1:Msize) = M(j,1:Msize) / M(j,j)
            !print *, M(j,1:Msize)
            !write(*,'(*(f0.3,:,2x))') M(j,1:Msize)
            if (j < Msize) then
                do i = j+1, Msize, 1
                    y(i) = y(i) - M(i,j) * y(j)
                    M(i,1:Msize) = M(i,1:Msize) - M(i,j) * M(j,1:Msize)
                enddo !i
            endif
        enddo !j


        !write(*,*) 'Result 1'
        !do i = 1, Msize
        !    write(*,'(*(es0.3,:,2x))') (M(i,j), j = 1, Msize)
        !enddo

        x(Msize) = y(Msize)
        do i = Msize-1, 1, -1
            x(i) = y(i)
            do j = i+1, Msize, 1
                x(i) = x(i) - M(i,j) * x(j)
            enddo
        enddo !i

        !write(*,'(100es12.3)') (x(i), i = 1, Msize)

        !l(1:Msize) = M(1:Msize,2)
        !p(1:Msize) = M(1:Msize,5) * 100

        !write(*,'(100es12.3)') matmul(M2,x)

    end subroutine gauss_method


end module inverse

