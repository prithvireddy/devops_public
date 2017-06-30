#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2017 DennyZhang.com
## Licensed under MIT
##   https://raw.githubusercontent.com/DennyZhang/devops_public/master/LICENSE
##
## File : enforce_rubocopcheck.py
## Author : Denny <denny@dennyzhang.com>
## Description :
##
## More reading: TODO
##
## --
## Created : <2017-04-02>
## Updated: Time-stamp: <2017-06-30 16:53:16>
##-------------------------------------------------------------------
import argparse
import sys
import os
import subprocess
import re

def ignore_folder(code_dir, check_ignore_folder):
    ignore_folder_list = []
    if check_ignore_folder != "":
        with open(check_ignore_folder) as f:
            ignore_folder_list = f.readlines()

    folder_list = []
    for f in os.listdir("/tmp/"):
        if os.path.f.is_file() is False:
            folder_list.append(f)

    l = []
    for folder in folder_list:
        skip = False
        for ignore_folder_pattern in ignore_folder_list:
            ignore_folder_pattern = ignore_folder_pattern.strip().strip("\n")
            if ignore_folder_pattern == "":
                continue
            if re.search(ignore_folder_pattern, folder) is not None :
                skip = True
                break
        if skip is False:
            l.append(folder)
    return l

def run_check(code_folder, check_pattern):
    has_error = False
    os.chdir(code_folder)
    print "Run check command: %s, under %s" % (check_command, code_folder)
    returncode = subprocess.call(check_command, shell=True)
    if returncode != 0:
        has_error = True
        print "Error to run %s. Return code: %d" % (check_command, returncode)
    return has_error
################################################################################
#
# wget -O /tmp/enforce_rubocopcheck.py https://raw.githubusercontent.com/DennyZhang/devops_public/tag_v6/python/enforce_rubocopcheck/enforce_rubocopcheck.py
# python /tmp/enforce_rubocopcheck.py --code_dir devops_code/devops_public
################################################################################

if __name__ == '__main__':
    # get parameters from users
    parser = argparse.ArgumentParser()
    parser.add_argument('--code_dir', required=False, default=".", \
                        help="Source code directory to be scanned", type=str)
    parser.add_argument('--check_ignore_folder', required=False, default="", \
                        help="file pattern listed in the file will be skipped for scan", type=str)

    l = parser.parse_args()

    code_dir = os.path.expanduser(l.code_dir)
    check_ignore_folder = l.check_ignore_folder
    if check_ignore_folder != "":
        check_ignore_folder = os.path.expanduser(l.check_ignore_folder)

    print "Run rubocop for *.rb under %s" % (code_dir)
    folder_list = ignore_folder(code_dir, check_ignore_folder)

    has_error = True
    for folder in folder_list:
        if run_check(folder, "rubocop .") is False:
            has_error = False

    if has_error is False:
        print "OK: no error detected from rubocop check"
        sys.exit(0)
    else:
        print "ERROR: %s has failed." % (os.path.basename(__file__))
        sys.exit(1)
## File : enforce_rubocopcheck.py ends