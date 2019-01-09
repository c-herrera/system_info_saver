#!/bin/bash
# File          : 
# Purpose       : 
# Description   : 
#                 
#                 
# Version       : 0.0.1
# Date          : 
# Created by    : Carlos Herrera.
# Notes         : To run type sh system-info.sh in a system terminal with root access.
#                 If modified, please contact the autor to add and check the changes
# Scope         : Generic linux info gathering script, works good on red hat 7.5
#               : Do not remove this header, thanks!

# Fun times on errors!
set +x
# set otherwise for fun !!!
echo "Running LTSSMTool with the next arguments"
echo "Address = $1"
echo "Bus width = $2"
echo "Bus speed = $3"

address=$1
buswidth=$2
busspeed=$3

echo  " $(date +%Y:%m:%d:%H:%M:%S)"
echo  " Running LTMSS pmil argument "
./LTSSMtool pml1 1000 [$address,$buswidth,$busspeed]

echo  " $(date +%Y:%m:%d:%H:%M:%S)"
echo  " Running LTMSS linkretrain argument "
./LTSSMtool linkRetrain 100 [$1,$2,$3]

echo  " $(date +%Y:%m:%d:%H:%M:%S)"
echo  " Running LTMSS linkdisable argument "
./LTSSMtool linkDisable 100 [$1,$2,$3]

echo  " $(date +%Y:%m:%d:%H:%M:%S)"
echo  " Running LTMSS speedchange argument "
./LTSSMtool speedChange 100 [$1,$2,$3]

echo  " $(date +%Y:%m:%d:%H:%M:%S)"
echo  " Running LTMSS flr argument "
./LTSSMtool flr 100 [$1,$2,$3]

echo  " $(date +%Y:%m:%d:%H:%M:%S)"
echo  " Running LTMSS tcEqredo argument "
./LTSSMtool txEqRedo 100 [$1,$2,$3]

echo  " $(date +%Y:%m:%d:%H:%M:%S)"
echo  " Running LTMSS SBR argument "
./LTSSMtool sbr 1000 [$1,$2,$3]


echo "Done"
exit





