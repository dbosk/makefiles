makefiles
===============================================================================

[![CircleCI](https://circleci.com/gh/dbosk/makefiles.svg?style=svg)](https://circleci.com/gh/dbosk/makefiles)

These are a set of generic makefiles for handling course material and research 
publications in an easy manner.  I started development during my first years as 
Lecturer in Mid Sweden University 
[[MIUN](http://apachepersonal.miun.se/~danbos/)], starting in 2011, and they 
were used there (and still are) by me and my colleagues.  I later added some 
more research-paper oriented features during my doctoral studies in KTH Royal 
Institute of Technology, Sweden [[KTH](http://www.csc.kth.se/~dbosk/)].

They are published here under an MIT license (see the LICENSE file).


Structure and usage
-------------------------------------------------------------------------------

The makefile structure is inspired by the BSD ports system.  My experience is 
with the OpenBSD [[OpenBSD](http://www.openbsd.org/faq/ports/ports.html)], so 
my inspiration is from their adaption.

Although I'm more fond of the BSD make(1) utility, these makefiles are for GNU 
make(1).  This is because most of my colleagues used GNU/Linux and it's easer 
to use gmake(1) on a BSD system than try to find _the_ BSD make(1) in a GNU 
system.

The usage is to include the relevant .mk-files in your Makefile, set the 
variables and then build the relevant target.  For example, add

```Makefile
INCLUDE_MAKEFILES=makefiles
include ${INCLUDE_MAKEFILES}/subdir.mk
include ${INCLUDE_MAKEFILES}/tex.mk
```

to the end of your `Makefile`.  More on this in the next section.

The files on the form `miun.*.mk` have the old defaults for my colleagues at 
Mid Sweden University.


Dependencies and installation
-------------------------------------------------------------------------------

There are three ways of using this makefile library.  The first and obvious one 
is to download the files you need, add them to the working directory and use 
them in your Makefile.  This can even be automated using make(1), by adding the 
following lines in the end of your Makefile:

```Makefile
INCLUDE_MAKEFILES?= .
INCLUDES=   depend.mk

define inc
ifeq ($(findstring $(1),${MAKEFILE_LIST}),)
$(1):
    wget https://raw.githubusercontent.com/dbosk/makefiles/master/$(1)
include ${INCLUDE_MAKEFILES}/$(1)
endif
endef
$(foreach i,${INCLUDES},$(eval $(call inc,$i)))
```

This will automatically download and include any files specified in the 
`INCLUDES` variable.  A more trivial code snippet, but with some minor 
drawbacks, is this:

```Makefile
tex.mk depend.mk:
    wget https://raw.githubusercontent.com/dbosk/makefiles/master/$@

include tex.mk
include depend.mk
```

The make(1) utility will then realise it must make those files, and hence it'll 
download them to the current working directory.  Then you can use the target 
`clean-depends` to clean them.


The second and better way to use this library is to use the repo as a (Git) 
submodule in your repository.  To do this you would first add the submodule: 
`git submodule add -b master https://github.com/dbosk/makefiles.git`.  Then you 
would add the following two lines to your Makefile:

```Makefile
INCLUDE_MAKEFILES=makefiles
include ${INCLUDE_MAKEFILES}/<name-of-file>.mk
```

Note that you need the variable `INCLUDE_MAKEFILES`.  This variable is used 
internally by the different .mk-files to find their respective dependencies 
from the part of the tree your Makefile resides.  E.g. tex.mk in turn includes 
depend.mk.

The third option is to install the makefiles globally on the system.  To do 
this, just run `sudo make install` in the root of the makefiles repo.  That 
will install the files into /usr/local/include, where GNU make(1) will look for 
them.

The dependencies for these files to work are the following programs:

 - GNU make(1),
 - pax(1),
 - wget(1),
 - unzip(1),
 - latex(1),
 - pdflatex(1),
 - latexmk(1L),
 - dia(1),
 - inkscape(1), and
 - LibreOffice.

Either you install these manually or they will be installed automatically when 
needed through the use of `depend.mk`.  You will need sudo(8) privileges to 
install them.


For Mac users
-------------------------------------------------------------------------------

Since Apple is using an old version of Info-ZIP's unzip(1) command in the OS 
X systems, you will be caused much grievance.  By default `depend.mk` uses 
`unzip -DD` to extract dependencies, this causes timestamps of the extracted 
files to be that of extraction instead of what is stored in the zip file.  The 
benefit of this is that the extracted files will be newer than the zip file, 
hence make(1) won't try to rebuild them.  In the old version of unzip(1) used 
by OS X, the `-DD` option doesn't exist.  As a consequence you'll be asked if 
you'd like to overwrite the extracted files --- every time you recompile.  So 
if you use a Mac, run make(1) as follows:

```
$ UNZIP=unzip make ...
```
