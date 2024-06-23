libname inlib "D:\Workshop\OrionStar\ordetail";

proc print data=inlib.continent noobs;
   var continent_name continent_id;
run;
