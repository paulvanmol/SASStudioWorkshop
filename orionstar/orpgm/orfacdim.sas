 /****************************************************************/
 /*          S A S   S A M P L E   L I B R A R Y                 */
 /*                                                              */
 /*                                                              */
 /*    NAME: orfacdim                                            */
 /*   TITLE: Orion Star Create Fact and Dimensional Tables       */
 /*    DESC: Generates the Orion Star Schema (the dimension      */
 /*          tables and the fact table) from the normalized      */
 /*          detail data tables.                                 */
 /*                                                              */
 /*   USAGE: Prior to running this program, submit the %orion    */
 /*          macro found in the ormacro folder to set up librefs.*/
 /*          Note that this program overwrites existing Orion    */
 /*          Star formats and existing star schema tables if run */
 /* PRODUCT: SAS                                                 */
 /*  SYSTEM: ALL                                                 */
 /*    KEYS: ORION STAR SCHEMA                                   */
 /*   PROCS: FORMAT SQL SORT DATA STEP                           */
 /*    DATA:                                                     */
 /*                                                              */
 /* SUPPORT: SDKJDM,SDKSVH               UPDATE: 10JUL2003       */
 /*     REF:                                                     */
 /*                                                              */
 /*                                                              */
 /*  Copyright (C) 2001-2003 SAS Institute Inc., Cary, NC, USA   */
 /*                    All rights reserved.                      */
 /****************************************************************/

proc sql;
    *   create index Customer_Type_ID on
         Ordetail.Customer_Type(Customer_Type_ID);
quit;

Proc Format lib=orfmt.orionfmt;
	value $Gender 
	M=Male 
	F=Female;
	
	value AgeGroup 
	15-30 = '15-30 years'
	30-45 = '31-45 years'
	45-60 = '46-60 years'
	60-75 = '61-75 years'
    75-95 = '76-95 years';
run;

Data Orstar.Customer_Dim (Label='Customer Dimension'
      Compress=Yes drop=Customer_Type_ID);
   set Ordetail.Customer(keep=Customer_ID  Customer_Name Gender
       Birth_date Country Customer_Type_ID
       Customer_FirstName Customer_LastName
       Rename=(Country=Customer_Country Gender=Customer_Gender 
       Birth_date=Customer_BirthDate));
   Attrib Customer_Age_Group length=$12 label='Customer Age Group';
   if Customer_Type_ID > 0 then
     set Ordetail.Customer_Type (keep=Customer_Type_ID Customer_Type
     Customer_group) key=Customer_Type_ID;
   if _iorc_ then _error_=0;
   Format Customer_Gender $Gender.;
   Length Customer_Age 3;
   Label Customer_Age='Customer Age';
   Customer_age=ceil(yrdif(Customer_BirthDate,today(),'actual'));
   Customer_Age_Group=put(Customer_age,agegroup.);
run;

proc sql;
   Drop index Customer_ID on Orstar.Customer_Dim;
   Drop index Customer_Country on Orstar.Customer_Dim;
   Drop index Customer_Type on Orstar.Customer_Dim;
   Drop index Customer_Group on Orstar.Customer_Dim;
   Alter table Orstar.Customer_Dim DROP PRIMARY KEY;
quit;

proc sort Data=Orstar.Customer_Dim force;
   by Customer_ID;
run;

proc sql;
 /* Index Definitions generated from Modeling Tool */
 CREATE UNIQUE INDEX Customer_ID
        ON Orstar.Customer_Dim(Customer_ID);
 CREATE INDEX Customer_Country
        ON Orstar.Customer_Dim(Customer_Country);
 CREATE INDEX Customer_Type
        ON Orstar.Customer_Dim(Customer_Type);
 CREATE INDEX Customer_Group
        ON Orstar.Customer_Dim(Customer_Group);

 ALTER TABLE Orstar.Customer_Dim
        ADD PRIMARY KEY (Customer_ID);
quit;

data formats;
         set Ordetail.Organization(
                 RENAME = (Employee_ID = Start org_Name = Label));
         Retain Type    'N' FmtName 'ORG';
