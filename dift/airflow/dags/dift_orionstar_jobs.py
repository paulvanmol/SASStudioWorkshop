from datetime import datetime, timedelta
from airflow import DAG, Dataset
from airflow.sensors.filesystem import FileSensor
from sas_airflow_provider.operators.sas_studio import SASStudioOperator
from sas_airflow_provider.operators.sas_jobexecution import SASJobExecutionOperator
from sas_airflow_provider.operators.sas_create_session import SASComputeCreateSession
from sas_airflow_provider.operators.sas_delete_session import SASComputeDeleteSession

dag = DAG(dag_id="dift_orionstar_jobs",
   description="DIFT Orion Star Jobs",
   schedule="18 15 * * *",
   start_date=datetime(2025,8,8),
   tags=["orion","dift","migrated"],
   catchup=False)

task1 = SASStudioOperator(task_id="Load_Customer_Dimension",
   exec_type="flow",
   path_type="compute",
   path="/gelcontent/sasstudioworkshop/dift/migratedjobs/DIFT Populate Customer Dimension Table.flw",
   compute_context="SAS Studio compute context",
   connection_name="sas_default",
   exec_log=True,
   codegen_init_code=False,
   codegen_wrap_code=False,
   trigger_rule='all_success',
   dag=dag)

task2 = SASStudioOperator(task_id="load_product_dimension",
   exec_type="flow",
   path_type="compute",
   path="/gelcontent/sasstudioworkshop/dift/migratedjobs/DIFT Populate Product Dimension Table.flw",
   compute_context="SAS Studio compute context",
   connection_name="sas_default",
   exec_log=True,
   codegen_init_code=False,
   codegen_wrap_code=False,
   trigger_rule='all_success',
   dag=dag)

task3 = SASStudioOperator(task_id="Load_orderfact",
   exec_type="flow",
   path_type="compute",
   path="/gelcontent/sasstudioworkshop/dift/migratedjobs/DIFT Populate Order Fact Table.flw",
   compute_context="SAS Studio compute context",
   connection_name="sas_default",
   exec_log=True,
   codegen_init_code=False,
   codegen_wrap_code=False,
   trigger_rule='all_success',
   dag=dag)

task4 = SASStudioOperator(task_id="load_org_dim",
   exec_type="flow",
   path_type="compute",
   path="/gelcontent/sasstudioworkshop/dift/migratedjobs/DIFT Populate Organization Dimension Table.flw",
   compute_context="SAS Studio compute context",
   connection_name="sas_default",
   exec_log=True,
   codegen_init_code=False,
   codegen_wrap_code=False,
   trigger_rule='all_success',
   dag=dag)

task5 = SASStudioOperator(task_id="Load_old_recent_orders",
   exec_type="flow",
   path_type="compute",
   path="/gelcontent/sasstudioworkshop/dift/migratedjobs/DIFT Populate Old and Recent Orders Tables.flw",
   compute_context="SAS Studio compute context",
   connection_name="sas_default",
   exec_log=True,
   codegen_init_code=False,
   codegen_wrap_code=False,
   trigger_rule='all_success',
   dag=dag)

task6 = SASStudioOperator(task_id="load_customer_orders",
   exec_type="flow",
   path_type="compute",
   path="/gelcontent/sasstudioworkshop/dift/migratedjobs/DIFT Populate Customer Order Information Table.flw",
   compute_context="SAS Studio compute context",
   connection_name="sas_default",
   exec_log=True,
   codegen_init_code=False,
   codegen_wrap_code=False,
   trigger_rule='all_success',
   dag=dag)

task3 >> task5
task1 >> task6
task3 >> task6
