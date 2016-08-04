%define name local-pear
%define version 1.0
%define unmangled_version 1.0
%define release 1
%define _binaries_in_noarch_packages_terminate_build 0

Summary: PEAR DB, Var_Dump
Name: %{name}
Version: %{version}
Release: %{release}
License: GPL2
Source0: %{name}.tar.gz
Group: Applications/File
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Prefix: %{_prefix}
BuildArch: noarch

%define INSTALLDIR %{buildroot}/usr/local/

%description
local-pear

%prep

%build

%install
rm -rf %{INSTALLDIR}
mkdir -p %{INSTALLDIR}
cp -R . %{INSTALLDIR}

%clean
rm -rf %{buildroot}

%files
/usr/local/pear/
/usr/local/php/bin/pear
/usr/local/php/bin/peardev
/usr/local/php/bin/gen_php_doc.sh
