# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PLOCALES="ca de es fr ja ko pt_BR ru sv tr uk"
PLOCALES_BIN="${PLOCALES} bg cs eu fi hu id it ka nb nl pl pt tg zh_TW zh_CN"
PLOCALE_BACKUP="sv"
PYTHON_COMPAT=( python3_{10..13} )

inherit autotools linux-info multilib-minimal optfeature plocale \
	python-single-r1 pam systemd toolchain-funcs

DESCRIPTION="System Security Services Daemon provides access to identity and authentication"
HOMEPAGE="https://github.com/SSSD/sssd"
if [[ ${PV} != 9999 ]]; then
	SRC_URI="https://github.com/SSSD/sssd/releases/download/${PV}/${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~m68k ~mips ~ppc ~ppc64 ~riscv ~sparc ~x86"
else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/SSSD/sssd.git"
	EGIT_BRANCH="master"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="acl +daemon doc kerberos +locator +netlink nfsv4 nls +pam passkey samba selinux systemd systemtap test"
REQUIRED_USE="( ${PYTHON_REQUIRED_USE} )"
RESTRICT="!test? ( test )"

DEPEND="
	virtual/libintl
	!daemon? (
		pam? ( >=sys-libs/pam-0-r1[${MULTILIB_USEDEP}] )
		kerberos? ( >=app-crypt/mit-krb5-1.19.1[${MULTILIB_USEDEP}] )
	)
	daemon? (
		>=app-crypt/mit-krb5-1.19.1[${MULTILIB_USEDEP}]
		app-crypt/p11-kit
		>=dev-libs/ding-libs-0.2
		>=dev-libs/cyrus-sasl-2.1.25-r3[kerberos]
		dev-libs/jansson:=
		dev-libs/libpcre2:=
		dev-libs/libunistring:=[${MULTILIB_USEDEP}]
		>=dev-libs/popt-1.16
		>=dev-libs/openssl-1.0.2:=
		>=net-dns/bind-tools-9.9[gssapi]
		>=net-dns/c-ares-1.10.0-r1:=[${MULTILIB_USEDEP}]
		>=net-nds/openldap-2.4.30:=[sasl,experimental]
		>=sys-apps/dbus-1.6
		>=sys-apps/keyutils-1.5:=
		>=sys-libs/talloc-2.0.7
		>=sys-libs/tdb-1.2.9
		>=sys-libs/tevent-0.9.16
		virtual/ldb:=
		${PYTHON_DEPS}
		acl? ( net-fs/cifs-utils[acl] )
		netlink? ( dev-libs/libnl:3 )
		nfsv4? ( >=net-fs/nfs-utils-2.3.1-r2 )
		nls? ( >=sys-devel/gettext-0.18 )
		passkey? ( dev-libs/libfido2:= )
		samba? ( >=net-fs/samba-4.10.2[winbind] )
		selinux? (
			>=sys-libs/libselinux-2.1.9
			>=sys-libs/libsemanage-2.1
		)
		systemd? (
			sys-apps/systemd:=
			sys-apps/util-linux
			$(python_gen_cond_dep '
				dev-python/python-systemd[${PYTHON_USEDEP}]
			')
		)
		systemtap? ( dev-debug/systemtap )
	)"
RDEPEND="${DEPEND}
	passkey? ( sys-apps/pcsc-lite[policykit] )
	selinux? ( >=sec-policy/selinux-sssd-2.20120725-r9 )"
BDEPEND="
	virtual/pkgconfig
	app-text/docbook-xml-dtd:4.4
	>=dev-libs/libxslt-1.1.26
	${PYTHON_DEPS}
	doc? ( app-text/doxygen )
	nls? ( sys-devel/gettext
	       app-text/po4a )
	test? (
		dev-libs/check
		dev-libs/softhsm:2
		dev-util/cmocka
		net-libs/gnutls[pkcs11,tools]
		sys-libs/libfaketime
		sys-libs/nss_wrapper
		sys-libs/pam_wrapper
		sys-libs/uid_wrapper
	)
"

CONFIG_CHECK="~KEYS"

PATCHES=(
	"${FILESDIR}/${PN}-2.8.2-krb5_pw_locked.patch"
	"${FILESDIR}/${PN}-2.8.2-allow-client-build-without-pam.patch"
)

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/ipa_hbac.h
	/usr/include/sss_idmap.h
	/usr/include/sss_nss_idmap.h
	# --with-ifp
	/usr/include/sss_sifp.h
	/usr/include/sss_sifp_dbus.h
	# from 1.15.3
	/usr/include/sss_certmap.h
)

