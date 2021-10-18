#syntax=docker/dockerfile:1.3-labs

FROM homebrew/brew

RUN <<EOF
sudo apt-get update
sudo apt-get -y install --no-install-recommends jq
EOF

COPY test.sh /
CMD [ "/bin/bash", "/test.sh" ]