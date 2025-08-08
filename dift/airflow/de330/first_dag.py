# Run a SAS Studio flow
from airflow import DAG
from datetime import datetime

from airflow.operators.bash import BashOperator
from airflow.decorators import task
from sas_airflow_provider.operators.sas_studio import SASStudioOperator

dag = DAG('my_first_dag', description='My first ever DAG!', schedule_interval='@daily', start_date=datetime(2023, 1, 1), catchup=False)


bashTask = BashOperator(task_id='bash',
  bash_command='date', dag=dag)
@task(task_id="python", dag=dag)
def python_task(**kwargs):
    print("Python test")

pythonTask = python_task()

flowTask = SASStudioOperator(task_id="sas_flow",
   path_type="content",
   path="/Public/GELOrchestration/example_flow.flw",
   compute_context="SAS Studio compute context",
   connection_name="sas_default",
   exec_log=True,
   codegen_init_code=False,
   codegen_wrap_code=False,
   dag=dag)

bashTask >> pythonTask>>flowTask
