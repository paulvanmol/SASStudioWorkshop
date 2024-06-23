libname diftora oracle path='client.demo.sas.com:1521/ORCL' user=STUDENT password="Metadata0"; 

proc copy inlib=ordetail outlib=diftora; 
select order_item orders2017; 
run; 