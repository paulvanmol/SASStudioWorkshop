# If the flowTask runs successfully, it will update the dataset declared in the outlet.
from airflow import DAG, Dataset
from datetime import datetime
from sas_airflow_provider.operators.sas_studio import SASStudioOperator

dag = DAG('my_first_dag_Dataset_dep', description='My first ever DAG!', schedule_interval='@daily', start_date=datetime(2023, 1, 1), catchup=False)

global_params = {
   "DEV_transaction": 777777,
   "DEV_branch": 77
}

flowTask = SASStudioOperator(task_id="sas_flow",
   path_type="content",
   path="/Public/GELOrchestration/example_flow.flw",
   compute_context="SAS Studio compute context",
   connection_name="sas_default",
   exec_log=True,
   codegen_init_code=False,
   codegen_wrap_code=False,
   outlets=[Dataset("sas://sasdm/transactions")],
   macro_vars=global_params,
   trigger_rule='all_success',
   dag=dag)

flowTask
