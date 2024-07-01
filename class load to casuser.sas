proc print data=sashelp.class;
run; 

cas;
caslib _ALL_ assign;

data class_12_to_15;
    set sashelp.class; 
    where age between 12 and 15; 
    keep name age; 
run; 

proc casutil; 
    droptable casdata="class_12_to_15" incaslib="CASUSER" quiet;
    load data=work.class_12_to_15 outcaslib="casuser" casout="class_12_to_15" promote; 
    save casdata="class_12_to_15" incaslib="CASUSER" replace;
 quit;    