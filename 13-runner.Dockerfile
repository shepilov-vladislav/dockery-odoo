FROM registry.gitlab.com/devco-odoo/docker-odoo-base:base

# Get secondary binaries and pythonscripts by default
ONBUILD COPY .docker/bin/*           /usr/local/bin/
ONBUILD COPY .docker/lib/*           /usr/local/lib/python2.7/dist-packages/odoo-docker-base-libs/
# Get secondary entrypoint scripts and config files
ONBUILD COPY .docker/entrypoint.d/*  /home/entrypoint.d/
ONBUILD COPY .docker/config.d/*      /home/config.d/
# Set executing bit on freshly added files, also
ONBUILD RUN chmod +x -R /home /usr/local/bin/ /usr/local/lib/python2.7/dist-packages/
# Automate secondary build steps in one single step
ONBUILD COPY .docker/build.d         /home/build.d
ONBUILD RUN ln /usr/local/bin/build-dir-exec.sh /usr/local/bin/build.sh
ONBUILD RUN chmod +x /home/build.d/*.sh && build.sh

# curl, docker, ssh, git
ADD build/90-runner-libs.sh /tmp/command
RUN chmod +x /tmp/command && sync && /tmp/command

# python and odoo linting setup
ADD build/90-linting-tools.sh /tmp/command
RUN chmod +x /tmp/command && sync && /tmp/command

# Install rancher Cli
ENV RANCHER_CLI_VERSION v0.6.2-rc2
ADD https://github.com/rancher/cli/releases/download/${RANCHER_CLI_VERSION}/rancher-linux-amd64-${RANCHER_CLI_VERSION}.tar.gz /tmp/rancher-cli.tar.gz
RUN tar -zxf /tmp/rancher-cli.tar.gz -C /tmp
RUN chmod +x /tmp/rancher-${RANCHER_CLI_VERSION} && cp /tmp/rancher-${RANCHER_CLI_VERSION}/rancher /usr/local/bin/
RUN pip install click hammock odoorpc

ENTRYPOINT []
CMD []
