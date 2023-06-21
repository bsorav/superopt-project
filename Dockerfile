FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
# enable i386 packages support
RUN dpkg --add-architecture i386
# install required dependencies
COPY install-dependencies.sh /tmp/install-dependencies.sh
RUN apt-get update && bash /tmp/install-dependencies.sh
# add non-root user
RUN groupadd -r user && \
    useradd -r -g user -d /home/user -s /bin/bash -c "Docker image user" user && \
    mkdir -p /home/user && \
    chown -R user:user /home/user
# copy everything to user directory
COPY --chown=user . /home/user/eqchecker/
WORKDIR /home/user/eqchecker
# install boost
RUN make -C tars install_boost
# switch to non-root user
USER user
ENV SUPEROPT_TARS_DIR /home/user/eqchecker/tars
ENV LOGNAME user
