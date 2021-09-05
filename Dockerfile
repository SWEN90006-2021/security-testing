FROM ubuntu:18.04

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
    zzuf \
    wget

# Add a new user ubuntu, pass: ubuntu
RUN groupadd ubuntu && \
    useradd -rm -d /home/ubuntu -s /bin/bash -g ubuntu -G sudo -u 1000 ubuntu -p "$(openssl passwd -1 ubuntu)"

# Use ubuntu as the default username
USER ubuntu
WORKDIR /home/ubuntu

# Set up environment variable
ENV WORKDIR="/home/ubuntu"

# Copy file from the host folder where Dockerfile is stored
COPY --chown=ubuntu:ubuntu check_pin.c $WORKDIR/check_pin.c
COPY --chown=ubuntu:ubuntu random_fuzzer.sh $WORKDIR/random_fuzzer.sh
COPY --chown=ubuntu:ubuntu mutation_fuzzer.sh $WORKDIR/mutation_fuzzer.sh

# Install other software packages from source (e.g., radamsa fuzzer)
RUN cd $HOME && \
    git clone https://gitlab.com/akihe/radamsa.git && \
    cd radamsa && \
    make && \
    echo "ubuntu" | sudo -S make install

# Compile the program under test
RUN cd $HOME && \
    gcc -o check_pin check_pin.c -fno-stack-protector
