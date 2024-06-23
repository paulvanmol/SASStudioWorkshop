libname inlib "D:\Workshop\OrionStar\ordetail";
libname outlib "D:\Workshop\dift\datamart";

proc sql;
   create table outlib.Combined as
   select country, country_name, continent_name
   from inlib.country, inlib.continent
   where country.continent_id=continent.continent_id
;
quit;

/* ALTERNATE_NODE_NAME: Join - Populate Combined Table */
/* ALTERNATE_NODE_DESCRIPTION: Join Country and Country_Name tables */
/* COMMENT: Match records by Country_ID */


