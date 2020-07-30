VERSION=2.4.45

ENTROPY=`cat /proc/sys/kernel/random/entropy_avail`
if [ $ENTROPY -lt 3000 ]
then
  echo "This box can't do ssl tests... ${ENTROPY} is NOT enough"
  exit 1
fi

if [ ! -f httpd-${VERSION}.tar.gz ]; then
  wget https://dist.apache.org/repos/dist/dev/httpd/httpd-${VERSION}.tar.gz
  if [ $? -ne 0 ]; then
      wget http://mirror.easyname.ch/apache/httpd/httpd-${VERSION}.tar.gz
      if [ $? -ne 0 ]; then
        echo "Can't find httpd: ${VERSION}"
        exit 1
      fi 
  fi
else
  echo "WARN: using existing httpd-${VERSION}.tar.gz"
  sleep 1
fi

tar xvf httpd-${VERSION}.tar.gz
(cd httpd-${VERSION}
 ./configure --enable-mods-shared=reallyall \
             --enable-maintainer-mode \
             --enable-load-all-modules \
             --prefix=$HOME/TMP/APACHE-${VERSION}
 if [ $? -ne 0 ]; then
    echo "Can't configure"
      exit 1
 fi 
 make
 if [ $? -ne 0 ]; then
    echo "Can't build"
    exit 1
 fi 
 make install
 if [ $? -ne 0 ]; then
    echo "Can't install"
    exit 1
 fi 
)

# install perl modules
# dnf install 'perl(ExtUtils::MakeMaker)'
# dnf install 'perl(Test)'
# dnf install 'perl(HTTP::DAV)'
# dnf install 'perl(DateTime)'
# dnf install 'perl(Time::HiRes)'
# dnf install 'perl(Protocol::HTTP2::Client)'
# dnf install 'perl(AnyEvent)'
# dnf install 'perl(Test)'
# dnf install 'perl(Test::Harness)'
# dnf install 'perl(Crypt::SSLeay)'
# dnf install 'perl(Net::SSLeay)'
# dnf install 'perl(IO::Socket::SSL)'
# dnf install 'perl(IO::Socket::IP)'
# dnf install 'perl(IO::Select)'
# dnf install 'perl(LWP::Protocol::https)'
# get the test framework
svn checkout http://svn.apache.org/repos/asf/httpd/test/framework/trunk/
(cd trunk
 perl Makefile.PL -apxs ${HOME}/TMP/APACHE-${VERSION}/bin/apxs
 if [ $? -ne 0 ]; then
    echo "Can't build the tests"
    exit 1
 fi
 t/TEST
 if [ $? -ne 0 ]; then
    echo "At lest one test failed!!!!"
    exit 1
 fi
 t/TEST
)
echo "OK!"
