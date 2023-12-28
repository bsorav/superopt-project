# setup a base environment
FROM ubuntu:20.04 AS base
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
    mkdir -p /home/eqcheck/superopt-project && \
    chown -R eqcheck:eqcheck /home/eqcheck
# set cwd to project root
WORKDIR /home/eqcheck/superopt-project
# copy tars directory for custom installations
COPY --chown=eqcheck tars tars/
# install boost from tar
RUN make -C tars install_boost
# switch to non-root user
USER eqcheck
# setup environment variables
ENV SUPEROPT_TARS_DIR       /home/eqcheck/superopt-project/tars
ENV SUPEROPT_PROJECT_DIR    /home/eqcheck/superopt-project
ENV SUPEROPT_INSTALL_DIR    /home/eqcheck/superopt-project/usr/local
ENV SUPEROPT_SPEC_TESTS_DIR /home/eqcheck/superopt-project/superopt-tests/spec-tests
ENV PATH="${PATH}:${SUPEROPT_INSTALL_DIR}/bin"
ENV LOGNAME eqcheck
ENV PS1="%~$ "

# setup a src environment
FROM base AS src
# copy sources and build scripts to user directory
COPY --chown=eqcheck Makefile       .
COPY --chown=eqcheck superopt       superopt/
COPY --chown=eqcheck llvm-project   llvm-project/
COPY --chown=eqcheck jemalloc       jemalloc/
COPY --chown=eqcheck superoptdbs    superoptdbs/
COPY --chown=eqcheck superopt-tests superopt-tests/
# open shell by default
CMD [ "bash" ]

# setup a build environment
FROM src AS build
# build project
RUN make all
# open shell by default
CMD [ "bash" ]

# setup a binary environment
FROM base AS binary
# copy minimal binaries to user directory
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/superopt/build/etfg_i386/s2c                     superopt/build/etfg_i386/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/superopt/build/etfg_i386/spec2tfg                superopt/build/etfg_i386/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/superopt/build/etfg_x64/qd_helper_process        superopt/build/etfg_x64/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/superopt/build/etfg_x64/smt_helper_process       superopt/build/etfg_x64/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/superopt/build/third_party/cvc4                  superopt/build/third_party/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/superopt/build/third_party/yices_smt2            superopt/build/third_party/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/superopt/build/third_party/z3                    superopt/build/third_party/z3
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/superopt/build/third_party/z3v487                superopt/build/third_party/z3v487

COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/bin/clang-12                  llvm-project/build/bin/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/bin/clang-offload-bundler     llvm-project/build/bin/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/bin/clang-offload-wrapper     llvm-project/build/bin/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/bin/clang-tblgen              llvm-project/build/bin/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/bin/opt                       llvm-project/build/bin/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/bin/scan-build                llvm-project/build/bin/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/bin/scan-view                 llvm-project/build/bin/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/bin/llvm2tfg                  llvm-project/build/bin/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/bin/llc                       llvm-project/build/bin/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/bin/llvm-as                   llvm-project/build/bin/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/bin/llvm-config               llvm-project/build/bin/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/bin/llvm-dis                  llvm-project/build/bin/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/bin/llvm-link                 llvm-project/build/bin/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/bin/llvm-lit                  llvm-project/build/bin/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/bin/llvm-tblgen               llvm-project/build/bin/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/lib/clang                     llvm-project/build/lib/clang
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/libexec/ccc-analyzer          llvm-project/build/libexec/
COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/llvm-project/build/libexec/c++-analyzer          llvm-project/build/libexec/

COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/superoptdbs                                      superoptdbs/

COPY --chown=eqcheck --from=build /home/eqcheck/superopt-project/superopt-tests/spec-tests                        superopt-tests/spec-tests/
# create install symlinks
RUN mkdir -p /home/eqcheck/superopt-project/usr/local/bin \
    && ln -s /home/eqcheck/superopt-project/llvm-project/build/bin/clang-12     /home/eqcheck/superopt-project/llvm-project/build/bin/clang      \
    && ln -s /home/eqcheck/superopt-project/llvm-project/build/bin/clang-12     /home/eqcheck/superopt-project/llvm-project/build/bin/clang++    \
    && ln -s /home/eqcheck/superopt-project/llvm-project/build/bin/clang-12     /home/eqcheck/superopt-project/llvm-project/build/bin/clang-cl   \
    && ln -s /home/eqcheck/superopt-project/llvm-project/build/bin/clang-12     /home/eqcheck/superopt-project/llvm-project/build/bin/clang-cpp

