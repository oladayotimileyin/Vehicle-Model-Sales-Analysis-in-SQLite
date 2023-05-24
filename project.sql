--- Scale Model Cars
/*
It has 8 tables namely 

productLine: a list of product line categories
Customers: customer data
Employees: all employee information
Offices: sales office information
Orders: customers' sales orders
OrderDetails: sales order line for each sales order
Payments: customers' payment records
Products: a list of scale model cars
*/

--- Table connections
/*
productlines >> products : productLine on productCode
products >> orderdetails : productCode on productCode
orderdetails >> orders : orderNumber on orderNumber
orders >> customers : orderNumber on customerNumber
customers >> payments : customerNumber on customerNumber
customers >> employees : customerNumber on employeeNumber
employees >> offices : employeeNumber on officeCode

*/

--- quick inspections

SELECT 'customers' AS table_name, (SELECT COUNT(*) AS number_of_attributes FROM pragma_table_info('customers')), COUNT(*) AS number_of_rows FROM customers
UNION ALL
SELECT 'Products', (SELECT COUNT(*) FROM pragma_table_info('products')), COUNT(*) FROM Products
UNION ALL
SELECT 'ProductLines', (SELECT COUNT(*) FROM pragma_table_info('productlines')), COUNT(*) FROM ProductLines
UNION ALL
SELECT 'Orders', (SELECT COUNT(*) FROM pragma_table_info('orders')), COUNT(*) FROM Orders
UNION ALL
SELECT 'OrderDetails', (SELECT COUNT(*) FROM pragma_table_info('orderdetails')), COUNT(*) FROM OrderDetails
UNION ALL
SELECT 'Payments', (SELECT COUNT(*) FROM pragma_table_info('payments')), COUNT(*) FROM Payments
UNION ALL
SELECT 'Employees', (SELECT COUNT(*) FROM pragma_table_info('employees')), COUNT(*) FROM Employees
UNION ALL
SELECT 'Offices', (SELECT COUNT(*) FROM pragma_table_info('offices')), COUNT(*) FROM Offices;


---- Question 1 : Which Products Should We Order More of or Less of?
--- First we find products that are low in stock

SELECT p.productCode, p.productName, p.productLine,(SUM(quantityOrdered)/quantityInStock) AS stock_level
FROM products p
JOIN orderdetails o
ON p.productCode = o.productCode
GROUP BY p.productCode
ORDER BY stock_level
LIMIT 10;

--- second we compute product performance
SELECT p.productCode, p.productName, SUM(quantityOrdered * priceEach) AS product_performance
FROM products p
JOIN orderdetails o
ON p.productCode = o.productCode
GROUP BY p.productCode
ORDER BY product_performance DESC
LIMIT 10;

WITH stk_lv AS (
SELECT p.productCode, p.productName, p.productLine,(SUM(quantityOrdered)/quantityInStock) AS stock_level
FROM products p
JOIN orderdetails o
ON p.productCode = o.productCode
GROUP BY p.productCode),
perf_lv AS (
SELECT p.productCode, p.productName, SUM(quantityOrdered * priceEach) AS product_performance
FROM products p
JOIN orderdetails o
ON p.productCode = o.productCode
GROUP BY p.productCode
ORDER BY product_performance DESC
LIMIT 10)

SELECT stk_lv.*, perf_lv.product_performance
FROM stk_lv
JOIN perf_lv ON stk_lv.productCode = perf_lv.productCode
ORDER BY perf_lv.product_performance DESC;

/*
WITH stk_lv AS (
SELECT p.productCode, p.productName, (SUM(quantityOrdered)/quantityInStock) AS stock_level
FROM products p
JOIN orderdetails o
ON p.productCode = o.productCode
GROUP BY p.productCode
ORDER BY stock_level
LIMIT 10)

SELECT *
FROM stk_lv
WHERE stk_lv.productCode IN (
SELECT p.productCode, p.productName, SUM(quantityOrdered * priceEach) AS product_performance
FROM products p
JOIN orderdetails o
ON p.productCode = o.productCode
GROUP BY p.productCode
ORDER BY product_performance DESC
LIMIT 10);
*/

/*
Question 2: How Should We Match Marketing and Communication Strategies to Customer Behavior?
*/

SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit_generated
FROM products p
JOIN orderdetails od 
  ON p.productCode = od.productCode
JOIN orders o 
ON o.orderNumber = od.orderNumber
GROUP BY o.customerNumber;

/* Finding the VIP and Less Engaged Customers */
WITH eng_cus AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit_generated
FROM products p
JOIN orderdetails od 
  ON p.productCode = od.productCode
JOIN orders o 
ON o.orderNumber = od.orderNumber
GROUP BY o.customerNumber)

SELECT c.contactLastName, c.contactFirstName, c.city, c.country, ec.profit_generated
FROM customers c
JOIN eng_cus ec
ON c.customerNumber = ec.customerNumber
ORDER BY ec.profit_generated DESC
LIMIT 5;

--- Five least engaged customers
WITH eng_cus AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit_generated
FROM products p
JOIN orderdetails od 
  ON p.productCode = od.productCode
JOIN orders o 
ON o.orderNumber = od.orderNumber
GROUP BY o.customerNumber)

SELECT c.contactLastName, c.contactFirstName, c.city, c.country, ec.profit_generated
FROM customers c
JOIN eng_cus ec
ON c.customerNumber = ec.customerNumber
ORDER BY ec.profit_generated 
LIMIT 5;



/* 
Question 3: How Much Can We Spend on Acquiring New Customers?
*/

WITH eng_cus AS (
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit_generated
FROM products p
JOIN orderdetails od 
  ON p.productCode = od.productCode
JOIN orders o 
ON o.orderNumber = od.orderNumber
GROUP BY o.customerNumber)

SELECT AVG(ec.profit_generated) AS life_time_value
FROM eng_cus ec;


/* CONCLUSIONS

Question !: Which products should we order more of or less of?
  Answer: From our analysis, it was shown that 2001 Ferrari Enzo from the Classic cars line needs to restock more often and have the best performance. 
  Likewsie, classic cars have the best performance of the product lines
  
Question 2: How should we tailor marketing and communication strategies to customer behaviors?
Answer: Analysing the query results of top and bottom customers in terms of profit generation,
              we need to offer loyalty rewards and priority services for our top customers to retain them.
			  Also for bottom customers we need to solicit feedback to better understand their preferences, 
			  expected pricing, discount and offers to increase our sales
			  
Question 3: How much can we spend on acquiring new customers?
Answer 3: The average customer liftime value of our store is $ 39,040. This means for every new customer we make profit of 39,040 dollars. 
	          We can use this to predict how much we can spend on new customer acquisition, 
			  at the same time maintain or increase our profit levels.
			  
END OF PROJECT 

*/
  
