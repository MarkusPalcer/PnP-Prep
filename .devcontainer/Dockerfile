FROM texlive/texlive:latest

COPY .devcontainer/apt-install.sh /usr/local/bin/apt-install
RUN chmod +x /usr/local/bin/apt-install

RUN apt-install ruby-dev rake bundler build-essential libssl-dev

WORKDIR /workspace
RUN chown -R texlive:texlive "$(ruby -e 'print Gem.dir')"
COPY Gemfile Gemfile.lock ./

USER texlive
