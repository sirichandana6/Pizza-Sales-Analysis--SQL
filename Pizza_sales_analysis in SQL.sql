-- Importing csv data files to sql

create database pizzahut;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));

-- ANALYSIS ON DATA 
-- 1) Total number of orders placed
      
	select count(order_id) as total_orders from orders;
    
-- 2) Total Revenue generated from pizza sales

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- 3) Which is the highest priced pizza?
SELECT 
    name, price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- 4) Which is the most common pizza size ordered?

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- 5) Which are the 5 most ordered pizza types along with their quantities
SELECT 
    pizza_types.name, SUM(order_details.quantity) as quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- 6) Find the total quantity of each pizza ordered
SELECT 
    pizza_types.category, SUM(order_details.quantity) as quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- 7) Distribution of orders by hour of the day
SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS OrderCount
FROM
    orders
GROUP BY HOUR(order_time);

-- 8)Category wise distribution of pizzas 
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- 9) Group the orders by date and calculate average number of pizzas ordered per day
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizzas_ordered_perday
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;


-- 10)Top 3 most ordered pizzas based on revenue
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- 11) Percentage contribition of each pizza type to total revenue 
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- 12) Analysis on cumulative revenue generated over time
select order_date, sum(revenue) over(order by order_date) as cum_revenue
from
 (select orders.order_date,
 sum(order_details.quantity*pizzas.price) as revenue
 from order_details join pizzas
 on order_details.pizza_id=pizzas.pizza_id
 join orders on 
orders.order_id=order_details.order_id
 group by orders.order_date) as sales;
 
 -- 13) Top 3 most ordered pizza types based on revenue for each pizza category 
 select name, revenue from 
 (select category, name, revenue,
 rank() over(partition by category order by revenue desc) as rn
 from
 (select pizza_types.category, pizza_types.name,
 sum((order_details.quantity)*pizzas.price) as revenue
 from pizza_types join pizzas
 on pizza_types.pizza_type_id=pizzas.pizza_type_id
 join order_details
 on order_details.pizza_id=pizzas.pizza_id
 group by pizza_types.category, pizza_types.name) as a) as b
 where rn<=3;

      

    




