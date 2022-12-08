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

  Analysis: 3
  What was the first item from the menu purchased by each customer?

select customer_id,product_id 
With small as
(select s.customer_id,s.order_date,m.product_id
from sales s
join menu m
on s.product_id=m.product_id
group by s.customer_id,s.order_date,m.product_id)as sub
group by customer_id,product_id
order by sub.order_date;

