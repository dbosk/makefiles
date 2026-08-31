add_cus_dep( 'nlo', 'nls', 0, 'makenlo2nls' );
sub makenlo2nls {
        system( "makeindex -s nomencl.ist -o \"$_[0].nls\" \"$_[0].nlo\"" );
}
# Run pythontex(1) whenever the .pytxcode file changes, before the next
# latex(1) run.  Adapted from the pythontex-latexmkrc example on CTAN,
# without its symlink "fudge" for $out_dir: recent latexmk finds custom
# dependencies in the output directory by itself, and the fudge made it
# register a second, root-anchored rule that ran pythontex in the wrong
# directory.
add_cus_dep('pytxcode', 'pytxmcr', 0, 'pythontex');
sub pythontex {
    # From latexmk's point of view this makes the document depend on the
    # .pytxcode file; the rule is used for its side effect of creating
    # the .pytxmcr file and PythonTeX's other output files.
    my $pythontex = $ENV{PYTHONTEX} || 'python3 $(which pythontex)';
    my $pythontexflags = $ENV{PYTHONTEXFLAGS} // '--interpreter python:python3';
    return system("$pythontex $pythontexflags --verbose \"$_[0]\"");
}
