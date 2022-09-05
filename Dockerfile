FROM ubuntu:16.04

# Install common dependencies
RUN apt-get -y update && \
    apt-get -y install sudo \ 
    apt-utils \
    build-essential \
    openssl \
    clang \
    graphviz-dev \
    git \
    libgnutls28-dev \
    python-pip \
    nano \
    net-tools \
    vim \
    wget \
    software-properties-common \
    automake \
    libtool \
    libc6-dev-i386 \
    python-pip \
    g++-multilib \
    mono-complete \
    unzip

# Install Peach Fuzzer-specific dependencies 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata

RUN add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get -y update && \
    apt-get -y install gcc-4.4 && \
    apt-get -y install g++-4.4

# Add a new user ubuntu, pass: ubuntu
RUN groupadd ubuntu && \
    useradd -rm -d /home/ubuntu -s /bin/bash -g ubuntu -G sudo -u 1000 ubuntu -p "$(openssl passwd -1 ubuntu)"

# Use ubuntu as the default username
USER ubuntu
WORKDIR /home/ubuntu

# Set up environment variables
ENV WORKDIR="/home/ubuntu"
ENV AFL="${WORKDIR}/AFL"
ENV AFL_PATH="${WORKDIR}/AFL"
ENV PATH="${PATH}:${WORKDIR}:${AFL}:${WORKDIR}/peach-3.0.202-source/output/linux_x86_64_release/bin"

# The following environment variables are set to make AFL work inside a Docker container
ENV AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 \
    AFL_SKIP_CPUFREQ=1 \
    AFL_NO_AFFINITY=1

# Copy file from the host folder where Dockerfile is stored
COPY --chown=ubuntu:ubuntu check_pin.c $WORKDIR/check_pin.c
COPY --chown=ubuntu:ubuntu random_fuzzer.sh $WORKDIR/random_fuzzer.sh
COPY --chown=ubuntu:ubuntu mutation_fuzzer.sh $WORKDIR/mutation_fuzzer.sh
COPY --chown=ubuntu:ubuntu generation_fuzzer.sh $WORKDIR/generation_fuzzer.sh
COPY --chown=ubuntu:ubuntu png_pit_no_seeds.xml $WORKDIR/png_pit_no_seeds.xml
COPY --chown=ubuntu:ubuntu png_pit.xml $WORKDIR/png_pit.xml
COPY --chown=ubuntu:ubuntu wscript_build $WORKDIR/wscript_build
COPY --chown=ubuntu:ubuntu boom_pit.xml $WORKDIR/boom_pit.xml
COPY --chown=ubuntu:ubuntu read_and_process_v1.c $WORKDIR/read_and_process_v1.c
COPY --chown=ubuntu:ubuntu read_and_process_v2.c $WORKDIR/read_and_process_v2.c
COPY --chown=ubuntu:ubuntu good_bad_fuzz.c $WORKDIR/good_bad_fuzz.c

# Install other software packages from source (e.g., radamsa fuzzer)
RUN cd $WORKDIR && \
    git clone https://gitlab.com/akihe/radamsa.git && \
    cd radamsa && \
    make && \
    echo "ubuntu" | sudo -S make install

# Install Peach generation-based fuzzer
RUN cd $WORKDIR && \
    wget https://sourceforge.net/projects/peachfuzz/files/Peach/3.0/peach-3.0.202-source.zip && \
    unzip peach-3.0.202-source.zip && \
    cp wscript_build peach-3.0.202-source/Peach.Core.Analysis.Pin.BasicBlocks/ && \
    cd peach-3.0.202-source && \
    CC=gcc-4.4 CXX=g++-4.4 ./waf configure && \
    CC=gcc-4.4 CXX=g++-4.4 ./waf install

# Install AFL code coverage-guided greybox fuzzing
RUN cd $WORKDIR && \
    git clone https://github.com/google/AFL.git && \
    cd AFL && \
    make clean all && \
    cd llvm_mode; LLVM_CONFIG=llvm-config-3.8 make
