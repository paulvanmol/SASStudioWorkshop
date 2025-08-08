# Create a SAS program and pass the variables to a SAS Program
from airflow import DAG
from datetime import datetime
from airflow.operators.bash import BashOperator
from airflow.decorators import task
from sas_airflow_provider.operators.sas_studio import SASStudioOperator
from sas_airflow_provider.operators.sas_create_session import SASComputeCreateSession

dag = DAG('my_first_dag_passmacro2', description='My first ever DAG!', schedule_interval='@daily', start_date=datetime(2023, 1, 1), catchup=False)

global_params = {
   "DEV_transaction": 888888,
   "DEV_branch": 88
}

variables_program = '''
%let DEV_transaction=999999 ;
%let DEV_branch=99 ;
%let TEST_branch=22 ;
%put DEV TransactionId = &DEV_transaction ;
%put DEV Branch = &DEV_branch ;
'''
computeTask = SASComputeCreateSession(task_id="create_sess", dag=dag)

sasProgramTask = SASStudioOperator(task_id="sas_program",
    path_type="raw",
    exec_type="program",
    path=variables_program,
    compute_session_id="{{ ti.xcom_pull(key='compute_session_id', task_ids=['create_sess'])|first }}",
    compute_context="SAS Studio compute context",
    exec_log=True,
    macro_vars=global_params,
    output_macro_var_prefix="DEV_",
    dag=dag)

bashTask = BashOperator(task_id='bash', bash_command='date', dag=dag)

@task(task_id="python", dag=dag)
def python_task(**kwargs):
	print("Python test")

pythonTask = python_task()

computeTask >> bashTask >> pythonTask >> sasProgramTask