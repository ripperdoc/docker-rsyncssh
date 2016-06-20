#!/bin/sh
# https://github.com/tutumcloud/authorizedkeys

# key string has to be prefixed by ro: or rw:

RW='command="/usr/local/bin/rrsync /data/",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding'
RO='command="/usr/local/bin/rrsync -ro /data/",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding'

: ${AUTH_KEYS_FILE:=/root/.ssh/authorized_keys}

if [ "x${AUTHORIZED_KEYS}" != "x" ] && [ "${AUTHORIZED_KEYS}" != "**None**" ]; then
    echo "=> Found authorized keys to add to $AUTH_KEYS_FILE"
    touch $AUTH_KEYS_FILE || exit 1
    chmod 600 $AUTH_KEYS_FILE
    echo "$AUTHORIZED_KEYS"| tr "," "\n" | while read x; do
        FULLKEY=$(echo $x | sed -e 's/^ *//' -e 's/ *$//')
	STRIPKEY=$(echo $FULLKEY | sed -e 's/r[ow]: *//i')

	if [ "$STRIPKEY" = "$FULLKEY" ]; then
	   echo "Skipping key not starting by 'rw:' or 'ro:' : $FULLKEY"
           continue
        fi
        if echo $FULLKEY|grep -q -i "^ro:"; then
	   LINE="$RO $STRIPKEY"
        else
	   LINE="$RW $STRIPKEY"
        fi
	if ! grep -q -F -e "$STRIPKEY" $AUTH_KEYS_FILE; then
	    echo "$LINE" >> $AUTH_KEYS_FILE && echo "=> Adding public key to $AUTH_KEYS_FILE: $LINE"
        else
            echo "Key already in $AUTH_KEYS_FILE: $STRIPKEY"
        fi
    done
else
    echo "ERROR: No authorized keys found in \$AUTHORIZED_KEYS"
    exit 1
fi
