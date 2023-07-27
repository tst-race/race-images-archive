FROM ubuntu:18.04

# Configure Environment
ENV APP_ROOT=/code/
ENV DEBIAN_FRONTEND=noninteractive

# Make App Root Dir
RUN mkdir -p ${APP_ROOT}
WORKDIR ${APP_ROOT}

# Create User
RUN useradd -ms /bin/bash -g root -G sudo -u 2000 --password=rib rib && \
    mkdir /home/rib/.ssh && \
    touch /home/rib/.ssh/authorized_keys && \
    chmod 0400 /home/rib/.ssh/authorized_keys && \
    chown -R rib /home/rib

# Configure sshd
COPY ./sshd_config /etc/ssh/sshd_config

# Install Linux Packages
RUN apt-get -y update &&\
    apt-get install -y \
        curl \
        openssh-server

# Add Entrypoint Script
COPY ./run-command.sh ${APP_ROOT}

# Run Command
WORKDIR ${APP_ROOT}
CMD ["/bin/sh", "./run-command.sh"]

