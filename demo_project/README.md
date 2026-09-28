Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test

---

1. Create `public.demo_project_orders` table in your database.

```sql
create table public.demo_project_orders (
    order_id serial primary key,
    order_date date not null,
    customer_id int not null,
    order_amount numeric(10,2) not null
);

insert into public.demo_project_orders (order_date, customer_id, order_amount)
values
    ('2024-01-01', 1, 100.00),
    ('2024-01-02', 1, 150.00),
    ('2024-01-03', 2, 200.00),
    ('2024-02-01', 3, 99.99);
```

### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

