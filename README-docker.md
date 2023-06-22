# Installing in a docker environment

Follow these steps for building and running the equivalence checker inside a Docker container.

0. [Install Docker Engine](https://docs.docker.com/engine/install/) and set it up.  You may need to setup proxy for [docker daemon](https://docs.docker.com/config/daemon/systemd/#httphttps-proxy) and
   [docker client](https://docs.docker.com/network/proxy/).  Make sure you are able to run the [hello-world example](https://docs.docker.com/get-started/#test-docker-installation).
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

The equivalence checker is now ready for use.

