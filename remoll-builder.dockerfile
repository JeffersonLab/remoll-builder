# Build stage with Spack pre-installed and ready to be used
FROM jeffersonlab/remoll-spack:centos8 as builder


# What we want to install and how we want to install it
# is specified in a manifest file (spack.yaml)
RUN mkdir /opt/spack-environment \
&&  (echo "spack:" \
&&   echo "  definitions:" \
&&   echo "  - cxxstd:" \
&&   echo "    - cxxstd=17" \
&&   echo "  - packages:" \
&&   echo "    - clhep" \
&&   echo "    - xerces-c" \
&&   echo "    - geant4" \
&&   echo "    - root -opengl" \
&&   echo "  specs:" \
&&   echo "  - matrix:" \
&&   echo "    - - \$packages" \
&&   echo "    - - \$cxxstd" \
&&   echo "  packages:" \
&&   echo "    all:" \
&&   echo "      target:" \
&&   echo "      - x64_64" \
&&   echo "  concretization: together" \
&&   echo "  config:" \
&&   echo "    install_missing_compilers: true" \
&&   echo "    install_tree: /opt/software" \
&&   echo "  view: /opt/view") > /opt/spack-environment/spack.yaml

# Install the software, remove unnecessary deps
RUN cd /opt/spack-environment && spack env activate . && spack install --fail-fast && spack gc -y

# Strip all the binaries
RUN find -L /opt/view/* -type f -exec readlink -f '{}' \; | \
    xargs file -i | \
    grep 'charset=binary' | \
    grep 'x-executable\|x-archive\|x-sharedlib' | \
    awk -F: '{print $1}' | xargs strip -s

# Modifications to the environment that are necessary to run
RUN cd /opt/spack-environment && \
    spack env activate --sh -d . >> /etc/profile.d/z10_spack_environment.sh


# Bare OS image to run the installed executables
FROM centos:8

COPY --from=builder /opt/spack-environment /opt/spack-environment
COPY --from=builder /opt/software /opt/software
COPY --from=builder /opt/view /opt/view
COPY --from=builder /etc/profile.d/z10_spack_environment.sh /etc/profile.d/z10_spack_environment.sh



ENTRYPOINT ["/bin/bash", "--rcfile", "/etc/profile", "-l"]
