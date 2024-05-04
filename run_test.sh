clear
rm -rf eqcheck.*
make
eq32 ../test_progs/temp1.c --dst ../test_progs/temp2.c --dyn-debug=ssa_transform