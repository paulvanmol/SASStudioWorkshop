%let path=D:\Workshop\dift\reports;

%macro ForeCastGraph;

     options mprint;
  %if (%quote(&options) ne) %then
  %do;
     options &options;
  %end;  

     proc forecast data=&syslast alpha=&alpha interval=month 
                   lead=&lead method=&method out=FCAST outall;

  %if (%quote(&idvariable) ne) %then
  %do;
        id &idvariable;    
  %end;	

  %if (%quote(&fcastvariable) ne) %then
  %do;
        var &fcastvariable; 
  %end;

     run;

     symbol1 I=spline c=green;
     symbol2 I=spline c=blue l=3;
     symbol3 I=spline c=black;
     symbol4 I=spline c=red;
     symbol5 I=spline c=red;
     symbol6 I=spline c=black;
     legend1 down=2 across=3 label=('Legend:')
             position=(bottom center outside) ;	
     goptions dev=png;

  %if (%quote(&filename) ne) %then 
  %do;
     ods html path="&path"
              gpath="&path"
              file="&filename..html";
  %end;

  %if (%quote(&title) ne) %then %do;
     title "&title";
  %end;

     proc gplot data=FCAST;
	    plot &fcastvariable * &idvariable = _type_ / 
            legend=legend1 autovref href='01jan2012'd ;
     run;
     quit;

     ods html close;

%mend ForeCastGraph;


%ForeCastGraph;
