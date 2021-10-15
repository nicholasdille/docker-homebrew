# docker-homebrew

This container image mimics the behaviour of the official [GitHub action for testing formulae in a custom tap](https://github.com/Homebrew/brew/blob/master/Library/Homebrew/dev-cmd/tap-new.rb). The container image is published as [`nicholasdille/homebrew`](https://hub.docker.com/repository/docker/nicholasdille/homebrew).

## Usage

The default command expects to run on a repository of a custom tap which has checked out a branch with changes. The `brew` commands also expect to run in a directory with depth 2, e.g. `/src/my_repo` is ok but `/src` is not ok.

```bash
docker run -it --rm --volume ${PWD}:/src/nicholasdille/homebrew-tap --workdir /src/nicholasdille/homebrew-tap
```

The default command will perform several requests against the GitHub API and may run into rate limiting depending on your remaining requests.

## Custom build

This container image requires the [BuildKit](https://github.com/moby/buildkit) builder in Docker to successfully build.

The build of this container image can be customized using build arguments:

- `VERSION` specifies the upstream ubuntu image (default: `hirsute`)
- `USERNAME` and `UID` specify the username and user ID of the default user (default: `ubuntu`, `1000`)
- `GROUPNAME` and `GID` specify the group name and group ID (default: `ubuntu`, `1000`)

Example:

```bash
DOCKER_BUILDKIT=1 docker build --build-arg VERSION=focal --build-arg USERNAME=nicholas
```
