FROM registry.access.redhat.com/rhel7:latest

USER root

# Copy entitlements
COPY ./etc-pki-entitlement /etc/pki/entitlement

# Copy keys
COPY ./etc-pki-consumer /etc/pki/consumer
COPY ./etc-pki-product /etc/pki/product

# Copy repository configuration
COPY ./etc-rhsm-conf /etc/rhsm/
COPY ./etc-rhsm-ca /etc/rhsm/ca
COPY ./usr-share-rhsmplugins /usr/share/rhsm-plugins

# Show the secrets once copied, only purpose is for debugging
RUN ls /run/secrets/rhsm
RUN ls /etc/rhsm/
RUN cat /etc/rhsm/rhsm.conf
RUN ls /etc/pki/consumer
RUN ls /etc/pki/product
RUN ls /etc/pki/entitlement
RUN ls /usr/share/rhsm-plugins

# Delete /etc/rhsm-host to use entitlements from the build container
RUN rm -f /etc/rhsm-host
# See https://access.redhat.com/solutions/1443553

RUN subscription-manager identity
RUN subscription-manager status
RUN echo "Initial state" && subscription-manager repos --list

RUN yum-config-manager --disable '*' > /dev/null && subscription-manager repos --disable=*
RUN echo "all below should be DISABLED" && subscription-manager repos --list
RUN subscription-manager repos --enable 'rhel-7-server-rpms'
RUN echo "only rhel-7-server-rpms below should be ENABLED" && subscription-manager repos --list
RUN sleep 30
RUN echo "only rhel-7-server-rpms below should be ENABLED" && subscription-manager repos --list

USER 1001