run;

Proc format cntlin=formats lib=Orformat.orionfmt;
Run;

data formats;
         set Ordetail.Organization
                 (RENAME = (Employee_ID = Start org_ref_ID = Label));
         Retain  Type    'N'
                 FmtName 'ORGDIM';
run;

Proc format cntlin=formats lib=Orformat.orionfmt;
Run;

data formats;                                                                                                                            
	retain fmtname 'Job_Title' Type 'N';                                                                                                    
	merge ordetail.staff                                                                                                                    
	      ordetail.organization(keep=employee_id org_name org_level                                                                         
	      where=(org_level=1))                                                                                                              
	      ;                                                                                                                                 
	by employee_id;                                                                                                                         
	if employee_id=99999999 then delete;                                                                                                    
	start=employee_id;                                                                                                                      
	label=trim(Job_title)!!' '!!Org_name;                                                                                                   
	keep fmtname type start label;                                                                                                          
run;                                                                                                                                    
                                                                                                                                        
proc format cntlin=formats lib=Orformat.orionfmt;                                                                                        
run;


Proc sql;
         create view Org_Dim as
         select  a.Employee_ID,
                 a.country as employee_country,
                 a.Org_Name as Employee_Name,
                 Job_title,
                 Gender as Employee_Gender,
                 Salary,
                 Birth_date as Employee_BirthDate,
                 Manager_id,
                 Emp_Hire_date as Employee_Hire_date,
                 Emp_term_date as Employee_Term_date
         from    Ordetail.Organization a
         left join Ordetail.Staff b
         on      a.Employee_ID=b.Employee_ID
	 where   org_level=1;
quit;

sasfile organization close;

data organization /* (index=employee_id) */;
set org_dim(keep=employee_id manager_id);
run;
/* This table is used later in macro leveling */

sasfile organization open; 
/* Open it as sasfile because we have a lot of open/close of the table */

Data Organization_Dim
                 (Label='Organization Dimension' Compress=Yes);
         attrib  Employee_ID     length  = 8
                                 label   = "Employee ID"
                                 format  = 12.
                 Employee_Country
                                 length  = $ 2
                                 label   = "Employee Country"
                 Company         length  = $ 30
                                 label   = "Company "
                 Department      length  = $ 40
                                 label   = "Department "
                 Section         length  = $ 40
                                 label   = "Section "
                 Org_Group       length  = $ 40
                                 label   = "Group "
                 Job_Title       length  = $ 25
                                 label   = "Job Title"
                 Employee_Name   length  = $ 40
                                 label   = "Employee Name"
                 Employee_Gender length  = $ 1
                                 label   = "Employee Gender"
                                 format  = $Gender.
                 Salary          length  = 8
                                 label   = "Annual Salary"
                                 format  = Dollar12.2
                 Employee_BirthDate
                                 length  = 4
                                 label   = "Employee Birth Date"
                                 Format  = Date9.
                 Employee_Hire_Date
                                 length  = 4
                                 label   = "Employee Hire Date"
                                 format  = Date9.
                 Employee_Term_Date
                                 length  = 4
                                 label   = "Employee Termination Date"
                                 format  = Date9.
	         Manager_Levels           
	         		 length  = 3
	         		 LABEL   = 'Levels of Management'
	         Manager_Level1       
	                   	 length  = 8
	                   	 label   = 'Manager at 1. level'
	         Manager_Level2       
	                   	 length  = 8
	                   	 label   = 'Manager at 2. level'
	         Manager_Level3       
	                   	 length  = 8
	                   	 label   = 'Manager at 3. level'
	         Manager_Level4       
	                   	 length  = 8
	                   	 label   = 'Manager at 4. level'
	         Manager_Level5       
	                   	 length  = 8
	                   	 label   = 'Manager at 5. level'
	         Manager_Level6       
	                   	 length  = 8
	                   	 label   = 'Manager at 6. level'
 ;
	set Org_dim;
	_Group          = input(put(Employee_ID,orgdim.),12.);
	Org_Group           = put(_Group,org.);
	_Section        = input(put(_Group,orgdim.),12.);
	Section         = put(_section,org.);
	_Department     = input(put(_Section,orgdim.),12.);
	Department      = put(_Department,org.);
	_Company        = input(put(_Department,orgdim.),12.);
	Company         = put(_Company,org.);
	if manager_id then Manager_levels= 1;
	else manager_levels=0;
	Manager_level1 = manager_id;
	
	Drop _Group _Section _Department _Company Org_Ref_ID seq count;
