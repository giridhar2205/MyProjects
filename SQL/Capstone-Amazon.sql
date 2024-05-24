Aim of the project
-------------------
The major aim of the project is to gain valuable insights into the sales data of Amazon in order to understand the various factors 
influencing sales across different branches. By analyzing the sales data, we aim to uncover patterns, trends, and correlations that 
can provide valuable information for decision-making and strategic planning. This analysis will help identify key drivers of sales performance, 
such as customer demographics, product preferences, sales channels, and promotional strategies. Ultimately, the goal is to leverage this insight
 to optimize sales strategies, improve operational efficiency, and enhance overall business performance.

Table created with below syntax and for the given data is imported
there are 1000 rows and 17 columns post import. 3 more columns were added as per the project requirement

observations - in data
------------
database amazondata was created with table amazon into it

table creation
CREATE TABLE amazon (
    invoice_id VARCHAR(30),
    branch VARCHAR(5),
    city VARCHAR(30),
    customer_type VARCHAR(30),
    gender VARCHAR(10),
    product_line VARCHAR(100),
    unit_price DECIMAL(10, 2),
    quantity INT,
    VAT FLOAT(6, 4),
    total DECIMAL(10, 2),
    date DATE,
    time TIMESTAMP,
    payment_method varchar(20),
    cogs DECIMAL(10, 2),
    gross_margin_percentage FLOAT(11, 9),
    gross_income DECIMAL(10, 2),
    rating FLOAT(2, 1)
);


in the table creation payment_method is a string ,ewallet, cash, cr card, decimal cannot be created, 
taken varchar

invoice _id - taken  a primary key so that no duplication are created.

primary key created
ALTER TABLE amazon
ADD PRIMARY KEY (invoice_id);

Csv file - column I was mentioned as (tax5% )- changed it to VAT

cheking null values
SELECT 
    SUM(CASE WHEN 'invoice id' IS NULL THEN 1 ELSE 0 END) AS null_invoice_id,
    SUM(CASE WHEN branch IS NULL THEN 1 ELSE 0 END) AS null_branch,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN 'customer type' IS NULL THEN 1 ELSE 0 END) AS null_customer_type,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS null_gender,
    SUM(CASE WHEN product_line IS NULL THEN 1 ELSE 0 END) AS null_product_line,
    SUM(CASE WHEN' unit price' IS NULL THEN 1 ELSE 0 END) AS null_unit_price,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN VAT IS NULL THEN 1 ELSE 0 END) AS null_VAT,
    SUM(CASE WHEN total IS NULL THEN 1 ELSE 0 END) AS null_total,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS null_date,
    SUM(CASE WHEN time IS NULL THEN 1 ELSE 0 END) AS null_time,
    SUM(CASE WHEN payment IS NULL THEN 1 ELSE 0 END) AS null_payment_method,
    SUM(CASE WHEN cogs IS NULL THEN 1 ELSE 0 END) AS null_cogs,
    SUM(CASE WHEN 'gross margin percentage' IS NULL THEN 1 ELSE 0 END) AS null_gross_margin_percentage,
    SUM(CASE WHEN 'gross income' IS NULL THEN 1 ELSE 0 END) AS null_gross_income,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS null_rating
FROM 
    amazon;

adding 3 new columns  as per project requirement
 Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. This will help answer the question on which part of the day most sales are made.

ALTER TABLE amazon
ADD timeofday VARCHAR(20);

SET timeofday = (
    CASE 
        WHEN TIME(time) BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN TIME(time) BETWEEN '12:00:01' AND '18:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END
);
         

ALTER TABLE amazon
ADD dayname VARCHAR(10);

updating datname
UPDATE amazon
SET dayname = DAYNAME(STR_TO_DATE(date, '%d-%m-%Y'));

updating month name
ALTER TABLE amazon
ADD monthname VARCHAR(10);

UPDATE monthname
SET monthname = MONTHNAME(STR_TO_DATE(date, '%d-%m-%Y'));

select * from amazon; 

Normalisation
-------------
Normalization principles primarily apply when you have multiple tables in a relational database. However, even with just one table, you can still apply 
some principles of normalization to ensure data integrity and efficiency.

QUERIES answered as per business requirememt
--------------------------------------------
q1 What is the count of distinct cities in the dataset?
SELECT COUNT(DISTINCT city)from amazon;

q2 For each branch, what is the corresponding city?
select branch,city  from amazon;

q3 What is the count of distinct product lines in the dataset? 
SELECT COUNT(DISTINCT Product_line) FROM amazon;

q4 Which payment method occurs most frequently?
SELECT payment, COUNT(*) AS frequency FROM amazon GROUP BY payment ORDER BY frequency DESC

q5 Which product line has the highest sales?
SELECT product_line, SUM(total) AS total_sales FROM amazon 
GROUP BY product_line ORDER BY total_sales DESC LIMIT 3;

Q6 How much revenue is generated each month?
SELECT monthname ,SUM(TOTAL) FROM amazon GROUP BY monthname

q7 In which month did the cost of goods sold reach its peak?
SELECT  MONTHNAME,SUM(cogs) AS cost_of_goods_sold FROM  amazon 
GROUP BY monthname ORDER BY cost_of_goods_sold DESC LIMIT 3;

