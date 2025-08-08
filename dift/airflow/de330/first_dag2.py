# Run SAS programs
from airflow import DAG
from datetime import datetime
from airflow.operators.bash import BashOperator
from airflow.decorators import task
from sas_airflow_provider.operators.sas_studio import SASStudioOperator

dag = DAG('my_first_dag2', description='My first ever DAG!', schedule_interval='@daily', start_date=datetime(2023, 1, 1), catchup=False)

bashTask = BashOperator(task_id='bash', bash_command='date', dag=dag)

@task(task_id="python", dag=dag)
def python_task(**kwargs):
    print("Python test")

pythonTask = python_task()

sasTask = SASStudioOperator(task_id="sas_program",
   path_type="content",
   exec_type="program",
   path="/Public/GELOrchestration/1.sas",
   compute_context="SAS Studio compute context",
   connection_name="sas_default",
   exec_log=True,
   dag=dag)

sasTaskTwo = SASStudioOperator(task_id="sas_program_2",
   path_type="compute",
   exec_type="program",
   path="/gelcontent/2.sas",
   compute_context="SAS Studio compute context",
   connection_name="sas_default",
   exec_log=True,
   dag=dag)

sas_program_3 = '''
%let TEST_var1=john ;
%let TEST_var2=jack ;
%let DEV_var3=jill ;
%put &TEST_var1;
%put &TEST_var2;
%put &DEV_var3;
'''

sasTaskThree = SASStudioOperator(task_id="sas_program_3",
   path_type="raw",
   exec_type="program",
   path=sas_program_3,
   compute_context="SAS Studio compute context",
   connection_name="sas_default",
   exec_log=True,
   dag=dag)

bashTask >> pythonTask >> sasTask >> sasTaskTwo >> sasTaskThree