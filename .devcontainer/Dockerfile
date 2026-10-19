FROM texlive/texlive:latest

COPY .devcontainer/apt-install.sh /usr/local/bin/apt-install
RUN chmod +x /usr/local/bin/apt-install

RUN apt-install ruby-dev rake bundler

USER texlive

WORKDIR /workspace
