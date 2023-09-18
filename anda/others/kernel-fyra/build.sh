#!/bin/sh

# Set the kernel-ark release build rev number
export KERNEL_ARK_REV='200'

# Set the Fyra kernel overlay version
export FYRA_KERNELOVERLAY_VER='2'

# Fetch the patches
git clone https://github.com/FyraLabs/linux-kernel-patches.git patches

# Move into the patches' directory
pushd patches

# Acquire the latest supported kernel-ark branch
export BRANCH="$(readlink current)"

# Move out from the patches' directory
popd

# Fetch the source
git clone -b ${BRANCH} https://gitlab.com/cki-project/kernel-ark.git source

# Move into the source directory
pushd source

# Set proper user name for commits
git config user.name 'Terra' ; git config user.email 'mail@example.com'

# Apply all patches
for patch in ../patches/${BRANCH}/*.patch
    do git am $patch
done

# Build the SRPM
make \
    IS_FEDORA=1 \
    BUILD=${KERNEL_ARK_REV} \
    SPECPACKAGE_NAME='kernel-fyra' \
    DISTLOCALVERSION=".fyra${FYRA_KERNELOVERLAY_VER}" \
    dist-srpm -j$(nproc)

# Build the resulting SRPM
rpmbuild -rb \
    --without=debug \
    --without=configchecks \
    redhat/rpm/SRPMS/kernel-fyra-*.src.rpm

# Move the resulting RPM files into the target directory
for file in redhat/rpm/RPMS/*.rpm
    do mv -v $file ../anda-build/rpm/rpms/
done

# Also move the SRPM package file
mv -v redhat/rpm/SRPMS/*.src.rpm ../anda-build/rpm/srpms/

# We're done here
exit 0