pkg_setup() {
	linux-info_pkg_setup
	python-single-r1_pkg_setup
}

src_prepare() {
	default

	plocale_get_locales > src/man/po/LINGUAS || die

	sed -i \
		-e "/_langs]/ s/ .*//" \
		src/man/po/po4a.cfg \
		|| die
	enable_locale() {
		local locale=${1}

		sed -i \
			-e "/_langs]/ s/$/ ${locale}/" \
			src/man/po/po4a.cfg \
			|| die
	}

	plocale_for_each_locale enable_locale

	PLOCALES="${PLOCALES_BIN}"
	plocale_get_locales > po/LINGUAS || die

	sed -i \
		-e 's:/var/run:/run:' \
		src/examples/logrotate \
		|| die

	# disable flaky test, see https://github.com/SSSD/sssd/issues/5631
	sed -i \
		-e '/^\s*pam-srv-tests[ \\]*$/d' \
		Makefile.am \
		|| die

	eautoreconf

	multilib_copy_sources
}

src_configure() {
	local native_dbus_cflags=' '
	use daemon && native_dbus_cflags=$($(tc-getPKG_CONFIG) --cflags dbus-1 || die)

	# Workaround for bug #938302
	if use systemtap && has_version "dev-debug/systemtap[-dtrace-symlink(+)]" ; then
		export DTRACE="${BROOT}"/usr/bin/stap-dtrace
	fi

	multilib-minimal_src_configure
}

multilib_src_configure() {
	local myconf=()

	myconf+=(
		--libexecdir="${EPREFIX}"/usr/libexec
		--localstatedir="${EPREFIX}"/var
		--runstatedir="${EPREFIX}"/run
		--sbindir="${EPREFIX}"/usr/sbin
		--with-pid-path="${EPREFIX}"/run
		--with-plugin-path="${EPREFIX}"/usr/$(get_libdir)/sssd
		--enable-pammoddir="${EPREFIX}$(getpam_mod_dir)"
		--with-ldb-lib-dir="${EPREFIX}"/usr/$(get_libdir)/samba/ldb
		--with-db-path="${EPREFIX}"/var/lib/sss/db
		--with-gpo-cache-path="${EPREFIX}"/var/lib/sss/gpo_cache
		--with-pubconf-path=$(usex daemon "${EPREFIX}"/var/lib/sss/pubconf /var/lib/sss/pubconf)
		--with-pipe-path=$(usex daemon "${EPREFIX}"/var/lib/sss/pipes /var/lib/sss/pipes)
		--with-mcache-path=$(usex daemon "${EPREFIX}"/var/lib/sss/mc /var/lib/sss/mc)
		--with-secrets-db-path="${EPREFIX}"/var/lib/sss/secrets
		--with-log-path="${EPREFIX}"/var/log/sssd
		--with-kcm
		--enable-kcm-renewal
		--with-os=gentoo
		--disable-rpath
		--disable-static
		# Valgrind is only used for tests
		--disable-valgrind
		$(use_with samba)
		--with-smb-idmap-interface-version=6
		$(multilib_native_use_enable acl cifs-idmap-plugin)
		$(multilib_native_use_with selinux)
		$(multilib_native_use_with selinux semanage)
		--enable-krb5-locator-plugin
		$(use_enable samba pac-responder)
		$(multilib_native_use_with nfsv4 nfsv4-idmapd-plugin)
		$(use_enable nls)
		$(multilib_native_use_with netlink libnl)
		--with-manpages
		--with-sudo
		$(multilib_native_with autofs)
		$(multilib_native_with ssh)
		--without-oidc-child
		$(multilib_native_with passkey)
		--with-subid
		$(use_enable systemtap)
		--without-python2-bindings
		$(multilib_native_with python3-bindings)
		# Annoyingly configure requires that you pick systemd XOR sysv
		--with-initscript=$(usex systemd systemd sysv)
		KRB5_CONFIG="${ESYSROOT}"/usr/bin/krb5-config
		# Needed for Samba 4.21
		CPPFLAGS="${CPPFLAGS} -I${ESYSROOT}/usr/include/samba-4.0"
	)

	use systemd && myconf+=(
		--with-systemdunitdir=$(systemd_get_systemunitdir)
	)

	if ! multilib_is_native_abi || ! use daemon; then
		# work-around all the libraries that are used for CLI and server
		myconf+=(
			{POPT,TALLOC,TDB,TEVENT,LDB}_{CFLAGS,LIBS}=' '
			# ldb headers are fine since native needs it
			# ldb lib fails... but it does not seem to bother
			{DHASH,UNISTRING,INI_CONFIG_V{0,1,1_1,1_3}}_{CFLAGS,LIBS}=' '
			{PCRE,CARES,SYSTEMD_LOGIN,SASL,DBUS,CRYPTO,P11_KIT}_{CFLAGS,LIBS}=' '
			{NDR_NBT,SAMBA_UTIL,SMBCLIENT,NDR_KRB5PAC,JANSSON}_{CFLAGS,LIBS}=' '

			# use native include path for dbus (needed for build)
			DBUS_CFLAGS="${native_dbus_cflags}"

			# non-pkgconfig checks
			ac_cv_lib_ldap_ldap_search=yes
			--without-kcm
			--without-manpages
		)
	fi

	if ! use daemon; then
		# continued work-around when headers nor bind-tools are not present either
		myconf+=(
			NSUPDATE="${EPREFIX}"/bin/cat
			SAMBA_UTIL_{CFLAGS,LIBS}=' '
			ac_cv_header_ldb_h=yes
			ac_cv_header_ldb_module_h=yes
			ac_cv_type_LDAPDerefRes=yes

			ac_cv_header_unistr_h=yes
			ac_cv_header_unicase_h=yes
			ac_cv_lib_unistring_u8_strlen=yes
			ac_cv_lib_unistring_u8_casecmp=yes
			ac_cv_lib_unistring_u8_check=yes

			--disable-cifs-idmap-plugin
		)
		if ! use kerberos; then
			myconf+=(
				{KRB5,GSSAPI_KRB5}_{CFLAGS,LIBS}=' '
				KRB5_LIBS=yes
				ac_cv_header_krb5_h=yes
				ac_cv_header_krad_h=yes
				ac_cv_lib_krad_krad_packet_get_attr=yes
				--disable-krb5-locator-plugin
			)
		fi
	fi

	econf "${myconf[@]}"
}

