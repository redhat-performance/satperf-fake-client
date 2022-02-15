#!/bin/sh

ROOT_PASSWORD='redhat'
ROOT_PUBLIC_KEY='ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA57NxnEo8KnrBYRrWjgS8eSZBKiUFBbP4GGbC1M1Kxo+494T2+y3uuihK0Ey5n824ch2OafK7m/TnByIC9pQ3VuAi/ggiOfja2gvZ/GtTedE3ct0jVbGbM/98MS0GV1NoIZRqX6e44JMDqID+ngwQutPyTgxbJ/PL2jVUrjP6sOMEJqgSEbQ9a3s+oM3O0vMTLp7E0PtgKQo0bKRoKFEn5mUxiQ2gmwg/dPqOb2/VpBAKCozsE2illszzyP/KC1gq0VkgMqIZspUsXRqvDDbnaSkCc8/AwA0yBAPBMAjtuk5UZvpioHSh2X0ShcgHtYocZiQIxiSvDzvxdYkFBztu6w== example-key'

set -xe

podman build -f rhel8-ubi-init-smallest.Containerfile -t rhel8-ubi-init-smallest --build-arg=ROOT_PASSWORD="$ROOT_PASSWORD" --build-arg=ROOT_PUBLIC_KEY="$ROOT_PUBLIC_KEY" .
podman build -f rhel8-ubi-init-big_updated.Containerfile -t rhel8-ubi-init-big_updated .
podman build -f rhel8-ubi-init-big_outdated.Containerfile -t rhel8-ubi-init-big_outdated .
podman build -f rhel8-ubi-init-utils.Containerfile -t rhel8-ubi-init-utils .
podman build -f rhel7-ubi-init-smallest.Containerfile -t rhel7-ubi-init-smallest --build-arg=ROOT_PASSWORD="$ROOT_PASSWORD" --build-arg=ROOT_PUBLIC_KEY="$ROOT_PUBLIC_KEY" .
podman build -f rhel7-ubi-init-big_updated.Containerfile -t rhel7-ubi-init-big_updated .
podman build -f rhel7-ubi-init-big_outdated.Containerfile -t rhel7-ubi-init-big_outdated .
