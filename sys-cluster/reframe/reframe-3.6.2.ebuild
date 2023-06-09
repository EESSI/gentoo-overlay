# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{6..11} )

inherit distutils-r1

DESCRIPTION="ReFrame is a framework for writing regression tests for HPC systems"
HOMEPAGE="https://reframe-hpc.readthedocs.io/
	https://github.com/eth-cscs/reframe/"
SRC_URI="https://github.com/eth-cscs/${PN}/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="BSD"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~x86"
SLOT="0"

RDEPEND="dev-python/argcomplete[${PYTHON_USEDEP}]
	dev-python/jsonschema[${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.4.1[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/semver[${PYTHON_USEDEP}]"
BDEPEND="
	test? (
		>=dev-python/pytest-6.2.3[${PYTHON_USEDEP}]
		>=dev-python/pytest-forked-1.3.0[${PYTHON_USEDEP}]
	)"

distutils_enable_tests pytest

python_test() {
	"${EPYTHON}" test_reframe.py ||
		die "Tests fail with ${EPYTHON}"
}
