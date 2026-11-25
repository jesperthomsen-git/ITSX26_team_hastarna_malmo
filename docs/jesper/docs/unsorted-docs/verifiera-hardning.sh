#!/bin/bash

fel=0

if [ "$(getenforce)" = "Enforcing" ]; then
    echo "GÄLLER: SELinux enforcing"
else
    echo "GÄLLER INTE: SELinux enforcing"
    fel=1
fi

if semodule -l | grep -qx zonvakt; then
    echo "GÄLLER: Zonvakt-policy installerad"
else
    echo "GÄLLER INTE: Zonvakt-policy installerad"
    fel=1
fi

if semanage fcontext -l -C | grep -Fq '/srv/zonwebb(/.*)?'; then
    echo "GÄLLER: Bestående SELinux-märkning för zonwebb"
else
    echo "GÄLLER INTE: Bestående SELinux-märkning för zonwebb"
    fel=1
fi

exit "$fel"