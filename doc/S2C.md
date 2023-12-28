# Building S2C docker images
- Go to the root of superopt-project => `cd $SUPEROPT_PROJECT_DIR`
- Build dev image with sources => `docker build -t s2c-dev:1.0 --target src .`
- Build binary-only image => `docker build -t s2c:1.0 --target binary .`

# Saving S2C docker image
- Save dev image => `docker save s2c-dev:1.0 | bzip2 > s2c-dev-docker-image.tar.bz2`
- Save binary image => `docker save s2c:1.0 | bzip2 > s2c-docker-image.tar.bz2`

# Using S2C dev docker image
- Extract the docker image => `bunzip2 s2c-dev-docker-image.tar.bz2`
- Load the docker image => `docker load < s2c-dev-docker-image.tar`
- Start a docker container & enter shell => `docker run -it s2c-dev:1.0`
- Open README.md for details on how to run tests => `vim $SUPEROPT_SPEC_TESTS_DIR/README.md`
- Detach from shell without stopping image => `ctrl+p ctrl+q`
- Reattach to container shell => `docker attach <container-name-or-id>`

# Using S2C binary docker image
- Extract the docker image => `bunzip2 s2c-docker-image.tar.bz2`
- Load the docker image => `docker load < s2c-docker-image.tar`
- Start a docker container & enter shell => `docker run -it s2c:1.0`
- Open README.md for details on how to run tests => `vim README.md`
- Detach from shell without stopping image => `ctrl+p ctrl+q`
- Reattach to container shell => `docker attach <container-name-or-id>`
