# Formatting code with <i>`sqlfluff`</i>
Reference: [https://docs.sqlfluff.com/en/stable/rules.html](https://docs.sqlfluff.com/en/stable/rules.html)

Specific rules for the project are set in `.sqlfluff` config file.

- To lint a file, use this in the root folder of the project:
    ```
    sqlfluff lint your-file-name-or-folder-name
    ```
    ... this will show the sql lines that don't pass the rules defined in `.sqlfluff` config file.

- To fix ALL linting errors use the **fix** command
    ```bash
    sqlfluff fix your-file-name-or-folder-name
    ```

**WARNING**: Use `sqlfluff fix` with caution and make sure you <u>_**run it for one file at a time**_</u>, and that you compare the changes so that SQLFluff does not apply unwanted changes.
