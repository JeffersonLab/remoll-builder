FROM jeffersonlab/remoll-spack:centos8

RUN yum -y group install "Development Tools"

RUN yum -y install cmake

# What we want to install and how we want to install it
# is specified in a manifest file (spack.yaml)
RUN mkdir /opt/spack-environment \
&&  (echo "spack:" \
&&   echo "  specs:" \
&&   echo "    - boost cxxstd=11" \
&&   echo "    - geant4 +qt +opengl cxxstd=11" \
&&   echo "    - root cxxstd=11" \
&&   echo "    - mesa -llvm" \
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

ENTRYPOINT ["/bin/bash"]
CMD ["interactive-shell"]

