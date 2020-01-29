#!/bin/bash

pop=$1
backup=${2:-retain}

if [ $backup != retain ]
then
  mkdir ${pop}Backup
else
  mkdir $pop
fi

