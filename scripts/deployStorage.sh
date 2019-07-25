#!/bin/bash

count=${1}
end_count=${2}
index=$count
while [ $index -le $end_count ]
do
   #az group create -l southcentralus -n "student-$index"
   az group deployment create -g "student-$index" --template-uri https://raw.githubusercontent.com/grandparoach/sandbox/LCI/deployStorage3.json --parameters @lciparams.json &
   let index=$index+1
done
