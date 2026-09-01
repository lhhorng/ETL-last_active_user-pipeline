
# Build Last Active User ETL pipeline

## Description: 
I have learn two ways to proceed the upsert method (insert + update) with last_active_user metric through python and SQL. It serves with different purpose depend on the destination source. For example, we want to transfers the executed result from last_active_user to db. Through python, we can use temp_table to extract the latest active and insert it into the table using SQL (INSERT INTO DO UPDATE). 


## **Bulk Load Vs Incremental Load**

Bulk Load is when you load everything into your destination. Meanwhile, incremental load process ususally divide into two parts:
- [Initial load or historical load](https://hevodata.com/learn/initial-load-vs-full-load-etl/)
- [Incremental load](https://www.stitchdata.com/etldatabase/etl-load/)

![Logic flowchart](images/ETL_incremental_load.png)


## Example 1:
### ETL Bulk Load

A simple way to perform ETL task is bulk load or full load. By transfer the source data(.xlsx,.sql...) to destination. 
In full load, the whole dataset is fully load by overwirte with new dataset. There are pros and cons in term of full load.
First, the full load method could be useful with the small data volumn and the one-time insert.

![full load flow](https://github.com/lhhorng/etl_bulk_load/blob/f48d0ad9e08755b24e1e9e061c8c85c187298f23/full_load_flow_png.PNG)

Sample Dataset: (https://github.com/lhhorng/etl_bulk_load/tree/main/dataset)

## 🛠 Code:
```ruby
#!/usr/bin/env python
# coding: utf-8

# Import library 
import pandas as pd
import os
import time
import schedule

#Give the file path 
cwd = os.path.abspath(r"C:\Users\Documents\bulk_load") 
files = os.listdir(cwd)
df = pd.DataFrame()

#Append for the new data 
for file in files:
     if file.endswith('.xlsx'): 
        df = df.append(pd.read_excel(file),ignore_index = True) #read and append if it is new .xlsx file


#Connect to postgres Engine
from sqlalchemy import create_engine
from datetime import datetime


#credential
conn_string = 'postgresql+psycopg2://username:password@host:port/database'
db = create_engine(conn_string)
conn = db.connect()

#Push to postgres and set query duration
start_time = time.time()
df.to_sql(
    'sale_transaction', 
    con = conn,
    if_exists = "append",
    schema='public',   
    index=False,
)
print("to_sql duration: {} seconds".format(time.time() - start_time))
```




## Example 2:

### Context:

As explain in the description, our purpose is to get the lastest info about customer info and their active hours. So, we need a pipeline that could give us the _UPDATED_ user with their lastest transaction. So, we need an initial load of the previous record of user transaction and then we will use the append or updated for the last transaction of the users. 

Customer_active_hour table                         |       Customer_info Table                |
-- | --
![customer_active_hour_tbl](images/customer_active_hour.PNG)    |     ![customer_info_tbl](images/customer_info.PNG)






I want to get the metric of last_active_customer. So, the script would be: 

## 🛠 SQL Script:
```ruby
select
o.*,
last_online_date,
last_online_hours,
now()::timestamp as update_time


from public.customer_info o 

LEFT JOIN (
			SELECT
  		date,
			id,
 			max(date) over (partition by id) as last_online_date,
			online_hours as last_online_hours
			
			
			FROM customer_active_hour o1
		  WHERE id is not null
			group by id,date,online_hours
)t2 ON t2.id = o.id -- JOIN with customer_active_hour tbl record

WHERE last_online_date = date
order by id,date desc  

```

> **If the same customer who has been online in the following day, then the last_online_date column will be updated. Therefore, i just need to execute the following code below to set the condition of append (if there was a new user who online) and updated (if the same user are online in the new day)**

## 🛠 Code:

```ruby
import pandas as pd
import time
import psycopg2
import os 
from datetime import datetime


con = psycopg2.connect(
    host = 'db.bit.io', // I am using Bit.io 
    port = 5432,
    user = 'lhhorng',
    password = 'v2_427YJ_psP5ieRgM3hJva6yVaSAjbH',
    database='lhhorng/mydb2'
    )


print ("Database connected!")

cursor1 = con.cursor()

#from sqlalchemy import URL
sql = open ('etl_last_online_hour.sql','r')
sql_file = sql.read()

#Read sql query      

start_time = time.time()
cursor1.execute(sql_file)

print("to_sql duration: {} seconds".format(time.time() - start_time))


con.commit()
cursor1.close()
con.close()

```



