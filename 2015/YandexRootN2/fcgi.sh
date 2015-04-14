#!/bin/sh
#
# git-fcgi   The Git HTTP/FastCGI server
#
# chkconfig: - 80 20
# processname: git-fcgi
# description: Git HTTP/FastCGI server
# pidfile: /var/run/git-fcgi.pid

### BEGIN INIT INFO
# Provides: git-fcgi
# Required-Start: $local_fs $remote_fs $network
# Required-Stop: $local_fs $remote_fs $network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Start and stop Git HTTP/FastCGI server
### END INIT INFO

# Source function library.
. /etc/init.d/functions

# Config & Vars
prog=git-fcgi
childs=1
pidfile=/var/run/git-fcgi.pid
lockfile=/var/lock/subsys/git-fcgi
sockfile=/var/run/git-fcgi.sock
sockmode=0700;
sockuser=nginx
sockgroup=nginx
proguser=nginx
proggroup=nginx
gitexec=/usr/libexec/git-core/git-http-backend
fcgiexec=/usr/local/sbin/fcgiwrap
spawnexec=/usr/bin/spawn-fcgi
progexec="${spawnexec} -u ${proguser} -g ${proggroup} -U ${sockuser} -G ${sockgroup} -P ${pidfile} -s ${sockfile} -M ${sockmode} -- ${fcgiexec} -f -c ${childs} -p ${gitexec}"
RETVAL=0

# Functions
start() {
    echo -n $"Starting ${prog}: "
    [ -n "${sockfile}" -a -S "${sockfile}" ] && rm -f ${sockfile}
    daemon "${progexec} > /dev/null"
    RETVAL=$?
    echo
    [ $RETVAL = 0 ] && touch ${lockfile}
    return $RETVAL
}	

stop() {
    echo -n $"Stopping ${prog}: "
    [ -n "${sockfile}" -a -S "${sockfile}" ] && rm -f ${sockfile}
    killproc -p ${pidfile} ${prog}
    RETVAL=$?
    echo
    [ $RETVAL = 0 ] && rm -f ${lockfile} ${pidfile}
    return $RETVAL
}

restart() {
    stop
    start
}

reload() {
    restart
}

force_reload() {
    restart
}

rh_status() {
    status -p ${pidfile} ${prog}
}

# Main
case "$1" in
    start)
        rh_status > /dev/null 2>&1 && exit 0
        start
        ;;
    stop)
        stop
        ;;
    status)
        rh_status
        RETVAL=$?
        ;;
    restart)
        restart
        ;;
    reload)
        reload
        ;;
    force-reload)
        force_reload
        ;;
    condrestart|try-restart)
        if rh_status > /dev/null 2>&1; then
            restart
        fi
        ;;
    *)
        echo $"Usage: $prog {start|stop|restart|reload|force_reload|condrestart|try-restart|status|help}"
        RETVAL=2
esac

exit $RETVAL

