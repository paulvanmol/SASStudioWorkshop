# DAG triggered by a dataset update
from datetime import datetime, timedelta
from airflow import DAG, Dataset
from airflow.sensors.filesystem import FileSensor
from sas_airflow_provider.operators.sas_studio import SASStudioOperator


dag = DAG('my_second_dag',
   description='My second ever DAG!',
   schedule=[Dataset("sas://sasdm/transactions")],
   start_date=datetime(2024, 9, 1),
   catchup=False)

task1 = SASStudioOperator(task_id="update_transactions",
   path_type="content",
   exec_type="program",
   path="/Public/GELOrchestration/1.sas",
   compute_context="SAS Studio compute context",
   exec_log=True,
   dag=dag)


task2 = SASStudioOperator(task_id="customer_transactions",
   exec_type="flow",
   path_type="content",
   path="/Public/GELOrchestration/customers_flow.flw",
   compute_context="SAS Studio compute context",
   exec_log=True,
   outlets=[Dataset("sas://sasdm/customers_activity")],
   trigger_rule='all_success',
   dag=dag)

task3 = SASStudioOperator(task_id="customers_activity",
   exec_type="flow",
   path_type="content",
   path="/Public/GELOrchestration/customers_activity.flw",
   compute_context="SAS Studio compute context",
   exec_log=True,
   trigger_rule='all_success',
   dag=dag)

task1 >> task3
task2 >> task3
