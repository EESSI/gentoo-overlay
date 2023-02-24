# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit udev

DESCRIPTION="OpenIB userspace driver for the PathScale InfiniBand HCAs"
HOMEPAGE="https://github.com/cornelisnetworks/opa-psm2"
SRC_URI="https://github.com/cornelisnetworks/${PN}/archive/PSM2_${PV}.tar.gz"

LICENSE="|| ( BSD GPL-2 )"
SLOT="0"
KEYWORDS="amd64 ~x86 ~amd64-linux"
IUSE=""

BDEPEND="virtual/pkgconfig"
RDEPEND="sys-apps/util-linux
	sys-process/numactl
	virtual/udev"

S="${WORKDIR}/${PN}-PSM2_${PV}"

src_compile() {
	emake arch=x86_64 USE_PSM_UUID=1 WERROR=
}

src_install() {
	emake arch=x86_64 UDEVDIR="/lib/udev" DESTDIR="${D}/${EPREFIX}" install
	dodoc README
}
