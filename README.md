# Editable ROS Docker Development

## Panda Noetic
To Create Image, Run Container or Open another section in Container, please use
```bash
./enterpoint.sh
```

If you want to build with no-cache, which keeps docker content up to date but takes much longer time, use
```bash
export NOCACHE=true
./enterpoint.sh
```

You should firstly install [Docker Engine](https://docs.docker.com/engine/install/ubuntu/) on your Ubuntu. Then [manage docker as a non-root user](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user), to enable `docker <command>` instead of `sudo docker <conmmand>`

NOTE: Do not install Docker Desktop. It is different from the Docker Engine and not so friendly to docker development.

## Features:
 * Isolated: Container has an isolated env from the host but keeps the host user and partial configs
    * Optional you can volume directories to the container. Please check this in branch [volumed](https://github.com/AlfredMoore/ros-docker-dev/tree/volumed)
 * User spoofing: Container has the same username and password as the host.
 * SSH forwarding: Container has the same ssh agent as the root. No need to add any additional SSH key pair. You can use directly use `git` via SSH.
 * Oh-my-zsh: Container has an configured oh-my-zsh. It is editable in the [configs/oh-my-zsh.zshrc](./configs/oh-my-zsh.zshrc).
 * Editable and Readable: [Dockerfile](./panda-noetic.Dockerfile), [Building Config](./panda-bake.hcl) and [Running Config](./enterpoint.sh). You can also build from the [raw dockerfile](./raw.Dockerfile).

## TODO ~~(TBD: lazy man)~~
Update to docker compose run and build (docker compose documents are unclear).
