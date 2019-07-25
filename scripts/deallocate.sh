#!/bin/bash

count=${1}
end_count=${2}
index=$count
while [ $index -le $end_count ]
do
        rg="student-$index"
        echo $rg
        az vm list -g $rg --query "[].[join(' ',[resourceGroup, name])]" -o tsv | awk '{system("az vm deallocate -g "$1" -n "$2" &")}'
        let index=$index+1
done
