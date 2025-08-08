from datetime import datetime, timedelta
start_date = datetime.now() + timedelta(minutes=2)
cron_expression = f"{start_date.minute} {start_date.hour} * * *"

print('\n')
print(f'start_date="{start_date}"')
print(f'cron_expression="{cron_expression}"')