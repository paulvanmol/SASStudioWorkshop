options msglevel=I;
 /****************************************************************/
 /*          S A S   S A M P L E   L I B R A R Y                 */
 /*                                                              */
 /*                                                              */
 /*    NAME: timedim                                             */
 /*   TITLE: Create Time Dimension for use in the Orion Star     */
 /*          Sample data star schema.                            */
 /*    DESC: This is an example of how to create the Time Dim.   */
 /*          You can change the Language from Danish to your     */
 /*          language to get support for your local Holidays.    */
 /*          The Fiscal Year starts on December 1.               */
 /*   USAGE: Prior to running this program, submit the %orion    */
 /*          macro found in the ormacro folder to set up librefs.*/
 /*          The program uses the %upper macro found found       */
 /*          in the ormacro folder. Run this after %orion.       */
 /* PRODUCT: SAS                                                 */
 /*  SYSTEM: ALL                                                 */
 /*    KEYS: ORION STAR SCHEMA TIME DIM HOLIDAY                  */
 /*   PROCS: SQL, FORMAT                                         */
 /*    DATA:                                                     */
 /*                                                              */
 /* SUPPORT: SDKJDM,SDKSVH               UPDATE: 10JUL2003       */
 /*     REF:                                                     */
 /*                                                              */
 /*                                                              */
 /*  Copyright (C) 2001-2003 SAS Institute Inc., Cary, NC, USA   */
 /*                    All rights reserved.                      */
 /****************************************************************/

 Proc SQL;
 CREATE TABLE ORSTAR.Time_Dim (
       Date_ID              DATE LABEL='Date',
       Weekday_Num          SMALLINT LABEL='US WeekDay Number',
       Weekday_EU           SMALLINT LABEL='European Weekday Number',
       Weekday_Name         VARCHAR(20) LABEL='Weekday Name',
       Week_Num             SMALLINT LABEL='European Week Number',
       Week_Name            CHARACTER(7) LABEL='Week Name in display format (YYYY-WW)',
       Month_Num            SMALLINT LABEL='Month Number',
       Month_Name           VARCHAR(20) LABEL='Month Name',
       Quarter              CHARACTER(6) LABEL='Quarter',
       Year_ID              CHARACTER(4) LABEL='Year',
       Holiday_US           VARCHAR(45) LABEL='USA Holidays',
       Holiday_DK           VARCHAR(45) LABEL='Danish Holidays',
       Fiscal_Year          CHARACTER(4) LABEL='Fiscal Year',
       Fiscal_Quarter       CHARACTER(6) LABEL='Fiscal Quarter',
       Fiscal_Month_Num     SMALLINT LABEL='Fiscal Month Number');
 quit;

 Options DFLang=Danish;
 data Time_Dim(label='Time Dimension');
 Do Date_ID='01jan2007'd to '01jan2022'd;
    WeekDay_Num=Weekday(Date_ID);
    WeekDay_Name=Strip(Put(Date_ID,downame.));
    Month_Num=month(Date_ID);
    Year_ID=Put(Year(Date_ID),4.);
    Month_Name=Strip(Put(Date_ID,monname.));
    Quarter=put(Year_ID,4.)!!'Q'!!put(qtr(Date_ID),1.);
    If Put(Date_ID,holiday.) ne 'Workday' then
    Holiday_US=Put(Date_ID,holiday.);
    If Put(Date_ID,holiday_DK.) ne 'Hverdag' then
    Holiday_DK=Put(Date_ID,holiday_DK.);
    WeekDay_DK=Strip(Put(Date_ID,EURDFDWN.));
    Month_DK=Strip(Put(Date_ID,EURDFMN.));
	if Month_Num <=11 then Fiscal_Year=Put(Year(Date_ID),4.); 
	else Fiscal_Year=Put(Year(Date_ID)+1,4.);
    if Month_Num <=11 then Fiscal_Month_Num =month(Date_ID)+1; 
	else Fiscal_Month_Num=1;
	Fiscal_Quarter=Fiscal_Year!!'Q'!!put(ceil(Fiscal_Month_Num/3),1.); 
    Output;
    Holiday_US=' ';
    Holiday_DK=' ';
   
 end;
 run;

 Proc format;
 Picture We Low-High= '9999-99';
 run;

 Data ORstar.Time_Dim(Compress=Yes Label='Time Dimension' Sortedby=Date_ID);
 Length Date_ID 8 Year_ID $4 Quarter $6 Month_Name $20 Week_Name $7
 Weekday_Name $20 Month_Num Week_Num Weekday_Num Weekday_EU 8
 Fiscal_Year $4 Fiscal_Quarter $6 Fiscal_Month_Num 8;
 Format Date_ID Date9.;
 set ORstar.Time_Dim(obs=0) Time_Dim;
 retain Week 1 weekyear 2007;
 /*%upper(Weekday_DK);
 %upper(Month_DK);*/
 Weekday_EU=weekday(Date_ID-1);
 if Weekday_EU=1 then do;
    Week+1;
    if mdy(12,29,Input(Year_ID,4.)-(month_Num=1))
    <=Date_ID<=mdy(1,4,Input(Year_ID,4.)+(Month_Num=12)) then
    do;
      Week=1;
      WeekYear+1;
    end;
 end;
 Week_Num=Week;
 Week_Name=Put(WeekYear*100+Week_Num,we.);
 Drop Week WeekYear ;
 run;

 Proc SQL;
 CREATE INDEX Year_ID        ON ORstar.Time_Dim(Year_ID);
 CREATE INDEX Quarter        ON ORstar.Time_Dim(Quarter);
 CREATE INDEX Month_Num      ON ORstar.Time_Dim(Month_Num);
 CREATE INDEX Fiscal_Year    ON ORstar.Time_Dim(Fiscal_Year);
 CREATE INDEX Fiscal_Quarter ON ORstar.Time_Dim(Fiscal_Quarter);
 CREATE UNIQUE INDEX Date_ID ON ORstar.Time_Dim(Date_ID);
 ALTER TABLE ORstar.Time_Dim
     ADD PRIMARY KEY (Date_ID) ;
 quit;

 Proc contents data=ORstar.Time_Dim varnum;
 run;
 Options DFLang=English;
