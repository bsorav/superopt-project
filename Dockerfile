FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
# enable i386 packages support
RUN dpkg --add-architecture i386
# install required dependencies
COPY install-dependencies.sh /tmp/install-dependencies.sh
RUN apt-get update && bash /tmp/install-dependencies.sh
# add non-root user. The password hash was generated using the mkpasswd utility
RUN groupadd eqcheck && \
    groupadd -r admin && \
    useradd -g eqcheck -G admin -d /home/eqcheck -s /bin/bash -c "Docker image user for eqcheck" -p PbwH5rSGt4BBE eqcheck && \
    mkdir -p /home/eqcheck && \
    chown -R eqcheck:eqcheck /home/eqcheck
# install boost
COPY --chown=eqcheck tars                        /home/eqcheck/artifact/tars
RUN make -C /home/eqcheck/artifact/tars install_boost
# copy relevant files to user directory
COPY --chown=eqcheck superoptdbs                 /home/eqcheck/artifact/superoptdbs
COPY --chown=eqcheck jemalloc                    /home/eqcheck/artifact/jemalloc
COPY --chown=eqcheck superopt-tests              /home/eqcheck/artifact/superopt-tests
COPY --chown=eqcheck llvm-project                /home/eqcheck/artifact/llvm-project
COPY --chown=eqcheck superopt                    /home/eqcheck/artifact/superopt
COPY --chown=eqcheck *.py icc_bins.tgz Makefile  /home/eqcheck/artifact
COPY --chown=eqcheck binlibs                     /home/eqcheck/artifact/binlibs
# switch to non-root user
USER eqcheck
WORKDIR /home/eqcheck/artifact
ENV SUPEROPT_TARS_DIR /home/eqcheck/artifact/tars
ENV SUPEROPT_PROJECT_DIR /home/eqcheck/artifact
ENV PS1="%~$ "
ENV LOGNAME eqcheck
# this must happen AFTER copying superopt-tests
RUN mkdir -p /home/eqcheck/artifact/superopt-tests/build/localmem-tests && tar xmvf /home/eqcheck/artifact/icc_bins.tgz -C /home/eqcheck/artifact/superopt-tests/build/localmem-tests
# stop that pesky message
RUN touch /home/eqcheck/.zshrc
