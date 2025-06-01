#!/bin/bash
PREFIX="${1:-NOT_SET}"
INTERFACE="$2"
SUBNET_RANGE="${3:-0..255}"
HOST_RANGE="${4:-1..254}"

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run with elevated privileges (sudo)" >&2
    exit 1
fi

[[ "$PREFIX" = "NOT_SET" ]] && { echo "\$PREFIX must be passed as first positional argument"; exit 1; }
if [[ -z "$INTERFACE" ]]; then
    echo "\$INTERFACE must be passed as second positional argument"
    exit 1
fi

if [[ ! "$PREFIX" =~ ^[0-9]+\.[0-9]+$ ]]; then
    echo "ERROR: \$PREFIX must be in format N.N ( 192.168)" >&2
    exit 1
fi

if [[ ! "$SUBNET_RANGE" =~ ^([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]))?$ ]]; then
    echo "ERROR: \$SUBNET_RANGE must be a number (0-255) or range (0..255)" >&2
    exit 1
fi

if [[ ! "$HOST_RANGE" =~ ^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])(\.\.([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4]))?$ ]]; then
    echo "ERROR: \$HOST_RANGE must be a number (1-254) or range (1..254)" >&2
    exit 1
fi


check_range() {
    local range=$1
    if [[ "$range" == *..* ]]; then
        seq -s ' ' ${range//../ }
    else
        echo "$range"
    fi
}

for SUBNET in $(check_range "$SUBNET_RANGE")

do
	for HOST in $(check_range "$HOST_RANGE")
	do
		echo "[*] IP : ${PREFIX}.${SUBNET}.${HOST}"
		arping -c 3 -i "$INTERFACE" "${PREFIX}.${SUBNET}.${HOST}" 2> /dev/null
	done
done