For incremental snapshots

```sql
drop table if exists public.fact_orders cascade;
drop table if exists public.raw_orders cascade;

create table public.raw_orders (
    order_id int primary key,
    order_date date not null,
    customer_id int not null,
    order_amount numeric not null,
    status text not null
);

insert into public.raw_orders (order_id, order_date, customer_id, order_amount, status)
values
    (1, '2024-01-01', 1, 100.00, 'completed'),
    (2, '2024-01-02', 1, 150.00, 'completed'),
    (3, '2024-01-03', 2, 200.00, 'pending');

-- before the first run add more data
insert into public.raw_orders (order_id, order_date, customer_id, order_amount, status)
values
    (4, '2024-02-01', 3, 99.99, 'completed'),
    (5, '2024-03-10', 2, 250.00, 'completed'),
    (6, '2024-03-15', 4, 300.00, 'cancelled');
```

For dim_customers snapshots

```sql
drop table if exists public.dim_customers cascade;

create table public.raw_customers (
    customer_id int primary key,
    customer_name text not null,
    city text not null,
    updated_at timestamp not null
);

insert into public.raw_customers (customer_id, customer_name, city, updated_at)
values
    (1, 'Alice', 'New York', now()),
    (2, 'Bob', 'Los Angeles', now()),
    (3, 'Charlie', 'Chicago', now());
```

After first snapshot update some values

```sql
update public.raw_customers
set city = 'San Francisco', updated_at = now()
where customer_id = 2;

update public.raw_customers
set customer_name = 'Charlie Brown', updated_at = now()
where customer_id = 3;
```

After tests insert more data into raw_customers

```sql
insert into public.raw_customers (customer_id, customer_name, city, updated_at)
values
    (4, 'David', 'Miami', now()),
    (5, 'Eve', 'Seattle', now());
```