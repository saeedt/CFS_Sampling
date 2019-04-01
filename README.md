# CFS Sample Design Data and Scripts
Data and Scripts for the proposed sample design for CFS are stored in this repository. 
Following are the list of folders and their content. 

## Raw_Data
Main data sources used for generating the sample data are stored in this folder. 
* `FAF441_2016.csv` is 2016 FAF acquired from <https://www.bts.gov/faf>
* `Commodity_Naics.csv` is the mapping made between the SCTG codes used in the FAF 2016 dataset and NAICS codes used in CBP dataset.
* `cbp16co.7z` 2016 County Business Pattern complete county file acquired from <https://www.census.gov/data/datasets/2016/econ/cbp/2016-cbp.html>. Use [7-Zip](https://www.7-zip.org/) to extract the compressed archive. This is a huge text file with over 2 million rows and over 170 MB in size. It will crash most text editors like notepad!

## SQL
SQL Scripts used to create tables and anaylze the raw data are store in this folder. We used [PostgreSQL](https://www.postgresql.org/) which is a free open source database management system (DBMS). The queries and functions can be run on PostgreSQL 9.6 or later. Running on other SQL compatible DBMSs such as MySQL/MriaDB or MS SQL Server may require minor modifications. 

* `SQL_Scripts.sql` includes the scripts for creating tables and all queries developed for cleaning and aggregating the data. The comments in this file provide a high level explanation of each step. We used Common Table Expressions (CTEs) to merge multiple related queries in one step. 
* `Generate_est.sql' includes a function written in procedural PostgreSQL language that generates a sampling frame with user defined parameters based on CBP and FAF datasets. 

## Final_Data
Includes the final output of the scripts in `SQL` folder applied to the data in `Raw_Data`. 
* `fafcbp.csv` is the combined FAF and CBP datasets in CSV format. It is the disaggregated FAF data by county and NAICS based on CBP data. This data is needed by the `generate_est` function presented in `SQL` folder.
* `100K_Frame.csv` is a set of 100,000 establishments generated with the `generate_est` function. 