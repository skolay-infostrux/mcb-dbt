#!/usr/bin/env python3
"""
Execute 'dbt' with pre and post processing of `logs/dbt.log` files and artifacts in `target/' folder. 
Modifies the logging behaviour of having one ever-growing file into one log file per run

FEATURES:
    - Creates one log file per run
      This solves several issues:
        1. Standard `logs/dbt.log` can grow large after nultiple runs of many models.
           It is difficult if not impossible to trim the file and keep the limited history.
           With one file per run, we can automate how many historical to keep. 
           E.G. You can have a periodic clean up task that deletes/archives files older than N days
        
        2. Debugging: It is very difficult to find a log error of a certain run of a certain model when the file has multiple runs.

    - Log file name pattern.
        dbt.YYYYmmDD_HHMMSS.invocation_id=<uniqueidentifier>.log
        (This follows the log naming pattern of Airflow)

        SAMPLE NAME:
        dbt.20231007_070108.invocation_id=d34039a8-ca23-4d7f-ae3a-cb49f2ab7573.log

        where:
            - `YYYYmmDD_HHMMSS` is the timestamp(in seconds) when dbt command was launched. 
            - <uniqueidentifier> is the value of 'invocation_id' that dbt generates for each run

USAGE:
    python3 -m _dbt_cli dbt run --vars "{simulate_exception__bsar__benchmark: '1'}"
    
    Solves the problem of passing a command with multiple quotes like
    python3 -m _dbt_cli dbt run -s bsar__benchmark  --vars "{simulate_exception__bsar__benchmark: '1'}"

"""

import shutil
import sys, os, json
import subprocess 
# from subprocess import PIPE, STDOUT, Popen
from tempfile import TemporaryDirectory, gettempdir


def fix_dbt_args_dblqoutes(argv : list[str]):
  """ add double quotes around CLI arguments that follows --vars and --args"""
  item_prev = None
  _cmd = ""
  for idx, item in enumerate(argv):
    if idx == 0: continue
    # if idx == 1: continue
    if item_prev == "--vars" or item_prev == "--args":
        item = ('"' + item + '"')
    _cmd = _cmd + item + " "
    item_prev = item

  print("Execute:", _cmd)
  return _cmd

def launch_subprocess(cmd):
    # print STDOUT lines as they come
    with subprocess.Popen(cmd, 
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        text=True, #text: When set to True, will return the stdout and stderr as string, otherwise as bytes.
        ) as proc:
        for line in proc.stdout:
            print(line, end="")
    return proc

def run_bash(bash_command):
    bash_path = shutil.which("bash") or "bash"

    with subprocess.Popen([bash_path, "-c", bash_command],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        text=True, #text: When set to True, will return the stdout and stderr as string, otherwise as bytes.
        ) as proc:
        for line in proc.stdout:
            print(line, end="")

        for line in proc.stderr:
            print(line, end="")
    return proc


