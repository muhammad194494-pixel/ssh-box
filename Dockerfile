FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      openssh-server sudo ca-certificates curl wget git nano vim tmux htop \
      python3 python3-pip python3-venv build-essential unzip jq nodejs npm \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /run/sshd \
 && useradd -m -s /bin/bash maell \
 && echo "maell ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/maell \
 && chmod 440 /etc/sudoers.d/maell
COPY sshd_config /etc/ssh/sshd_config.d/99-box.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 22
CMD ["/entrypoint.sh"]
