# aus-web-data-crawl-abr
Approach to building a data pipeline for Australian Company Information: Extraction, Cleaning, and Integration

Technology Choices and Rationale 

Apache Spark:
Purpose: Large-scale data processing. 
Rationale: Spark is chosen for its ability to handle large datasets efficiently. It provides distributed data processing capabilities, making it ideal for processing the Common Crawl dataset and ABR data. 

Databricks:
Purpose: Collaborative data engineering and machine learning. 
Rationale: Databricks offers a unified analytics platform that simplifies the management and scaling of Spark jobs. It also provides collaborative features for data engineering teams. 

Python:
Purpose: Scripting. 
Rationale: Python is widely used in data engineering for its simplicity and extensive libraries. It is used for initial data extraction, cleaning, and transformation tasks. 

DBT (Data Build Tool):
Purpose: Data transformation and testing. 
Rationale: DBT is ideal for transforming and testing data. It allows for modular SQL-based transformations and ensures data quality through built-in testing capabilities. 

PostgreSQL:
Purpose: Storing integrated data. Rationale: 
PostgreSQL is a robust and reliable relational database. It is used to store the cleaned and integrated company data, providing efficient querying and indexing capabilities.

Pipeline Steps:

Step 1: 
Extract Australian Company Websites from Common Crawl 
• Search for domain URLs like.com.au, net.au, etc. using Common Crawl index. 
• Fetch corresponding WARC records and extract useful details (Company Name, Industry, Emails, Contact Info).
• Store the extracted website data in a structured format. Using your script provided in first cell, we will refine the Common Crawl extraction: 
• Extract company names from titles/meta tags. 
• Detect industries based on keywords. 
• Extract email, phone numbers, and social media links.

Step 2: Fetch Business Data from ABR (refer second cell)
• Query the Australian Business Register (ABR) using  dataset from (data.gov.au). 
• Extract company names, with the ABN and other business details. 
• Clean the data to handle inconsistencies in names.

Step 3: 
Data Cleaning & Normalization using Spark Dataframes and DBT 
• Remove duplicate entries. 
• Clean and normalize website data: Convert company names and industries to lowercase and trim spaces 
• Clean and normalize website data: Convert company names and industries to lowercase and trim spaces using DBT model (aus_company_data.sql)

Step 4: Store Processed Data in Postgres 
• Define a schema to store the integrated company data. 

Schema Design (Postgres DDL) Tables:
CREATE TABLE australian_websites ( id SERIAL PRIMARY KEY, url TEXT UNIQUE NOT NULL, company_name TEXT, title TEXT, description TEXT, industry TEXT, email_id TEXT, contact_no TEXT, social_links TEXT, snapshot_date TIMESTAMP );

CREATE TABLE abr ( abn VARCHAR(20) PRIMARY KEY, business_name TEXT NOT NULL, state TEXT, postcode TEXT, source TEXT DEFAULT 'ABR' );

-- Create an integrated view of company data 
CREATE VIEW aus_company_data AS SELECT COALESCE(aw.company_name, ab.business_name) AS company_name, aw.url AS website_url, ab.abn, aw.industry, aw.email_id, aw.contact_no, ab.state, ab.postcode FROM australian_websites aw LEFT JOIN abr ab ON LOWER(aw.company_name) = LOWER(ab.business_name);
• Load cleaned data into a Postgres databasec(refer fourth cell). 

Step 5: Implement Tests & Permissions in DBT 
• Add uniqueness,not null and referential integrity tests in dbt (dbt_integrity_test.sql,refer dbt_integrity_test and permissions.yml). 
• Ensure the tables are readable using the reader role in Postgres.
--Create Reader Role: CREATE ROLE reader; --Grant Select Permission to Reader Role: GRANT SELECT ON TABLE australian_websites TO reader; GRANT SELECT ON TABLE abr TO reader; GRANT SELECT ON VIEW aus_company_data TO reader; --Assign Reader Role to Users: GRANT reader TO username;

Step 6: Querying the Data for Business Insights 
• Example queries:
  --Retrieve all businesses in a given industry:
SELECT * FROM aus_company_data WHERE industry = 'Technology';
--Count the number of companies per industry:
SELECT industry, COUNT(*) AS company_count FROM aus_company_data GROUP BY industry;
--List companies with social media links: SELECT company_name, social_links FROM aus_company_data WHERE social_links IS NOT NULL;

