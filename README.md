makefiles
===============================================================================

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
variables and then build the relevant target.  The files on the form 
`miun.*.mk` have specific defaults for my colleagues at Mid Sweden University.


Dependencies and installation
-------------------------------------------------------------------------------

To use them, either download all files to a directory and then just run `sudo 
make install` in that directory.  That will install the files in 
/usr/local/include, where GNU make(1) will look for them.  Or, you can just 
download the relevant file to the working directory, then GNU make(1) will also 
be able to find it.  In the end of most of my own Makefile's I use the 
following lines:

```Makefile
tex.mk depend.mk:
    wget https://raw.githubusercontent.com/dbosk/makefiles/master/$@

include tex.mk
include depend.mk
```

The make(1) utility will then realise it must make those files, and hence it'll 
download them to the current working directory.  Then you can use the target 
`clean-depends` to clean them.

The dependencies for these files to work are the following programs:

	* GNU make(1),
	* pax(1),
	* wget(1),
	* latex(1),
	* pdflatex(1),
	* latexmk(1L), and
	* LibreOffice (this applies to miun.results.mk only).

Either you install these manually or they will be installed automatically when 
needed through the use of `depend.mk`.  You will need sudo(8) privileges to 
install them.
