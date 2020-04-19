# rosRobot dockerfile

Scripts to create a docker image with **ROS melodic** and **pytorch** and to run a development container with **terminator** and **pulseaudio** support.

1) Build docker image with:

`./build.sh`

2) Create the container environment with:

`./createEnv <name> <workdir>` 

`<workdir>` will be used as home folder inside the container and the user inside the container will be `$USER` with password `admin`.

3) To resume the container use:

`sudo docker start <name>`