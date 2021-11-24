# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..10} )
DISTUTILS_USE_SETUPTOOLS=pyproject.toml
inherit distutils-r1

DESCRIPTION="A library to query system architecture"
HOMEPAGE="https://github.com/archspec/archspec"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
ARCHSPEC_JSON="${PN}-json.tar.gz"
SRC_URI+=" https://github.com/${PN}/${PN}-json/archive/v${PV}.tar.gz -> ${ARCHSPEC_JSON}"

LICENSE="|| ( Apache-2.0 MIT )"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc ~ppc64 ~sparc ~x86 ~x64-macos"
#IUSE=""

RDEPEND=">dev-python/six-1.13[${PYTHON_USEDEP}]
	<dev-python/click-8.0[${PYTHON_USEDEP}]"

distutils_enable_tests pytest

src_unpack() {
	unpack ${P}.tar.gz
	tar -C "${P}"/"${PN}"/json --strip-components=1 -xzf "${DISTDIR}/${ARCHSPEC_JSON}" || die
}
