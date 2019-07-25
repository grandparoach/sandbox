#!/bin/bash

count=${1}
index=1
while [ $index -le $count ]
do
        az group delete -n "student-$index" --yes --no-wait
        let index=$index+1
done
