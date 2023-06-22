# Building

* Install dependencies using script: `sudo ./install-dependencies.sh`
* Create the boost tarfile: `make -C tars install_boost`
* `make install`

# Testing

`cd superopt-tests && make clangv_Od > clangv_Od.out & ../superopt/utils/show-results build`

# Installing in a docker environment

Follow these steps for building and running the equivalence checker inside a Docker container.

0. See doc/Docker.md for instruction on how to install the Docker engine.
1. Build the Docker image.  Note that internet connectivity is required in this step.
   ```
   docker build -t eqchecker .
   ```
   This process can take a while depending upon your internet connection bandwidth.  
2. Run the container.
   ```
   docker run -it eqchecker:latest /bin/bash
   ```
3. (Inside the container) Build and install the equivalence checker.
   ```
   make install
   ```
