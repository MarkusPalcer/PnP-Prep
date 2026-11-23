FROM texlive/texlive:latest

COPY .devcontainer/apt-install.sh /usr/local/bin/apt-install
RUN chmod +x /usr/local/bin/apt-install

# Add GitHub Client repo
RUN apt-install wget
RUN mkdir -p -m 755 /etc/apt/keyrings \
	&& out=/etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list

RUN apt-install ruby-dev rake bundler build-essential libssl-dev gh

WORKDIR /workspace
RUN chown -R texlive:texlive "$(ruby -e 'print Gem.dir')"
COPY Gemfile Gemfile.lock ./

USER texlive
