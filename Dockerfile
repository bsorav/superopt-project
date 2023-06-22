FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
# enable i386 packages support
RUN dpkg --add-architecture i386
# install required dependencies
COPY install-dependencies.sh /tmp/install-dependencies.sh
RUN apt-get update && bash /tmp/install-dependencies.sh
# add non-root user. The password hash was generated using the mkpasswd utility
RUN groupadd -r eqcheck && \
    useradd -r -g eqcheck -G admin -d /home/eqcheck -s /bin/bash -c "Docker image user for eqcheck" -p PbwH5rSGt4BBE eqcheck && \
    mkdir -p /home/eqcheck && \
    chown -R eqcheck:eqcheck /home/eqcheck
# copy everything to user directory
COPY --chown=eqcheck . /home/eqcheck/superopt-project/
WORKDIR /home/eqcheck/superopt-project
# install boost
RUN make -C tars install_boost
RUN make -C vscode-extension node_install
# switch to non-root user
USER eqcheck
RUN make -C vscode-extension node_install_modules
ENV SUPEROPT_TARS_DIR /home/eqcheck/superopt-project/tars
ENV SUPEROPT_PROJECT_DIR /home/eqcheck/superopt-project
ENV LOGNAME eqcheck
