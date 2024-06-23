%macro TabulateGChart;

   options mprint;
   ods listing close; 
   /* 
    If we do not close the listing destination, 
	SAS will try to write the graph file to the listing destination as well as any
	other destination we specify. By closing it, we elminate unecessary output and 
	possible permissions issues. 
   */ 

   %if (%quote(&options) ne) %then
   %do;
      options &options;
   %end;  


	%if(%sysfunc(fileexist(&path))) %then %do;
		%if (%quote(&path) ne) %then 
		%do;

		   ods html path="&path" gpath="&path"

			 %if (%quote(&filename) ne) %then
			 %do;
				   file="&filename..html" ;
			 %end;
		%end;

	  
	   %if (%quote(&tabulatetitle) ne) %then
	   %do;
		  title1 "&tabulatetitle";
	   %end;

	   proc tabulate data=&syslast;
		 class &classvar1 &classvar2;
		 var &analysisvar;
		 table &classvar1*&classvar2, 
			   &analysisvar*(min="Minimum"*f=comma7.2 
							 mean="Average"*f=comma8.2 
							 sum="Total"*f=comma14.2 
							 max="Maximum"*f=comma10.2);
	   run;

	   %if (%quote(&gcharttitle) ne) %then
	   %do;
		  title height=15pt "&gcharttitle";
	   %end;  

	   goptions dev=png;
	   proc gchart data=&syslast;
	   vbar &classvar1 / sumvar=&analysisvar group=&classvar2
		 				 clipref frame type=SUM outside=SUM 
						 coutline=BLACK;
	   run; quit;

	   ods html close;
	   ods listing;
	   
	%end;

	%else %do;
			%if &sysscp = WIN %then 
			%do;
			   %put ERROR: This folder does not exist. Please check that the folder referenced in the path option exists and that you are using back slashes.;
		    %end;
		    %else %if %index(*HP*AI*SU*LI*,*%substr(&sysscp,1,2)*) %then 
			      %do;
			         %put ERROR: This directory does not exist. Please check that the directory referenced in the path option exists and that you are using forward slashes.;
		          %end;
		          %else %if %index(*OS*VM*,*%substr(&sysscp,1,2)*)  %then 
				        %do;
   		                   %put ERROR: This sequential file does not exist. Please check that the file referenced in the path option exists.;
		                %end;
	%end;

%mend TabulateGChart;


%TabulateGChart;
