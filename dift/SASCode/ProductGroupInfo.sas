libname difttgt "D:/Workshop/dift/datamart";

options formchar="|---|-|---|" nodate nonumber ls=75 ps=90;

title;

proc sql print;
   select count(distinct product_group) as TotalGroups from difttgt.prodorders ;
   select distinct product_group from difttgt.prodorders;
quit;
