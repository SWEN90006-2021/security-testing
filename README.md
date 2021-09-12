# SWEN90006: Security & Software Testing

This repository contains instructions to run examples in lectures 7-12. We use Docker that allows students to build and run examples in the same way regardless of their operating systems (e.g., Linux, Windows, or macOS).

# Installation

## Install Docker

Please follow [this instruction](https://docs.docker.com/get-docker/) to install Docker on your machine.

## Build a Docker image

First, we need to build a Docker image using the given Dockerfile. The Docker image has everything ready for our experiments. Once we make changes to the Dockerfile, we would need to rerun this command.
```bash
docker build . -t swen90006 --no-cache
```

If the build is successful, we should have a new Docker image named swen90006. To see all Docker images on our computer, we can run the following command.
```bash
docker image ls
```

# Weekly Examples

Before start running an example, we need to start a Docker container using the successfully built Docker image
```bash
docker run -it swen90006 /bin/bash
```

## Week 7: Introduction to Security Testing
Compile a buggy program named check_pin. To demonstrate the stack overflow vulnerability in check_pin, we add the '-fno-stack-protector' option letting the compiler (gcc) to disable its stack protector.
```bash
cd $WORKDIR
gcc -o check_pin check_pin.c -fno-stack-protector
```

Run the random fuzzer to fuzz the check_pin example
```bash
cd $WORKDIR
random_fuzzer.sh ./check_pin 20 results-random
```

Run the mutation-based fuzzer to fuzz the check_pin example
```bash
cd $WORKDIR
mutation_fuzzer.sh ./check_pin 1234 20 results-mutation
```

## Week 8: Generation-based Blackbox Fuzzing and Code Coverage-guided Greybox Fuzzing
In this week we fuzz test [LibPNG](http://www.libpng.org/pub/png/libpng.html), which is the official PNG reference library.

### Fuzzing LibPNG using Generation-based Blackbox Fuzzing (e.g., Peach Fuzzer)
Compile the newest version of LibPNG. Once the compilation is done, all LibPNG utilities (e.g., pngimage) should be stored in the libpng folder.

```bash
cd $WORKDIR
git clone https://github.com/glennrp/libpng.git 
cd libpng
autoreconf -f -i
./configure --disable-shared
make clean all
```

Fuzzing pngimage, a specific utility in LibPNG, using Peach input generator with no seed inputs i.e. inputs are generated directly from a given input model.
```bash
cd $WORKDIR
generation_fuzzer.sh libpng/pngimage png_pit_no_seeds.xml 20 results-no-seeds
```

Fuzzing pngimage using Peach input generator with seed inputs which are stored in a folder named 'in'.
```bash
cd $WORKDIR
mkdir in
cp libpng/*.png in/
generation_fuzzer.sh libpng/pngimage png_pit.xml 20 results-with-seeds
```

### Fuzzing LibPNG using Code Coverage-guided Greybox Fuzzing (e.g., American Fuzzy Lop (AFL))
Compile LibPNG with AFL instrumentation pass (afl-clang-fast) so that code coverage information can be dynamically collected while the program under test is running. Note that unlike Peach fuzzer, the vanilla AFL fuzzer cannot detect and fix integrity checks like checksums so we disable the checksum checks in the LibPNG source code by applying a simple patch.

```bash
cd $WORKDIR
git clone https://github.com/glennrp/libpng.git libpng-afl
cd libpng-afl
sed -i 's/return ((int)(crc != png_ptr->crc));/return (0);/g' pngrutil.c
autoreconf -f -i
CC=afl-clang-fast ./configure --disable-shared
make clean all
```

Fuzzing pngimage using AFL. AFL will take the sample inputs, mutate them, and store interesting inputs into an output folder.
```bash
cd $WORKDIR
afl-fuzz -i in -o out -- libpng-afl/pngimage @@
```
