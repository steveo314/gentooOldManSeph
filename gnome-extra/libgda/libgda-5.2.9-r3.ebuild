# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

inherit db-use gnome2 java-pkg-opt-2 vala virtualx

DESCRIPTION="GNOME database access library"
HOMEPAGE="https://www.gnome-db.org/"

# firebird license is not GPL compatible
LICENSE="GPL-2+ LGPL-2+"

SLOT="5/4" # subslot = libgda-5.0 soname version
KEYWORDS="~alpha amd64 ~arm64 ~ppc ~ppc64 ~riscv ~sparc x86"

IUSE="berkdb canvas debug firebird keyring gtk graphviz http +introspection json ldap mdb mysql oci8 postgres sourceview ssl vala"
REQUIRED_USE="
	canvas? ( gtk )
	graphviz? ( gtk )
	sourceview? ( gtk )
	vala? ( introspection )
"

RDEPEND="
	app-text/iso-codes
	>=dev-libs/glib-2.32:2
	>=dev-libs/libxml2-2:=
	dev-libs/libxslt
	sys-libs/readline:0=
	sys-libs/ncurses:0=
	berkdb? ( sys-libs/db:* )
	firebird? ( dev-db/firebird )
	keyring? ( app-crypt/libsecret )
	gtk? (
		>=x11-libs/gtk+-3.0.0:3
		canvas? ( x11-libs/goocanvas:2.0= )
		sourceview? ( x11-libs/gtksourceview:3.0 )
		graphviz? ( media-gfx/graphviz )
	)
	http? ( >=net-libs/libsoup-2.24:2.4 )
	introspection? ( >=dev-libs/gobject-introspection-1.30:= )
	json? ( dev-libs/json-glib )
	ldap? ( net-nds/openldap:= )
	mdb? ( >app-office/mdbtools-0.5:= )
	mysql? ( dev-db/mysql-connector-c:0= )
	postgres? ( dev-db/postgresql:= )
	ssl? ( dev-libs/openssl:0= )
	>=dev-db/sqlite-3.10.2:3=
	vala? ( dev-libs/libgee:0.8 )
"

# TODO: libgee shouldn't be needed at build with USE=-vala, but needs build system fixes - bug 674066
DEPEND="${RDEPEND}
	dev-libs/libgee:0.8
"

# java dep shouldn't rely on slots, bug #450004
BDEPEND="
	app-text/yelp-tools
	dev-util/glib-utils
	dev-build/gtk-doc-am
	>=dev-util/intltool-0.40.6
	virtual/pkgconfig
	java? ( >=virtual/jdk-1.6 )
	vala? ( $(vala_depend) )
"

# firebird support bindist-restricted because it is not GPL compatible
RESTRICT="
	firebird? ( bindist )
"

pkg_setup() {
	java-pkg-opt-2_pkg_setup
}

src_prepare() {
	# They need python2
	sed -e '/SUBDIRS =/ s/trml2html//' \
		-e '/SUBDIRS =/ s/trml2pdf//' \
		-i libgda-report/RML/Makefile.{am,in} || die

	# replace my_bool with _Bool
	eapply "${FILESDIR}/${PN}-5.2-my_bool-error.patch"
	# ... and stop using bool elsewhere too
	eapply "${FILESDIR}/${PN}-5.2.9-redefine-bool-error.patch"

	# Prevent file collisions with libgda:4
	eapply "${FILESDIR}/${PN}-4.99.1-gda-browser-doc-collision.patch"
	eapply "${FILESDIR}/${PN}-4.99.1-control-center-icon-collision.patch"
	# Move files with mv (since epatch can't handle rename diffs) and
	# update pre-generated gtk-doc files (for non-git versions of libgda)
	local f
	for f in tools/browser/doc/gda-browser* ; do
		mv ${f} ${f/gda-browser/gda-browser-5.0} || die "mv ${f} failed"
	done
	for f in tools/browser/doc/html/gda-browser.devhelp* ; do
		sed -e 's:name="gda-browser":name="gda-browser-5.0":' \
			-i ${f} || die "sed ${f} failed"
		mv ${f} ${f/gda-browser/gda-browser-5.0} || die "mv ${f} failed"
	done
	for f in control-center/data/*_gda-control-center.png ; do
		mv ${f} ${f/_gda-control-center.png/_gda-control-center-5.0.png} ||
			die "mv ${f} failed"
	done

	# Fix building without introspection.
	eapply "${FILESDIR}/${PN}-5.2.9-no-introspection.patch"

	# Fix build with gcc14
	# https://github.com/gentoo/gentoo/pull/36912#issuecomment-2171657215
	eapply "${FILESDIR}/${PN}-5.2.9-fix-gcc14.patch"

	# bug #944755
	eapply "${FILESDIR}/${PN}-5.2.9-c23.patch"

	gnome2_src_prepare
	java-pkg-opt-2_src_prepare
}

src_configure() {
	local bdbroot bdbinc bdblib

	if use berkdb; then
		bdbinc=$(db_includedir)
		bdbroot=${bdbinc%/include/*}
		bdbinc=${bdbinc#${bdbroot}/}
		bdblib=$(get_libdir)
	fi

	use vala && vala_setup

	# Upstream broken configure handling for UI library introspection and vala bindings if passing a choice with
	# use_enable - https://gitlab.gnome.org/GNOME/libgda/issues/158
	# But if we don't pass an explicit choice, it behaves as we need (only enable them if --enable-ui AND the
	# appropriate --enable-introspection or --enable-vala)
	gnome2_src_configure \
		--with-help \
		--disable-default-binary \
		--disable-static \
		--enable-system-sqlite \
		$(use_with berkdb bdb "${bdbroot}") \
		$(use_with berkdb bdb-includedir-name "${bdbinc}") \
		$(use_with berkdb bdb-libdir-name "${bdblib}") \
		$(use_with canvas goocanvas) \
		$(use_enable debug) \
		$(use_with firebird firebird /usr) \
		$(use_with keyring libsecret) \
		$(use_with graphviz) \
		$(use_with gtk ui) \
		$(use_with http libsoup) \
		$(use_enable introspection) \
		"$(use_with java java $JAVA_HOME)" \
		$(use_enable json) \
		$(use_with ldap) \
		--with-ldap-libdir-name="$(get_libdir)" \
		$(use_with mdb mdb /usr) \
		$(use_with mysql mysql /usr) \
		$(use_with oci8 oracle) \
		$(use_with postgres postgres /usr) \
		$(use_enable ssl crypto) \
		$(use_with sourceview gtksourceview) \
		$(use_enable vala)
}

src_test() {
	# multi-threading tests suffer from race conditions
	virtx emake -j1 check
}

pkg_preinst() {
	gnome2_pkg_preinst
	java-pkg-opt-2_pkg_preinst
}

src_install() {
	gnome2_src_install
	# Use new location
	if use gtk; then
		mv "${ED}"/usr/share/appdata "${ED}"/usr/share/metainfo || die
	fi
}
