#!/bin/bash

cd sims
perl -e 'for(<*>){((stat)[9]<(unlink))}'
