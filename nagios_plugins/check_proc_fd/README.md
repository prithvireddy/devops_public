check_proc_fd
==============

- Link: http://www.dennyzhang.com/nagois_monitor_process_fd/
- Code: https://github.com/DennyZhang/check_proc_fd

Zabbix plugin to check proc fd: Monitor fd opened by a given process

```
/sshx:denny@dennyzhang.com: #$ ./check_proc_fd.sh --help
check_proc_fd v1.0

Usage:
./check_proc_fd.sh -w <warn_count> -c <criti_count> <pid_pattern> <pattern_argument>

Below: If tomcat opens more than 1024 files, send warning
./check_proc_fd.sh -w 1024 -c 2048 --pidfile "/var/run/tomcat7.pid"
./check_proc_fd.sh -w 1024 -c 2048 --pid 11325
./check_proc_fd.sh -w 1024 -c 2048 --cmdpattern "tomcat7.*java.*Dcom"

Copyright (C) 2014 DennyZhang (denny.zhang001@gmail.com)
```

Sample output:
```
/sshx:denny@dennyzhang.com: #$ ./check_proc_fd.sh -w 1024 -c 2048 --pidfile "/var/run/tomcat7.pid"
OK: file opened by pid(12356) is 201|fd=201
```