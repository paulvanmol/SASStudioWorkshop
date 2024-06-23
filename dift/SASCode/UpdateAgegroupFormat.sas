/*****************************************************************/
/*                                                               */
/* Program to update the AGEGROUP format.                        */
/*                                                               */
/* The user Formats catalog is stored in the following location  */
/* <drive>:\SAS\Config\Lev1\SASApp\SASEnvironment\SASFormats     */
/* where <drive> is C: for Ardence (US)                          */
/*                  D: for VMs                                   */
/* If necessary, modify the path in the libname statement below  */
/*                                                               */
/*****************************************************************/

/* Point to where the user formats are stored */
libname fmts "D:\SAS\Config\Lev1\SASApp\SASEnvironment\SASFormats";

/* Execute this PROC FORMAT to view the existing AGEGROUP format */
proc format lib=fmts fmtlib;
   select agegroup;
run;

/* Set up a location for a temporary data set */
LIBNAME difttgt BASE "D:\Workshop\dift\datamart";

/* Write the AGEGROUP format to a temporary data set */
proc format lib=fmts cntlout=difttgt.temp;
   select agegroup;
run;

/* View the data set */
proc print data=difttgt.temp;
   var fmtname start end label;
run;

/* Add a row to the data set with the new agegroup values */
proc sql;
   insert into difttgt.temp
   set fmtname='agegroup',
       start='76',
       end='100',
       label='76 & over';
quit;  

/* View the updated data set */
proc print data=difttgt.temp;
   var fmtname start end label;
run;

/* Execute this PROC FORMAT to reconstitute the AGEGROUP format */
proc format lib=fmts cntlin=difttgt.temp;
run;

/* Execute this PROC FORMAT to view the updated AGEGROUP format */
proc format lib=fmts fmtlib;
   select agegroup;
run;



