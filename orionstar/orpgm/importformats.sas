libname v9fmt cvp "&path/orionstar/orfmt"; 
proc format cntlin=v9fmt.formats lib=orformat fmtlib; 
run; 

proc format lib=orformat fmtlib ;
select $country; 
run; 