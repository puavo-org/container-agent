# SPDX-License-Identifier: MIT
# Copyright (C) Opinsys Oy 2026

# Build system
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c

RUN ?= runsc

.PHONY: default help init

help: ## Show this help
	@awk -F ':[^#]*## ?' '/^[a-z_-]+:[^#]*##/{printf "  make %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

default: help

ifneq ($(filter init,$(MAKECMDGOALS)),)
  ifndef NAME
    $(error NAME is required, e.g.: make init NAME=docker-agent)
  endif
endif

init: ## Initialize .env (NAME=<project_name>)
	@docker_socket="/var/run/docker.sock"
	runtime_dir="$${XDG_RUNTIME_DIR:-/run/user/$$(id -u)}"
	ssh_auth_sock="$${SSH_AUTH_SOCK:-}"
	case "$${ssh_auth_sock}" in
		"$${runtime_dir}"/*) ;;
		*) ssh_auth_sock="";;
	esac
	if [ -n "$${ssh_auth_sock}" ] && [ ! -S "$${ssh_auth_sock}" ]; then
		ssh_auth_sock=""
	fi
	if [ -z "$${ssh_auth_sock}" ] && [ -S "$${runtime_dir}/gnupg/S.gpg-agent.ssh" ]; then
		ssh_auth_sock="$${runtime_dir}/gnupg/S.gpg-agent.ssh"
	fi
	docker_gid="$$(stat -c %g "$${docker_socket}" 2>/dev/null || printf '0')"
	kvm_gid="$$(stat -c %g /dev/kvm 2>/dev/null || printf '0')"
	printf '%s\n' \
		"DOCKER_AGENT_PROJECT=\"$(NAME)\"" \
		"DOCKER_AGENT_BASE_IMAGE=\"debian:13\"" \
		"DOCKER_AGENT_UID=\"$$(id -u)\"" \
		"DOCKER_AGENT_GID=\"$$(id -g)\"" \
		"DOCKER_AGENT_NAME=\"$(NAME)\"" \
		"DOCKER_AGENT_XDG_RUNTIME_DIR=\"$${runtime_dir}\"" \
		"DOCKER_AGENT_SSH_AUTH_SOCK=\"$${ssh_auth_sock}\"" \
		"DOCKER_AGENT_IMAGE=\"$(NAME):latest\"" \
		"DOCKER_AGENT_SOCKET=\"$${docker_socket}\"" \
		"DOCKER_AGENT_DOCKER_GID=\"$${docker_gid}\"" \
		"DOCKER_AGENT_KVM_GID=\"$${kvm_gid}\"" \
		"DOCKER_AGENT_NETWORK_MODE=\"bridge\"" \
		"DOCKER_AGENT_HINDSIGHT_BASE_URL=\"http://host.docker.internal:8888\"" \
		"DOCKER_AGENT_HOST_GATEWAY=\"host-gateway\"" \
		"DOCKER_AGENT_RUNTIME=\"$(RUN)\"" \
		> .env
