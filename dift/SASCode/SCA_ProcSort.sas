libname inlib "D:\Workshop\OrionStar\ordetail";
libname outlib "D:\Workshop\dift\datamart";

proc sort data=inlib.country out=outlib.country_sorted;
   by country;
run;
