# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.2-gtk3"
PYTHON_COMPAT=( python3_{10..13} python3_13t )

inherit python-single-r1 wxwidgets cmake xdg

DESCRIPTION="GUI for the creation & processing of panoramic images"
HOMEPAGE="http://hugin.sf.net"
SRC_URI="https://downloads.sourceforge.net/${PN}/${P/_/}.tar.bz2"

LICENSE="GPL-2+ BSD BSD-2 MIT wxWinLL-3 ZLIB FDL-1.2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

LANGS=" ca ca-valencia cs da de en-GB es eu fi fr hu it ja nl pl pt-BR ro ru sk sv zh-CN zh-TW"
IUSE="debug lapack python raw sift $(echo ${LANGS//\ /\ l10n_})"

CDEPEND="
	dev-db/sqlite:3
	dev-libs/boost:=
	>=media-gfx/enblend-4.0
	media-gfx/exiv2:=
	media-libs/freeglut
	media-libs/glew:=
	media-libs/libjpeg-turbo:=
	>=media-libs/libpano13-2.9.19_beta1:=
	media-libs/libpng:=
	media-libs/openexr:=
	media-libs/tiff:=
	>=media-libs/vigra-1.11.1-r5[openexr,tiff]
	sci-libs/fftw:3.0=
	sci-libs/flann
	sys-libs/zlib
	virtual/glu
	virtual/opengl
	x11-libs/wxGTK:${WX_GTK_VER}=[X,opengl]
	lapack? ( virtual/blas virtual/lapack )
	python? ( ${PYTHON_DEPS} )
	sift? ( media-gfx/autopano-sift-C )"
RDEPEND="${CDEPEND}
	media-libs/exiftool
	raw? ( media-gfx/dcraw )"
DEPEND="${CDEPEND}
	dev-cpp/tclap
	sys-devel/gettext
	virtual/pkgconfig
	python? ( >=dev-lang/swig-2.0.4 )"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

DOCS=( authors.txt README TODO )

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	sed -i \
		-e "/COMMAND.*GZIP/d" \
		-e "s/\.gz//g" \
		"${S}"/doc/CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_HSI=$(usex python)
		-DENABLE_LAPACK=$(usex lapack)
		-DBUILD_WITH_EGL=yes
	)
	setup-wxwidgets
	cmake_src_configure
}

src_install() {
	cmake_src_install
	use python && python_optimize

	local lang
	for lang in ${LANGS} ; do
		case ${lang} in
			ca) dir=ca_ES;;
			ca-valencia) dir=ca_ES@valencia;;
			cs) dir=cs_CZ;;
			*) dir=${lang/-/_};;
		esac
		if ! use l10n_${lang} ; then
			rm -r "${ED}"/usr/share/locale/${dir} || die
		fi
	done
}
