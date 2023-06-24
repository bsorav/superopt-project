# Create a fully-built Docker image

1. While booting the OS from a CD/DVD, set "fsck.mode=skip" to the kernel boot params (after /casper/vmlinuz) via GRUB menu entry. See https://bugs.launchpad.net/ubuntu/+source/casper/+bug/1930880
2. Install Docker using the instructions in doc/Docker.md
3. Load the docker image using the instructions in doc/Docker.md
4. Run a container using the docker image using `make docker-run` in superopt-project. Initialize .zshrc using the zsh prompt menu. Add `alias ls='ls -F --color'` to .zshrc
5. Run "make install" inside the container
6. Update the defaultServerURL and build the client using `vsce package` in vscode-extension/eqchecker
7. Run the server inside the Docker container using `make` in `vscode-extension/server`
8. Inside the container, run `ssh-copy-id eqcheck@0:` (to allow password-less ssh for upload-eqchecks script)

# Install vscode and load vscode extension

1. Copy the .vsix file using `docker cp <container-name>:/home/eqcheck/superopt-project/vscode-extension/eqchecker-0.20.0.vsix .`
2. Copy the superopt-tests directory using `docker cp <container-name>:/home/eqcheck/superopt-project/superopt-tests .`
3. Copy the `code_1.79.2-1686734195_amd64.deb` file from the CD/DVD and run `apt install ./code_1.79.2-1686734195_amd64.deb`.
4. Run code on the host
5. Manage extensions --> install from VSIX --> choose the copied vsix file
6. Use the equivalence checking extension.  Enter your email address (softaviator1@nic.in) and use "0000" as OTP
7. Open `strlen\_src.c`, `strlen\_dst.c`, `quicksort.c` from the copied superopt-tests/ directory in vscode and run an equivalence check on it.

# Run and upload the tests
1. Inside the container, run `make clangv_Od >& clangv_Od` in `superopt-tests`
2. Upload the passing proofs to the server under a label that can be used during the presentation using `upload-eqcheck --eqchecksDir superopt-tests/build --sessionName tests --passingOnly`

# [Optional] Commit the container
1. Commit the container to obtain an image file called eqchecker-built using the instructions in doc/Docker.md [takes time; roughly 150-200GB image]

# Presentation

## On the vscode client on the host
1. Start with `strlen_src.c` vs. `strlen_dst.c`
2. Show `quicksort.c`
3. Show `bzip2_locals.c` and show the successful tests in the `tests` session

## On the command line in the container
1. Show "clangv" on bzip2 on the command-line
2. Show "eq32" on the generated executable on the command-line
3. Show "upload-eqcheck" on the command-line
4. Show "analyze" on the command-line
