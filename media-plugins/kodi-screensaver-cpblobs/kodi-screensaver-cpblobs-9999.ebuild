# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="CpBlobs screensaver for Kodi"
HOMEPAGE="https://github.com/xbmc/screensaver.cpblobs"
KODI_PLUGIN_NAME="screensaver.cpblobs"

case ${PV} in
9999)
	EGIT_REPO_URI="https://github.com/xbmc/${KODI_PLUGIN_NAME}.git"
	inherit git-r3
	;;
*)
	CODENAME="Matrix"
	SRC_URI="https://github.com/xbmc/${KODI_PLUGIN_NAME}/archive/${PV}-${CODENAME}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${KODI_PLUGIN_NAME}-${PV}-${CODENAME}"
	KEYWORDS="~amd64 ~x86"
	;;
esac

LICENSE="GPL-2+"
SLOT="0"
IUSE=""

DEPEND="
	>=media-libs/glm-0.9.9.8-r1
	=media-tv/kodi-${PV%%.*}*
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	if [[ -d depends ]]; then
		rm -r depends || die
	fi
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_LIBDIR="${EPREFIX}/usr/$(get_libdir)/kodi"
	)
	cmake_src_configure
}
