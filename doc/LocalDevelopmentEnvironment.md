# Local Development Environment #

## Setup ##
This section assumes that the development WorkSpace was built based on our latest and greatest development image that has VSCode and git already installed.

To run `dbt` locally, you will need to:
1. RECOMMENDED: set up key pair authentication to Snowflake for your account
1. Set up your Python environment and install `dbt` dependencies.
1. set up the `dbt` connection to Snowflake for local development using shell environment variables

### Set Up Key Pair Authentication to Snowflake ###

#### Create RSA Authentication Key Pair ####
1. If it doesn't exist, create a directory where we will store the encrypted RSA authentication keys, e.g. `~/.ssh`
    ```shell
    mdkir -p ~/.ssh
    ```
1. Generate the encrypted private RSA key in PEM format, e.g. `~/.ssh/snowflake_rsa_key.p8`. You will be prompted to provide an encryption password. **Make note of this password as we will need it later!**
    ```shell
    openssl genrsa 2048 | openssl pkcs8 -topk8 -v2 des3 -inform PEM -out ~/.ssh/snowflake_rsa_key.p8
    ```
1. Generate the public key matching the private one, e.g. `~/.ssh/snowflake_rsa_key.pub`. You will be prompted to provide the private RSA key encryption password.
    ```shell
    openssl rsa -in ~/.ssh/snowflake_rsa_key.p8 -pubout -out ~/.ssh/snowflake_rsa_key.pub
    ```
1. Restrict access to the key files
    ```shell
    chmod 400 ~/.ssh/snowflake_rsa_key.*
    ```

#### Set the RSA Public Key in Snowflake ####
1. Log into Snowflake, and switch to `ACCOUNTADMIN`
    ```sql
    USE ROLE accountadmin;
    ```
1. Copy the value of your RSA public key we created and add it as the `rsa_public_key` value in the following query (replace `user_name` with your username), then run the query
   ```sql
   ALTER USER user_name SET rsa_public_key='MIIBIjANBgkqh...';
   ```

### Setting Up your WorkSpace ###
1. Make sure Python 3.8 is installed. For our VDIs (amazon-linux), follow  [this link](https://techviewleo.com/how-to-install-python-on-amazon-linux/). Python 3.8 is as of this writing the only interpreter that Snowflake pyspark extension works with.

1. Clone the project in your WorkSpace to a directory of your choice and switch into it. The following commands are meant to be run from inside the repo folder.

1. Setup the Python virtual environment and install dbt and other dependencies:
    ```shell
    source ./setup_python_venv.sh
    ```

1. Activate your Python virtual environment:
    ```shell
    source .venv/bin/activate
    ```
   > **NOTE**: The terminal prompt should start with (.venv) or similar to indicate that you are indeed in the Python virtual environment, e.g.:
   > ```bash
    > (.venv) dbt-starter-project$
    > ```
   > To exit the (.venv) just type `deactivate` on the command line.

### Setup `dbt` Authentication to Snowflake ###
`dbt` will use environment variables as specified in the `dbt_project.yml` and `profiles.yml`. The `setup_environment_variables.sh` script will help you set those up. Be aware that these vars will be used by the CI/CD pipeline, as well as when you run `dbt` locally, both inside and outside Docker.

1. Configure the `dbt` Snowflake connection environment variables:
    ```bash
   source setup_environment_variables.sh
    ```
   Follow the prompts and provide the required details. You can press (Enter) to accept the default values, where provided.

   > By default, `dbt` is configured to connect to Snowflake using a Private RSA Key and passphrase. If you'd like to change that to password authentication, you will need to modify `profiles.yml` accordingly, see also:
   > * https://docs.getdbt.com/reference/warehouse-setups/snowflake-setup#user--password-authentication
   > * https://docs.snowflake.com/en/user-guide/security-mfa.html#label-mfa-token-caching

1. Test the `dbt` Connection to Snowflake
    To verify that all environment variables have been set correctly, run:
    ```shell
    make dbt_env_vars
    ```

    You can also test the `dbt` connection to Snowflake with:
    ```
    dbt debug
    ```
    You should see Snowflake responding with `All checks passed!`

1. Your configuraiton is now complete! Please note that, when you shut down your dev environment, the activation of your Python virutual environment and the Snowflake environment variables will be lost. To set these up again those for a new work sessions, you will only need to run:
    ```
    # To activate the Python virutual environment
    source .venv/bin/activate
    # To setup the Snowflake environment variables
    source setup_environment_variables.sh
    ```
    For next steps in using your environment, refer to the [Using the dbt Starter Project](./UsingDbtStarterProject.md) document.

## VSCode and Command Line Development Without Docker ##

> Please note that launching VSCode or IntelliJ from the command line is currently not enabled in Kasm workspaces.

1. Start VSCode by running
    ```bash
    code .
    ```
   > It is important to start VSCode from the same terminal session where you set the `dbt` environment variables. That way, the VSCode terminal will inherit the `dbt` variables set in the parent terminal session. Othewise, you may have to run `source setup_environment_variables.sh` inside the VSCode terminal to set these up again.


## Lint Checks ##
GitHub CI pipelines typically preform a series of checks before any pull request can be created. You can proactivelly run these checks locally rather than have them prevent you from creating your pull request.

> **IMPORTANT:** You should review all updates made by automatic fixes to ensure no breaking changes were introduced.

Lint checks commonly configured on `dbt` projects can include:

* [pre-commit](PreCommit.md)
* [SQLFluff](SQLFluff.md)
