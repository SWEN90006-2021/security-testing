FROM ubuntu:20.04

# On Mac M1, M2 and M3 chip, Please uncomment the below line. And comment the above line
#FROM --platform=linux/amd64 ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install common dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    sudo \
    build-essential \
    openssl \
    clang \    
    graphviz-dev \
    git \
    libgnutls28-dev \
    python2 \
    nano \
    net-tools \
    vim \
    wget \
    software-properties-common \
    automake \
    libtool \
    libc6-dev-i386 \
    g++-multilib \
    unzip \
    tzdata \
    llvm \
    llvm-dev \
    gnupg \
    zlib1g-dev \
    ca-certificates && \
    ln -s /usr/bin/python2.7 /usr/bin/python


# Install Mono from the official Mono Project repository
RUN wget https://download.mono-project.com/repo/xamarin.gpg && \
    apt-key add xamarin.gpg && \
    echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | tee /etc/apt/sources.list.d/mono-official-stable.list && \
    rm xamarin.gpg && \
    apt-get update -y && \
    apt-get install -y mono-complete

# Install downgraded version of gcc and g++ to 4.4, to install peach
RUN echo 'deb http://dk.archive.ubuntu.com/ubuntu/ trusty main' >> \
    /etc/apt/sources.list && \
echo 'deb http://dk.archive.ubuntu.com/ubuntu/ trusty universe' >> \
    /etc/apt/sources.list && \
apt-get update 
RUN apt-get install -y gcc-4.4 g++-4.4

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
ENV MONO_ENV_OPTIONS="--interpreter"

# The following environment variables are set to make AFL work inside a Docker container
ENV AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 \
    AFL_SKIP_CPUFREQ=1 \
    AFL_NO_AFFINITY=1 \
    AFL_NO_X86=1

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
    wget https://storage.googleapis.com/fuzzbench-files/peach-3.0.202-source.zip &&\
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
    cd llvm_mode; LLVM_CONFIG=llvm-config-10 make
