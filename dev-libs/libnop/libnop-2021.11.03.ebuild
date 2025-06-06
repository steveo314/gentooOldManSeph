# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CommitId=35e800d81f28c632956c5a592e3cbe8085ecd430
DESCRIPTION="C++ Native Object Protocols"
HOMEPAGE="https://github.com/google/libnop"
SRC_URI="https://github.com/google/${PN}/archive/${CommitId}.tar.gz
	-> ${P}.tar.gz"

S="${WORKDIR}"/${PN}-${CommitId}

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="test"

BDEPEND="test? ( dev-cpp/gtest )"
RESTRICT="!test? ( test )"

PATCHES=( "${FILESDIR}"/${P}-libstdc++.patch )

src_compile() {
	use test && default
}

src_install() {
	doheader -r include/nop
	einstalldocs
}

src_test() {
	out/test || die
}
