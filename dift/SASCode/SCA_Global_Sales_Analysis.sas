options nodate nonumber;
libname diftsas "D:\Workshop\dift\data";
libname inlib "D:\Workshop\orionstar\ordetail";
libname outlib "D:\Workshop\dift\datamart";
libname library "D:\SAS\Config\Lev1\SASApp\SASEnvironment\SASFormats";

%macro Global_Sales_Analysis(table=,splitcol=,class1=,class2=,
                             analysis1=,analysis2=);

   /* add continent and country to the sales data */
   proc sql;
      create table &table as
      select Continent_Name,Customer_Country,
             Customer_ID,Order_ID,Discount,
             &class1 %if &class2 ne %then ,&class2;,
             &analysis1 %if &analysis2 ne %then ,&analysis2;
      from
         inlib.Country, inlib.Continent, diftsas.&table
      where
         Country.Continent_ID = Continent.Continent_ID
         and Country.Country = &table..Customer_Country;
   quit;

   /* find the unique values of continent or country */
   proc sort data=&table(keep=&splitcol) 
             out=splitvalues nodupkey;
      by &splitcol;
   run;

   /* put the unique continents or countries into
      macro variables and generate a data set name
      for each continent or country */
   data _null_;
      set splitvalues end=last;
      call symputx('splitval'||left(_n_),&splitcol);
      call symputx('dsname'||left(_n_),
                   translate(trim(&splitcol),'__','/ '));
      if last then call symputx('count',_n_);
   run;
   /* create a subset for each continent or country */
   data %do i=1 %to &count; outlib.&&dsname&i %end;;
      set &table;
      select(&splitcol);
         %do i=1 %to &count;
           when("&&splitval&i") output outlib.&&dsname&i;
         %end;
      otherwise;
      end;
   run;
   /* create a report for each continent or country */
   %do i=1 %to &count;
      ods html
        file="D:\Workshop\dift\reports\Report_&&dsname&i...html";
      ods noproctitle;
      title1 "Counts for &class1" 
             %if &class2 ne %then " and &class2";;
      proc freq data=outlib.&&dsname&i;
         table &splitcol/nocum nopct out=Freq_&&dsname&i;
         table &class1 %if &class2 ne %then * &class2;;
      run;
      
      data _null_;
         set Freq_&&dsname&i;
         call symputx('freq',count);
      run;
      %if &freq GT 1000 %then %do;
      title1 "Mean and Sum &analysis1" 
         %if &analysis2 ne %then " and &analysis2";;
      title2 "By &class1" %if &class2 ne %then " and &class2";;
      title3 "In &&splitval&i";
      proc means data=outlib.&&dsname&i mean sum;
         class &class1 &class2;
         var &analysis1 &analysis2;
      run;
      %end;
      ods html close;
   %end;
%mend Global_Sales_Analysis;

options mprint;
%*Global_Sales_Analysis
      (table=CustomerOrderInfo,
       splitcol=Continent_Name,
       class1=Customer_Gender,  class2=Customer_Age_Group,
       analysis1=Total_Retail_Price);
%Global_Sales_Analysis
      (table=CustomerOrderInfo,
       splitcol=Customer_Country,
       class1=Customer_Gender,  class2=Customer_Age_Group,
       analysis1=Total_Retail_Price, analysis2=CostPrice_Per_Unit);


