# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# added: see https://projects.gentoo.org/python/guide/distutils.html#basic-use-pep-517-mode
DISTUTILS_USE_PEP517=poetry

PYTHON_COMPAT=( python3_{6..11} )
inherit distutils-r1
DISTUTILS_USE_SETUPTOOLS=pyproject.toml

DESCRIPTION="A library to query system architecture"
HOMEPAGE="https://github.com/archspec/archspec"
# Use the tarball from GitHub, as the one from PyPI does not contain the tests.
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
# The tarball from GitHub does not contain the archspec microarchitectures data file,
# which is part of the archspec-json repository. So, we need to download that tarball as well.
ARCHSPEC_JSON="${PN}-json-${PV}.tar.gz"
SRC_URI+=" https://github.com/${PN}/${PN}-json/archive/v${PV}.tar.gz -> ${ARCHSPEC_JSON}"

LICENSE="|| ( Apache-2.0 MIT )"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc ~ppc64 ~riscv ~sparc ~x86 ~x64-macos"

RDEPEND=">dev-python/six-1.13[${PYTHON_USEDEP}]
	=dev-python/click-8.1.3[${PYTHON_USEDEP}]"
BDEPEND="test? (
		dev-python/jsonschema[${PYTHON_USEDEP}]
	)"

distutils_enable_tests pytest

src_unpack() {
	unpack ${P}.tar.gz
	# Extract the archspec-json file into the right subdirectory of the archspec sources.
	tar -C "${P}"/"${PN}"/json --strip-components=1 -xzf "${DISTDIR}/${ARCHSPEC_JSON}" || die
}
