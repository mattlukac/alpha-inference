#!/bin/bash

scale=$1

if [ $scale == 200kb ]
then
  scaleNum=200000
  echo $scaleNum
elif [ $scale == 1.1Mb ]
then
  scaleNum=1100000
  echo $scaleNum
fi

