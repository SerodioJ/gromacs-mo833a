#!/bin/bash

release=true
input_path="input"
data_path="data"

while getopts :di:p: flag
do
    case "${flag}" in
        d) release=false;;
        i) input_path=$OPTARG;;
        p) data_path=$OPTARG;;
    esac
done

if $release; then
    build_path="build_release"
else
    build_path="build_debug"
fi

mkdir -p $data_path
cp $input_path/* $data_path
cd $data_path

export PATH=$(pwd)/$build_path/bin:$PATH

gmx pdb2gmx -f 6LVN.pdb -o 6LVN_processed.gro -water spce
gmx editconf -f 6LVN_processed.gro -o 6LVN_newbox.gro -c -d 1.0 -bt cubic
gmx solvate -cp 6LVN_newbox.gro -cs spc216.gro -o 6LVN_solv.gro -p topol.top
gmx grompp -f ions.mdp -c 6LVN_solv.gro -p topol.top -o ions.tpr
gmx genion -s ions.tpr -o 6LVN_solv_ions.gro -p topol.top -pname NA -nname CL -neutral
gmx grompp -f ions.mdp -c 6LVN_solv_ions.gro -p topol.top -o em.tpr
