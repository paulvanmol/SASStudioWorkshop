/**********************************************/
/* Dynamically Create Metadata Folders in 9.2 */
/* James Waite (Toronto - Technical Trainer)  */
/* September 2010                             */
/**********************************************/

/************   SETUP STEPS   ***********

	1. Login to SMC as Unrestricted User (i.e. sasadm@saspw)
	2. Determine the ID value of the Foundation Repository and paste below as the %let ReposId value
		Metadata Manager > Active Server > Foundation > Properties > Registration
	3. Optionally, create a new Folder in SAS Folders at whatever level you want
		i.e. SAS Folders > Dynamic Folder Example
	4. Determine the ID value of the parent folder (SAS Folders or the folder created in Step 3) 
		and paste below as the %let InitialParentFolderId value
		Folder > Properties > Authorization > Advanced > Inheritance Tab > Object ID

**********  END SETUP STEPS  ***********/

/*	
ESTABLISH PARAMETER VALUES THAT WILL BE USED THROUGHOUT THE VARIOUS STEPS BELOW

THIS EXAMPLE USES DATALINES TO ENTER ParentFolder AND SubFolder VALUES BUT THESE
COULD EASILY BE LOADED INTO AN EXCEL/CSV SHEET AND READ IN USING PROC IMPORT

	%let InputFilePathAndName = "C:\DynamicFolderCreation\FolderStructure.csv";
*/
	%let OutputFilePathAndName = "C:\Temp\FolderCreationXML.xml";
	%let InitialParentFolderId = A5E6ELOE.AJ0002BY; /* REFER TO SETUP STEPS ABOVE */
	%let ReposId = A0000001.A5E6ELOE; /* REFER TO SETUP STEPS ABOVE */

	%let server = "localhost";
	%let port = 8561;
	%let userid = "sasadm@saspw"; /* IDEALLY, USE AN UNRESTRICTED ACCOUNT */
	%let password = "{sas002}BA7B9D061CB4066E47F2455F373B030E";

/*********  NOTE  **********
TO ENCONDE A PASSWORD, USE PROC PWENCODE AS FOLLOWS
	PROC PWENCODE in="TypeYourPassword";
	RUN;
THEN COPY THE ENCODED VALUE FROM THE LOG
	i.e.: {sas002}BA7B9D061CB4066E47F2455F373B030E
******* END NOTE  ********/

/* IF USING A CSV OR SIMILAR FILE, IMPORT THE CONTENTS OF THE FILE 
	THAT CONTAINS THE PARENTFOLDER/SUBFOLDER VALUES AND RELATIONSHIPS

PROC IMPORT OUT= WORK.FolderStructure 
            DATAFILE= &InputFilePathAndName  
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
*/

DATA WORK.FolderStructure;
   INPUT ParentFolder $ 1-20 SubFolder $ 21-40; 
   DATALINES;
Parent 1            Sub Folder 1-1
Parent 1            Sub Folder 1-2
Parent 1            Sub Folder 1-3
Parent 2            Sub Folder 2-1
Parent 2            Sub Folder 2-2
Parent 3
Parent 4
Parent 5            Sub Folder 5-1
Parent 5            Sub Folder 5-2
Sub Folder 1-1      Sub Folder 1-1-1
Sub Folder 1-1      Sub Folder 1-1-2
Sub Folder 1-1-1    Sub Folder 1-1-1-1
Sub Folder 2-2      Sub Folder 2-2-1
;

/*
CREATE A TEMPORARY DATASET THAT CREATES A CORRESPONDING ID VALUE FOR
EACH FOLDER/SUBFOLDER, WITHOUT SPACES AND PRECEDED BY A DOLLAR SIGN 
SO THAT IT CAN BE USED IN THE INPUT XML AS AN ALIAS.  IT WILL BE REPLACED
BY A METADATA ID (i.e. A5E6ELOE.AJ0002BY) UPON SUCCESSFUL ADD
*/

data work.FolderStructureWithIDs;
	set work.FolderStructure;
	by ParentFolder;
	ParentRefId = "$" || compress(ParentFolder);
	SubRefId = "$" || compress(SubFolder);
run;

