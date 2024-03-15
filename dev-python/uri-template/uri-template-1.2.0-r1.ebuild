# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( pypy3 python3_{10..12} )

inherit distutils-r1

MY_P="${PN}-v${PV}"
DESCRIPTION="URI Template expansion in strict adherence to RFC 6570"
HOMEPAGE="
	https://gitlab.linss.com/open-source/python/uri-template
	https://pypi.org/project/uri-template/
"
SRC_URI="
	https://gitlab.linss.com/open-source/python/${PN}/-/archive/v${PV}/${MY_P}.tar.gz
"
S="${WORKDIR}/${MY_P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"

src_unpack() {
	# unpack ${MY_P}.tar.gz
	# Extract the tar.gz into ${PN}-${PV}.
	mkdir -p "${MY_P}"
	tar -C "${MY_P}" --strip-components=1 -xzf "${DISTDIR}/${MY_P}.tar.gz" || die
}

src_prepare() {
	distutils-r1_src_prepare
	# fix the version number
	sed -i -e "/version/s:0\.0\.0:${PV}:" setup.py || die
}

python_test() {
	"${EPYTHON}" "test.py" || die "Tests fail with ${EPYTHON}."
}
