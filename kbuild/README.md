# KBuild

Custom cargo commad to build run and configure(in the future) the kernel.

## Build and install the package

To build the package simply run inside this directory ```cargo build```.
To install the package move into the parent directory and run ```cargo install --path kbuild/```

## Run the image

Run the kernel iso with qemu ```cargo kbuild runner```.

## Build the kernel

Build the kernel  with ```cargo kbuild build```. (A simple wrapper for cargo build).

## Configure the kernel

Configure the kernel with ```cargo kbuild configure```. (Nice to have, but the end is far away).