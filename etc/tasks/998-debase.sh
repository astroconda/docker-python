#!/bin/bash
packages=(
    gcc
    gcc-c++
    gcc-gfortran
)
yum remove -y "${packages[@]}"
