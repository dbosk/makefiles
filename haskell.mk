LD=   ghc
.SUFFIXES: .hs .lhs
.hs.o .lhs.o:
	ghc ${HSFLAGS} -c $<
