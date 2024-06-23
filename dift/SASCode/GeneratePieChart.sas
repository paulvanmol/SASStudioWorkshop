%macro PieChart;

   options mprint;
   ods listing close; 

%if(%sysfunc(fileexist(&path))) %then %do;
		%if (%quote(&path) ne) %then 
		%do;

			%if (%quote(&filename) ne) %then
			 %do;
				  ods pdf file="&path.\&filename..pdf";
			 %end; 
		%end;


	   	%if (%quote(&charttitle) ne) %then
	  	%do;
		  	title height=15pt "&charttitle";
	   	%end;  

	 
	 	proc gchart data=&syslast;
	   	pie &classvar / sumvar=&analysisvar;
	   	run; quit;

	   	ods pdf close;
	   	ods listing;
	   	
	%end;

	%else %do;
		%if &sysscp = WIN %then 
		%do;
			%put ERROR: <text omitted; refer to file for complete text>.;
		%end;

		%else %if %index(*HP*AI*SU*LI*,*%substr(&sysscp,1,2)*) %then 
		%do;
			%put ERROR: <text omitted; refer to file for complete text>.;
		%end;

		%else %if %index(*OS*VM*,*%substr(&sysscp,1,2)*)  %then 
		%do;
   		     %put ERROR: <text omitted; refer to file for complete text>.;
		%end;
	%end;

%mend PieChart;


%PieChart;
