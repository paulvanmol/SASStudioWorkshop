# Runs a SAS Job
from airflow import DAG
from datetime import datetime
from airflow.operators.bash import BashOperator
from airflow.decorators import task
from sas_airflow_provider.operators.sas_jobexecution import SASJobExecutionOperator

dag = DAG('my_first_dag_job', description='My first ever DAG!', schedule_interval='@daily', start_date=datetime(2023, 1, 1), catchup=False)

bashTask = BashOperator(task_id='bash', bash_command='date', dag=dag)

@task(task_id="python", dag=dag)
def python_task(**kwargs):
    print("Python test")

pythonTask = python_task()

# Job parameters can be passed into the job
job_parameters = {
    "param1": "class"
}

sasTask = SASJobExecutionOperator(task_id='sas_job',
    job_name='/Public/GELOrchestration/example_job',
    job_exec_log=True,
    parameters=job_parameters,
    dag=dag)

bashTask >> pythonTask >> sasTask