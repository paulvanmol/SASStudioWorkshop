from airflow import DAG
from airflow.sensors.filesystem import FileSensor
from airflow.operators.bash import BashOperator
from airflow.decorators import task
from sas_airflow_provider.operators.sas_studio import SASStudioOperator
from datetime import datetime, timedelta

dag = DAG(
    dag_id='my_first_dag_filedep',
    description='A DAG that triggers when a file appears in the file system',
    schedule_interval=None,  # Explicitly set to None for externally triggered DAGs
    catchup=False
)

file_sensor_task = FileSensor(
    task_id='wait_for_file',
    filepath='/gelcontent/trigger.txt',
    fs_conn_id="fs_default", # Ensure you have this connection set in Airflow
    poke_interval=60,  # Time in seconds that the job should wait in between each try during the poking.
    timeout=600,  # Time in seconds before the task times out and fails.
    mode='reschedule',  # Use reschedule mode instead of the default poke mode
    dag=dag
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
    exec_log=True,
    dag=dag)

file_sensor_task >> bashTask >> pythonTask >> flowTask