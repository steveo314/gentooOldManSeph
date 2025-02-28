# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/bcl.asc

inherit autotools verify-sig

DESCRIPTION="Create, destroy, resize, check, copy partitions and file systems"
HOMEPAGE="https://www.gnu.org/software/parted/"
SRC_URI="
	mirror://gnu/${PN}/${P}.tar.xz
	verify-sig? ( mirror://gnu/${PN}/${P}.tar.xz.sig )
"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~loong ~mips ppc ppc64 ~riscv ~s390 sparc x86"
IUSE="+debug device-mapper nls readline"

# util-linux for libuuid
RDEPEND="
	>=sys-fs/e2fsprogs-1.27
	sys-apps/util-linux
	device-mapper? ( >=sys-fs/lvm2-2.02.45 )
	readline? (
		>=sys-libs/ncurses-5.7-r7:0=
		>=sys-libs/readline-5.2:0=
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	nls? ( >=sys-devel/gettext-0.12.1-r2 )
	verify-sig? ( >=sec-keys/openpgp-keys-bcl-20230315 )
	virtual/pkgconfig
"

DOCS=(
	AUTHORS BUGS ChangeLog NEWS README THANKS TODO doc/{API,FAT,USER.jp}
)

PATCHES=(
	"${FILESDIR}"/${PN}-3.2-po4a-mandir.patch
	"${FILESDIR}"/${PN}-3.3-atari.patch
	# https://lists.gnu.org/archive/html/bug-parted/2022-02/msg00000.html
	"${FILESDIR}"/${PN}-3.4-posix-printf.patch
	# https://debbugs.gnu.org/61129
	"${FILESDIR}"/${PN}-3.6-tests-unicode.patch
	# https://debbugs.gnu.org/61128
	"${FILESDIR}"/${PN}-3.6-tests-non-bash.patch
	# bug #910487
	"${FILESDIR}"/${P}-underlinked-util-linux.patch
	# bug #943690
	"${FILESDIR}"/${P}-c23.patch
)

# false positive
QA_CONFIG_IMPL_DECL_SKIP="MIN"

src_prepare() {
	default
	eautoreconf

	touch doc/pt_BR/Makefile.in || die
}

src_configure() {
	# -fanalyzer substantially slows down the build and isn't useful for
	# us. It's useful for upstream as it's static analysis, but it's not
	# useful when just getting something built.
	export gl_cv_warn_c__fanalyzer=no

	local myconf=(
		$(use_enable debug)
		$(use_enable device-mapper)
		$(use_enable nls)
		$(use_with readline)
		--disable-rpath
		--disable-static
	)
	econf "${myconf[@]}"
}

src_install() {
	default

	find "${ED}" -type f -name '*.la' -delete || die
}
