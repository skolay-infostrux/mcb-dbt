# GitHub CI/CD Setup and Configuration of Github Actions #
This has already been done on Infostrux's github, but if you need do this on a different Github, here are the instructions:

1) Create a service USER in Snowflake which will be used by github actions dbt tasks to access your warehouse. Use a role that can execute transformations. For example:

```
TODO - needs and example
create user dev_dbt_service ...
```

2) Set up [secrets in github](https://github.com/Azure/actions-workflow-samples/blob/master/assets/create-secrets-for-GitHub-workflows.md) that will allow DBT to access the warehouse. The [profiles.yaml settings](https://docs.getdbt.com/reference/warehouse-profiles/snowflake-profile#configurations) in this project are driven by enviornment variables that will be created from the secrets. See [profiles.yml](profiles.yml) for the list of secrets that you need to create.

3) Configure Key Pair authentification:

    a) Generate an **encrypted** private key **locally** (see [here](https://docs.snowflake.com/en/user-guide/key-pair-auth.html#step-1-generate-the-private-key)):

    Command example:

    ```
    openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out id_rsa.p8
    ```
    You will be asked to generate a **passphrase** that will be used to access the encrypted private key. Take  note of the passphrase used.

    b) Set up the following **[github secrets](https://github.com/Azure/actions-workflow-samples/blob/master/assets/create-secrets-for-GitHub-workflows.md)**:

    - `DBT_SNOWFLAKE_KEY`: corresponds to the content of the private key (ex: you can use a command like `cat id_rsa.p8` to access the (encrypted) content of the key).
    - `DBT_SNOWFLAKE_KEY_PASSPHRASE`: used by github actions to decrypt the content of DBT_SNOWFLAKE_KEY (use the passphrase from step a) above).

    - `DBT_SNOWFLAKE_KEY_PATH` (ex: `/home/runner/work/.ssh/id_rsa.p8`) that corresponds to the file path github actions (docker) will use to save and access the content of DBT_SNOWFLAKE_KEY.

    c) Generate a public key **locally** based on the private key generated in step a) (see [here](https://docs.snowflake.com/en/user-guide/key-pair-auth.html#step-2-generate-a-public-key)):

    Command example:

    ```
    openssl rsa -in id_rsa.p8 -pubout -out id_rsa.pub
    ```

    d) In Snowflake, assign the public key to the github actions user (ex: you can use a command like `cat id_rsa.pub` to extract the content of the public key) (see [here](https://docs.snowflake.com/en/user-guide/key-pair-auth.html#step-4-assign-the-public-key-to-a-snowflake-user-key)):

    Snowflake command example:

    ```
    alter user GITHUB set rsa_public_key='MIIB…'
    ```

4) Set up Slack notification
```
In order to get Slack notifications for github workflow status, first you need to create a Webhook in your Slack account
- Go to https://api.slack.com/apps
- Click the button 'Create an App'
- Choose the option From Scratch
- Give your app a name. E.g.: dbt-starter-slack-notifications
- Choose your Workspace
- Click the Incoming Webhook and enable
- Create a new Slack channel that will show the notifications. E.g.: infostrux-dbt-starter-pipeline-status
- Click Add New Webhook to Workspace and give it a name.
- Choose the channel you created before and click next
- Copy the new created Webhook URL and add it to the Github Actions secrets with the name - SLACK_WEBHOOK_URL

Next you need to update the Git Actions to use this webhook url by editing:
.github/workflows/schedule_dbt_job.yml
notify_when can be one/some of the following: success,failure,warnings
put attention that a workflow step is succesful if continue-on-error: true

Open your Github Action and fail it deliberately to test your Github Actions monitoring.
```


## Pipeline Steps ##

### Common Steps ###
Both workflows downloads python & its dependencies also any dbt dependencies that are declared in requirements, and tests if there is a working connection to snowflake before running the rest of the steps.
`Report Status` sends the status to `Slack` at the end of a workflow.

### dbt-ci Workflow ###
Only runs when there is a pull request open towards master branch.

- `Download dbt Artifacts` stage checks if there are any artifacts created by a previous `deploy` workflow and downloads it, if it finds any.
- `Move dbt Artifacts to Target Directory` as the name suggests moves them to the directory `dbt` expects them to be.
- `Get Deferred State` prepares the flags for the `dbt`. This will create a flag with the artifact or will be null if there is no artifact, so the next steps can run accordingly.
- `seed/run/test` steps run the corresponging `dbt` commands with the flag from the above step.

### dbt-deploy Workflow ###
Only runs when there is a push to master branch (i.e. merging a PR).

- `seed/run/snapshot` steps run the corresponging `dbt` commands.
- `Upload dbt Artifacts` creates artifacts in `Github` from the snapshot created in the previous stage.
