# Usage
# docker build .
# docker run -P -t -i [containerid] /bin/bash
# docker run -P -t -i 964086c8574a /bin/bash

FROM ubuntu:16.10

LABEL version="1.0" description="Web site framework and application server"

RUN apt-get update && apt-get install -y \
        apache2 \
        g++ \
        libapache2-mod-perl2 \
        libberkeleydb-perl \
        libcaptcha-recaptcha-perl \
        libcgi-pm-perl \
        libclass-errorhandler-perl \
        libconvert-asn1-perl \
        libcrypt-blowfish-perl \
        libcrypt-cbc-perl \
        libcrypt-des-ede3-perl \
        libcrypt-rijndael-perl \
        libdata-buffer-perl \
        libdata-dump-perl \
        libdata-guid-perl \
        libdata-validate-domain-perl \
        libdate-manip-perl \
        libdatetime-event-recurrence-perl \
        libdatetime-format-http-perl \
        libdatetime-format-mysql-perl \
        libdatetime-format-pg-perl \
        libdatetime-perl \
        libdatetime-set-perl \
        libdbi-perl \
        libdevel-cover-perl \
        libdigest-hmac-perl \
        libdigest-md2-perl \
        libemail-mime-createhtml-perl \
        libemail-mime-perl \
        libfile-mimeinfo-perl \
        libfile-remove-perl \
        libfile-slurp-perl \
        libfreezethaw-perl \
        libhtml-formattext-withlinks-perl \
        libhtml-tokeparser-simple-perl \
        libhttp-browserdetect-perl \
        libhttp-parser-xs-perl \
        libidna-punycode-perl \
        libio-stringy-perl \
        libjson-perl \
        libjson-xs-perl \
        liblog-trace-perl \
        libmime-lite-perl \
        libmodule-build-perl \
        libnet-dns-perl \
        libnet-ip-perl \
        libnet-scp-perl \
        libnet-ssh2-perl \
        libnumber-bytes-human-perl \
        libnumber-format-perl \
        libperl-critic-perl \
        libproc-processtable-perl \
        libsort-versions-perl \
        libspreadsheet-parseexcel-perl \
        libsys-cpuload-perl \
        libtemplate-perl \
        libterm-readline-gnu-perl \
        libtest-assertions-perl \
        libtest-deep-perl build-essential \
        libtest-differences-perl \
        libtest-distribution-perl \
        libtest-perl-critic-perl \
        libtest-pod-coverage-perl \
        libtest-pod-perl \
        libtest-strict-perl \
        libtest-warn-perl \
        libtext-autoformat-perl \
        libunicode-maputf8-perl \
        libwww-perl \
        libxml-simple-perl \
        lsof \
        perlmagick \
    && cpan App::cpanminus \
    && cpanm \
        DateTime::Incomplete \
        Encode::Detect::Detector \
        Encode::InCharset \
        jQuery::File::Upload \
        Linux::SysInfo \
        List::Uniq \
        MIME::Words

COPY . /usr/local/paraframe
COPY docker /
WORKDIR /usr/local/paraframe

EXPOSE 80

#CMD /paraframe/install.sh
