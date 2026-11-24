#!/bin/bash

LOGG="$HOME/zonvakt-test.log"

{
    echo "=== Zonvakt säkerhetstest ==="
    date -Is

    echo "SELinux: $(getenforce)"

    echo "Test 1: Tillåten anslutning"
    printf 'hej\n' | nc -w 3 127.0.0.1 7543

    echo "Test 2: Otillåten operation"
    printf 'overtrad\n' | nc -w 3 127.0.0.1 7543

} | tee "$LOGG"