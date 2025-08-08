from airflow import DAG
from datetime import datetime, timedelta
from airflow.operators.bash import BashOperator
from airflow.decorators import task
from airflow.sensors.date_time import DateTimeSensor
from sas_airflow_provider.operators.sas_studio import SASStudioOperator

# set year month and day
year=2025
month=8
day=5
# set cron a few minutes from now
cron_expression='30 14 * * *' # set a few minutes form now


dag = DAG(
    'my_first_dag_timedep',
    description='Time Dependencies',
    schedule_interval=cron_expression,  # Set to the cron expression we created
    start_date=datetime(year,month,day),  # Set to the start_date which is two minutes from now
    catchup=True  # Backfilling
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