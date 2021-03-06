class Perl < Formula
  desc "Highly capable, feature-rich programming language"
  homepage "https://www.perl.org/"
  url "http://www.cpan.org/src/5.0/perl-5.22.1.tar.xz"
  mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/p/perl/perl_5.22.1.orig.tar.xz"
  sha256 "9e87317d693ce828095204be0d09af8d60b8785533fadea1a82b6f0e071e5c79"

  head "https://perl5.git.perl.org/perl.git", :branch => "blead"

  bottle do
    revision 1
    sha256 "e5b74b2aae601761f639bc668f929a39592c2231dbef5ed28f01fdd877e0bed7" => :el_capitan
    sha256 "f180afdea11e1f4e12378881d58c27efa04abee091140c2e055439a14a668802" => :yosemite
    sha256 "f5561ffe42ca1559fb72e855ecc36c133a5c6142a1cfac2cf9387b4da9b25d95" => :mavericks
  end

  keg_only :provided_by_osx,
    "OS X ships Perl and overriding that can cause unintended issues"

  option "with-dtrace", "Build with DTrace probes"
  option "without-test", "Skip running the build test suite"

  deprecated_option "with-tests" => "with-test"

  def install
    args = %W[
      -des
      -Dprefix=#{prefix}
      -Dman1dir=#{man1}
      -Dman3dir=#{man3}
      -Duseshrplib
      -Duselargefiles
      -Dusethreads
    ]

    args << "-Dusedtrace" if build.with? "dtrace"
    args << "-Dusedevel" if build.head?

    system "./Configure", *args
    system "make"

    # OS X El Capitan's SIP feature prevents DYLD_LIBRARY_PATH from being
    # passed to child processes, which causes the make test step to fail.
    # https://rt.perl.org/Ticket/Display.html?id=126706
    # https://github.com/Homebrew/homebrew/issues/41716
    if MacOS.version < :el_capitan
      system "make", "test" if build.with? "test"
    end

    system "make", "install"
  end

  def caveats; <<-EOS.undent
    By default Perl installs modules in your HOME dir. If this is an issue run:
      `#{bin}/cpan o conf init`
    EOS
  end

  test do
    (testpath/"test.pl").write "print 'Perl is not an acronym, but JAPH is a Perl acronym!';"
    system "#{bin}/perl", "test.pl"
  end
end
