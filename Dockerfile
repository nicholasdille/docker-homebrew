# syntax=docker/dockerfile:1.3-labs

ARG VERSION=hirsute
FROM ubuntu:${VERSION}

COPY <<docker-no-recommends <<docker-no-suggests /etc/apt/apt.conf.d/
APT::Install-Recommends "false";
docker-no-recommends
APT::Install-Suggests "false";
docker-no-suggests

RUN --mount=type=cache,target=/var/cache/apt <<EOF
apt-get update
apt-get -y install \
    curl \
    ca-certificates \
    xz-utils \
    sudo \
    git \
    build-essential
EOF

ARG USERNAME=ubuntu
ARG UID=1000
ARG GROUPNAME=ubuntu
ARG GID=1000
ARG PASSWORD=password
RUN <<EOF
groupadd --gid "${GID}" "${GROUPNAME}"
useradd --create-home --shell /bin/bash --uid "${UID}" --gid "${GROUPNAME}" "${USERNAME}"
echo "${USERNAME}:${PASSWORD}" | chpasswd
EOF
ENV USER=${USERNAME}

RUN <<EOF
mkdir -p /home/linuxbrew
chown "${UID}:${GID}" /home/linuxbrew
EOF

COPY <<EOF  /etc/sudoers.d/${USERNAME}
${USERNAME} ALL=(ALL) NOPASSWD: ALL
EOF

USER ${USERNAME}
WORKDIR /home/${USERNAME}

RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash \
 && echo "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >>/home/${USER}/.bashrc