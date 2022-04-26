#!/bin/bash

cd ../..
trap "exit" INT

docker build -t gromacs-ativ4-exp1:release --build-arg flags="-DGMX_BUILD_OWN_FFTW=ON" .
