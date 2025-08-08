from datetime import datetime, timedelta
from airflow import DAG, Dataset
from airflow.sensors.filesystem import FileSensor
from sas_airflow_provider.operators.sas_studio import SASStudioOperator
from sas_airflow_provider.operators.sas_jobexecution import SASJobExecutionOperator
from sas_airflow_provider.operators.sas_create_session import SASComputeCreateSession
from sas_airflow_provider.operators.sas_delete_session import SASComputeDeleteSession

dag = DAG(dag_id="mydag",
   description="mydag",
   schedule="@daily",
   start_date=datetime(2025,8,6),
   is_paused_upon_creation=False,
   tags=["SAS Viya", "Scheduling"],
   catchup=False)

task1 = SASStudioOperator(task_id="1_example_flow.flw",
   exec_type="flow",
   path_type="content",
   path="/Public/GELOrchestration/example_flow.flw",
   compute_context="SAS Studio compute context",
   connection_name="sas_default",
   exec_log=True,
   codegen_init_code=False,
   codegen_wrap_code=False,
   trigger_rule='all_success',
   dag=dag)

