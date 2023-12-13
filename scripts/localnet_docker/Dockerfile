#####################################
FROM golang:1.20.7-bullseye AS lotus-builder
MAINTAINER Lotus Development Team

RUN apt-get update && apt-get install -y ca-certificates build-essential clang ocl-icd-opencl-dev ocl-icd-libopencl1 jq libhwloc-dev 

ENV XDG_CACHE_HOME="/tmp"

### taken from https://github.com/rust-lang/docker-rust/blob/master/1.63.0/buster/Dockerfile
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.63.0

RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='5cc9ffd1026e82e7fb2eec2121ad71f4b0f044e88bca39207b3f6b769aaa799c' ;; \
        arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='e189948e396d47254103a49c987e7fb0e5dd8e34b200aa4481ecc4b8e41fb929' ;; \
        *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    url="https://static.rust-lang.org/rustup/archive/1.25.1/${rustArch}/rustup-init"; \
    wget "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rustArch}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;

#COPY ./lotus/ /opt/filecoin
RUN git clone -b v1.25.0 https://github.com/filecoin-project/lotus.git /opt/filecoin
WORKDIR /opt/filecoin

RUN scripts/docker-git-state-check.sh

COPY ./devnet.patch /opt/filecoin
RUN git apply ./devnet.patch
RUN git diff

### make configurable filecoin-ffi build
ARG FFI_BUILD_FROM_SOURCE=0
ENV FFI_BUILD_FROM_SOURCE=${FFI_BUILD_FROM_SOURCE}

RUN make clean deps

ARG RUSTFLAGS=""
ARG GOFLAGS=""

RUN make 2k 

#####################################
FROM ubuntu:20.04 AS lotus-base
MAINTAINER Lotus Development Team

# Base resources
COPY --from=lotus-builder /etc/ssl/certs                           /etc/ssl/certs
COPY --from=lotus-builder /lib/*/libdl.so.2         /lib/
COPY --from=lotus-builder /lib/*/librt.so.1         /lib/
COPY --from=lotus-builder /lib/*/libgcc_s.so.1      /lib/
COPY --from=lotus-builder /lib/*/libutil.so.1       /lib/
COPY --from=lotus-builder /usr/lib/*/libltdl.so.7   /lib/
COPY --from=lotus-builder /usr/lib/*/libnuma.so.1   /lib/
COPY --from=lotus-builder /usr/lib/*/libhwloc.so.*  /lib/
COPY --from=lotus-builder /usr/lib/*/libOpenCL.so.1 /lib/

RUN useradd -r -u 532 -U fc \
 && mkdir -p /etc/OpenCL/vendors \
 && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

#####################################
FROM lotus-base AS lotus
MAINTAINER Lotus Development Team

COPY --from=lotus-builder /opt/filecoin/lotus /usr/local/bin/
COPY --from=lotus-builder /opt/filecoin/lotus-shed /usr/local/bin/
COPY --from=lotus-builder /opt/filecoin/scripts/docker-lotus-entrypoint.sh /

ARG DOCKER_LOTUS_IMPORT_SNAPSHOT https://snapshots.mainnet.filops.net/minimal/latest
ENV DOCKER_LOTUS_IMPORT_SNAPSHOT ${DOCKER_LOTUS_IMPORT_SNAPSHOT}
ENV FILECOIN_PARAMETER_CACHE /var/tmp/filecoin-proof-parameters
ENV LOTUS_PATH /var/lib/lotus
ENV DOCKER_LOTUS_IMPORT_WALLET ""

RUN mkdir /var/lib/lotus /var/tmp/filecoin-proof-parameters
RUN chown fc: /var/lib/lotus /var/tmp/filecoin-proof-parameters

VOLUME /var/lib/lotus
VOLUME /var/tmp/filecoin-proof-parameters

USER fc

EXPOSE 1234

ENTRYPOINT ["/docker-lotus-entrypoint.sh"]

CMD ["-help"]

#####################################
FROM lotus-base AS lotus-devnet

RUN apt-get update && apt-get install -y curl git

ENV FILECOIN_PARAMETER_CACHE /var/tmp/filecoin-proof-parameters
ENV LOTUS_MINER_PATH /root/.lotusminer
ENV LOTUS_PATH /root/.lotus 
ENV LOCALNET_RPC_URL http://127.0.0.1:1234/rpc/v1
ENV PRIVATE_KEY=0x0a3570f105ea5d06c355ea1a7a1fea441e90e44984896779b6c44c2ca5a8e16b

COPY --from=lotus-builder /opt/filecoin/lotus          /usr/local/bin/
COPY --from=lotus-builder /opt/filecoin/lotus-seed     /usr/local/bin/
COPY --from=lotus-builder /opt/filecoin/lotus-shed     /usr/local/bin/
COPY --from=lotus-builder /opt/filecoin/lotus-miner    /usr/local/bin/
COPY ./devnet.bash    /usr/local/bin/
COPY ./devnet-entry.bash /usr/local/bin/

RUN mkdir /var/tmp/filecoin-proof-parameters
RUN mkdir /var/lib/lotus
RUN mkdir /var/lib/lotus-miner
RUN chown fc: /var/tmp/filecoin-proof-parameters
RUN chown fc: /var/lib/lotus
RUN chown fc: /var/lib/lotus-miner

COPY ./filecoin-proof-parameters/* /var/tmp/filecoin-proof-parameters/
RUN lotus fetch-params 2k

VOLUME /var/tmp/filecoin-proof-parameters
VOLUME /var/lib/lotus
VOLUME /var/lib/lotus-miner
VOLUME /root

EXPOSE 1234
EXPOSE 2345

RUN /usr/local/bin/devnet.bash

CMD ["/usr/local/bin/devnet-entry.bash"]
