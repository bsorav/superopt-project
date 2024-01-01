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
# copy everything to user directory
COPY --chown=eqcheck . /home/eqcheck/superopt-project/
WORKDIR /home/eqcheck/superopt-project
# install boost
RUN make -C tars install_boost
# RUN make -C vscode-extension node_install
# RUN npm install --global vsce
# RUN systemctl enable ssh
# switch to non-root user
USER eqcheck
ENV SUPEROPT_TARS_DIR /home/eqcheck/superopt-project/tars
ENV SUPEROPT_PROJECT_DIR /home/eqcheck/superopt-project
# ENV PATH="${PATH}:/home/eqcheck/bin"
ENV PS1="%~$ "
# RUN make -C vscode-extension server_install_modules client_install_modules
# RUN ssh-keygen -t rsa -f /home/eqcheck/.ssh/id_rsa -N ""
# RUN mkdir /home/eqcheck/bin \
#     && ln -s ../superopt-project/superopt/build/etfg_i386/eq /home/eqcheck/bin/eq32 \
#     && ln -s ../superopt-project/superopt/build/etfg_i386/analyze /home/eqcheck/bin/analyze32 \
#     && ln -s ../superopt-project/superopt/build/etfg_i386/clangv /home/eqcheck/bin/clangv32 \
#     && ln -s ../superopt-project/superopt/utils/show-results /home/eqcheck/bin/show-results \
#     && ln -s ../superopt-project/vscode-extension/scripts/upload-eqcheck /home/eqcheck/bin/upload-eqcheck
RUN mkdir -p superopt-tests/build/localmem-tests && unzip icc_bins.zip -d superopt-tests/build/localmem-tests/
ENV LOGNAME eqcheck
