FROM texlive/texlive:latest

COPY .devcontainer/apt-install.sh /usr/local/bin/apt-install
RUN chmod +x /usr/local/bin/apt-install

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \ 
    apt-install ruby ruby-dev bundler

RUN curl -fsSL https://junie.jetbrains.com/install.sh | bash

WORKDIR /workspace
