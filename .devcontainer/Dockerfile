FROM texlive/texlive:latest

COPY .devcontainer/apt-install.sh /usr/local/bin/apt-install
RUN chmod +x /usr/local/bin/apt-install

RUN curl -fsSL https://junie.jetbrains.com/install.sh | bash

WORKDIR /workspace