data _null_;

	length d $25;
	length k $25;
	length ParentFolderToUse $50;

	/* CREATE THE PHYISCAL XML FILE */
	file &OutputFilePathAndName;

	/*
	READ IN NAME AND ID VALUES FROM THE TEMPORARY TABLE
	ORDER BY PARENTFOLDER SO THAT EACH NEW PARENT FOLDER
	CAN BE ASSOCIATED WITH THE STARTING FOLDER THAT ALREADY
	EXISTS IN METADATA
	*/
	set work.FolderStructureWithIDs end=LastRecord;
	by ParentFolder;

	/* IF FIRST RECORD, CREATE THE ROOT ELEMENT IN THE XML DOCUMENT */
	if _n_=1 then do;
		put '<Multiple_Requests>';

		/* ESTABLISH HASH OBJECT TO STORE SUBFOLDER NAMES, TO CHECK 
		IF A SUBFOLDER IS A PARENT FOLDER FOR ANY OTHER FOLDERS.  
		THIS ALLOWS FOR UNLIMITED LEVELS OF FOLDER HIERARCHY */
		declare hash h();
   		rc = h.defineKey('k');
  		rc = h.defineData('d');
   		rc = h.defineDone();
	end;

	/*
	PREPARE STRING VARIABLES TO BE PUT INTO XML FILE AT APPROPRIATE
	LOCATIONS, SINCE THE PUT STATEMENT DOESN'T ALLOW CONCATENATION OF
	STRINGS WHILE OUTPUTTING LINES TO THE PHYSICAL FILE
	*/
		ParentFolderString = '<Tree Name="' || trim(ParentFolder) || '" Id="' || trim(ParentRefId) || '" PublicType="Folder" TreeType="BIP Folder" UsageVersion="1000000">';
		SubFolderString = '<Tree Name="' || trim(SubFolder) || '" Id="' || trim(SubRefId) || '" PublicType="Folder" TreeType="BIP Folder" UsageVersion="1000000">';
		TreeParentFolderString = '<Tree ObjRef="' || trim(ParentRefId) || '"/>';
		InitialParentFolderString = '<Tree ObjRef="' || "&InitialParentFolderId" || '"/>';
		ReposIdString = '<Reposid>' || "&ReposId" || '</Reposid>';

		/* ADD THE CURRENT SUBFOLDER VALUE TO THE HASH OBJECT TO COMPARE EACH SUBSEQUENT 
		PARENTFOLDER VALUE AGAINST */
		k = SubRefId;
		d = SubRefId;
		rc = h.add();

	/*
	FOR EACH NEW PARENT FOLDER, SPECIFY THE EXISTING
	METADATA FOLDER IN WHICH IT IS TO BE A SUBFOLDER
	*/ 
	if first.ParentFolder then do;
		/*CHECK WHETHER PARENTFOLDER VALUE HAS BEEN ADDED TO HASH OBJECT AS A SUBFOLDER
		AT SOME EARLIER POINT.  IF SO, USE THAT VALUE AS THE PARENT FOLDER.  IF NOT, USE
		THE PARENT VALUE OF THE METADATA FOLDER THAT IS THE TOPMOST/ROOT FOLDER */

		k = ParentRefId;
		rc = h.find();
		if (rc ne 0) then do;
			put '<AddMetadata>';
			put '<Metadata>';
			put ParentFolderString;
			put '<ParentTree>';
			put InitialParentFolderString;
			put '</ParentTree>';
		    	put '</Tree>';
			put '</Metadata>';
		  	put ReposIdString;
		 	put '<NS>SAS</NS>';
		  	put '<Flags>268435456</Flags>';
		 	put '<Options/>';
			put '</AddMetadata>';
		end;

	end;

	/*
	ADD SUBFOLDER INFORMATION IF THERE ARE ANY SUBFOLDER VALUES
	*/
	if SUBFOLDER ne ' ' then do;
		put '<AddMetadata>';
		put '<Metadata>';
		put SubFolderString;
		put '<ParentTree>';
		put TreeParentFolderString;
		put '</ParentTree>';
	   	put '</Tree>';
		put '</Metadata>';
	  	put ReposIdString;
	 	put '<NS>SAS</NS>';
	  	put '<Flags>268435456</Flags>';
	 	put '<Options/>';
		put '</AddMetadata>';
	end;

	/* IF LAST RECORD, CLOSE THE ROOT ELEMENT IN THE XML DOCUMENT */
	if LastRecord then do;
		put '</Multiple_Requests>';
	end;

run;


/*
READ IN THE CONTENTS OF THE XML DOCUMENT JUST CREATED
*/

filename input &OutputFilePathAndName;

/*
CONNECT TO THE METADATASERVER AND SUBMIT THE XML AS INPUT
*/

proc metadata
      server = &server 
      port=&port 
      userid = &UserId
      password = &password 
      in=input;
run;

*/

