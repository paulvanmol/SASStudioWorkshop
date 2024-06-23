proc options option=encoding;
run;

libname ordetail "C:\workshop\OrionStar20\ordetail";
libname orformat "C:\workshop\orionstar20\orfmt";
libname orstar "C:\workshop\orionstar20\orstar";
options fmtsearch=(orformat);

/*Rename orders to orders_2007*/

/*
proc datasets lib=ordetail;
change orders= orders2007;
quit;
*/
data ordetail.orders2007 ordetail.orders2012 ordetail.orders2017;
	set ordetail.orders2007;
	output ordetail.orders2007;
	order_date=intnx('year',order_date,5,'same');
	delivery_date=intnx('year',delivery_date,5,'same');
	output ordetail.orders2012;
	order_date=intnx('year',order_date,5,'same');
	delivery_date=intnx('year',delivery_date,5,'same');
	output ordetail.orders2017;
run;

data ordetail.orders; 
set ordetail.orders2017;
run; 

proc freq data=ordetail.orders;
	table order_date;
		format order_date year4.;
run;