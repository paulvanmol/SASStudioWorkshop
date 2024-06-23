/*Orion Case Study*/
libname ordetail base "/workshop/orionstar/ordetail"; 
libname orformat base "/workshop/orionstar/orfmt"; 
libname diftsas base "/workshop/dift/data" ;
options fmtsearch=(work orformat.orionfmt library); 
libname diftora ORACLE path="client.demo.sas.com:1521/ORCL" authdomain="OracleAuth";
libname orstar base "/workshop/dift/datamart";
libname difttgt base "/workshop/dift/datamart"; 

/*
	The following options are used for debugging purposes. 
	This can be removed when going into production.
*/
options SYMBOLGEN MPRINT MLOGIC;

/*
	The following option is there to let SAS know that it 
	needs to continue in case of exceptions.
*/
options obs=max NOSYNTAXCHECK;

/*
	Define the run-time parameters for this flow. 

	DELIVERING_PARTY is used in:
		- Pick file
		- Import Excel
		- Copy or move file
	ROOT_DIR is used in:
		- Import TEST.CSV
		- Copy or move file
	PROCESS_DTTM is used in:
		- Query - Perform mapping
		- Update Table
*/
%LET DELIVERING_PARTY = 111_orionstar;
%LET ROOT_DIR = /workshop/dift/;
%LET PROCESSED_DTTM = %SYSFUNC(DATETIME(), DATETIME.);

/*
	Define the parameters for the 'Store run-time information' custom step.
*/
%LET FLOW_NAME = Populate_Orderfact;
%LET TARGET_TABLE = ORDER_FACT;
%LET START_DTTM = %SYSFUNC(DATETIME(), DATETIME.);