# SPDX-License-Identifier: MIT
# Copyright (C) Opinsys Oy 2026

ARG BASE_IMAGE=debian:13
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    bash-completion \
    bc \
    bison \
    build-essential \
    ca-certificates \
    clang \
    cmake \
    cpio \
    curl \
    dialog \
    docker.io \
    file \
    flex \
    gdb \
    git \
    gpg \
    iproute2 \
    kmod \
    less \
    libelf-dev \
    libegl1 \
    libncurses-dev \
    libssl-dev \
    make \
    man-db \
    nano \
    ninja-build \
    openssh-client \
    pkg-config \
    python3 \
    python3-pip \
    qemu-system-gui \
    qemu-system-modules-opengl \
    qemu-system-x86 \
    qemu-utils \
    rsync \
    strace \
    sudo \
    vim \
    xz-utils \
    zsh \
 && rm -rf /var/lib/apt/lists/*

ARG DOCKER_AGENT_UID
ARG DOCKER_AGENT_GID
ARG DOCKER_AGENT_USERNAME

RUN set -eux; \
    if ! getent group "${DOCKER_AGENT_GID}" >/dev/null; then \
        groupadd --gid "${DOCKER_AGENT_GID}" "${DOCKER_AGENT_USERNAME}"; \
    fi; \
    if getent passwd "${DOCKER_AGENT_UID}" >/dev/null; then \
        user_name="$(getent passwd "${DOCKER_AGENT_UID}" | cut -d: -f1)"; \
    else \
        useradd --uid "${DOCKER_AGENT_UID}" --gid "${DOCKER_AGENT_GID}" --create-home --shell /bin/bash "${DOCKER_AGENT_USERNAME}"; \
        user_name="${DOCKER_AGENT_USERNAME}"; \
    fi; \
    printf '%s ALL=(ALL:ALL) NOPASSWD:ALL\n' "${user_name}" > /etc/sudoers.d/90-docker-agent; \
    chmod 0440 /etc/sudoers.d/90-docker-agent; \
    visudo --check --file=/etc/sudoers.d/90-docker-agent

CMD ["sleep", "infinity"]