multilib_src_compile() {
	if multilib_is_native_abi && use daemon; then
		default
		use doc && emake docs
	else
		emake libnss_sss.la
		use pam && emake pam_sss.la pam_sss_gss.la
		if use daemon || use kerberos; then
			use locator && emake sssd_krb5_locator_plugin.la
		fi
		use samba && emake sssd_pac_plugin.la
	fi
}

multilib_src_test() {
	if multilib_is_native_abi && use daemon; then
		local -x CK_TIMEOUT_MULTIPLIER=10
		emake check VERBOSE=yes
	fi
}

multilib_src_install() {
	if multilib_is_native_abi && use daemon; then
		emake -j1 DESTDIR="${D}" install
		if use python; then
			python_fix_shebang "${ED}"
			python_optimize
		fi
	else
		# easier than playing with automake...
		use pam && dopammod .libs/pam_sss.so
		use pam && dopammod .libs/pam_sss_gss.so

		into /
		dolib.so .libs/libnss_sss.so*

		if use daemon || use kerberos; then
			if use locator; then
				exeinto /usr/$(get_libdir)/krb5/plugins/libkrb5
				doexe .libs/sssd_krb5_locator_plugin.so
			fi
		fi

		if use samba; then
			exeinto /usr/$(get_libdir)/krb5/plugins/authdata
			doexe .libs/sssd_pac_plugin.so
		fi
	fi
}

multilib_src_install_all() {
	einstalldocs

	! use daemon && return

	insinto /etc/sssd
	insopts -m600
	doins src/examples/sssd-example.conf

	insinto /etc/logrotate.d
	insopts -m644
	newins src/examples/logrotate sssd

	newconfd "${FILESDIR}"/sssd.conf sssd

	keepdir /var/lib/sss/db
	keepdir /var/lib/sss/deskprofile
	keepdir /var/lib/sss/gpo_cache
	keepdir /var/lib/sss/keytabs
	keepdir /var/lib/sss/mc
	keepdir /var/lib/sss/pipes/private
	keepdir /var/lib/sss/pubconf/krb5.include.d
	keepdir /var/lib/sss/secrets
	keepdir /var/log/sssd

	# strip empty dirs
	if ! use doc; then
		rm -r "${ED}"/usr/share/doc/"${PF}"/doc || die
		rm -r "${ED}"/usr/share/doc/"${PF}"/{hbac,idmap,nss_idmap}_doc || die
	fi

	rm -r "${ED}"/run || die
	find "${ED}" -type f -name '*.la' -delete || die
}

pkg_postinst() {
	! use daemon && return
	elog "You must set up sssd.conf (default installed into /etc/sssd)"
	elog "and (optionally) configuration in /etc/pam.d in order to use SSSD"
	elog "features."
	optfeature "Kerberos keytab renew (see krb5_renew_interval)" app-crypt/adcli
}
