#!/bin/bash

release=true
use_container=false
input_path="input"
data_path="data"

trap "exit" INT
while getopts cdi:p: flag
do
    case "${flag}" in
        c) use_container=true;;
        d) release=false;;
        i) input_path=$OPTARG;;
        p) data_path=$OPTARG;;

    esac
done
echo $use_container
echo $release

if $release; then
    build_path="build_release"
    tag="release"
else
    build_path="build_debug"
    tag="debug"
fi

mkdir -p $data_path
rm $data_path/*
cp $input_path/* $data_path
if $use_container; then 
    cd $data_path
    docker run -it -v ${PWD}:${PWD} -w ${PWD} --rm gromacs-ativ3-exp1:$tag gmx pdb2gmx -f 6LVN.pdb -o 6LVN_processed.gro -water spce
    docker run -it -v ${PWD}:${PWD} -w ${PWD} --rm gromacs-ativ3-exp1:$tag gmx editconf -f 6LVN_processed.gro -o 6LVN_newbox.gro -c -d 1.0 -bt cubic
    docker run -it -v ${PWD}:${PWD} -w ${PWD} --rm gromacs-ativ3-exp1:$tag gmx solvate -cp 6LVN_newbox.gro -cs spc216.gro -o 6LVN_solv.gro -p topol.top
    docker run -it -v ${PWD}:${PWD} -w ${PWD} --rm gromacs-ativ3-exp1:$tag gmx grompp -f ions.mdp -c 6LVN_solv.gro -p topol.top -o ions.tpr
    docker run -it -v ${PWD}:${PWD} -w ${PWD} --rm gromacs-ativ3-exp1:$tag gmx genion -s ions.tpr -o 6LVN_solv_ions.gro -p topol.top -pname NA -nname CL -neutral
    docker run -it -v ${PWD}:${PWD} -w ${PWD} --rm gromacs-ativ3-exp1:$tag gmx grompp -f ions.mdp -c 6LVN_solv_ions.gro -p topol.top -o em.tpr
else
    export PATH=$(pwd)/$build_path/bin:$PATH
    cd $data_path
    gmx pdb2gmx -f 6LVN.pdb -o 6LVN_processed.gro -water spce
    gmx editconf -f 6LVN_processed.gro -o 6LVN_newbox.gro -c -d 1.0 -bt cubic
    gmx solvate -cp 6LVN_newbox.gro -cs spc216.gro -o 6LVN_solv.gro -p topol.top
    gmx grompp -f ions.mdp -c 6LVN_solv.gro -p topol.top -o ions.tpr
    gmx genion -s ions.tpr -o 6LVN_solv_ions.gro -p topol.top -pname NA -nname CL -neutral
    gmx grompp -f ions.mdp -c 6LVN_solv_ions.gro -p topol.top -o em.tpr
fi
