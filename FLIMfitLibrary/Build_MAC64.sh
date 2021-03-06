#!/bin/bash

echo "Ensure homebrew is installed..."
(brew | grep "command not found") \
	&& ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)" \
	|| echo "homebrew installed"

echo "Ensure gcc 4.7 and boost are installed..."
# Ensure gcc47, boost is installed using Homebrew
(brew list | grep gcc47) && echo " installed" || brew tap homebrew/versions
(brew list | grep gcc47)  || brew install gcc47
(brew list | grep boost) && echo " installed" || brew install boost
(brew list | grep ghostscript) && echo " installed" || brew install ghostscript

# Make sure we compile with gcc-4.7
export CC=gcc-4.7
export CXX=g++-4.7

echo "Cleaning 64 bit CMake Project..."
rm -rf GeneratedProjects/gcc_64
mkdir -p GeneratedProjects/gcc_64
cd GeneratedProjects/gcc_64

echo "Generating 64 bit CMake Project..."
cmake ../../ -G "Unix Makefiles"

echo "Building 64 bit Project..."
make

cd ../../

echo "Cleaning 64 bit CMake Xcode Project..."
rm -rf GeneratedProjects/Xcode_64
mkdir -p GeneratedProjects/Xcode_64
cd GeneratedProjects/Xcode_64

echo "Generating 64 bit CMake Xcode Project..."
cmake ../../ -G "Xcode"

cd ../../


