% pnpprep.cls: custom class based on the standard report class
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{pnpprep}[2026/05/21 Custom report-based class]

% Pass all unknown options to the base report class.
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{report}}
\ExecuteOptions{a4paper}
\ProcessOptions\relax

% Load the standard report class.
\LoadClass{report}

% Paragraph spacing: no indent, small vertical gap between paragraphs
\setlength{\parindent}{0pt}
\setlength{\parskip}{0.5\baselineskip}

% Remove page numbers from every page.
\makeatletter
\def\ps@empty{%
  \let\@oddhead\@empty
  \let\@evenhead\@empty
  \let\@oddfoot\@empty
  \let\@evenfoot\@empty}
\let\ps@plain\ps@empty
\pagestyle{empty}
\makeatother

% Required Packages
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage[ngerman]{babel}
\RequirePackage{framed}
\RequirePackage[dvipsnames]{xcolor}
\RequirePackage[most]{tcolorbox}
\RequirePackage{fancyvrb}
\RequirePackage{xparse}
\RequirePackage{geometry}

\RequirePackage{pnp-flexiblebox}
\RequirePackage{pnp-gm}
\RequirePackage{pnp-speech}
\RequirePackage{pnp-music}
\RequirePackage{pnp-todo}
\RequirePackage{pnp-decision}
\RequirePackage{pnp-sammelprobe}
\RequirePackage{pnp-wertekasten}
\RequirePackage{pnp-databox}

% Seitenränder
\geometry{
    left=2cm,
    right=2cm,
    top=2cm,
    bottom=2cm
}

% Abstand nach \paragraph
\makeatletter
\renewcommand\paragraph{\@startsection{paragraph}{4}{\z@}%
  {-3.25ex\@plus -1ex \@minus -.2ex}%
  {1.5ex \@plus .2ex}%
  {\normalfont\normalsize\bfseries}}
\makeatother

% Make chapters print only the title, not the chapter number.
\makeatletter
\renewcommand\chaptermark[1]{%
  \markboth{\MakeUppercase{#1}}{}}
\def\@chapter[#1]#2{% 
  \refstepcounter{chapter}%
  \clearpage
  \ifodd\c@page\else
    \hbox{}\thispagestyle{empty}\newpage
  \fi
  \addcontentsline{toc}{chapter}{#1}%
  \chaptermark{#1}%
  \addtocontents{lof}{\protect\addvspace{10\p@}}%
  \addtocontents{lot}{\protect\addvspace{10\p@}}%
  \if@twocolumn
    \@topnewpage[\@makechapterhead{#2}]%
  \else
    \@makechapterhead{#2}%
    \@afterheading
  \fi}
\def\@makechapterhead#1{%
  \vspace*{50\p@}%
  {\parindent \z@ \raggedright \normalfont
    \interlinepenalty\@M
    \Huge \bfseries #1\par\nobreak
    \vskip 40\p@}}
\makeatother