# Isolate the secrets issue
**UPDATE**: I have found that the change in the behavior is caused by [this commit](https://github.com/docker/compose/commit/b387ba4a05accb92a52b48e75c46e61cab9cbc82). Please see the issue below.


This repository is dedicated for a [github issue](https://github.com/docker/compose/issues/13255).

Despite secret name and secret value being in the .env file and the .env file being picked up by the configuration, these envs are not picked up from the env-file for the secrets:
```shell
$ docker compose --env-file .env --progress plain build --no-cache | grep '^#6'
#6 [stage-0 2/2] RUN --mount=type=secret,id=my_secret_name     --mount=type=secret,id=my_secret_value     echo "env file works, because this env var is being picked up from the env file: env-file-works"     && ls -la /run/secrets/     && cat /run/secrets/*
#6 0.143 env file works, because this env var is being picked up from the env file: env-file-works
#6 0.144 total 0
#6 0.144 drwxr-xr-x    1 root     root            58 Sep 29 12:48 .
#6 0.144 drwxr-xr-x    1 root     root            14 Sep 29 12:48 ..
#6 0.144 -r--------    1 root     root             0 Sep 29 12:48 my_secret_name
#6 0.144 -r--------    1 root     root             0 Sep 29 12:48 my_secret_value
#6 DONE 0.2s
```

Meanwhile, in case these values are present in the shell the executes `docker compose build`, everything works:
```shell
$ MY_SECRET_NAME=foo MY_SECRET_VALUE=bar docker compose --env-file .env --progress plain build --no-cache | grep '^#6'
#6 [stage-0 2/2] RUN --mount=type=secret,id=my_secret_name     --mount=type=secret,id=my_secret_value     echo "env file works, because this env var is being picked up from the env file: env-file-works"     && ls -la /run/secrets/     && cat /run/secrets/*
#6 0.133 env file works, because this env var is being picked up from the env file: env-file-works
#6 0.134 total 8
#6 0.134 drwxr-xr-x    1 root     root            58 Sep 29 12:50 .
#6 0.134 drwxr-xr-x    1 root     root            14 Sep 29 12:50 ..
#6 0.134 -r--------    1 root     root             3 Sep 29 12:50 my_secret_name
#6 0.134 -r--------    1 root     root             3 Sep 29 12:50 my_secret_value
#6 0.135 foobar
#6 DONE 0.2s
```


```shell
$ docker version
Client: Docker Engine - Community
 Version:           28.4.0
 API version:       1.51
 Go version:        go1.24.7
 Git commit:        d8eb465
 Built:             Wed Sep  3 21:00:00 2025
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          28.4.0
  API version:      1.51 (minimum version 1.24)
  Go version:       go1.24.7
  Git commit:       249d679
  Built:            Wed Sep  3 20:56:56 2025
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.7.27
  GitCommit:        05044ec0a9a75232cad458027ca83437aae3f4da
 runc:
  Version:          1.2.5
  GitCommit:        v1.2.5-0-g59923ef
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0

$ docker buildx version
github.com/docker/buildx v0.28.0 b1281b81bba797b21d9eaf256e6a13eb14419836

$ docker compose version
Docker Compose version v2.39.4
```
