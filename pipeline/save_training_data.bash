#!/bin/bash

popName=$1

source config.txt
export trainingSetSize
export numChannels
export numBootChannels
export numBootSamples

python save_training_data.py $popName
