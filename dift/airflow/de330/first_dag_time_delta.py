from airflow import DAG
from datetime import datetime, timedelta
from airflow.operators.bash import BashOperator
from airflow.decorators import task
from airflow.sensors.date_time import DateTimeSensor
from sas_airflow_provider.operators.sas_studio import SASStudioOperator

# set default arguments for every task
default_args = {
    'start_date': datetime(2023, 4, 1),
}


dag = DAG(
    'my_first_dag_time_delta',
    default_args=default_args,
    description='A DAG that runs every 30 minutes',
    schedule=timedelta(minutes=30),  # Run every 30 minutes
    catchup=False  # To prevent backfilling
)

bashTask = BashOperator(task_id='bash', bash_command='date', dag=dag)

@task(task_id="python", dag=dag)
def python_task(**kwargs):
    print("Python test")

pythonTask = python_task()

flowTask = SASStudioOperator(task_id="sas-flow",
    path_type="content",
    path="/Public/GELOrchestration/example_flow.flw",
    compute_context="SAS Studio compute context",
    connection_name="sas_default",
    exec_log=True,
    dag=dag)

bashTask >> pythonTask >> flowTask