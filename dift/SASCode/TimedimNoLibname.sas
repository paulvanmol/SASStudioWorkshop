 /****************************************************/
 /* Customized TIMEDIM.SAS program for DI Class.     */
 /****************************************************/


data difttgt.TimeDim(label='Time Dimension' sortedby=Date_ID);
   length Date_ID 4;
   format Date_ID date9.;
   Do Date_ID='01jan2001'd to '01jan2013'd;
      WeekDay_Num=Weekday(Date_ID);
      WeekDay_Name=Strip(Put(Date_ID,downame.));
      Month_Num=month(Date_ID);
      Year_ID=Put(Year(Date_ID),4.);
      Month_Name=Strip(Put(Date_ID,monname.));
      Quarter=put(Year_ID,4.)!!'Q'!!put(qtr(Date_ID),1.);
      If Put(Date_ID,holiday.) ne 'Workday' then Holiday_US=Put(Date_ID,holiday.);
      if Month_Num <=11 then Fiscal_Year=Put(Year(Date_ID),4.); 
         else Fiscal_Year=Put(Year(Date_ID)+1,4.);
      if Month_Num <=11 then Fiscal_Month_Num =month(Date_ID)+1; 
         else Fiscal_Month_Num=1;
      Fiscal_Quarter=Fiscal_Year!!'Q'!!put(ceil(Fiscal_Month_Num/3),1.); 
      Output;
      Holiday_US=' ';
   end;
run;

proc sql;
   create unique index Date_ID on difttgt.TimeDim(Date_ID);
quit;

* proc datasets lib=difttgt;
*    delete TimeDim;
* run;


