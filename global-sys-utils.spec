Name:           global-sys-utils
Version:        1.0.0
Release:        1%{?dist}
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
* Wed Jul 16 2025 You - 1.0.0-1
- Initial RPM release