def run_bash_dbt():
    cmd = fix_dbt_args_dblqoutes(sys.argv) #.replace('"', '\\"')
    bash_command = """
    mkdir -p logs; 
    mkdir -p target; # we need it before the run to redirect STDOUT to a file here 
    #rm -fr target/* # for "run-operation" we should delete at least `partial_parse.msgpack`, otherwise we can't generate 'run_results_info.json'
    rm -fr target/partial_parse.msgpack # for "run-operation" we should delete at least `partial_parse.msgpack`, otherwise we can't generate 'run_results_info.json'

    # backup `dbt.log` of the previous run. 
    [ -f logs/dbt.log ] && cp -Pb logs/dbt.log logs/dbt.log.bak; 
    [ -f target/dbt.log ] && rm -f target/dbt*.log; 
    [ -f target/run_results.json ] && rm -f target/run_results*.*; 

    DBT_START_TIMESTAMP=$(date "+%FT%T.%3N%z") ; 
    DBT_START_FILE_LOCAL=$(date "+%Y%m%d_%H%M%S") ; 
    DBT_START_FILE_UTC=$(date -u "+%Y%m%d_%H%M%S") ; 
    echo "" > logs/dbt.log; # Clear dbt.log
    echo "${DBT_START_TIMESTAMP} [info ] [MainThread]: Launching: """ + cmd.replace('"', '\\"') + """ " > logs/dbt.log; # Timestamp and CLI call > dbt.log 
""" + cmd + """
  if [ -f logs/dbt.log ]; then 
    cp -fP logs/dbt.log target/dbt.log; 
    # extract dbt run "invocation_id" from "logs/dbt.log"
    #   Look for the line starting and ending with many "========"
    INVOCATION_ID=$(grep -e "^"========="" logs/dbt.log | grep ""========="$" | grep " | " | tail -1 | grep -oP "(?<= \| ).*(?= )");

    DBT_LOG_FILE="dbt.${DBT_START_FILE_LOCAL}.invocation_id=${INVOCATION_ID}.log" ; 
    # DBT_LOG_FILE="dbt.${DBT_START_FILE_UTC}.invocation_id=${INVOCATION_ID}.log" ; 
    cp -f logs/dbt.log logs/${DBT_LOG_FILE}; 

    # cat logs/dbt.log \
    # | grep -zoP '(?<=<run_results_info_json>)(?s).*(?=</run_results_info_json>)' \
    # | tr -d '\\000' \
    # | python3 -m json.tool --indent=2 \
    # > target/run_results_info.json; 
  fi

  ## redirect STDOUT of this process to STDOUT of parent bash process using " >&1"
  #echo DBT_EXIT_CODE=$DBT_EXIT_CODE >&1

# exit with the error code of the `dbt run` 
exit $DBT_EXIT_CODE
"""
    # print(bash_command) #un-comment to se the genrated bash script
    proc = run_bash(bash_command)

    with open(f'logs/dbt.log', 'r') as file:
        data = file.read()
    run_results_info_json = extract_run_results_info_json(data)
    if run_results_info_json is not None:
      with open('target/run_results_info.json', 'w') as file:
        print(run_results_info_json, file = file)

    return proc


def extract_run_results_info_json(data, xmltag = 'run_results_info_json'):
    tag_start = '<'+xmltag+'>'
    tag_end = '</'+xmltag+'>'

    # find last occurrence of tags in the file
    tag_start_idx = data.rfind(tag_start)
    tag_end_idx = data.rfind(tag_end)
    if tag_start_idx>0 and tag_end_idx>0 and tag_start_idx<tag_end_idx:
        # content between tags was found
        run_results_info_json = ''
        for idx in range(tag_start_idx + len(tag_start), tag_end_idx):
            run_results_info_json = run_results_info_json + data[idx]
        try:
            my_json=json.loads(run_results_info_json)
            return json.dumps(my_json, indent=2)
        except Exception as ex:
            # Not a valid JSON!
            # print(f"Unexpected {ex}, {type(ex)=}")
            pass
            
    return None

#### MAIN 
if sys.argv[1] != "dbt":
    print("Launches 'dbt' and processes logs.")
    print("USAGE:")
    print("  \033[1m dbt\033[0m \033[3m[OPTIONS]\033[0m COMMAND [ARGS] \033[m...")
    print("\n\033[3m ERROR: Command must start with the 'dbt' word!  \033[m")

    # print("Colors... \033[31mred\033[m \033[32mgreen\033[m \033[33myellow\033[m \033[34mgreen\033[m \033[35mmagenta\033[m \033[36mcyan\033[m \033[39mdefault  \033[m")
    # print("Bold, Italic,... \033[1mBold\033[m \033[3mItalic\033[m \033[4mUnderline\033[m \033[7mInverted\033[m \033[9mStrike\033[m \033[0mNormal")
    # print("Colors + Bold... \033[1;31mBold red\033[m \033[3;32mItalic green\033[m")
    exit(-1) # not usual 1 or 2 returned by dbt error

proc = run_bash_dbt()

# print("DBT_EXIT_CODE=%d" % proc.returncode)
exit(proc.returncode)
