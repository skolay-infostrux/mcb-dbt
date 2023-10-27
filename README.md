# Welcome to your `dbt` project!
## Review documents in [./doc](./doc/) folder
1. [Generating a Snowflake Private Key.md](./doc/Generating%20a%20Snowflake%20Private%20Key.md)
1. [Development in Python (.venv).md](./doc/Development%20in%20Python%20(.venv).md)
1. [Pre-commit.md](./doc/Pre-commit.md)
- other useful documents in [./doc](./doc/) folder


## **Prerequisites**
1. Snowflake account exists and is setup.
    - user accounts were created.
    - basic roles, warehouses and databases are present.
      <br> ***NOTE:** this step should be done using the customer-specific **terraform** project*

2. Configure Snowflake [key-pair authentication](https://docs.snowflake.com/en/user-guide/key-pair-auth.html) for your Snowflake user.
<br> see: [doc/Generating a Snowflake Private Key.md](./doc/Generating%20a%20Snowflake%20Private%20Key.md)
<br> ***NOTE:** Don't store the key in this directory - you don't want to commit it to git by accident.*

3. **Python 3.10** is installed on the local machine.<br>__*IMPORTANT: version has to be 3.8 <= version <= 3.10*__
   - `venv` package is installed<br>
    You may need to install `venv` package (if missing) with<br>
    `sudo apt install python3.10-venv`

5. __*Visual Studio Code*__ is installed

### **Choose development container (venv vs. docker)**
- _**Docker**_ <br>
    - can encapsulate more than Python dependencies e.g. apps like VScode or an the entire OS.
    - completely isolated from host, including env variables
    - required apps need to be installed in the container's `Dockerfile`<br>
      including python, pip, git, dbt and any other necessary applications
    - is heavier than `venv`
      - image can get big, larger than `(.venv)` folder
      - memory footprint is larger than `venv`
    - see: [doc/Development in `Docker` Container.md](./doc/Development%20in%20Docker%20container.md)

- _**venv**_ <br>
    - only encapsulates Python dependencies.
    - not fully isolated from the host
    - can run all apps already installed on the host e.g. VScode, python, pip, git, terraform
    - is lighter than Docker. Disk size of (.venv) and memory footprint are smaller
    - will default to packages on the host environment<br>
    - see: [doc/Development in Python (.venv).md](./doc/Development%20in%20Python%20(.venv).md)




## **Setting environment variables**
The project is using the `.env` file in the project root folder.
The `.env` file is automatically loaded when the container [`(.venv)` | `(.docker)`] is started

 > **Note:** It is important to use `.env` for any sensitive information since it will not be checked into source control.
 > <br>       The `.env` file is explicitly excluded in `.gitignore` file.
 > <br>       **_The `.env` file will not be checked in GitHub repository !!!_**

1. Start by copying the content of `.env.sample` file into the new `.env`.
    ```bash
    cp .env.sample .env
    ```

2. Example<br>
  Assuming all your credentials are stored in the folder `${HOME}/.ssh/`
    > ```bash
    > # SNOWFLAKE credentials
    > export DBT_SNOWFLAKE_ACCOUNT=$(cat "${HOME}/.ssh/snowflake.account")
    > export DBT_SNOWFLAKE_USER=$(cat "${HOME}/.ssh/snowflake.username")
    > export DBT_SNOWFLAKE_PASSWORD=$(cat "{HOME}/.ssh/snowflake.password")
    >  ```
    ***Hint:** You can avoid having the credentials in clear in the `.env` by redirecting to files in the secure folder `${HOME}/.ssh/` .*

3. Modify `.env` as necessary or add additional variables if needed
    ```bash
    # SNOWFLAKE credentials
    export DBT_SNOWFLAKE_ACCOUNT=<Snowflake Account>
    export DBT_SNOWFLAKE_USER=<Snowflake Username>
    export DBT_SNOWFLAKE_PASSWORD=<Snowflake Password>
    ```

### **Modifying environment variables**
The `.env` file is automatically loaded when the container is started. <br>However, re-load the updated `.env` file while in then container:<br>
```bash
source .env
```

## **Start developing in the container (`venv` or `docker`)**

Execute this command in the **root folder of your project**
  - _**venv**_  <small>(recommended for this project)</small>
    <br>`./setup_python_venv.sh`
    <br>see: [doc/Development in Python (.venv).md](./doc/Development%20in%20-%20Python%20(.venv).md)

  - _**docker**_
    <br>`make run`
    <br>see: [doc/Development in `Docker` Container.md](./doc/Development%20in%20Docker%20container.md)

  Entering the container will set the variables from `.env` in the container and execute `dbt debug`
<br>You should see, in green [<span style="color:#27ae60">OK ...</span>] and lastly <b style="color:#27ae60">All checks passed!</b>
```
Configuration:
  profiles.yml file [OK found and valid]
  dbt_project.yml file [OK found and valid]

Required dependencies:
- git [OK found]

Connection:
  account: <target.account from profiles.yml>
  user: <target.username from profiles.yml>
  database: <target.database from profiles.yml>
  schema: <target.database from profiles.yml>
  warehouse: <target.warehouse from profiles.yml>
  role: <target.role from profiles.yml>
  client_session_keep_alive: False
  Connection test: [OK connection ok]

All checks passed!
```
