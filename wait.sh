#!/bin/bash
sleep 1
dots=''
until ! kubectl get pod -A | grep -Ev '(STATUS|Running|Completed)' >/dev/null
do
  if [ "$dots" = '..........' ];
  then
    dots=''
    echo -ne "\r          "
  fi
  dots="$dots."
  echo -n -e "\r$dots"
  sleep 1
done
echo -e '\r          \rReady'
