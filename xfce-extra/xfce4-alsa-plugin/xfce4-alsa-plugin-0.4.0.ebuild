# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit vala meson

DESCRIPTION="Simple ALSA volume control for xfce4-panel"
HOMEPAGE="https://github.com/equeim/xfce4-alsa-plugin"
SRC_URI="https://github.com/equeim/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~ppc ~ppc64 ~riscv x86"

RDEPEND="
	media-libs/alsa-lib
	>=xfce-base/xfce4-panel-4.13
	x11-libs/gtk+:3[introspection]
"
DEPEND="${RDEPEND}"
BDEPEND="
	$(vala_depend)
	sys-devel/gettext
"

src_configure() {
	vala_setup
	meson_src_configure
}
