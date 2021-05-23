# Build envoroment

The build enviroment is base on randomdude/gcc-cross-compiler docker images, plus the rust 
toolchain installation setup to nightly version.

The image is assembled with a buildah script.

## Build the image

To build the images simply run ```./jarvis-build-env```.

## Run the image

Run the image with docker or podman simple with the command, attaching as a valume the project root dir.

```shell
podman run -it --rm -v `pwd`:/working_home:z dlabc/jarvis-build-env:0.0.2
```
