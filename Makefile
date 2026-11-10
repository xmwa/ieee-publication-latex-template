# IEEE Transactions template: build and revision workflow.
#
#   make                  main.pdf, supplementary.pdf, response.pdf
#   make main | supp | response
#   make marked           main-marked.pdf and supplementary-marked.pdf: revision marks shown (blue/red text, margin tags), for the reviewers
#   make letters          cover_letter.pdf and proof_response.pdf (not in `all`)
#   make preview          refresh preview/ (tracked in git, linked from the README): journal, marked, and conference paper, supplementary, all three letters
#   make snapshot         freeze the submitted version into submitted/ + submitted.zip
#   make snapshot ROUND=r1    ... into submitted_r1/ + submitted_r1.zip
#   make diff             diff.pdf and diff-supp.pdf: latexdiff of submitted/ against the current main.tex and supplementary.tex
#   make diff OLD=submitted_r1    ... against another snapshot
#   make clean            remove build artifacts (keeps PDFs)
#   make distclean        also remove the PDFs (never touches submitted*/ or zips)
#
# Everything builds from the project root; PDFs and aux files land here. The default build is the clean copy: no revision marks, so main.pdf is what you submit and what the page limit is checked against.
# main.tex reads supplementary.aux for its \ref{supp:...} references, so every main-paper build depends on `supp`. (latexmkrc does the same for plain latexmk and Overleaf.)

LATEXMK   ?= latexmk
LATEXDIFF ?= latexdiff
LMK        = $(LATEXMK) -pdf -interaction=nonstopmode -halt-on-error -file-line-error
MARKED     = -usepretex='\def\CleanCopy{0}'

ROUND   ?=
SNAPDIR  = $(if $(ROUND),submitted_$(ROUND),submitted)
OLD     ?= submitted
SRCDIRS  = preamble authors sections tables supplementary figures bib

JOBS = main main-conference main-marked supplementary supplementary-marked response cover_letter proof_response diff diff-supp

.PHONY: all main supp response marked letters preview snapshot diff clean distclean

all: main supp response

main: supp
	$(LMK) main.tex

supp:
	$(LMK) supplementary.tex

response:
	$(LMK) letters/response.tex

# The marked paper reads its \ref{supp:...} numbers from the clean supplementary.aux. They only differ if a \del{...} in the supplement removes a numbered item.
marked: supp
	$(LMK) -jobname=main-marked $(MARKED) main.tex
	$(LMK) -jobname=supplementary-marked $(MARKED) supplementary.tex

letters:
	$(LMK) letters/cover_letter.tex
	$(LMK) letters/proof_response.tex

# The template's own preview PDFs, committed so GitHub visitors can see the output. Root PDFs stay git-ignored; only this copy is tracked. Rerun after changing the template. The paper is built in both modes regardless of preamble/venue.tex.
preview: supp response letters
	$(LMK) -usepretex='\def\PaperMode{journal}' main.tex
	$(LMK) -jobname=main-marked -usepretex='\def\PaperMode{journal}\def\CleanCopy{0}' main.tex
	$(LMK) -jobname=main-conference -usepretex='\def\PaperMode{conference}' main.tex
	mkdir -p preview
	cp main.pdf main-marked.pdf main-conference.pdf supplementary.pdf response.pdf cover_letter.pdf proof_response.pdf preview/

# A self-contained bundle of what was submitted. The .bbl files go in because submission systems compile the uploaded source but never run BibTeX, and because `make diff` needs the old bibliography to diff against. supplementary.aux goes in for the same reason: main.tex reads its \ref{supp:...} numbers from it. cp -L copies the files behind a linked folder (e.g. authors/ shared between papers), not the link. Refuses to overwrite an existing snapshot: it is the baseline for `make diff`.
snapshot: main supp
	@if [ -e "$(SNAPDIR)" ]; then \
	  echo "$(SNAPDIR)/ already exists. Remove it first or pick another ROUND=."; \
	  exit 1; \
	fi
	mkdir -p $(SNAPDIR)
	cp main.tex supplementary.tex latexmkrc main.bbl supplementary.bbl supplementary.aux $(SNAPDIR)/
	cp -RL $(SRCDIRS) $(SNAPDIR)/
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
