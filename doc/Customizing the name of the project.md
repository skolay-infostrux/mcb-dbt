## **Customizing the name of the project**
In dbt the name of the project must follow the `snake_case` rules(letters, digits and underscores only, and cannot start with a digit). <br>
See dbt docs here https://docs.getdbt.com/reference/project-configs/name.

Change to your desired name in these files:
- dbt_project.yml (must use `snake_case` with '_' as word separator e.g. 'sag_dbt')
  - in the **root**
    ```
    name: 'sag_dbt'
    ```

  - under **models:** node
    ```
    models:
    ...
    sag_dbt:
    ```
- when using **Docker** (best paractice: use '-' or '_' as word separator e.g. 'sag-dbt')
    - <u>Dockerfile</u>
        ```
        ARG PROJECT="sag-dbt"
        ```
    - <u>Makefile</u>
      You must use the same name used in the <u>Dockerfile</u> e.g. 'sag-dbt'
        ```
        PROJECT := "sag-dbt"
        ```
