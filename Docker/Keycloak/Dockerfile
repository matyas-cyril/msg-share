# Pour Ansible
ARG PRIVATE_REGISTRY=""
ARG IMAGE="redhat/ubi9"
ARG TAG="9.7"

FROM ${PRIVATE_REGISTRY}${IMAGE}:${TAG} AS ubi-micro-build
RUN mkdir -p /mnt/rootfs
RUN dnf install --installroot /mnt/rootfs python3 --releasever 9 --setopt install_weak_deps=false --nodocs -y && \
    dnf --installroot /mnt/rootfs clean all && \
    rpm --root /mnt/rootfs -e --nodeps setup

FROM keycloak/keycloak:26.4
COPY --from=ubi-micro-build /mnt/rootfs/ /

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]