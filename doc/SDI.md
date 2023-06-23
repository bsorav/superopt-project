# Installation via CD/DVD

1. While booting the OS from a CD/DVD, set "fsck.mode=skip" to the kernel boot params (after /casper/vmlinuz) via GRUB menu entry. See https://bugs.launchpad.net/ubuntu/+source/casper/+bug/1930880
2. Install Docker using the instructions in doc/Docker.md
3. Load the docker image using the instructions in doc/Docker.md
4. Run a container using the docker image (instructions in README.md)
5. Run "make install" inside the container
7. Exit the container
8. Commit the container to obtain an image file called eqchecker-built [takes time; roughly 150-200GB image]
9. Run the container using the eqchecker-built image
10. Build the client using `vsce package` in vscode-extension/eqchecker
11. Copy the .vsix file using `docker cp <container-name>:/home/eqcheck/superopt-project/vscode-extension/eqchecker-0.20.0.vsix .`
12. Copy the superopt-tests directory using `docker cp <container-name>:/home/eqcheck/superopt-project/superopt-tests .`
13. Copy the `code_1.79.2-1686734195_amd64.deb` file from the CD/DVD and run `apt install ./code_1.79.2-1686734195_amd64.deb`.
14. Run the server inside the Docker container using `make` in `vscode-extension/server`
15. Run code on the host
16. Manage extensions --> install from VSIX --> choose the copied vsix file
17. Use the equivalence checking extension.  Use "0000" as OTP
18. Open some files from the copied superopt-tests/ directory in vscode and run equivalence checks on them
19. Inside the container, run `make clangv_Od` in `superopt-tests`
20. Upload the passing proofs to the server under a label that can be used during the presentation

# Presentation

## On the vscode client on the host
1. Start with `strlen_src.c` vs. `strlen_dst.c`
2. Show `quicksort.c`
3. Show `bzip2_locals.c`

## On the command line in the container
1. Show "clangv" on bzip2 on the command-line
2. Show "eq32" on the generated executable on the command-line
3. Show "upload-eqcheck" on the command-line
   - test it on the laptop first
4. Show "analyze" on the command-line
