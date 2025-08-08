# initialize macro variables and pass them to a SAS Program Down Stream Task.
from airflow import DAG
from datetime import datetime
from airflow.operators.bash import BashOperator
from airflow.decorators import task
from sas_airflow_provider.operators.sas_studio import SASStudioOperator
from sas_airflow_provider.operators.sas_create_session import SASComputeCreateSession

dag = DAG('my_first_dag_passmacros_downstream', description='My first ever DAG!', schedule_interval='@daily', start_date=datetime(2023, 1, 1), catchup=False)

# Create a Compute session and make the session id available as XCom variable

computeTask = SASComputeCreateSession(task_id="create_sess", dag=dag)

variables_program = '''
%let DEV_transaction=999999 ;
%let DEV_branch=99 ;
%let TEST_branch=22 ;
'''


sasProgramTask = SASStudioOperator(task_id="sas_program",
    path_type="raw",
    exec_type="program",
    path=variables_program,
    compute_session_id="{{ ti.xcom_pull(key='compute_session_id', task_ids=['create_sess'])|first }}",
    compute_context="SAS Studio compute context",
    exec_log=True,
    output_macro_var_prefix="DEV_",
    dag=dag)

downstream_program = '''
%put &=DEV_transaction ;
%put &=DEV_branch ;
%put &=TEST_branch ;
'''

sasProgramDownStreamTask = SASStudioOperator(task_id="sas_downstream_program",
    path_type="raw",
    exec_type="program",
    path=downstream_program,
    # compute_session_id="{{ ti.xcom_pull(key='compute_session_id', task_ids=['create_sess'])|first }}",
    compute_context="SAS Studio compute context",
    connection_name="sas_default",
    exec_log=True,
    codegen_init_code=False,
    codegen_wrap_code=False,
    macro_vars={"DEV_transaction": "{{ti.xcom_pull(key='DEV_TRANSACTION', task_ids=['sas_program'])|first}}",
     "DEV_branch": "{{ti.xcom_pull(key='DEV_BRANCH', task_ids=['sas_program'])|first}}"},
    dag=dag)

bashTask = BashOperator(task_id='bash', bash_command='date', dag=dag)

@task(task_id="python", dag=dag)
def python_task(**kwargs):
	print("Python test")

pythonTask = python_task()

computeTask >> bashTask >> pythonTask >> sasProgramTask >> sasProgramDownStreamTask