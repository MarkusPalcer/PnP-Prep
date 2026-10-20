FROM texlive/texlive:latest

COPY .devcontainer/apt-install.sh /usr/local/bin/apt-install
RUN chmod +x /usr/local/bin/apt-install

RUN apt-install ruby-dev rake bundler

USER texlive

# Kiro
RUN curl -fsSL https://download.crew.kiro.dev/cli.sh | bash
RUN curl -fsSL https://cli.kiro.dev/install | bash
EXPOSE 5476

WORKDIR /workspace
