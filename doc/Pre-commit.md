# Pre-commit
 Git hook scripts are useful for identifying simple issues before submission to code review. Running hooks on every commit to automatically point out issues in code such as missing update columns in schema files, descriptions, or test.

 As more pre-commit hooks are created, sharings them across projects can be painful and pre-commit have been develop to solve that issue. Pre-commit is a multi-language package manager for pre-commit hooks. You specify a list of hooks you want and pre-commit manages the installation and execution of any hook written in any language before every commit.

An excellent pre-commit tutorial is available [here](https://www.elliotjordan.com/posts/pre-commit-01-intro/) and a lot of DBT related hooks are available [here](https://github.com/offbi/pre-commit-dbt) as well.

The complete list of hooks is listed in the .pre-commit-config.yaml document
at the root of the project.

### Run locally before commit
Before you commit you should run this locally in project folder
```bash
pre-commit run --all-files
```
or specific filenames to run hooks on
```
pre-commit run --files file1 file2
```
This will fix trailing white spaces for your files for your files *BEFORE* you commit.

**NOTE**: `pre-commit` will also execute `sqlfluff --lint` to show linting/formatting errors that that don't follow the rules sepecified in `.sqlfluff` config file.
You can fix these errors manually or using `sqlfluff fix`

### Skipping hooks

If you ever need to bypass the pre-commit hooks (for example, to issue a one-time commit to a protected local branch), you can use the -n or --no-verify flag when committing.

```bash
git commit -nm "pre-commit won't run on this commit."
```
