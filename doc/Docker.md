# Installing Docker

Instruction taken from [Install Docker Engine](https://docs.docker.com/engine/install/)

1. The tar file is available in tars/docker-24.0.2.tgz
2. Extract the archive using the tar utility. The dockerd and docker binaries are extracted.
```
tar xzvf tars/docker-24.0.2.tar.gz
```

3. Optional: Move the binaries to a directory on your executable path, such as `/usr/bin/`. If you skip this step, you must provide the path to the executable when you invoke docker or dockerd commands.
```
sudo cp docker/* /usr/bin/
```
4. Start the Docker daemon:
```
sudo dockerd &
```
If you need to start the daemon with additional options, modify the above command accordingly or create and edit the file /etc/docker/daemon.json to add the custom configuration options.

5. Add the docker group and add yourself to that group
```
sudo groupadd docker
sudo usermod -aG docker $USER
```
Log out and log back in so that your group membership is re-evaluated. You may need to reboot the machine.

6. Verify that Docker is installed correctly by running the hello-world image.
```
docker run hello-world
```
This command downloads a test image and runs it in a container. When the container runs, it prints a message and exits.

7. If you are behind a proxy, create a config directory using `sudo mkdir -p /etc/systemd/system/docker.service.d` and edit `/etc/systemd/system/docker.service.d/http-proxy.conf` as follows:
```
[Service]
Environment="HTTP_PROXY=http://proxy82.iitd.ac.in:3128"
Environment="HTTPS_PROXY=http://proxy82.iitd.ac.in:3128"
```
8. Saving a docker image
   ```
   docker save eqcheck:latest | bzip2 > eqchecker-docker-image.tar.bz2
   ```
9. Loading a docker image
   ```
   bunzip2 eqchecker-docker-image.tar.bz2
   docker load < eqchecker-docker-image.tar
   ```
10. To convert a container to an image
```
$ docker commit container_name image_name
```
11. List, stop and remove a container
```
$ docker ps
$ docker stop container_name
$ docker rm container_name
```
12. To copy a file from the container to the host
```
$ sudo docker cp container_name:/path/to/file/in/container .
```
13. To open a shell in a running container
```
docker exec -it <container-name-or-id> <shell-executable>
```
