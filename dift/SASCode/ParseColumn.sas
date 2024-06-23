%dqload(dqlocale=(&locale), dqsetuploc="&setuploc", DQINFO=1);
options mprint;
%macro GetToken;
    data &_OUTPUT;
       set &syslast;
       Token =dqParseTokenGet(dqParse(&column, "&parseDefinition", "&locale"), 
                                                      "&token", 
                                                       "&parseDefinition", 
                                                                "&locale");
   run;
%mend GetToken;
%GetToken;