q8 Which product line generated the highest revenue?
SELECT  product_line,    SUM(total) AS total_revenue FROM  amazon
GROUP BY  product_line ORDER BY  total_revenue DESC LIMIT 3;

q9 In which city was the highest revenue recorded?
SELECT city, SUM(total) AS highest_revenue FROM amazon 
GROUP BY city ORDER BY highest_revenue DESC LIMIT 3;

q10 Which product line incurred the highest Value Added Tax?
SELECT product_line, SUM(vat) AS highest_vat FROM amazon 
GROUP BY product_line ORDER BY highest_vat DESC LIMIT 3;

q11 For each product line, add a column indicating "Good" if its sales are above average, 
otherwise "Bad."
SELECT 
    *,
    CASE 
        WHEN total > avg_sales THEN 'Good'
        ELSE 'Bad'
    END AS sales_status
FROM (
    SELECT 
        *,
        AVG(total) OVER (PARTITION BY product_line) AS avg_sales
    FROM 
        amazon
) AS avg_data;

q12 Identify the branch that exceeded the average number of products sold --
SELECT 
    a.branch,
    SUM(a.quantity) AS total_products_sold,
    AVG(b.avg_quantity) AS avg_products_sold
FROM 
    amazon AS a
JOIN (
    SELECT 
        branch,
        AVG(quantity) AS avg_quantity
    FROM 
        amazon
    GROUP BY 
        branch
) AS b ON a.branch = b.branch
GROUP BY 
    a.branch
HAVING 
    SUM(a.quantity) > AVG(b.avg_quantity);
    
q13 Which product line is most frequently associated with each gender?
SELECT
    product_line, gender,COUNT(*) AS frequency
FROM
    amazon GROUP BY gender,product_line ORDER BY gender,frequency DESC;
    
q14 Calculate the average rating for each product line.
SELECT
    product_line,AVG(rating) AS average_rating
FROM
    amazon GROUP BY product_line order by average_rating desc;

q15 Count the sales occurrences for each time of day on every weekday.
SELECT
    dayname,
    CASE
        WHEN TIME(time) BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN TIME(time) BETWEEN '12:00:01' AND '18:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day,
    COUNT(*) AS sales_occurrences
FROM
    amazon
GROUP BY
    dayname,
    time_of_day

q16 Identify the customer type contributing the highest revenue
SELECT
    customer_type, SUM(total) AS total_revenue FROM amazon 
    GROUP BY customer_type ORDER BY total_revenue DESC ;

q17 Determine the city with the highest VAT percentage
SELECT  city, AVG(VAT / total * 100) AS avg_vat_percentage
FROM
    amazon GROUP BY  city ORDER BY  avg_vat_percentage DESC LIMIT 3;
    
q18 Identify the customer type with the highest VAT payments
SELECT
    customer_type,    SUM(VAT) AS total_vat_payments
FROM
    amazon GROUP BY customer_type ORDER BY total_vat_payments DESC LIMIT 1;
    
q19 What is the count of distinct customer types in the dataset
 SELECT customer_type,COUNT(DISTINCT customer_type) AS distinct_customer_types 
FROM amazon group by customer_type;

q20 What is the count of distinct payment methods in the dataset
SELECT payment,COUNT(DISTINCT payment) AS distinct_payment
FROM amazon group by payment;

q21 Which customer type occurs most frequently
SELECT customer_type, COUNT(*) AS frequency
FROM amazon
GROUP BY customer_type
ORDER BY frequency DESC;

q22 Identify the customer type with the highest purchase frequency
SELECT
    customer_type, COUNT('Unit price'*Quantity) AS purchase_frequency
FROM amazon GROUP BY customer_type ORDER BY purchase_frequency ;

q23 Determine the predominant gender among customers
SELECT gender,COUNT(*) AS gender_count FROM
 amazon GROUP BY  gender  ;

q24 Examine the distribution of genders within each branch
SELECT
    branch,
    gender,
    COUNT(*) AS gender_count,
    COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY branch) AS gender_proportion
FROM    amazon GROUP BY branch, gender ORDER BY branch, gender_count DESC;

q25 Identify the time of day when customers provide the most ratings
SELECT
    CASE
        WHEN TIME(time) BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN TIME(time) BETWEEN '12:00:01' AND '18:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day,
    COUNT(*) AS rating_count
FROM
    amazon GROUP BY time_of_day
ORDER BY rating_count DESC ;

q26 Determine the time of day with the highest customer ratings for each branch
SELECT branch,
    CASE
        WHEN TIME(time) BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN TIME(time) BETWEEN '12:00:01' AND '18:00:00' THEN 'Afternoon'
        ELSE 'Evening'    END AS time_of_day,
    COUNT(*) AS rating_count
FROM  amazon GROUP BY  branch,time_of_day
ORDER BY branch, rating_count DESC;

q27 Identify the day of the week with the highest average ratings
SELECT 
    dayname,
    AVG(rating) AS avg_rating 
FROM 
    amazon 
GROUP BY 
    dayname 
ORDER BY 
    avg_rating DESC;

q28 Determine the day of the week with the highest average ratings for each branch.
SELECT
    branch,
    dayname,
    AVG(rating) AS avg_rating
FROM
    amazon
GROUP BY
    branch,
    dayname
ORDER BY
    branch,
    avg_rating DESC;