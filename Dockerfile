FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive
MAINTAINER Daniel Bosk <dbosk@kth.se>
LABEL se.bosk.daniel.makefiles.version="$Id: a87b15aa048853482266a66d06b5f88b0248d244 $"
LABEL se.bosk.daniel.makefiles.url="https://github.com/dbosk/makefiles"
RUN apt update -y && \
  apt install --no-install-recommends -y \
    texlive-full \
    xindy \
    curl \
    git \
    gnuplot \
    imagemagick \
    inkscape \
    make \
    noweb \
    pandoc \
    python3-matplotlib \
    python3-numpy \
    python3-pygments \
    python3-scipy \
    qrencode && \
  rm -Rf /var/lib/apt/lists/* && \
  rm -Rf /usr/share/doc
COPY doc.mk /usr/local/include
COPY exam.mk /usr/local/include
COPY haskell.mk /usr/local/include
COPY latexmkrc /usr/local/include
COPY noweb.mk /usr/local/include
COPY pkg.mk /usr/local/include
COPY portability.mk /usr/local/include
COPY pub.mk /usr/local/include
COPY results.mk /usr/local/include
COPY subdir.mk /usr/local/include
COPY tex.mk /usr/local/include
COPY transform.mk /usr/local/include
WORKDIR /workdir
