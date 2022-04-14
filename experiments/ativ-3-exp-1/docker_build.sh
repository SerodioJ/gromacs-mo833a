#!/bin/bash

cd ../..
trap "exit" INT

docker build -t gromacs-ativ3-exp1:release --build-arg flags="-DGMX_BUILD_OWN_FFTW=ON" .
docker build -t gromacs-ativ3-exp1:debug --build-arg flags="-DGMX_BUILD_OWN_FFTW=ON -DCMAKE_BUILD_TYPE=Debug" .
