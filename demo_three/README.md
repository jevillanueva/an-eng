Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices


1. Base Info

Create raw_orders only if it does not exist

```sql
create schema if not exists demo_three;
create table if not exists demo_three.raw_orders (
    order_id int primary key,
    order_date date not null,
    customer_id int not null,
    order_amount numeric(10,2) not null,
    status text not null
);
```

Add some demo data (ignore duplcates if they exist)

```sql
insert into demo_three.raw_orders (order_id, order_date, customer_id, order_amount, status)
values
    (1, '2024-01-01', 1, 100.00, 'completed')
on conflict (order_id) do nothing;

insert into demo_three.raw_orders (order_id, order_date, customer_id, order_amount, status)
values
    (2, '2024-01-02', 1, 150.50, 'completed'),
    (3, '2024-01-03', 2, 200.00, 'pending'),
    (4, '2024-02-01', 3, 99.99, 'completed'),
    (5, '2024-03-10', 2, 250.00, 'completed'),
    (6, '2024-03-15', 3, 300.00, 'cancelled')
    ON CONFLICT (order_id) DO NOTHING;

select * from demo_three.raw_orders order by order_id;
```


For Apply Reusable Cleaning Macros to stg_customers

```sql
drop table if exists demo_three.customers_raw cascade;

create table demo_three.customers_raw (
    customer_id int primary key,
    customer_name text,
    email text,
    country text
); 

insert into demo_three.customers_raw (customer_id, customer_name, email, country)
values
    (1, '   Alice   ', 'Alice@example.Com', 'USA'),
    (2, 'bob', 'bob@example.com', 'uk'),
    (3, 'CHARLIE   ', 'charlie@example.org', 'India'),
    (4, null, 'missing@example.com', 'USA'),
    (5, 'Eve', null, 'France');

select * from demo_three.customers_raw;
```
