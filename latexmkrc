# latexmkrc: read by latexmk from the project root, locally and on Overleaf.
# main.tex reads supplementary.aux for its \ref{supp:...} references (preamble/xref.tex). When that .aux is missing or older than supplementary.tex, this rule compiles the supplement first. The name check stops a document from rebuilding itself.
add_cus_dep('tex', 'aux', 0, 'makeexternaldocument');
sub makeexternaldocument {
    if ($root_filename ne $_[0]) {
        return system("latexmk -pdf -interaction=nonstopmode -halt-on-error \"$_[0]\"");
    }
    return 0;
}
