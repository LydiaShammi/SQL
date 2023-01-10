CREATE database dbo1;
SET search_path = dbo1;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

  select * from members;
  select * from menu;
  select * from sales;

  Analysis: 1
  What is the total amount each customer spent at the restaurant?

  select s.customer_id,sum(m.price)as total_amount
  from sales s
  join menu m
  on s.product_id=m.product_id
  group by s.customer_id;

  Analysis: 2
  How many days has each customer visited the restaurant?

  select customer_id,count(distinct(order_date)) as No_of_days
  from sales
  group by customer_id;

  Analysis 3 :
What was the first item from the menu purchased by each customer?

WITH ordered_sales_cte AS
(
SELECT customer_id, order_date, product_name,
DENSE_RANK() OVER(PARTITION BY s.customer_id
ORDER BY s.order_date) AS rank
FROM dbo.sales AS s
JOIN dbo.menu AS m
ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM ordered_sales_cte
WHERE rank = 1
GROUP BY customer_id, product_name;

#Analysis 4:
#What is the most purchased  item on the menu and how many times it purchased by all customers?

SELECT (COUNT(s.product_id)) AS most_purchased, product_name
FROM dbo.sales AS s
JOIN dbo.menu AS m
ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY most_purchased DESC
LIMIT 1

#Analysis 5 :
#Which item was the most popular one for each customer?   

WITH fav_item_cte AS  
(
SELECT s.customer_id, m.product_name,
COUNT(m.product_id) AS order_count,
DENSE_RANK() OVER(PARTITION BY s.customer_id
ORDER BY COUNT(m.product_id) DESC) AS rank
FROM dbo.menu AS m
JOIN dbo.sales AS s
ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, order_count
FROM fav_item_cte
WHERE rank = 1;

#Analysis 6 : 
#Which item was purchased first by the customer after they became a member?


WITH member_sales_cte AS
(
SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
DENSE_RANK() OVER(PARTITION BY s.customer_id
ORDER BY s.order_date) AS rank
FROM dbo.sales AS s
JOIN dbo.members AS m
ON s.customer_id = m.customer_id
WHERE s.order_date = m.join_date
)
SELECT s.customer_id, s.order_date, m2.product_name
FROM member_sales_cte AS s
JOIN dbo.menu AS m2
ON s.product_id = m2.product_id


#Analysis 7:
#Which item was purchased right before the customer became a member

WITH prior_member_purchased_cte AS
(
SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
DENSE_RANK() OVER(PARTITION BY s.customer_id
ORDER BY s.order_date DESC) AS rank
FROM dbo.sales AS s
JOIN dbo.members AS m
ON s.customer_id = m.customer_id
WHERE s.order_date < m.join_date
)
SELECT s.customer_id, s.order_date, m2.product_name
FROM prior_member_purchased_cte AS s
JOIN dbo.menu AS m2
ON s.product_id = m2.product_id
WHERE rank = 1;	


#Analysis 8 :
#What is the total number of items and amount spent for each member before they became a member?


SELECT
s.customer_id,
COUNT(DISTINCT s.product_id) AS unique_menu_item,
SUM(mm.price) AS total_sales
FROM
dbo.sales AS s
JOIN
dbo.members AS m
ON s.customer_id = m.customer_id
JOIN
dbo.menu AS mm
ON s.product_id = mm.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;

#Analysis 9:
#If each customers’ $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have ?

WITH price_points AS
(
SELECT *,
CASE
WHEN product_id = 1 THEN price * 20
ELSE price * 10
END AS points
FROM
dbo.menu
)
SELECT
s.customer_id,
SUM(p.points) AS total_points
FROM
price_points AS p
JOIN
dbo.sales AS s
ON p.product_id = s.product_id
GROUP BY
s.customer_id
ORDER BY
customer_id



#Analysis 10:
In the first week after a customer joins the program, (including their join date) they earn 2x points on all items; not just sushi —
how many points do customer A and B have at the end of Jan21?
Note :here you can use a concept of interval function which returns the index of the argument that is more than the first
argument meaning It returns 0 if 1st number is less than the 2nd number and 1 if 1st number is less than the 3rd number and so
on or -1 if 1st number is null

WITH dates_cte AS
(
SELECT *,
join_date + INTERVAL'6 day' AS valid_date,
DATE('2021-01-31') AS last_date
FROM
dbo.members AS m
),
points_cte AS (
SELECT d.customer_id, s.order_date, d.join_date,
d.valid_date, d.last_date, m.product_name, m.price,
SUM(CASE
WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
ELSE 10 * m.price
END) AS points
FROM dates_cte AS d
JOIN dbo.sales AS s
ON d.customer_id = s.customer_id
JOIN dbo.menu AS m
ON s.product_id = m.product_id
WHERE s.order_date < d.last_date
GROUP BY d.customer_id, s.order_date, d.join_date, d.valid_date, d.last_date, m.product_name, m.price
)
SELECT
customer_id,
SUM(points) AS total_points
FROM
points_cte
GROUP BY
customer_id

                                                  
***************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************
















