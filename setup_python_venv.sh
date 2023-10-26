#!/usr/bin/env bash

export VENV_FOLDER='.venv'
python -m venv ${VENV_FOLDER}

# detect operating system ans set the
case "$OSTYPE" in
  darwin*)  export MY_OS="OSX" && export VENV_FOLDER_BIN="${VENV_FOLDER}/bin" ;;
  linux*)   export MY_OS="LINUX" && export VENV_FOLDER_BIN="${VENV_FOLDER}/bin" ;;
  msys*)    export MY_OS="WINDOWS" && export VENV_FOLDER_BIN="${VENV_FOLDER}/Scripts" ;;
  *)        export MY_OS="unknown: $OSTYPE" ;;
esac

# force the 'activate' script to load .env
echo "source .env" >> ${VENV_FOLDER_BIN}/activate
echo "[ -f .env ] && source .env" >> ${VENV_FOLDER_BIN}/activate

source ${VENV_FOLDER_BIN}/activate

# (optional) modify the prompt and append also to the 'activate' script
PS1='\e[0;31m(.venv) \[\033[32m\]\u@\h \[\033[33m\]\w\[\033[0m\]\n$ '
echo "PS1='${PS1}'" >> ${VENV_FOLDER_BIN}/activate
# (optional) add some help to the 'activate' script
echo "echo -e \"\n\e[3;32mThe Python virtual environment has been activated from folder\e[1;32m '${VENV_FOLDER}' \e[m \" " >> ${VENV_FOLDER_BIN}/activate
echo "echo -e \"  To deactivate, run:\e[1;31m deactivate \e[m \n \" " >> ${VENV_FOLDER_BIN}/activate

# start adding required packages
python -m pip install --upgrade pip
echo -e "pip install -r requirements.txt"
pip install -r requirements.txt

printf '\e[1;32m dbt deps \e[0;32m [Install dbt pacakge dependencies] ...\e[m\n'
dbt deps

printf '\e[1;33m>>> DBT environment variables \n\e[0;13m'
set | grep ^DBT_ | sed 's/.*DBT_SNOWFLAKE_PRIVATE_KEY_PASSPHRASE.*/DBT_SNOWFLAKE_PRIVATE_KEY_PASSPHRASE=********/'

printf '\e[1;32m dbt debug \e[0;32m [Checking dbt connection to Snowflake] ...\e[m\n'
dbt debug

echo
echo -e "\e[3;32m...Your Python virtual environment has been setup in folder\e[1;32m '${VENV_FOLDER}' \e[m"
echo -e "  To activate, run:\e[1;32m source ${VENV_FOLDER_BIN}/activate \e[m"
echo -e "  To deactivate (if active), run:\e[1;31m deactivate \e[m"
echo -e "\e[3m  NOTE: Next time you open a bash terminal in VScode, it should open with (.venv) already activated \e[m"
