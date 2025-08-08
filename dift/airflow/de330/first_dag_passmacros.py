# Pass macro variables to a SAS Studio flow task
from airflow import DAG
from datetime import datetime
from airflow.operators.bash import BashOperator
from airflow.decorators import task
from sas_airflow_provider.operators.sas_studio import SASStudioOperator

dag = DAG('my_first_dag_passmacro', description='Passing macro variables to a SAS Pogram', schedule_interval='@daily', start_date=datetime(2023, 1, 1), catchup=False)

global_params = {
   "DEV_transaction": 888888,
   "DEV_branch": 88
}

flowTask = SASStudioOperator(task_id="sas_flow",
    path_type="content",
    path="/Public/GELOrchestration/example_flow.flw",
    compute_context="SAS Studio compute context",
    exec_log=True,
    macro_vars=global_params,
    dag=dag)

bashTask = BashOperator(task_id='bash', bash_command='date', dag=dag)

@task(task_id="python", dag=dag)
def python_task(**kwargs):
	print("Python test")

pythonTask = python_task()

bashTask >> pythonTask >> flowTask