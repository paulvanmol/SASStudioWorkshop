%let path=/gelcontent/sasstudioworkshop;
libname diftodet "&path/orionstar/ordetail"; 
libname difttgt "&path/dift/datamart";
libname diftsas "&path/dift/data"; 
libname library "&path/orionstar/orfmt"; 

options nofmterr fmtsearch=(work library); 
/*proc format cntlin=library.formats lib=library;
proc format lib=library fmtlib; run; */
