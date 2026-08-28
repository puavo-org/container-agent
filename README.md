# Docker Agent

This repository provides a template of a development sandbox for coding agents.

It has the following features:

1. Relies on [`gVisor`](https://github.com/google/gvisor) for providing a safe
   sandbox.
2. Provides a redundant rootfs with passwordless sudo.
3. Exposes users home directory.

These are only the absolutely minimal restrictions that one should place while
using coding agents. Further restrictions can be obviously applied, when seen
feasible.

## Docker settings

`sudo runsc install` has SUID and host Unix-domain socket access disabled by
default.

SUID can be enabled by editing `/etc/docker/daemon.json` and adding
`runtimeArgs` field:

```json
{
  "runtimes": {
    "runsc": {
      "path": "/usr/bin/runsc",
      "runtimeArgs": ["--allow-suid", "--host-uds=open"]
    }
  }
}
```

## Creating a development container

Initialize `.env` and start the container:

```sh
make init NAME=docker-agent
docker compose up --build
```

Override can be done with, for example, `make init NAME=docker-agent RUN=runc`.

A development shell can be opened inside the container as follows:

```
docker exec -it docker-agent zsh -l
```

## License

`docker-agent` is licensed under `MIT`.  See [LICENSE](LICENSE) for more information.
