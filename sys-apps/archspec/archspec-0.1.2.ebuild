# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{5,6,7,8,9} )

inherit distutils-r1

#DISTUTILS_USE_SETUPTOOLS=pyproject.toml

DESCRIPTION="A library to query system architecture"
HOMEPAGE="https://github.com/archspec/archspec"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="|| ( Apache-2.0 MIT )"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc ~ppc64 ~riscv ~sparc ~x86 ~x64-macos"
IUSE=""

#DEPEND="dev-python/pyproject2setuppy[${PYTHON_USEDEP}]
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	>dev-python/six-1.13[${PYTHON_USEDEP}]
	=dev-python/click-8.1.3[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"
BDEPEND=""