run;
/* Set initial Macro variables for leveling macro */
%let prevlevel=1;
%let level=2;
%let found=1;

/* The leveling macro creates the Management Level above each Employee */
/* This is done by generating each level in the data step. 
   Since we have 6 levels in the data, data step is run 6 times */

%macro leveling;
%do %while(&found);

data organization_dim(drop=set dsid rc found levtxt);
   retain set;
   set organization_dim;
   if _n_ = 1 then call symput('found','0');

   if manager_levels = &prevlevel then do;
        dsid = open("organization(where=
      	(employee_id=" || put(Manager_Level&prevlevel.,12.) || '))','I');
	rc = fetch(dsid);
       found = getvarn(dsid,varnum(dsid,'manager_id'));
       rc = close(dsid);
       if found > . and  found ne manager_id then do;
          if not set then do;
            call symput('found', '1');
            call symput('prevlevel',symget('level'));
	  /* If they have a manager themselves, increase their level value */
            call symput('level',put(sum(1,input(symget('level'),bz1.)),z1.));
            set = 1;
         end;
         Manager_levels = manager_levels + 1;
         Manager_Level&level. = found;
      end;
   end;
run;
%end;
%mend;
%leveling;

sasfile organization close; 

proc sort Data= organization_dim(drop=manager_id) 
		  out = Orstar.Organization_Dim (label='Organization Dimension');
         by Employee_ID;
run;

Proc sql;
  create unique index Employee_ID on Orstar.Organization_Dim(Employee_ID);
  alter table Orstar.Organization_Dim add primary key (Employee_ID);
quit;

data formats(keep=start label Type fmtname);
         set Ordetail.Product_List
                 (Rename = (Product_ID = Start
                                    Product_name  = Label));
         Retain Type    'N'
           FmtName  'Product';
Run;
Proc format cntlin=formats lib=Orformat.orionfmt;
Run;

data formats(keep=start label Type fmtname);
         set Ordetail.Product_List
                 (RENAME = (Product_ID = Start
                                    Product_Ref_ID = Label));
         Retain Type    'N'
           FmtName  'PRODDIM';
run;
proc format cntlin=formats lib=Orformat.orionfmt;
Run;

 /* One way using SQL */
 /*
 proc sql;
         create table Orstar.Product_dim(Label='Product Dimension') as
         select  a.Product_ID,
                 a.Product_Name,
                 put(a.Product_ref_ID,Product.) as Product_Group,
                 put(b.Product_ref_ID,Product.) as Product_Category,
                 put(c.Product_ref_ID,Product.) as Product_Line
         from    Ordetail.Product_List a,
                 Ordetail.Product_List b,
                 Ordetail.Product_List c
         where   a.Product_Level=1 and
                 b.Product_Level=2 and
                 c.Product_Level=3 and
                 a.Product_Ref_ID=b.Product_ID and
                 b.Product_Ref_ID=c.Product_ID
         order by a.Product_ID;
 quit;
 */
Proc sql;
 create view product_sup as
 select a.*, b.supplier_name, b.country as Supplier_Country
 from Ordetail.Product_List a,
 	  Ordetail.Supplier b
 where a.supplier_id=b.supplier_id;
quit;

 /* A better way using Data Step, runs in half the Time */

Data Orstar.Product_Dim(Label='Product Dimension' keep= 
			Product_Id
			Product_Line
			Product_Category
			Product_Group
			Product_Name
			Supplier_Country
			Supplier_Name
			Supplier_ID   
	);
	attrib 	Product_ID
				length  = 8
				label   = "Product ID"
				format  = 12.
			Product_Line     
				length  = $ 20
				label   = "Product Line"
			Product_Category
				length  = $ 25
				label   = "Product Category"
			Product_Group
				length  = $ 25
				label   = "Product Group"
			Product_Name
				length  = $ 45
				label   = "Product Name"
			Supplier_Country
				length  = $ 2
				label   = "Supplier Country"
				format  = $Country.
			Supplier_Name
				length  = $ 30
				label   = "Supplier Name"
			Supplier_ID
				length  = 4
				label   = "Supplier ID"
				format  = 12.
	;
	set Product_sup;
	where Product_Level=1;
	_group  =input(put(Product_ID,proddim.),12.);
	Product_group=put(_Group,Product.);
	_Category=input(put(_Group,proddim.),12.);
	Product_Category=put(_Category,Product.);
	_Line=input(put(_Category,proddim.),12.);
	Product_Line    =put(_Line,Product.);
run;

proc sort Data=Orstar.Product_Dim;
   by Product_ID;
run;

 Proc sql;
   CREATE UNIQUE INDEX Product_ID
          ON Orstar.Product_Dim(Product_ID);
   CREATE INDEX Product_Group
          ON Orstar.Product_Dim(Product_Group);
   CREATE INDEX Product_Line 
          ON Orstar.Product_Dim(Product_Line);
   CREATE INDEX Product_Category
          ON Orstar.Product_Dim(Product_Category);
  alter table Orstar.Product_Dim add primary key (Product_ID);
quit;

Data Order_Fact;
   merge   Ordetail.Orders
           Ordetail.Order_Item(in=b drop=Order_Item_Num);
   by Order_ID;
   if b;
run;

proc sort Data=Order_Fact;
         by Customer_ID;
run;

proc sort data=Ordetail.Customer(keep=Customer_ID Street_ID)
         out=Customer;
         by Customer_ID ;
run;

Data Order_Fact;
         length  Customer_ID Employee_ID Street_ID 8
                         Order_Date Delivery_Date 4 ;
         merge   Order_Fact(in=a)
                         Customer;
         by Customer_ID;
         if a;
run;

proc sort data = Order_Fact 
		  out  = Orstar.Order_Fact (label='Order Fact Table');
      by Order_Date Customer_ID Employee_ID Street_ID Product_ID Order_ID;
run;
 /* Table Time_Dim only needs to be generated once. 
    Program TIMEDIM in the ORPGM folder does it */

 proc sql;
         CREATE INDEX Customer_ID ON Orstar.Order_Fact(Customer_ID);
         *CREATE INDEX Employee_ID ON Orstar.Order_Fact(Employee_ID);
         CREATE INDEX Order_Date ON Orstar.Order_Fact(Order_Date);
quit;



 /* Testing that all the star schema tables can be joined by creating
    a view and materializing it afterwards */
proc sql _Method;
   Drop table Basetable;
   Drop View Basetable;
   *create Table basetable as ;
   create View basetable as
   select  c.Customer_Gender,
           t.Year_ID, t.Quarter,                  /* Time Hierarchy */
           c.Customer_Group,                   /* Customer Hierarchy */
           o.Company, o.Employee_Name, Salary, /* Organization Hierarchy */
           p.Product_Line, p.Product_Name,     /* Product Hierarchy    */
           f.Quantity,                         /* Fact */
           f.Total_Retail_Price
   from    Orstar.Order_Fact f,
           Orstar.Time_Dim t,
           Orstar.Organization_Dim o,
           Orstar.Customer_Dim c,
           Orstar.Product_Dim p,
           Orstar.Geography_Dim g
   where   f.Order_Date    =       t.Date_ID and
           f.Street_ID     =       g.Street_ID and
           f.Customer_ID   =       c.Customer_ID and
           f.Employee_ID   =       o.Employee_ID and
           f.Product_ID    =       p.Product_ID and
           c.Customer_Country = 'DK' and
           t.Year_ID='2019';
quit;

data Test;  /*Materializing the view */
   set basetable;
run;