RUN mkdir -p /home/eqcheck/superopt-project/usr/local/bin \
    && ln -s /home/eqcheck/superopt-project/llvm-project/build/bin/clang                                       /home/eqcheck/superopt-project/usr/local/bin/clang                \
    && ln -s /home/eqcheck/superopt-project/llvm-project/build/bin/clang++                                     /home/eqcheck/superopt-project/usr/local/bin/clang++              \
    && ln -s /home/eqcheck/superopt-project/llvm-project/build/bin/llc                                         /home/eqcheck/superopt-project/usr/local/bin/llc                  \
    && ln -s /home/eqcheck/superopt-project/llvm-project/build/bin/llvm-as                                     /home/eqcheck/superopt-project/usr/local/bin/llvm-as              \
    && ln -s /home/eqcheck/superopt-project/llvm-project/build/bin/llvm-dis                                    /home/eqcheck/superopt-project/usr/local/bin/llvm-dis             \
    && ln -s /home/eqcheck/superopt-project/llvm-project/build/bin/llvm-link                                   /home/eqcheck/superopt-project/usr/local/bin/llvm-link            \
    && ln -s /home/eqcheck/superopt-project/llvm-project/build/bin/llvm2tfg                                    /home/eqcheck/superopt-project/usr/local/bin/llvm2tfg             \
    && ln -s /home/eqcheck/superopt-project/llvm-project/build/bin/opt                                         /home/eqcheck/superopt-project/usr/local/bin/opt                  \
    && ln -s /home/eqcheck/superopt-project/llvm-project/build/bin/scan-build                                  /home/eqcheck/superopt-project/usr/local/bin/scan-build           \
    && ln -s /home/eqcheck/superopt-project/llvm-project/build/bin/scan-view                                   /home/eqcheck/superopt-project/usr/local/bin/scan-view            \
    && ln -s /home/eqcheck/superopt-project/superopt/build/third_party/cvc4                                    /home/eqcheck/superopt-project/usr/local/bin/cvc4                 \
    && ln -s /home/eqcheck/superopt-project/superopt/build/third_party/yices_smt2                              /home/eqcheck/superopt-project/usr/local/bin/yices_smt2           \
    && ln -s /home/eqcheck/superopt-project/superopt/build/third_party/z3/z3-4.8.14-x64-glibc-2.31/bin/z3      /home/eqcheck/superopt-project/usr/local/bin/z3                   \
    && ln -s /home/eqcheck/superopt-project/superopt/build/third_party/z3v487/usr/bin/z3                       /home/eqcheck/superopt-project/usr/local/bin/z3v487               \
    && ln -s /home/eqcheck/superopt-project/superopt/build/etfg_i386/s2c                                       /home/eqcheck/superopt-project/usr/local/bin/s2c                  \
    && ln -s /home/eqcheck/superopt-project/superopt/build/etfg_i386/spec2tfg                                  /home/eqcheck/superopt-project/usr/local/bin/spec2tfg             \
    && ln -s /home/eqcheck/superopt-project/superopt/build/etfg_x64/smt_helper_process                         /home/eqcheck/superopt-project/usr/local/bin/smt_helper_process   \
    && ln -s /home/eqcheck/superopt-project/superopt/build/etfg_x64/qd_helper_process                          /home/eqcheck/superopt-project/usr/local/bin/qd_helper_process      

RUN mkdir -p /home/eqcheck/superopt-project/usr/local \
    && ln -s /home/eqcheck/superopt-project/llvm-project/build/lib   /home/eqcheck/superopt-project/usr/local/lib  \
    && ln -s /home/eqcheck/superopt-project/superoptdbs              /home/eqcheck/superopt-project/usr/local/superoptdbs
# remove build artifacts and strip binaries
RUN rm -rf tars superoptdbs/Makefile && find -type f -name '*.bz2' -delete && find . -type f -executable -exec strip {} \;
# set cwd to tests root
WORKDIR ${SUPEROPT_SPEC_TESTS_DIR}
# enter shell by default
CMD [ "bash" ]
