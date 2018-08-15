FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive
MAINTAINER Daniel Bosk <dbosk@kth.se>
LABEL se.bosk.daniel.makefiles.version="$Id: 17d9268af6777d40cdfaa987349df5ccedd061fc $"
LABEL se.bosk.daniel.makefiles.url="https://github.com/dbosk/makefiles"
RUN apt update -y && apt install -y \
  texlive-full
RUN apt update -y && apt install -y \
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
  qrencode
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
