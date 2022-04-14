#!/bin/bash

samples=10;
data_path="data";
results_path="results"

trap "exit" INT
while getopts s:p:r: flag
do
    case "${flag}" in
        s) samples=$OPTARG;;
        p) data_path=$OPTARG;;
        r) results_path=$OPTARG;;
    esac
done

mkdir -p $results_path
OLD_PATH=$PATH

# Release

rm $results_path/docker_release.csv
for counter in $(seq 1 $samples); do
    echo Starting Release Run $counter of $samples
    docker run -it -v ${PWD}:${PWD} -w ${PWD} --rm gromacs-ativ3-exp1:release gmx mdrun -v -deffnm $data_path/em 2>/dev/null | grep "MO833" | cut -d " " -f 5 >> $results_path/docker_release.csv
    echo Release Runs: $counter/$samples
done

#Debug
export PATH=$(pwd)/build_debug/bin:$OLD_PATH
rm $results_path/docker_debug.csv
for counter in $(seq 1 $samples); do
    echo Starting Debug Run $counter of $samples
    docker run -it -v ${PWD}:${PWD} -w ${PWD} --rm gromacs-ativ3-exp1:debug gmx mdrun -v -deffnm $data_path/em 2>/dev/null | grep "MO833" | cut -d " " -f 5 >> $results_path/docker_debug.csv
    echo Debug Runs: $counter/$samples
done