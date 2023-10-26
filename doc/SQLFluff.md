# SQLFluff #

> For more configuration options, see https://docs.sqlfluff.com/en/stable/configuration.html#installation-configuration

## Setup ##
In order to use SQLFluff, once you've activated your Python virtual environment, you will need to install it
```shell
pip install sqlfluff
```

## Usage ##
To run a lint check of your SQL code, simply provide the relative or absolute path to the file(s) you would like to verify. Similarly, you can run the fix command to fix all fixable linting violations
```shell
# Check for violations
sqlfluff lint path/to/files/
sqlfluff lint path/to/single_file.sql
# Fix violations
sqlfluff fix path/to/files/
sqlfluff fix path/to/single_file.sql
```

To use SQLFluff with dbt you will also need to install the `sqlfluff-templater-dbt` module
```shell
pip install sqlfluff-templater-dbt
```

## VSCode SQLFluff Extension ##
If you use VSCode, you may want to leverage the [VSCode SQL Extension](https://marketplace.visualstudio.com/items?itemName=dorzey.vscode-sqlfluff). The extension will highlight linting issues in your SQL code and will also allow you to apply automatic fixes where possible. You can still use SQLFluff at the command line but, to avoid conflicts, ensure you don't run it at the command line while the extension is running an automatic fix.

### SQL Language Mode ###
To use the VSCode SQLFluff Extension, ensure the file you are editing is recognized as a `SQL` file. The VSCode configuration here assumes that you have the [VSCode Better Jinja extension](https://marketplace.visualstudio.com/items?itemName=samuelcolvin.jinjahtml) installed.  If you don't, you can install it from Quick Open (Ctrl+P) by running
```
ext install samuelcolvin.jinjahtml
```

The Better Jinja extension will set the file Language Mode to `Jinja SQL` which is recognized by the VSCode SQL Extension just fine. If you don't have Better Jinja (or another extension) and VSCode does not recognize your file as `SQL`, you can specify the file Language Mode in the status bar (bottom right) but you will need to do this every time you open the file

![Language Mode](./images/VSCodeStatusBarLanguageMode.jpeg)

### Setup ###
To install the VSCode SQLFluff Extension in VS Code, launch Quick Open (Ctrl+P), and run
```
ext install dorzey.vscode-sqlfluff
```

### Configuration ###
A default configuration for using the extension with Snowflake and dbt is already included in this repo, see `.vscode/settings.json`. You can edit this file directly or modify the extension's settings from VSCode's Extensions Settings interface.

> Please note that, while the VSCode SQLFluff Extension will highlight lint errors in `SQL` files, it cannot be used to automatically fix lint errors in real-time (while typing) when used on dbt projects. While the extension has the option to set the `sqlfluff.linter.run` setting value to `onType`, this will cause issues when using it with dbt projects. For dbt code, the linter setting must be set to `onSave`
> ```json
> "sqlfluff.linter.run": "onSave",
> ```

For additional configuration, see the extension page the on [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=dorzey.vscode-sqlfluff).

### Usage ###
> **DO NOT MODIFY the file while the extension is running it to avoid corrupting it!**

If the open file is recognized as SQL (or `Jinja SQL` with the Better Jinja extension), the SQLFluff extension will take about 20 seconds after the file is first open to highlight all lint issues. To attempt to fix issues based on the rules  defined in the `.sqlfluff` file, you can trigger the extension formatter with
* Linux: Shift+Control+I
* Mac: Shift+Option+F

Alternatively, you can run `Format Document` from the command palette
* Linux: Shift+Control+P, search `Format Document`
* Mac: Shift+Command+P, search `Format Document`

### Automatic Lint Fixes ###
> Not all lint errors can be fixed automatically. Once you've applied the automatic lint fixes, you will need to fix highlighted errors by hand.
