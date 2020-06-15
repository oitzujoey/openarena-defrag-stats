#!/bin/bash

TEMPDIR=$1

cd $TEMPDIR

while true
do
    if [ ! -z "$(ls -A $TEMPDIR)" ]
    then
        for file in $TEMPDIR/*
        do
            printf 'execq %s\n' "tmp/$(basename $file)"
            sleep 0.1
            rm $file
        done
    fi
    if read -rt0.1 INPUT
    then
        printf "$INPUT\n"
    fi
#     sleep 0.1
done
