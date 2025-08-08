from airflow import DAG
from airflow.sensors.sql import SqlSensor
from airflow.operators.bash import BashOperator
from airflow.decorators import task
from sas_airflow_provider.operators.sas_studio import SASStudioOperator
from datetime import datetime, timedelta

dag = DAG(
    dag_id='my_first_dag_sqldep',
    description='A DAG that triggers when a records appears in postgres SQL',
    schedule_interval=None,  # Explicitly set to None for externally triggered DAGs
    catchup=False
)

sql_sensor_task = SqlSensor(
   task_id='waiting_for_data',
   conn_id='postgres',
   sql="select * from load_status where data_scope='DWH' and load_date='{{ ds }}'",
   poke_interval=30,
   timeout=60 * 5,
   mode='reschedule',
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

sql_sensor_task >> bashTask >> pythonTask >> flowTask