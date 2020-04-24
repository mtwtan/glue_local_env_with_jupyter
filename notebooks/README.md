# PySpark ETL scripts that can be run to validate the setup

## Pre-requisites
- Appropriate IAM permissions need to be given to the user running the script.
- The user credentials and configuration will be in the .aws folder in the user home directory

## The script and the results of each snippet is below:

```python
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

glueContext = GlueContext(SparkContext.getOrCreate())
```


```python
persons = glueContext.create_dynamic_frame.from_catalog(
             database="blogs_jupyter",
             table_name="persons")
print("Count: " + str(persons.count()))
persons.printSchema()
```

    Count: 1961
    root
    |-- family_name: string
    |-- name: string
    |-- links: array
    |    |-- element: struct
    |    |    |-- note: string
    |    |    |-- url: string
    |-- gender: string
    |-- image: string
    |-- identifiers: array
    |    |-- element: struct
    |    |    |-- scheme: string
    |    |    |-- identifier: string
    |-- other_names: array
    |    |-- element: struct
    |    |    |-- lang: string
    |    |    |-- note: string
    |    |    |-- name: string
    |-- sort_name: string
    |-- images: array
    |    |-- element: struct
    |    |    |-- url: string
    |-- given_name: string
    |-- birth_date: string
    |-- id: string
    |-- contact_details: array
    |    |-- element: struct
    |    |    |-- type: string
    |    |    |-- value: string
    |-- death_date: string
    



```python
memberships = glueContext.create_dynamic_frame.from_catalog(
                 database="blogs_jupyter",
                 table_name="memberships")
print("Count: " + str(memberships.count()))
memberships.printSchema()
```

    Count: 10439
    root
    |-- area_id: string
    |-- on_behalf_of_id: string
    |-- organization_id: string
    |-- role: string
    |-- person_id: string
    |-- legislative_period_id: string
    |-- start_date: string
    |-- end_date: string
    



```python
orgs = glueContext.create_dynamic_frame.from_catalog(
           database="blogs_jupyter",
           table_name="organizations")
print("Count: " + str(orgs.count()))
orgs.printSchema()
```

    Count: 13
    root
    |-- identifiers: array
    |    |-- element: struct
    |    |    |-- scheme: string
    |    |    |-- identifier: string
    |-- other_names: array
    |    |-- element: struct
    |    |    |-- lang: string
    |    |    |-- note: string
    |    |    |-- name: string
    |-- id: string
    |-- classification: string
    |-- name: string
    |-- links: array
    |    |-- element: struct
    |    |    |-- note: string
    |    |    |-- url: string
    |-- image: string
    |-- seats: int
    |-- type: string
    



```python
orgs = orgs.drop_fields(['other_names',
                        'identifiers']).rename_field(
                            'id', 'org_id').rename_field(
                               'name', 'org_name')
orgs.toDF().show()
```

    +--------------+--------------------+--------------------+--------------------+--------------------+-----+-----------+
    |classification|              org_id|            org_name|               links|               image|seats|       type|
    +--------------+--------------------+--------------------+--------------------+--------------------+-----+-----------+
    |         party|            party/al|                  AL|                null|                null| null|       null|
    |         party|      party/democrat|            Democrat|[[website, http:/...|https://upload.wi...| null|       null|
    |         party|party/democrat-li...|    Democrat-Liberal|[[website, http:/...|                null| null|       null|
    |   legislature|d56acebe-8fdc-47b...|House of Represen...|                null|                null|  435|lower house|
    |         party|   party/independent|         Independent|                null|                null| null|       null|
    |         party|party/new_progres...|     New Progressive|[[website, http:/...|https://upload.wi...| null|       null|
    |         party|party/popular_dem...|    Popular Democrat|[[website, http:/...|                null| null|       null|
    |         party|    party/republican|          Republican|[[website, http:/...|https://upload.wi...| null|       null|
    |         party|party/republican-...|Republican-Conser...|[[website, http:/...|                null| null|       null|
    |         party|      party/democrat|            Democrat|[[website, http:/...|https://upload.wi...| null|       null|
    |         party|   party/independent|         Independent|                null|                null| null|       null|
    |         party|    party/republican|          Republican|[[website, http:/...|https://upload.wi...| null|       null|
    |   legislature|8fa6c3d2-71dc-478...|              Senate|                null|                null|  100|upper house|
    +--------------+--------------------+--------------------+--------------------+--------------------+-----+-----------+
    



```python
memberships.select_fields(['organization_id']).toDF().distinct().show()
```

    +--------------------+
    |     organization_id|
    +--------------------+
    |d56acebe-8fdc-47b...|
    |8fa6c3d2-71dc-478...|
    +--------------------+
    



```python
l_history = Join.apply(orgs,
                       Join.apply(persons, memberships, 'id', 'person_id'),
                       'org_id', 'organization_id').drop_fields(['person_id', 'org_id'])
print ("Count: " + str(l_history.count()))
l_history.printSchema()
```

    Count: 10439
    root
    |-- role: string
    |-- seats: int
    |-- org_name: string
    |-- links: array
    |    |-- element: struct
    |    |    |-- note: string
    |    |    |-- url: string
    |-- type: string
    |-- sort_name: string
    |-- area_id: string
    |-- images: array
    |    |-- element: struct
    |    |    |-- url: string
    |-- on_behalf_of_id: string
    |-- other_names: array
    |    |-- element: struct
    |    |    |-- lang: string
    |    |    |-- note: string
    |    |    |-- name: string
    |-- name: string
    |-- birth_date: string
    |-- organization_id: string
    |-- gender: string
    |-- classification: string
    |-- death_date: string
    |-- legislative_period_id: string
    |-- identifiers: array
    |    |-- element: struct
    |    |    |-- scheme: string
    |    |    |-- identifier: string
    |-- image: string
    |-- given_name: string
    |-- start_date: string
    |-- family_name: string
    |-- id: string
    |-- contact_details: array
    |    |-- element: struct
    |    |    |-- type: string
    |    |    |-- value: string
    |-- end_date: string
    



```python
glueContext.write_dynamic_frame.from_options(frame = l_history,
          connection_type = "s3",
          connection_options = {"path": "s3://< S3 buckets >/blog-jupyter/glue_output/legislator_history"},
          format = "parquet")
```




    <awsglue.dynamicframe.DynamicFrame at 0x7f526c44bdd0>


