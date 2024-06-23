data _null_; 
   infile "D:\Workshop\dift\data\reportdate.txt" dsd missover;
   input Date :date9.; 
   call symputx("RD",put(Date,date9.));
run;

%put REPORTDATE= &RD;

LIBNAME diftora ORACLE user=educ pw=educ PATH=ora11g ;
LIBNAME difttgt BASE "D:\Workshop\dift\datamart";

%macro OldAndRecentOrders(reportdate);

data difttgt.OldOrders2 difttgt.RecentOrders2 ;
   set diftora.orders;
   if datepart(ORDER_DATE) <= "&reportdate"d then output difttgt.OldOrders2;
   if datepart(ORDER_DATE) >  "&reportdate"d then output difttgt.RecentOrders2;
run;

ods noproctitle;
proc freq data=difttgt.OldOrders2;
   title "Orders Before &reportdate By Order Type";
   tables &freqvar;
run;

proc freq data=difttgt.RecentOrders2;
   title "Orders After &reportdate By Order Type";
   tables &freqvar;
run;

%mend;

%let freqvar=order_type;
%OldAndRecentOrders(&RD);


