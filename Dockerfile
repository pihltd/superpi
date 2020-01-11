#! Trying to put samtools and fusera in a single container

#######################################################
#                                                     #
#         Installing samtools and htslib              #
#                                                     #
#######################################################

FROM ubuntu:16.04

MAINTAINER Todd Pihl @ FNLCR todd.pihl@nih.gov

#htslib pull
ENV VERSIONH 1.9
ENV NAMEH htslib
ENV URLH "https://github.com/samtools/${NAMEH}/releases/download/${VERSIONH}/${NAMEH}-${VERSIONH}.tar.bz2"

#samtools pull
ENV VERSIONS 1.9
ENV NAMES samtools
ENV URLS "https://github.com/samtools/${NAMES}/releases/download/${VERSIONS}/${NAMES}-${VERSIONS}.tar.bz2"

#Add required libraries
RUN apt-get update
RUN apt-get -y install \
  build-essential \
  zlib1g-dev \
  libncurses5-dev \
  libbz2-dev \
  liblzma-dev \
  libcurl4-openssl-dev \
  libssl-dev \
  libfuse-dev \
  fuse

#htslib build
WORKDIR /
ADD ${URLH} /

RUN tar xvjf ${NAMEH}-${VERSIONH}.tar.bz2
WORKDIR ${NAMEH}-${VERSIONH}
RUN pwd
RUN ./configure
RUN make
RUN make install
WORKDIR /

#samtools build
ADD ${URLS} /
RUN tar xvjf ${NAMES}-${VERSIONS}.tar.bz2
WORKDIR ${NAMES}-${VERSIONS}
RUN ./configure
RUN make
RUN make install
WORKDIR /

#####################################################
#                                                   #
#         Installing Fusera                         #
#                                                   #
#####################################################

ENV VERSIONF v0.0.13
ENV URLF "https://github.com/mitre/fusera/releases/download/${VERSIONF}/fusera"

ADD ${URLF} /
RUN mv fusera /usr/local/bin
WORKDIR /usr/local/bin
RUN chmod 555 fusera
WORKDIR /
###################################################
#                                                 #
#         Set up the rest                         #
#                                                 #
###################################################

#/data is the fusera mountpoint.  Mounted as part of workflow
#/results is directory where samtools saves files.  Mount to VM directory for saved data
#/creds is where the ngc file resides.  Mount to VM directory containing ngc file
VOLUME ["/data", "/results","/creds"]
