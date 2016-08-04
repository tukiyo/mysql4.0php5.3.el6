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

%define INSTALLDIR %{buildroot}/usr/local/pear

%description
local-pear

%prep

%build

%install
rm -rf %{INSTALLDIR}
mkdir -p %{INSTALLDIR}
cp -R .registry * %{INSTALLDIR}

%clean
rm -rf %{buildroot}

%files
/usr/local/pear/.registry/db.reg
/usr/local/pear/.registry/var_dump.reg
/usr/local/pear/DB.php
/usr/local/pear/DB/
/usr/local/pear/Var_Dump.php
/usr/local/pear/Var_Dump/
/usr/local/pear/data/Var_Dump/
/usr/local/pear/doc/DB/
/usr/local/pear/doc/Var_Dump/
/usr/local/pear/test/DB/
/usr/local/pear/test/Var_Dump/
