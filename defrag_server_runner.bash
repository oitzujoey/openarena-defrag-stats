#!/bin/bash

#   User configurable settings
#   Name displayed when running script
GAME='Defrag'
#   Directory containing server binary
BINDIR=/usr/local/games/defrag
#   Full name of server binary
SERVER=oa_ded.x86_64
#   Named pipe used to send commands to server
PIPE=oa_pipe
#   Optional server arguments
SARGS="+set com_legacyprotocol 71 +set com_pipefile $PIPE +set fs_homepath /home/joey/.defrag +set fs_basegame baseoa +set fs_game defrag +exec server.cfg"
#   Home directory for OpenArena
DIR=~/.defrag
#   baseoa
BASEDIR=$DIR/baseoa
#   Script to call that manages server I/O.
MANAGER=defrag_server_manager.bash


red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

#   Run the game
printf "${blu}=== Starting $GAME ===${end}\n"

$BINDIR/$SERVER $SARGS $@ > >(cat 2>/dev/null) 2> >(tee >($BINDIR/$MANAGER $BASEDIR $DIR $PIPE))

printf "${blu}=== $GAME exited ===${end}\n"

# printf "${blu}=== Runner exiting ===${end}\n"
