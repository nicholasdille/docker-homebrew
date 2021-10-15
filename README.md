# docker-homebrew

This container image mimics the behaviour of the official [GitHub action for testing formulae in a custom tap](https://github.com/Homebrew/brew/blob/master/Library/Homebrew/dev-cmd/tap-new.rb). The container image is published as [`nicholasdille/homebrew`](https://hub.docker.com/repository/docker/nicholasdille/homebrew).

## Usage

The default command expects to run on a repository of a custom tap which has checked out a branch with changes. The `brew` commands also expect to run in a directory with depth 2, e.g. `/src/my_repo` is ok but `/src` is not ok.

```bash
docker run -it --rm --volume ${PWD}:/src/nicholasdille/homebrew-tap --workdir /src/nicholasdille/homebrew-tap
```
