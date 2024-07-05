# Building and Running

See [Getting Started](doc/GettingStarted.md)

# Viewing the proofs generated from testing
```
vscode-extension/scripts/upload-eqcheck --sessionName <sessionName> --eqchecksDir <dir1> --eqchecksDir <dir2>... [--passingOnly]
```
The directories `dir1`, `dir2`, ... are traversed recursively to identify any eqchecks that should be picked up.  The `sessionName` can be used to load the session that contains all these eqchecks.

# Installing in a docker environment

Follow these steps for building and running the equivalence checker inside a Docker container.

0. See doc/Docker.md for instruction on how to install the Docker engine.
1. Build the Docker image.  Note that internet connectivity is required in this step.
   ```
   make docker-build
   ```
   This process can take a while depending upon your internet connection bandwidth.  
2. Run the container forwarding container's port 80 to host's port 80.
   ```
   make docker-run
   ```
   The 8181 port is used by scan-view.
3. (Inside the container) Build and install the equivalence checker.
   ```
   make install
   ```
