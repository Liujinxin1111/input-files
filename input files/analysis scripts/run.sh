cpptraj ../com.top  < corre.in > m4.out 
sed -i '/^[  ]*$/d' p-d.dat
./trcomp_matrix_xyz.pl p-d.dat > dccmn425wt.dat
