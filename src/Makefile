EXE = center_search

OBJS = inverse.o globals.o fileio.o calendar.o namelist.o update.o tmean.o field_expansion.o interp.o search_max.o find_center.o main.o
#OBJS = globals.o fileio.o calendar.o namelist.o update.o tmean.o interp.o search_max.o  main.o

FC = ifort
FLAGS = -assume byterecl -convert little_endian -warn all -O0

%.o : %.f90
	${FC} -c $< ${FLAGS} -c -mkl

%.f90~ : %.f90
	cp $< ../backup/$@

all : ${EXE}

${EXE} : ${OBJS}
	${FC} -o $@ $^ -lmkl_lapack95_lp64 -mkl


.PHONY : clean re run test backup

clean :
	@ rm -fv *.o *.mod ${EXE}

re : clean all

run :
	./${EXE}

test : globals.o interp.o tester.o
	ifort -o exe $^
	./exe

backup : ${OBJS:.o=.f90~}

