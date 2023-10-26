# Development in Python virtual environment `venv`

## Prerequisites
1. **Python 3.10** is installed on the local machine.<br>__*IMPORTANT: version has to be 3.8 <= version <= 3.10*__
   - `venv` package is installed<br>
    You may need to install `venv` package (if missing) with<br>
    `sudo apt install python3.10-venv`

2. __*Visual Studio Code*__ is installed
    <br>*Windows specific instalation steps*
    1. Install *Visual Studio Code*
        > download link: https://code.visualstudio.com/download <br>
        > help link: https://code.visualstudio.com/docs/setup/windows

        - Pick "User Installer" to install for current user (recommended)

        - Pick "System Installer" to install for all users (requires admin account)

    2. Install latest "Git for Windows" (64bit) from https://git-scm.com/download/win
    <br>_IMPORTANT: If "Git for Windows" is already installed, please re-install and make sure you follow the steps below:_

        - at the "Select Components" prompt please check:
        <br>**_(NEW!) Add a Git Bash Profile to Windows Terminal_**
        - at the "Choosing the default editor used by Git" choose:
            <br>**_Use Visual Studio Code as Git's default editor_**
        - at the "Configuring the line ending conversions" choose second option:
            <br>**_Check as-is, commit Unix-style line_**
    3. In VScode set the default terminal to the `Git bash`
        <br>(in `C:\Program Files\Git\bin\bash.exe --login -i`)
        <br>_NOTE: This ensures that the VSCode terminal will always open as `bash` rather than the windows default terminal (`Command Prompt` or `PowerShell`)_


5. Clone the project in your WorkSpace to a directory of your choice and switch into it. <br>
`cd my-project-folder`

6. Snowflake private key was created and applyed to your Snowflake account.

7. Snowflake passphrase file exist on the Windows local machine in folder<br>
    `${HOME}/.ssh`

8. Environment variables are set in file `.env` in the **root folder of your project**
    <br>_TIP: you can copy the provided `.env.sample` file and modify accordingly.
    <br>The `.env.sample` is assumming all credential files are stored in specific files in the folder `${HOME}/.ssh`_

## Create a new virtual environment
1. Open the project in VSCode
2. Open a terminal
3. Execute this command in the terminal<br>
    `./setup_python_venv.sh`
### What it does behind the scenes:
1. Create the `venv` environment
2. Enter the activates the virtual environment
3. Installs packages declared in `requirements.txt`
4. Runs `dbt deps` that installs additional dbt packages declared in `packages.yml`
5. Sets the environment variables declared in `.env` file
6. Runs `dbt debug` that will confirm:
    - connectivity to Snowflake (valid account, user and credentials)
    - the dbt project integrity
    > You should see _dbt_ responding with <br>
    > `All checks passed!`

## Activate virtual environment
In the terminal, a Python active virtual environment is indicated by the `(.venv)` prompt prefix.

If you don't see the `(.venv)` prompt prefix please run

Windows:
```
source .venv/Scripts/activate
```

Linux:
```
source .venv/bin/activate
```

To deactivate thea virtual environment type:
```
deactivate
```
> NOTE: Next time you open a terminal, VScode should detect the existence of a virtual environment and it should activate it.
