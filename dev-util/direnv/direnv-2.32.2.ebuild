# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Direnv is an environment switcher for the shell."
HOMEPAGE="http://direnv.net"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://eessi-gentoo-snapshot.s3.eu-west-1.amazonaws.com/direnv-2.32.2-vendor.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~riscv ~x86"

src_compile() {
	ego build
}

src_install() {
	#emake PREFIX="${D}/${EPREFIX}/usr" install
	dobin direnv
	dodir /usr/share/fish/vendor_conf.d
	echo "${EPREFIX}/usr/bin/direnv hook fish | source" > "${D}/${EPREFIX}/usr/share/fish/vendor_conf.d/direnv.fish"
	doman man/*.1
}

src_test() {
	emake test-stdlib test-go test-bash
}
