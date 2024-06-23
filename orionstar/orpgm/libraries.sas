options dlcreatedir; 
libname ordetail "/workshop/orionstar/ordetail" ; 
libname orstar "/workshop/dift/datamart"; 
libname orfmt cvp "/workshop/orionstar/orfmt"; 
libname orformat "/workshop/orionstar/orfmt"; 

options fmtsearch=(orformat orfmt.orionfmt); 

proc format lib=orformat.orionfmt cntlin=orfmt.formats; 
run; 

libname orfmt "/workshop/orionstar/orfmt"; 



libname ordet cvp "/workshop/orionstar/ordetail" ; 
proc copy inlib=ordet outlib=work; 
run; 


proc cimport lib=ordetail file="/workshop/orionstar/ordet.cpt" extendvar=2 ; 
run; 