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

% Colors

% Pergamentfarben
\definecolor{PergamentHell}{RGB}{245,238,220}
\definecolor{PergamentDunkel}{RGB}{173,140,82}

% Question/true-false block support.
\definecolor{questionblue}{RGB}{220,235,250}
\definecolor{resultgreen}{RGB}{220,245,220}
\definecolor{resultred}{RGB}{250,220,220}

% Frame support for Meisterinformation blocks.
\newtcolorbox{gm}{
  enhanced,
  breakable,
  colback=white,
  colframe=black,
  boxrule=0pt,
  leftrule=1.5pt,
  rightrule=0pt,
  toprule=0pt,
  bottomrule=0pt,
  left=0.8em,
  right=0.8em,
  top=0.5em,
  bottom=0.5em,
  before skip=\medskipamount,
  after skip=\medskipamount
}

\newcommand{\gmnote}[1]{%
  \begin{gm}
    #1
  \end{gm}
}

\newcommand{\decide}[3]{%
  \begin{decision}
    \begin{condition}#1\end{condition}
    \begin{true}#2\end{true}
    \begin{false}#3\end{false}
  \end{decision}
}



% Music note command: centered boxed note with padding and margin after

\newtcolorbox{musicbox}{colback=gray!10,boxrule=0pt,sharp corners,
  left=5mm,right=5mm,top=5mm,bottom=5mm,boxsep=0pt,halign=center,valign=center}
\newcommand{\music}[1]{%
  \par
  \begin{center}%
    \begin{musicbox}%
      {\large ♪\quad #1 \quad \large ♪}%
    \end{musicbox}%
  \end{center}%
  \vspace{5mm}%
}

\newcommand{\todo}[1]{%
\leavevmode  
\par\medskip
  \begin{tcolorbox}[colback=yellow,colframe=black,boxrule=0.5pt,sharp corners,left=4pt,right=4pt,top=4pt,bottom=4pt]
    #1
  \end{tcolorbox}
  \par\medskip
}

\makeatletter

\newcounter{decisioncount}

\newif\if@indecision
\@indecisionfalse

\newcommand\decisionerror[1]{%
  \PackageError{pnpprep}{#1}{The environment must be used inside a decision environment.}}



\newenvironment{decision}{%
  \refstepcounter{decisioncount}%
  \edef\currentdecisiongroup{questionresult\thedecisioncount}%
  \@indecisiontrue
  \par\medskip
  \nopagebreak
  \noindent
  \begin{minipage}{\linewidth}
  \hbadness=10000
  \ignorespaces
}{%
  \end{minipage}
  \par\medskip
  \@indecisionfalse
}

\newenvironment{condition}{%
  \if@indecision
  \else
    \decisionerror{\string\begin{condition} used outside of a decision}
  \fi
  \begin{tcolorbox}[colback=questionblue,colframe=black,boxrule=0.5pt,sharp corners,
      left=4pt,right=4pt,top=4pt,bottom=4pt,before skip=0pt,after skip=0pt]
    \bfseries\ignorespaces
}{%
  \end{tcolorbox}
}

\newenvironment{true}{%
  \if@indecision
  \else
    \decisionerror{\string\begin{true} used outside of a decision}
  \fi
  \begingroup
  \begin{minipage}[t]{0.48\linewidth}%
  \begin{tcolorbox}[colback=resultgreen,colframe=black,boxrule=0.5pt,sharp corners,
      left=4pt,right=4pt,top=4pt,bottom=4pt,equal height group=\currentdecisiongroup]
    \ignorespaces
}{%
  \end{tcolorbox}%
  \end{minipage}%
  \hfill%
  \endgroup
  \ignorespacesafterend
}

\newenvironment{longtrue}{%
  \par\medskip
\begin{tcolorbox}[colback=resultgreen,colframe=black,boxrule=0.5pt,sharp corners,
      left=4pt,right=4pt,top=4pt,bottom=4pt]
    \ignorespaces
}{%
  \end{tcolorbox}%
  \par\medskip
}

\newenvironment{false}{%
  \if@indecision
  \else
    \decisionerror{\string\begin{false} used outside of a decision}
  \fi
  \hfill%
  \begingroup
  \begin{minipage}[t]{0.48\linewidth}%
  \begin{tcolorbox}[colback=resultred,colframe=black,boxrule=0.5pt,sharp corners,
      left=4pt,right=4pt,top=4pt,bottom=4pt,equal height group=\currentdecisiongroup]
    \ignorespaces
}{%
  \end{tcolorbox}%
  \end{minipage}%
  \endgroup
}

\newenvironment{longfalse}{%
  \par\medskip
\begin{tcolorbox}[colback=resultred,colframe=black,boxrule=0.5pt,sharp corners,
      left=4pt,right=4pt,top=4pt,bottom=4pt]
    \ignorespaces
}{%
  \end{tcolorbox}%
  \par\medskip
}


\makeatother

% `speech` environment: italic text, preserve source line breaks, non-monospace
\DefineVerbatimEnvironment{speech}{Verbatim}{%
  formatcom=\itshape\rmfamily,
  fontsize=\normalsize,
  baselinestretch=1
}


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

% Flexible Box
\makeatletter
\NewDocumentEnvironment{FlexibleBox}{m O{PergamentHell} O{PergamentDunkel} O{white}}
{%
  \if@nobreak
    \everypar{}%
  \fi
  \par
  \begin{tcolorbox}[
    width=\linewidth,
    colback=#2,
    colframe=#3,
    coltitle=#4,
    colbacktitle=#3,
    fonttitle=\bfseries,
    title=#1,
    boxrule=0.5pt,
    arc=2mm,
    left=2mm,
    right=2mm,
    top=1mm,
    bottom=1mm
  ]
}
{%
  \end{tcolorbox}
  \par
}
\makeatother

% Sammelprobe-Makro
\NewDocumentCommand{\sammelprobe}{m m o}{%
\begin{FlexibleBox}{Sammelprobe}

\begin{center}
\footnotesize\itshape
3 TaW* = 1 QS; 10 QS Nötig; Teilerfolg bei 6 QS
\end{center}

\noindent\textbf{Talent(e):} #1

\medskip

\noindent\textbf{Dauer pro Versuch:} #2

\IfValueT{#3}{%
    \medskip
    \noindent\textbf{Ziel:} #3
}

\end{FlexibleBox}
}

% Wertekasten für Gegner
\NewDocumentEnvironment{Wertekasten}{m}
{%
\begin{FlexibleBox}{#1}

\NewDocumentCommand{\wert}{m m}{%
    \textbf{##1:}\hspace{1em}##2\hspace{2em}%
}

\NewDocumentCommand{\waffe}{m m m m m}{%
    \textbf{##1:}\hspace{1em}%
    \wert{AT}{##2}%
    \wert{PA}{##3}%
    \wert{TP}{##4}%
    \wert{INI}{##5}%
    \\%
}

\NewDocumentCommand{\ruestung}{m m}{%
    \wert{Rüstung}{##1}%
    \wert{RS}{##2}%
    \\%
}
}
{%
\end{FlexibleBox}
}