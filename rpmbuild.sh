#!/bin/bash

# Build an RPM that installs global-gcp-backup and global-logrotate (no .sh extension) to /usr/local/bin
set -e

NAME=global-sys-utils
VERSION=1.0.0
RELEASE=1

# 1. Prepare scripts (remove .sh extension for install)
cp global-gcp-backup.sh global-gcp-backup
cp global-logrotate.sh global-logrotate
chmod +x global-gcp-backup global-logrotate
# Convert scripts to Unix line endings to avoid ^M issues on Linux
sed -i 's/\r$//' global-gcp-backup global-logrotate

# 2. Create Google Cloud SDK repo file
cat > google-cloud-sdk.repo << 'EOF'
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# 3. Create minimal RPM spec
cat > ${NAME}.spec << EOF
Name:           ${NAME}
Version:        ${VERSION}
Release:        ${RELEASE}%{?dist}
Summary:        System utilities: GCP backup and log rotation
License:        MIT
%define _source_payload w9.gzdio
%define _binary_payload w9.gzdio
URL:            https://example.com
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch
Requires:       bash
Requires:       coreutils
Requires:       findutils
Requires:       google-cloud-cli
Obsoletes:      global-logrotate
Provides:       global-logrotate

%description
Installs global-gcp-backup and global-logrotate scripts to /usr/local/bin/.
Also installs the Google Cloud SDK repo file if not present.

%prep
%autosetup

%build

%install
mkdir -p %{buildroot}/usr/local/bin
install -m 0755 global-gcp-backup %{buildroot}/usr/local/bin/global-gcp-backup
install -m 0755 global-logrotate %{buildroot}/usr/local/bin/global-logrotate
# Install the repo file
mkdir -p %{buildroot}/etc/yum.repos.d
install -m 0644 google-cloud-sdk.repo %{buildroot}/etc/yum.repos.d/google-cloud-sdk.repo

%post
echo "To install gsutil, run: yum install google-cloud-cli"

%files
/usr/local/bin/global-gcp-backup
/usr/local/bin/global-logrotate
/etc/yum.repos.d/google-cloud-sdk.repo

%changelog
* $(date '+%a %b %d %Y') You - 1.0.0-1
- Initial RPM release
EOF

# 4. Create source tarball
mkdir -p temp_build/${NAME}-${VERSION}
cp global-gcp-backup global-logrotate google-cloud-sdk.repo ${NAME}.spec temp_build/${NAME}-${VERSION}/
tar -czf ${NAME}-${VERSION}.tar.gz -C temp_build ${NAME}-${VERSION}
rm -rf temp_build

# 5. Setup RPM build tree
for d in BUILD BUILDROOT RPMS SOURCES SPECS SRPMS; do mkdir -p rpmbuild/$d; done
cp ${NAME}-${VERSION}.tar.gz rpmbuild/SOURCES/
cp ${NAME}.spec rpmbuild/SPECS/

# 6. Build the RPM
rpmbuild --define "_topdir $(pwd)/rpmbuild" \
         --define "_source_payload w9.gzdio" \
         --define "_binary_payload w9.gzdio" \
         -ba rpmbuild/SPECS/${NAME}.spec

# 7. Show result
find rpmbuild/RPMS -name "*.rpm"
echo "\nInstall with: sudo rpm -i <rpm-file>" 