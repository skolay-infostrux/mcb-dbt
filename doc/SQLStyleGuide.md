# SQL Style Guide #
> This guide has been, for the most part, shamelessly adapted from the [dbt Style Guide](https://github.com/dbt-labs/corp/blob/main/dbt_style_guide.md) and a few others, see the References section at the end.

## Why? ##
> This section is for those who wonder why would one bother with coding standards and argue that, as long as the code works, one need not bother spending time on making it "pretty". If you already know why, feel free to skip this section.

### Readability ###
Code is read many more times than it is written, so it is imperative that it is easy to read and understand at a glance. Time spent unravelling poorly written code is time taken away from productive work - building new features and improving existing ones. As such, poorly written code is nothing else but technical debt and increases implementation costs.

### Collaboration ###
We all have preferences of how code should be written. However, one person's preference is another person's annoyance. Even worse, as code is worked on my many people, having to switch between different coding styles as one reviews different parts of a codebase can make code interpretation a task much harder than it needs to be. It is, therefore, imperative that developers follow the same coding standard as they author code. A common standard may not be a perfect fit to everyone's preference, but it goes a long way towards collaborating effectively.

### Professionalism ###
As a consulting company, our code will ultimately be read by our client's tech teams. The quality of the code we deliver will influence whether the client sees us as a professional organization. Our professionalism will ultimately result in clients deciding to expand their relationship with us, giving us favourable reviews and possibly even referrals. The quality of our code, then, is a business necessity and a factor for our enduring success.

## How? ##

### Automation ###
If we all agree on following a single standard, it becomes easier to use tools to automate its implementation. Humans often overlook and forget things. Linters exist for exactly that purpose. They should be part of any project's CI pipeline to ensure code merged to all repos follows the same standard.

### SQL Linters ###
We work primarily in SQL. For one reason or another, SQL does not seem to have matured as much in the direction of coding standards the same way as programming languages have. Nevertheless, there is not only a silent consensus on what good SQL should look like but also attempts to come up with a standard format and tools to put them to practice.

Many SQL IDEs and editors attempt to auto-format or at least suggest certain style norms and there exist, at least some, reputable tools to automate both style checks and fixes. Of particular interest to us would be [SQLFluff](https://github.com/sqlfluff/sqlfluff) and the auto-suggestion and auto-formatting features of DBeaver. There is a SQLFluff extension to Visual Studio Code which we will be looking into as well.

## SQL Style Guidelines ##
- **DO NOT OPTIMIZE FOR A SMALLER NUMBER OF LINES OF CODE. NEWLINES ARE CHEAP, BRAIN TIME IS EXPENSIVE**
- Schema, table and column names should be in `snake_case`
- Use names based on the _business_ terminology, rather than the source terminology
- Use trailing commas
- Indents should be four spaces (except for predicates, e.g. `HAVING`, which should line up with the `WHERE` keyword)
- Lines of SQL should be no longer than 80 characters
- Field names should all be lowercase
- SQL keywords and function names should all be UPPERCASE
- The `AS` keyword should be used when aliasing a field or table
- Fields should be stated before aggregates / window functions
- Aggregations should be executed as early as possible before joining to another table.
- Prefer grouping by column name (`GROUP BY customer_id, order_id`) over ordering and grouping by number (`GROUP BY 1, 2`). Note that if you are grouping by more than a few columns, it may be worth revisiting your model design.
- Prefer `UNION ALL` to `UNION` [*](http://docs.aws.amazon.com/redshift/latest/dg/c_example_unionall_query.html)
- Avoid alias initialisms. It is harder to understand what the alias `c` stands for compared to `customers`.
- If joining two or more tables, _always_ prefix your column names with the table alias. If only selecting from one table, prefixes are not needed.
- Be explicit about your join (i.e. write `INNER JOIN` instead of `JOIN`). `LEFT JOIN`s are normally the most useful, `RIGHT JOIN`s often indicate that you should change which table you select `FROM` and which one you `JOIN` to.
- Your join should list the `LEFT` table first (i.e. the table you are selecting `FROM`):
```sql
SELECT
    trips.driver_id,
    drivers.rating AS driver_rating,
    riders.rating AS rider_rating

FROM trips
LEFT JOIN users AS drivers
    ON trips.driver_id = drivers.user_id
LEFT JOIN users AS riders
    ON trips.rider_id = riders.user_id;
```
- Timestamp columns should be named `<event>_at`, e.g. `created_at`, and should be in UTC. If a different timezone is being used, this should be indicated with a suffix, e.g `created_at_pt`.
- Booleans should be prefixed with `is_` or `has_`.
- Currency amount (money) fields should be of `NUMBER(39,4)` data type in Snowflake.
  - In DBMSs which don't support scaled integers, they should be in decimal currency, e.g. `19.99` for $19.99, or
  - in many app DBS, currency amounts are stored as integers in cents; if non-decimal currency is used, indicate this with suffix, e.g. `price_in_cents`.
- Avoid reserved words as column names.
- Consistency is key! Use the same field names across models where possible, e.g. a key to the `customers` table should be named `customer_id` rather than `user_id`.

### Example SQL ###
```sql
WITH

my_data AS (

    SELECT * FROM {{ ref('my_data') }} AS my_data

),

some_cte AS (

    SELECT * FROM {{ ref('some_cte') }} AS some_cte

),

some_cte_agg AS (

    SELECT
        id,
        SUM(field_4) AS total_field_4,
        MAX(field_5) AS max_field_5

    FROM some_cte
    GROUP BY id

),

final AS (

    SELECT DISTINCT
        my_data.field_1,
        my_data.field_2,
        my_data.field_3,
        some_cte_agg.total_field_4,
        some_cte_agg.max_field_5,

        -- Use line breaks to visually separate calculations into blocks
        CASE
            WHEN my_data.cancellation_date IS NULL
                AND my_data.expiration_date IS NOT NULL
                THEN my_data.expiration_date
            WHEN my_data.cancellation_date IS NULL
                THEN my_data.start_date + 7
            ELSE my_data.cancellation_date
        END AS cancellation_date

    FROM my_data
    LEFT JOIN some_cte_agg
        ON my_data.id = some_cte_agg.id
    WHERE my_data.field_1 = 'abc'
        AND (
            my_data.field_2 = 'def'
            OR my_data.field_2 = 'ghi'
        )
    HAVING COUNT(*) > 1

)

SELECT * FROM final
```

## YAML style guide ##
* Indents should be two spaces
* List items should be indented
* Use a new line to separate list items that are dictionaries where appropriate
* Lines of YAML should be no longer than 80 characters.

Example YAML
```yaml
version: 2

models:
  - name: events
    columns:
      - name: event_id
        description: This is a unique identifier for the event
        tests:
          - unique
          - not_null

      - name: event_time
        description: "When the event occurred in UTC (eg. 2018-01-01 12:00:00)"
        tests:
          - not_null

      - name: user_id
        description: The ID of the user who recorded the event
        tests:
          - not_null
          - relationships:
              to: ref('users')
              field: id
```

## References ##
* [dbt Style Guide](https://github.com/dbt-labs/corp/blob/main/dbt_style_guide.md)
* [SQLFluff Rules Reference](https://docs.sqlfluff.com/en/stable/rules.html)
* [Meltano Sql Style Guide](https://handbook.meltano.com/data-team/sql-style-guide)
