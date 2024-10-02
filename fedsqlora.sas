libname oralib oracle path="XE" schema=educ authdomain="OracleAuth"; 
proc fedsql; 
describe table oralib.customer_dim; 
quit; 
