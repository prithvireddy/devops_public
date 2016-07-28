#!/bin/bash -ex
##-------------------------------------------------------------------
## @copyright 2016 DennyZhang.com
## Licensed under MIT
##   https://raw.githubusercontent.com/DennyZhang/devops_public/tag_v1/LICENSE
##
## File : refresh_db_report.sh
## Author : DennyZhang.com <denny@dennyzhang.com>
## Description :
## --
## Created : <2015-09-24>
## Updated: Time-stamp: <2016-07-28 10:08:43>
##-------------------------------------------------------------------
################################################################################################
## env variables:
##       env_parameters:
##           export SSH_DOCKER_DAEMON="ssh root@172.17.0.1"
##           export KIBANA_DASHBOARD_URL="http://104.131.129.100:5601"
##           export DESTROY_CONTAINER=false
################################################################################################
. /etc/profile
[ -n "$DOWNLOAD_TAG_NAME" ] || export DOWNLOAD_TAG_NAME="tag_v2"
export DOWNLOAD_PREFIX="https://raw.githubusercontent.com/DennyZhang/devops_public/${DOWNLOAD_TAG_NAME}"
if [ ! -f /var/lib/devops/refresh_common_library.sh ]; then
    [ -d /var/lib/devops/ ] || (sudo mkdir -p  /var/lib/devops/ && sudo chmod 777 /var/lib/devops)
    wget -O /var/lib/devops/refresh_common_library.sh "$DOWNLOAD_PREFIX/common_library/refresh_common_library.sh"
fi
bash /var/lib/devops/refresh_common_library.sh "2593132520" "/var/lib/devops/devops_common_library.sh" \
     "${DOWNLOAD_PREFIX}/common_library/devops_common_library.sh"
. /var/lib/devops/devops_common_library.sh
################################################################################################
source_string "$env_parameters"

ensure_variable_isset "SSH_DOCKER_DAEMON is not given " "$SSH_DOCKER_DAEMON"
ensure_variable_isset "KIBANA_DASHBOARD_URL is not given " "$KIBANA_DASHBOARD_URL"
[ -n "$DESTROY_CONTAINER" ] || DESTROY_CONTAINER=false

echo "destroy old docker container of data-report"
$SSH_DOCKER_DAEMON docker stop data-report || true
$SSH_DOCKER_DAEMON docker rm data-report || true

if $DESTROY_CONTAINER; then
    echo "Quit after container destroy"
    exit 0
fi

echo "start elk data report container and services inside"
$SSH_DOCKER_DAEMON docker run -t -d --name data-report --privileged -p 5601:5601 denny/elk:datareport /usr/sbin/sshd -D

$SSH_DOCKER_DAEMON docker exec -t data-report "service logstash start"
$SSH_DOCKER_DAEMON docker exec -t data-report "service elasticsearch start"
$SSH_DOCKER_DAEMON docker exec -t data-report "service kibana4 start"

echo "Download and inject data file"
$SSH_DOCKER_DAEMON docker exec -t data-report "wget -O /tmp/db_summary_report.txt http://repo.fluigdata.com:18000/prodenv_db_summary_report/db_summary_report.txt"
$SSH_DOCKER_DAEMON docker exec -t data-report "cat /tmp/db_summary_report.txt >> /var/log/data_report.log"

echo "Check kibana dashboard"
$SSH_DOCKER_DAEMON docker exec -t data-report "lsof -i tcp:5601"

echo "Check DB Report: $KIBANA_DASHBOARD_URL"
## File : refresh_db_report.sh ends
