# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..13} )

inherit gnome2 python-r1

DESCRIPTION="Python client bindings for D-Bus AT-SPI"
HOMEPAGE="https://wiki.gnome.org/Accessibility"

# Note: only some of the tests are GPL-licensed, everything else is LGPL
LICENSE="LGPL-2 GPL-2+"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm arm64 ~hppa ~loong ~ppc ~ppc64 ~riscv sparc x86"

IUSE="test"
RESTRICT="!test? ( test )"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	${PYTHON_DEPS}
	>=dev-libs/atk-2.11.2
	dev-python/dbus-python[${PYTHON_USEDEP}]
	>=dev-python/pygobject-2.90.1:3[${PYTHON_USEDEP}]
"
RDEPEND="
	${DEPEND}
	>=sys-apps/dbus-1
	>=app-accessibility/at-spi2-core-2.34[introspection]
"
# sys-apps/which BDEPEND can be dropped on next release (>2.46.1)
BDEPEND="
	sys-apps/which
	virtual/pkgconfig
	test? ( x11-libs/gtk+:3 )
"

src_prepare() {
	gnome2_src_prepare
	python_copy_sources
}

src_configure() {
	python_foreach_impl run_in_build_dir gnome2_src_configure $(use_enable test tests)
}

src_compile() {
	python_foreach_impl run_in_build_dir gnome2_src_compile
}

src_test() {
	python_foreach_impl run_in_build_dir dbus-run-session emake check
}

src_install() {
	installing() {
		gnome2_src_install
		python_optimize
	}
	python_foreach_impl run_in_build_dir installing

	docinto examples
	dodoc examples/*.py
}
