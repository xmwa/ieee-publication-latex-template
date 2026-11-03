# IEEE Transactions template: build and revision workflow.
#
#   make                  main.pdf, supplementary.pdf, response.pdf
#   make main | supp | response
#   make cleancopy        main-clean.pdf and supplementary-clean.pdf: camera-ready, all revision marks stripped
#   make letters          cover_letter.pdf and proof_response.pdf (not in `all`)
#   make measure          main-measure.pdf: clean copy with full-length photo biographies, to check the page budget
#   make preview          refresh preview/ (tracked in git, linked from the README): journal and conference paper, supplementary, all three letters
#   make snapshot         freeze the submitted version into submitted/ + submitted.zip
#   make snapshot ROUND=r1    ... into submitted_r1/ + submitted_r1.zip
#   make diff             diff.pdf and diff-supp.pdf: latexdiff of submitted/ against the current main.tex and supplementary.tex
#   make diff OLD=submitted_r1    ... against another snapshot
#   make clean            remove build artifacts (keeps PDFs)
#   make distclean        also remove the PDFs (never touches submitted*/ or zips)
#
# Everything builds from the project root; PDFs and aux files land here.
# main.tex reads supplementary.aux for its \ref{supp:...} references, so every main-paper build depends on `supp`. (latexmkrc does the same for plain latexmk and Overleaf.)

LATEXMK   ?= latexmk
LATEXDIFF ?= latexdiff
LMK        = $(LATEXMK) -pdf -interaction=nonstopmode -halt-on-error -file-line-error
CLEAN      = -usepretex='\def\CleanCopy{1}'

ROUND   ?=
SNAPDIR  = $(if $(ROUND),submitted_$(ROUND),submitted)
OLD     ?= submitted
SRCDIRS  = preamble sections tables supplementary figures bib

JOBS = main main-conference main-clean main-measure supplementary supplementary-clean response cover_letter proof_response diff diff-supp

.PHONY: all main supp response cleancopy letters measure preview snapshot diff clean distclean

all: main supp response

main: supp
	$(LMK) main.tex

supp:
	$(LMK) supplementary.tex

response:
	$(LMK) letters/response.tex

# The clean paper reads its \ref{supp:...} numbers from the marked supplementary.aux. They only differ if a \del{...} in the supplement removes a numbered item.
cleancopy: supp
	$(LMK) -jobname=main-clean $(CLEAN) main.tex
	$(LMK) -jobname=supplementary-clean $(CLEAN) supplementary.tex

letters:
	$(LMK) letters/cover_letter.tex
	$(LMK) letters/proof_response.tex

# Page-budget check: the clean copy (deleted text takes no room) with sections/biographies_measure.tex in place of the short placeholder bios. main.pdf is not touched.
measure: supp
	$(LMK) -jobname=main-measure -usepretex='\def\CleanCopy{1}\def\MeasureBios{1}' main.tex
	@grep -o 'Output written on main-measure.pdf ([0-9]* pages*' main-measure.log | sed 's/.*(/main-measure.pdf: /'

# The template's own preview PDFs, committed so GitHub visitors can see the output. Root PDFs stay git-ignored; only this copy is tracked. Rerun after changing the template. The paper is built in both modes regardless of preamble/venue.tex.
preview: supp response letters
	$(LMK) -usepretex='\def\PaperMode{journal}' main.tex
	$(LMK) -jobname=main-conference -usepretex='\def\PaperMode{conference}' main.tex
	mkdir -p preview
	cp main.pdf main-conference.pdf supplementary.pdf response.pdf cover_letter.pdf proof_response.pdf preview/

# A self-contained bundle of what was submitted. The .bbl files go in because submission systems compile the uploaded source but never run BibTeX, and because `make diff` needs the old bibliography to diff against. supplementary.aux goes in for the same reason: main.tex reads its \ref{supp:...} numbers from it. Refuses to overwrite an existing snapshot: it is the baseline for `make diff`.
snapshot: main supp
	@if [ -e "$(SNAPDIR)" ]; then \
	  echo "$(SNAPDIR)/ already exists. Remove it first or pick another ROUND=."; \
	  exit 1; \
	fi
	mkdir -p $(SNAPDIR)
	cp main.tex supplementary.tex latexmkrc main.bbl supplementary.bbl supplementary.aux $(SNAPDIR)/
	cp -R $(SRCDIRS) $(SNAPDIR)/
	rm -f $(SNAPDIR).zip
	cd $(SNAPDIR) && zip -rq ../$(SNAPDIR).zip . -x '.*' '*/.*'
	@echo "Snapshot: $(SNAPDIR)/ and $(SNAPDIR).zip"

# --flatten inlines every \input (resolved relative to each entry file) and the .bbl, so edits inside sections/ and supplementary/ show up in the diff PDFs.
diff: main supp
	@if [ ! -f "$(OLD)/main.tex" ]; then \
	  echo "No $(OLD)/main.tex. Run 'make snapshot' when you submit."; \
	  exit 1; \
	fi
	$(LATEXDIFF) --flatten $(OLD)/main.tex main.tex > diff.tex
	$(LMK) diff.tex
	$(LATEXDIFF) --flatten $(OLD)/supplementary.tex supplementary.tex > diff-supp.tex
	$(LMK) diff-supp.tex

clean:
	rm -f *.aux *.bbl *.blg *.fdb_latexmk *.fls *.log *.out *.synctex.gz \
	      *.toc *.lof *.lot *.run.xml *.bcf diff.tex diff-supp.tex

distclean: clean
	rm -f $(addsuffix .pdf,$(JOBS))
