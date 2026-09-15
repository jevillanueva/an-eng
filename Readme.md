1. Install requirements in virtual environment

```bash
pip install -r requirements.txt
```

2. Test dbt version

```bash
dbt --version
```

3. Create a new dbt project

```bash
dbt init demo_dag_pg
```

4. Configure the database connection in the `profiles.yml` file. The file
is located in the `~/.dbt/` directory.
On Windows, it is located in the `C:\Users\<YourUsername>\.dbt\` directory.

5. Enter the dbt project directory

```bash
cd demo_dag_pg
```

6. Test the dbt project setup

```bash
dbt debug
```

7. Run the dbt project

```bash
dbt run
```

8. Verify the dbt project run results in the target database.

9. Create seeds, load files into the seeds directory, and run them the files called
`customers.csv` and `orders.csv` files.

10. Execute the seeds to load the data into the database and verify the results.

```bash
dbt seed
```