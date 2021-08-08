# Data Cleaning with SQL🧼
In this project, I have showcased different techniques used for data cleaning in SQL. From exploring the data to finding inconsistencies in the data, and then removing the inconsistencies, SQL has specific methods for all.

There are two files in this repository that contains the queries I executed to explore and clean the data.
#### [Version 1](https://github.com/khanmazhar/data-cleaning-with-sql/blob/main/queries_v1.sql): 
This SQL file contains only the queries that I used to explore and clean the data.
#### [Version 2](https://github.com/khanmazhar/data-cleaning-with-sql/blob/main/queries_v2.sql):
This SQL file contains queries that I ran to first normalize the data and then explore and clean the data. While this step is not necessary for data analysis, it can speed up the queries run time alot.
The idea is that performing queries on strings in a database usually takes longer time to execute. Therefore, we create a separate table for repeating strings and connect it to the main table using a foreign key.
