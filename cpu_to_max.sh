#!/bin/bash
# 	File          :
#	Date          :
#	Program name  :
#	Version       : 0.0
#	Author        : ----
#	Enviroment    : CLI
#	Description   : Add Description
#
#	Notes         : This script will create a
#	loop that "steals" cpu cycles
#
#
echo "This program will try to eat resources "
# This little program is a resources eater
X=0;while [ 1 ];do echo $X;X=$((X+1));done
