FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive
MAINTAINER Daniel Bosk <dbosk@kth.se>
LABEL se.bosk.daniel.makefiles.version="$Id: 198175dc3b11e7c72e26822df02cc276c2838a23 $"
LABEL se.bosk.daniel.makefiles.url="https://github.com/dbosk/makefiles"
RUN apt update -y && \
  apt install --no-install-recommends -y \
    texlive-full \
    xindy \
  && \
  apt purge -fy texlive-fonts-extra-doc \
    texlive-latex-base-doc \
    texlive-fonts-recommended-doc \
    texlive-latex-extra-doc \
    texlive-latex-recommended-doc \
    texlive-metapost-doc \
    texlive-humanities-doc \
    texlive-pictures-doc \
    texlive-pstricks-doc \
    texlive-publishers-doc \
    texlive-science-doc \
  && \
  apt autoclean -y && \
  apt autoremove -y && \
  apt clean && \
  rm -Rf /var/lib/apt/lists/* && \
  rm -Rf /usr/share/doc && \
  rm -Rf /usr/share/man
RUN apt install --no-install-recommends -y \
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
    qrencode \
  && \
  apt purge -fy make-doc && \
  apt autoclean -y && \
  apt autoremove -y && \
  apt clean && \
  rm -Rf /var/lib/apt/lists/* && \
  rm -Rf /usr/share/doc && \
  rm -Rf /usr/share/man
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
