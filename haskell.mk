.SUFFIXES: .hs
.hs.o:
	ghc -c $<
