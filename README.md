# IEEE Publication LaTeX Template

A LaTeX project for IEEE journal and conference papers built on `IEEEtran`, with the parts that usually get improvised at the last minute already in place: S-numbered supplementary material that the paper references by label, one record per author (bio and photo included), a clean/marked revision switch, a double-anonymous review switch, latexdiff, a realistic page count from the first build, and the letters you need at submission, revision, and proof stage.

![Close-ups of the journal and conference author blocks, revision marks, response letter, and S-numbered supplementary](preview/overview.png)

**Preview:** [journal paper](preview/main.pdf) · [with revision marks](preview/main-marked.pdf) · [anonymous review copy](preview/main-anon.pdf) · [conference paper](preview/main-conference.pdf) · [supplementary](preview/supplementary.pdf) · [response to reviewers](preview/response.pdf) · [cover letter](preview/cover_letter.pdf) · [proof response](preview/proof_response.pdf)

Built from the one-prompt setup described in [One Prompt, One Complete IEEE Transactions Project With Claude Code](https://blog.wangxm.com/2026/07/ieee-transactions-project-claude-code-one-prompt/), extended with a journal/conference switch.

## Quick start

```sh
make              # main.pdf, supplementary.pdf, response.pdf
make preview      # refresh the PDFs in preview/
```

Then edit `preamble/authors.tex` (title, authors, venue) and the files in `sections/`. On Overleaf, upload the project and compile `main.tex`; see [Overleaf](#overleaf).

## Journal or conference

The venue type is one word in `preamble/venue.tex`:

```latex
\providecommand{\PaperMode}{journal}   % journal | conference
```

`main.tex` and `supplementary.tex` both read it (`\documentclass[\PaperMode]{IEEEtran}`), so one edit switches the whole project. What changes:

| | `journal` (default) | `conference` |
| --- | --- | --- |
| Author block | one line with IEEE memberships, plus footnotes for dates, funding, and affiliations | side-by-side name/affiliation blocks, no footnotes |
| Funding | footnote on page 1 | write it in the Acknowledgment |
| Code/data link (`\PaperDataURL`) | last footnote on page 1 | not printed; put it in the text |
| Running header, page numbers, drop cap | yes | none (IEEEtran drops them) |
| Biographies | at the end of the paper | none |
| Copyright notice | added by IEEE | optional `\IEEEpubid` line, commented in `main.tex` |

The letters don't change with the mode. `response.tex` works as a journal response or a conference rebuttal. `cover_letter.tex` and `proof_response.tex` are journal-stage documents.

## Project map

```
.
├── main.tex                  # paper entry point: preamble, then \input of each section
├── supplementary.tex         # supplementary entry point: S-numbered (S-I, Fig. S1, Eq. (S1), Table S-I)
├── latexmkrc                 # builds the supplement before main.tex when its .aux is missing (also on Overleaf)
├── preamble/
│   ├── venue.tex             # journal | conference switch and the double-anonymous switch (loaded before \documentclass)
│   ├── authors.tex           # title, venue name, data URL; picks the authors and their order; author block, header
│   ├── revision.tex          # \rev \del \todo \resp and the marked/clean switch
│   └── xref.tex              # \ref{supp:...} from the paper into the supplement (xr-hyper)
├── sections/                 # main paper body, one file per section
│   ├── 01_introduction.tex
│   ├── 02_related_work.tex
│   ├── 03_method.tex
│   ├── 04_experiments.tex    # setup + results, inputs tables/tab_example.tex
│   ├── 05_discussion.tex
│   ├── 06_conclusion.tex
│   └── biographies.tex       # journal only: \AuthorBio for each author
├── supplementary/            # supplementary body: S1_derivations, S2_experiments, tab_ablation
├── tables/                   # main-paper tables, one file per table, caption above
├── authors/                  # one record per author (details, bio, photo) and the headshots
│   ├── authorinfo.sty        # \DefineAuthor, \AuthorSlot, \AuthorField, \AuthorBio
│   └── first_author.tex ...  # placeholder records
├── figures/                  # figures for both documents
├── bib/refs.bib              # one bibliography for both documents
├── letters/
│   ├── response.tex          # point-by-point response to reviewers
│   ├── cover_letter.tex      # submission cover letter (journal)
│   └── proof_response.tex    # galley-proof author-query reply (journal)
├── preview/                  # committed preview PDFs (make preview) and the README image
└── Makefile
```

## Make targets

All commands run from the project root, and every PDF lands in the root.

| Command | Output |
| --- | --- |
| `make` | `main.pdf`, `supplementary.pdf`, `response.pdf` |
| `make main` / `make supp` / `make response` | one of the above |
| `make marked` | `main-marked.pdf` and `supplementary-marked.pdf`, with revision marks and margin tags shown |
| `make anon` | `main-anon.pdf`, `supplementary-anon.pdf`, `response-anon.pdf`: double-anonymous review copies (see [Double-anonymous review](#double-anonymous-review)) |
| `make letters` | `cover_letter.pdf`, `proof_response.pdf` |
| `make preview` | refreshes `preview/`: journal, marked, anonymous, and conference paper, supplementary, all three letters |
| `make snapshot [ROUND=r1]` | `submitted/` (or `submitted_r1/`) plus a zip ready to upload, including the `.bbl` files, `supplementary.aux`, and the files behind a linked `authors/` |
| `make diff [OLD=submitted_r1]` | `diff.pdf` and `diff-supp.pdf`, latexdiff of the snapshot against the current sources |
| `make clean` / `make distclean` | remove build files / also remove the root PDFs |

Plain `make` builds the clean copy: no revision marks, so `main.pdf` is what you submit and what the page limit applies to. Every main-paper target builds the supplement first, because the paper reads its `\ref{supp:...}` numbers from `supplementary.aux`. `distclean` never touches `submitted*/` or `preview/`. `make snapshot` refuses to overwrite an existing snapshot.

Requirements: a TeX distribution with `pdflatex`, `latexmk`, `bibtex`, and the `IEEEtran`, `orcidlink`, `ulem`, `marginnote`, and `hyperref` (for `xr-hyper`) packages (all in TeX Live; on TinyTeX, `tlmgr install` anything missing, typically including `courier`, the typewriter font for `\texttt` and URLs). `latexdiff` for `make diff`, and `make` and `zip` for the Makefile.

## Revision workflow

1. The day you submit, run `make snapshot`. It copies the sources plus the compiled `.bbl` files and `supplementary.aux` into `submitted/` and zips them. Both matter: submission systems compile your source but don't run BibTeX, and `main.tex` reads its supplementary numbers from that `.aux`.
2. When the reviews come back, edit freely. Wrap changes in `\rev{...}` (blue), `\del{...}` (red strikeout), or `\resp{R1.2}{...}`, which also puts the comment tag R1.2 in the margin. Leave notes for co-authors with `\todo{...}`.
3. `make marked` gives the marked-up manuscript, `make diff` the latexdiff PDFs, and `make response` the response letter, where `\reviewer{1}` and the `rcomment`/`answer` environments number comments 1.1, 1.2, and so on to match the margin tags.
4. Before resubmitting, `make snapshot ROUND=r1` freezes that round too.
5. Plain `make` always gives the clean paper and supplementary with all marks removed, so the resubmitted and camera-ready versions need no source edits. Delete the `\rev`/`\del`/`\resp` wrappers whenever you like; they print nothing extra in the clean copy.

The switch itself is a line at the top of `main.tex` and `supplementary.tex`:

```latex
\ifdefined\CleanCopy\else\def\CleanCopy{1}\fi   % 1 = clean (default), 0 = marked
```

A value given on the command line wins (`make marked`, or `latexmk -pdf -usepretex="\def\CleanCopy{0}" main.tex`), so you only edit the line on Overleaf.

## Referring to the supplement

Never type "Table S-III" by hand. Label things in `supplementary/` as usual (`\label{tab:ablation}`) and refer to them from the paper with the `supp:` prefix:

```latex
see Table~\ref{supp:tab:ablation} and Eq.~\eqref{supp:eq:estimator}
```

`preamble/xref.tex` loads `xr-hyper`, which reads the numbers from `supplementary.aux`. That file has to exist when `main.tex` compiles. `make` builds the supplement first, `latexmkrc` does the same for plain `latexmk` and Overleaf when the `.aux` is missing or `supplementary.tex` changed, and `make snapshot` puts the `.aux` in the submission bundle. One gap: plain `latexmk` doesn't notice edits made only inside `supplementary/`, so after changing those, run `make` or compile `supplementary.tex` once before `main.tex`.

The supplement has its own bibliography. If it cites nothing, or your venue wants all references in the main paper, delete the two bibliography lines at the end of `supplementary.tex` (an empty bibliography is a compile error) and cite in plain text there. For a long supplement, uncomment `{\small\tableofcontents}` after `\maketitle`; the table of contents is already widened for numbers like S-VIII.

## Authors

Every author has one record in `authors/` with their name, IEEE grade, ORCID, affiliation, e-mail, photo, and biography:

```latex
\DefineAuthor{first}{
  name   = First~A.~Author,
  member = {Member,~IEEE},          % braces around a value with a comma; {} for no IEEE grade
  orcid  = 0000-0000-0000-0000,
  ...
  photo  = authors/first_author.jpg, % 1in x 1.25in; leave empty for a placeholder box
  bio    = {received the B.S. degree ...},
}
```

`preamble/authors.tex` loads the records and picks the order with `\AuthorSlot{A}{first}`, which defines the `\AuthorA`, `\AuthorAOrcid`, `\AuthorADept`, ... macros that the journal and conference author blocks and the letters use. `sections/biographies.tex` is one `\AuthorBio{key}` per author.

The placeholder records ship with full-length (about 110-word) bios and photo-sized boxes, so `main.pdf` already has a realistic page count. Many IEEE venues set a page limit that includes references and biographies and charge for every page beyond it, so check that count against the venue's limit as you write. A biography with a photo doesn't break across columns, so the count moves in steps: trimming a few lines may change nothing until a whole biography fits in the column above.

**Writing several papers?** Keep one `authors/` folder for all of them and replace each paper's folder with a link to it (`ln -s ../authors authors`), so an affiliation or bio is updated once. Overleaf and submission systems can't follow links, so upload real files there; `make snapshot` copies the files behind the link into the bundle. Don't put real records in a public repository.

## Double-anonymous review

Some IEEE journals (TETCI, for example) and many conferences review double-anonymously: the PDF the reviewers get must not identify the authors. One line in `preamble/venue.tex` switches the whole project:

```latex
\providecommand{\Anonymous}{0}   % 0 | 1
```

With `1`, every build of `main.tex` and `supplementary.tex` (including `make marked` and `make diff`) is anonymous, and nothing in the source has to be deleted: the author records, the Acknowledgment, and the biographies are still there for the final version. `make anon` builds anonymous copies (`main-anon.pdf`, `supplementary-anon.pdf`, `response-anon.pdf`) without touching the switch. For an anonymous marked copy without editing the switch: `latexmk -pdf -usepretex='\def\Anonymous{1}\def\CleanCopy{0}' main.tex`.

What anonymous mode hides:

- the author block: one line, "Anonymous Authors", with no affiliations, ORCID iDs, IEEE grades, or e-mail addresses (journal and conference layouts);
- every first-page footnote: received/revised dates, funding and grant numbers, corresponding author, affiliations, and the `\PaperDataURL` link;
- the Acknowledgment and the biographies;
- the running header, which shows only the short title instead of the venue line and "Author *et al.*";
- the PDF metadata: `pdfauthor` is empty (the template writes no XMP);
- in `letters/response.tex`, the author names, which become "Anonymous Authors" and "The Authors", since the response goes to the reviewers.

The cover letter goes to the editor only, so it keeps the names by default. If your venue wants it anonymous too, set `\CoverLetterAnonymous` to `1` near the top of `letters/cover_letter.tex`. The proof response is written after acceptance and is always named.

The template can't find identifying text you write yourself, so mark it:

```latex
\anon{In our earlier work~\cite{smith2024}}{In~\cite{smith2024}}, ...   % \anon{named text}{neutral text}
Code: \anonurl{https://github.com/your-lab/project}                      % "[link hidden for review]" when anonymous
```

`\anonurl` takes any URL, including `%`, `#`, and `_`, but like `\url` it can't go inside another command's argument.

### Before you submit an anonymous copy

1. Build with the switch on and read the first page: "Anonymous Authors", no footnotes, a header with only the short title.
2. Check the metadata: `pdfinfo main.pdf | grep -i author` must show an empty Author field (also for `supplementary.pdf`).
3. Search the sources for anything that gives you away. Fill in your own names, domain, institution, lab, and grant numbers:
   ```sh
   grep -rniE "surname1|surname2|@your-domain|your university|your lab|grant|our (earlier|previous|prior) work|we (previously|recently|earlier)" sections supplementary tables bib
   ```
   Cite your own papers in the third person ("Smith *et al.* [3] showed"), not "our earlier work [3]", or wrap the sentence in `\anon`.
4. Search the PDF text the same way: `pdftotext main.pdf - | grep -niE "..."` with the same pattern.
5. Check your figures: PDFs and images exported from plotting tools or Visio/draw.io can carry an author name in their own metadata (`pdfinfo figures/*.pdf`, `exiftool figures/*`). Look for names in figure text, axis labels, and file paths shown in screenshots too.
6. Upload the PDF, not the source. The source bundle from `make snapshot` still contains `authors/`, `preamble/authors.tex`, and the biographies.
7. For the final version, set the switch back to `0`.

## Overleaf

`main.tex` and `supplementary.tex` stay at the root on purpose: submission systems compile an entry file from its own folder, and every path here is written from the root. All paths are relative to the project root, so the project can be uploaded to Overleaf as is. `main.tex` is picked as the main document. To build the supplementary or a letter, change the main document in the Overleaf menu. Overleaf runs `latexmk`, and the project's `latexmkrc` follows Overleaf's documented setup for `xr` so the supplement compiles first and `\ref{supp:...}` resolves (tested with local `latexmk`, not yet on Overleaf itself; if the references show "??" there, compile `supplementary.tex` once, then `main.tex`). If you edited files in `supplementary/`, compile `supplementary.tex` once before `main.tex`.

Make targets don't run on Overleaf. For an anonymous copy there, set `\Anonymous` to `1` in `preamble/venue.tex`. The default build is the clean copy; for the marked copy, change `\def\CleanCopy{1}` to `0` in the line at the top of `main.tex` (and `supplementary.tex`). Snapshots and latexdiff are local-only.

## For AI agents

This section is for coding agents (Claude Code, Codex, Cursor, and so on) working in this repo. People editing by hand can follow it too.

### Rules

1. **Paper facts live only in `preamble/authors.tex`, author facts only in their record in `authors/`.** Never type a title, author name, affiliation, email, ORCID, venue name, or manuscript ID into `main.tex`, `supplementary.tex`, a section, or a letter. Use the macros (`\PaperTitle`, `\PaperVenue`, `\PaperManuscriptID`, `\PaperAuthorsPlain`, `\AuthorA`, `\AuthorAEmail`, ...).
2. **Every path is relative to the project root.** Write `\input{sections/03_method}` and `\input{preamble/authors}`, never `../`. Letters are compiled from the root (`latexmk -pdf letters/response.tex`), not from `letters/`.
3. **Entry files stay at the root.** Don't move `main.tex` or `supplementary.tex` into a folder.
4. **One file per section and per table.** Main-paper sections go in `sections/`, supplementary sections and tables in `supplementary/`, main-paper tables in `tables/`.
5. **No top-level `\ifCLASSOPTION...` in `preamble/authors.tex`.** The letters use the `article` class, where those conditionals don't exist; mode-dependent code goes inside a macro body.
6. **Keep it Overleaf-safe.** No `-shell-escape`, no `-outdir`, no packages outside TeX Live, no build step that only works through `make`.
7. **Don't delete or overwrite `submitted*/`.** Those snapshots are the baseline for `make diff`.
8. **Write one paragraph per line** in `.tex` files (no hard wrapping), including multi-line `%` comments.
9. **Only `preview/*.pdf` is tracked.** Root PDFs and build files are git-ignored; don't commit them.
10. **In a double-anonymous paper, route identifying text through `\anon{...}{...}` and `\anonurl{...}`.** Never add names, affiliations, grants, or links outside them, and keep `\Anonymous` in `preamble/venue.tex` as the only switch.
11. **Never hard-code a supplementary number in the paper.** Write `\ref{supp:<label>}`; labels inside `supplementary/` have no prefix. Don't write "Table S-II" or "Section S-I" by hand.

### Common tasks

- **Change title or venue:** edit the matching macro in `preamble/authors.tex`. **Change an author's details, bio, or photo:** edit their record in `authors/`. Every PDF picks it up.
- **Set or remove the code/data link:** `\PaperDataURL` in `preamble/authors.tex`. Journal mode prints it as the last first-page footnote; `\newcommand{\PaperDataURL}{}` drops the footnote. The URL must not contain `%` or `#`.
- **Add a fourth author:** copy a record to `authors/fourth_author.tex` and give it a new key (`\DefineAuthor{fourth}{...}`). In `preamble/authors.tex`, `\input{authors/fourth_author}` and add `\AuthorSlot{D}{fourth}`, then add the author to both branches of `\PaperAuthors` (conference: another `\and` + `\IEEEauthorblockN`/`\IEEEauthorblockA`; journal: the author line and a `\thanks`) and to `\PaperAuthorsPlain`. Add `\AuthorBio{fourth}` to `sections/biographies.tex`.
- **Prepare a double-anonymous submission:** set `\Anonymous` to `1` in `preamble/venue.tex`, wrap self-identifying text in `\anon`/`\anonurl`, rebuild, and run the checks in [Before you submit an anonymous copy](#before-you-submit-an-anonymous-copy).
- **Switch to conference:** change `journal` to `conference` in `preamble/venue.tex`. Move the funding sentence into the Acknowledgment in `main.tex`.
- **Add a section:** create `sections/0N_name.tex` starting with `\section{...}` and `\label{sec:name}`, then add `\input{sections/0N_name}` in `main.tex` in reading order. Renumber files if you insert one in the middle.
- **Add a table:** create `tables/tab_name.tex` with a `table` environment, caption above, `\label{tab:name}`, and `\input` it from the section that first refers to it.
- **Add a figure:** put the PDF/PNG in `figures/` and use `\includegraphics{name}` (no folder prefix needed). Caption below, `\label{fig:name}`.
- **Add a reference:** add the BibTeX entry to `bib/refs.bib` and `\cite{key}` it.
- **Add supplementary content:** create `supplementary/S3_name.tex` with `\section{...}` and `\label{sec:name}`, and `\input{supplementary/S3_name}` in `supplementary.tex`. Refer to it from the paper as `Section~\ref{supp:sec:name}`.
- **Check the page count against the venue limit:** `make`, then the page count of `main.pdf` (journal mode, with one record per real author).
- **Mark a revision for reviewer comment k of reviewer N:** wrap the new text in `\resp{RN.k}{...}` and answer it in `letters/response.tex` under `\reviewer{N}` (the k-th `rcomment`).

### Verify a change

1. Build: `make` (plus `make letters` if you touched `preamble/authors.tex` or `letters/`, and `make marked` if you touched `preamble/revision.tex`). A non-zero exit is a failure.
2. Check the logs: `grep -n "^!" *.log` must print nothing, and `grep "Warning" main.log` should not report undefined references or citations, or `xr` failing to find `supplementary.aux`.
3. Look at the output, not just the exit code. Render pages (`pdftoppm -r 80 -png main.pdf /tmp/page`) or open the PDF and check the change is there and nothing else moved.
4. If you changed anything that affects both venues, also build the conference version: `latexmk -pdf -jobname=main-conference -usepretex='\def\PaperMode{conference}' main.tex`.
5. If the template itself changed, run `make preview` so the committed previews match.

## Checklist before submitting

- Replace every `XXX`, the placeholder ORCID iDs, and the example `.bib` entries. Set `\PaperDataURL` or empty it.
- Delete the revision-markup demo paragraph in `sections/01_introduction.tex`.
- Check that the last page's columns are balanced. If they aren't, add `\usepackage{flushend}` or `\IEEEtriggeratref{n}` before the bibliography.
- Check the page count of `main.pdf` against the venue's limit, with a record (bio and photo) for every real author.
- Run `pdfinfo main.pdf` to make sure the PDF title, author, and keywords are right.
- Double-anonymous venue? Set `\Anonymous` to `1` in `preamble/venue.tex` and go through [Before you submit an anonymous copy](#before-you-submit-an-anonymous-copy). The anonymous copy has no biographies or acknowledgment, so it is shorter than the final paper; plan the page budget for the named version.
- Upload `supplementary.aux` with the source (the `make snapshot` zip has it), or the paper's supplementary references print as "??".

## License

[MIT](LICENSE), covering the template files. `IEEEtran.cls` is not included here; it comes with your TeX distribution under its own license (LPPL).
