#!/bin/bash

data_path="data";
results_path="results"

trap "exit" INT
while getopts p:r: flag
do
    case "${flag}" in
        p) data_path=$OPTARG;;
        r) results_path=$OPTARG;;
    esac
done

mkdir -p $results_path
OLD_PATH=$PATH

# Perf
echo Starting Perf Profiling
docker run -it --privileged -v ${PWD}:${PWD} -w ${PWD} --rm gromacs-ativ4-exp1:release perf record --call-graph lbr -o $results_path/perf.data gmx mdrun -v -deffnm $data_path/em
echo Perf Profiling ended

# Callgrind
echo Starting Callgrind Profiling
docker run -it --privileged -v ${PWD}:${PWD} -w ${PWD} --rm gromacs-ativ4-exp1:release valgrind --tool=callgrind --callgrind-out-file=$results_path/callgrind.data gmx mdrun -v -deffnm $data_path/em
echo Perf Profiling ended
