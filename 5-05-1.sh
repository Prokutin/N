#!/bin/bash
PREFIX="${1:-NOT_SET}"
INTERFACE="$2"
SUBNET="${3:-0..255}"
HOST="${4:-1..254}"
oct1="${PREFIX%%.*}"
oct2="${PREFIX#*.}"

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run with elevated privileges (sudo)" >&2
    exit 1
fi 

[[ "$PREFIX" = "NOT_SET" ]] && { echo "\$PREFIX must be passed as first positional argument"; exit 1; }
if [[ -z "$INTERFACE" ]]; then
    echo "\$INTERFACE must be passed as second positional argument"
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

check_parameters() {
    local value="$1"
    local min="$2"
    local max="$3"

	if [[ "$value" == *".."* ]]; then
        return 0
    fi

    if [[ ! "$value" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    if [[ "$value" -ge "$min" && "$value" -le "$max" ]]; then
        return 0
    else
        return 1
    fi
}

check_parameters "$oct1" 0 254 || { echo "ERROR: " ${PREFIX} "must be a ip (0.0 - 254.254)"  ; exit 1; }
check_parameters "$oct2" 0 254 || { echo "ERROR: " ${PREFIX} "must be a ip (0.0 - 254.254)"  ; exit 1; }
check_parameters "$SUBNET" 0 255 || { echo "ERROR: " ${SUBNET} "must be a number (0-255)"  ; exit 1; }
check_parameters "$HOST" 1 254 || { echo "ERROR: " ${HOST} "must be a number (1-254)"  ; exit 1; }


for SUBNET in $(check_range "$SUBNET")

do
	for HOST in $(check_range "$HOST")
	do
		echo "[*] IP : ${PREFIX}.${SUBNET}.${HOST}"
		arping -c 3 -i "$INTERFACE" "${PREFIX}.${SUBNET}.${HOST}" 2> /dev/null
	done
done