# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_P="${P/+/}"

inherit toolchain-funcs autotools

DESCRIPTION="Real Time Log Monitoring and Alerting"
HOMEPAGE="https://crypt.gen.nz/logsurfer/"
SRC_URI="https://downloads.sourceforge.net/logsurfer/${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="freedist GPL-2+"
SLOT="0"
KEYWORDS="amd64 x86"
RESTRICT="bindist" #444330

RDEPEND="
	acct-group/logsurfer
	acct-user/logsurfer
"

PATCHES=(
	"${FILESDIR}/${P}-fix-declaration-of-check_context_linelimit.patch"
	"${FILESDIR}/${P}-C23.patch"
)

src_prepare() {
	default

	#https://bugs.gentoo.org/905941
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--with-etcdir=/etc
	)

	econf "${myeconfargs[@]}"
}

src_compile() {
	tc-export CC
	default
}

src_install() {
	dobin src/logsurfer
	doman man/logsurfer.1 man/logsurfer.conf.4

	newinitd "${FILESDIR}"/logsurfer-1.8.initd-r1 logsurfer
	newconfd "${FILESDIR}"/logsurfer.confd logsurfer

	einstalldocs
}
