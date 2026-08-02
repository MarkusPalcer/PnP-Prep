.PHONY: all clean test doc

all: clean doc

clean:
	find . -type f \( \
		-name '*.aux' -o \
		-name '*.log' -o \
		-name '*.out' -o \
		-name '*.toc' -o \
		-name '*.synctex.gz' -o \
		-name '*.fls' -o \
		-name '*.fdb_latexmk' -o \
		-name '*.pdf' -o \
		-name '*.dvi' \
	\) -delete

doc:
	$(MAKE) doc/pnpprep/Readme.pdf

%.pdf: %.tex
	cd $(dir $<) && pdflatex -interaction=nonstopmode -halt-on-error $(notdir $<)