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
		-name '*.dvi' -o \
		-name '*.toc' \
	\) -delete

doc:
	$(MAKE) doc/pnpprep/Readme.pdf
	$(MAKE) doc/pnpprep/dsa/Readme.pdf

TEST_TEX := $(shell find ./test -type f -name '*.tex')
TEST_PDF := $(TEST_TEX:.tex=.pdf)

test: $(TEST_PDF)

%.pdf: %.tex
	cd $(dir $<) && pdflatex -interaction=nonstopmode -halt-on-error $(notdir $<)
	cd $(dir $<) && pdflatex -interaction=nonstopmode -halt-on-error $(notdir $<)