#!/bin/bash

cluster_result=$(rpk cluster health |  grep -oP '(?<=\[).*(?=])')
pass=false

if  echo $cluster_result == "3 4 5" > /dev/null ; then 
 patition_result=$(rpk topic describe -p log | grep -oP '(?<=\[).*(?=])')
 if [[ "echo $patition_result" != *"0"* ]] && [[ "echo $patition_result" != *"1"* ]] && [[ "echo $patition_result" != *"2"* ]] ; 
   then
    echo "Congrats! You have completed the challenge!! " 
 else
  echo "Something was not right when decommissioning the redpanda-0, please check again"
 fi
else
 echo "Looks like there are some problem with either starting the new redpanda-5 broker, or decommissioning the redpanda-0 one, please check again"
fi