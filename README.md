# docker-homebrew

This container image mimics the behaviour of the official [GitHub action for testing formulae in a custom tap](https://github.com/Homebrew/brew/blob/master/Library/Homebrew/dev-cmd/tap-new.rb). The container image is published as [`nicholasdille/homebrew`](https://hub.docker.com/repository/docker/nicholasdille/homebrew).

## Usage

The default command expects to run on a repository of a custom tap which has checked out a branch with changes.

```bash
docker run -it --rm --volume ${PWD}:/src/nicholasdille/homebrew-tap --workdir /src/nicholasdille/homebrew-tap nicholasdille/homebrew
```

The default command will perform several requests against the GitHub API and may run into rate limiting depending on your remaining requests.
