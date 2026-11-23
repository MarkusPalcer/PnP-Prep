% pnpcards.cls: Class to create flash-card-like documents
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{pnpcards}[2026/10/06 Custom flash cards]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\LoadClass{article}
\RequirePackage[a6paper,landscape,margin=5mm,noheadfoot]{geometry}
\RequirePackage{environ}
\RequirePackage{graphicx}
\RequirePackage{xcolor}

\pagestyle{empty}
% Card areas are fixed-size boxes placed flush against the text area's top edge.
\setlength{\topskip}{0pt}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}

\newlength{\pnpcards@contentwidth}
\newlength{\pnpcards@cardtextwidth}
\newlength{\pnpcards@titleheight}
\newdimen\pnpcards@titleavailablewidth
\newdimen\pnpcards@titleboxheight
\newlength{\pnpcards@frontgap}
\newlength{\pnpcards@referencewidth}
\newlength{\pnpcards@titlewithreferencewidth}
\newlength{\pnpcards@frontcontenttopinset}
\newlength{\pnpcards@backcontenttopinset}
\newdimen\pnpcards@frontbodyheight
\newdimen\pnpcards@backbodyheight
\newcount\pnpcards@referencelines
\newcount\pnpcards@cardindex
\newcount\pnpcards@breakcount
\newif\ifpnpcards@debugframes
\pnpcards@debugframesfalse
\setlength{\pnpcards@contentwidth}{\textwidth}
\setlength{\pnpcards@titleheight}{15mm}
\setlength{\pnpcards@frontgap}{2mm}
\setlength{\pnpcards@referencewidth}{15mm}
\setlength{\pnpcards@titlewithreferencewidth}{%
    \dimexpr\pnpcards@contentwidth-\pnpcards@referencewidth-\pnpcards@frontgap\relax
}
% Keep the glyph bounds inside the front area despite the zero top skip.
\setlength{\pnpcards@frontcontenttopinset}{0.3mm}
% Align the visible first back line within 1 mm of the content area's top.
\setlength{\pnpcards@backcontenttopinset}{0.2mm}
\pnpcards@frontbodyheight=\dimexpr\textheight-\pnpcards@titleheight-\pnpcards@frontgap\relax
\pnpcards@backbodyheight=\textheight

\newcommand{\EnableCardDebugFrames}{\pnpcards@debugframestrue}

\newbox\pnpcards@cardcontent
\newbox\pnpcards@frontcontent
\newbox\pnpcards@backcontent
\newbox\pnpcards@splitinspection
\newbox\pnpcards@area
\newbox\pnpcards@referencebox
\newbox\pnpcards@referenceline
\newbox\pnpcards@referenceinspection
\newbox\pnpcards@titlebox
\newbox\pnpcards@minimumtitlebox
\newif\ifpnpcards@referencewide
\newif\ifpnpcards@hasreference
\newif\ifpnpcards@titleminimumwidthfailure
\newif\ifpnpcards@titleminimumheightfailure
\def\pnpcards@reference{}

\ExplSyntaxOn
\fp_new:N \l_pnpcards_title_width_scale_fp
\fp_new:N \l_pnpcards_title_height_scale_fp
\fp_new:N \l_pnpcards_title_scale_fp
\bool_new:N \l_pnpcards_title_overflow_bool

\cs_new_protected:Npn \pnpcards@IfBlank #1#2#3
    {
        \tl_set:Nn \l_tmpa_tl {#1}
        \tl_remove_all:Nn \l_tmpa_tl {\relax}
        \tl_if_blank:VTF \l_tmpa_tl {#2} {#3}
    }

\cs_new_protected:Npn \pnpcards@ScaleTitleBox
    {
        \pnpcards@titleboxheight=\dimexpr
            \ht\pnpcards@titlebox+\dp\pnpcards@titlebox
        \relax
        \pnpcards@CheckTitleMinimum
        \fp_set:Nn \l_pnpcards_title_width_scale_fp { 1000000000 }
        \fp_set:Nn \l_pnpcards_title_height_scale_fp { 1000000000 }
        \dim_compare:nNnT { \wd\pnpcards@titlebox } > { 0pt }
            {
                \fp_set:Nn \l_pnpcards_title_width_scale_fp
                    {
                        \dim_to_fp:n { \pnpcards@titleavailablewidth }
                        / \dim_to_fp:n { \wd\pnpcards@titlebox }
                    }
            }
        \dim_compare:nNnT { \pnpcards@titleboxheight } > { 0pt }
            {
                \fp_set:Nn \l_pnpcards_title_height_scale_fp
                    {
                        \dim_to_fp:n { \pnpcards@titleheight }
                        / \dim_to_fp:n { \pnpcards@titleboxheight }
                    }
            }
        \dim_compare:nNnTF { \wd\pnpcards@titlebox } = { 0pt }
            {
                \dim_compare:nNnTF { \pnpcards@titleboxheight } = { 0pt }
                    { \fp_set:Nn \l_pnpcards_title_scale_fp { 1 } }
                    { \fp_set_eq:NN \l_pnpcards_title_scale_fp \l_pnpcards_title_height_scale_fp }
            }
            {
                \fp_set:Nn \l_pnpcards_title_scale_fp
                    {
                        \fp_min:nn
                            { \l_pnpcards_title_width_scale_fp }
                            { \l_pnpcards_title_height_scale_fp }
                    }
            }
        \bool_set_true:N \l_pnpcards_title_overflow_bool
        \bool_while_do:Nn \l_pnpcards_title_overflow_bool
            {
                \edef\pnpcards@titlescalefactor
                    { \fp_eval:n { round(\l_pnpcards_title_scale_fp, 10) } }
                \fp_compare:nNnTF { \l_pnpcards_title_scale_fp } > { 16000 }
                    {
                        \edef\pnpcards@titleouterfactor
                            { \fp_eval:n { round(\l_pnpcards_title_scale_fp / 4096, 10) } }
                        \setbox\pnpcards@minimumtitlebox=\hbox{%
                            \scalebox{\pnpcards@titleouterfactor}{%
                                \scalebox{4096}{\copy\pnpcards@titlebox}%
                            }%
                        }%
                    }
                    {
                        \setbox\pnpcards@minimumtitlebox=\hbox{%
                            \scalebox{\pnpcards@titlescalefactor}{\copy\pnpcards@titlebox}%
                        }%
                    }
                \bool_set_false:N \l_pnpcards_title_overflow_bool
                \dim_compare:nNnT { \wd\pnpcards@minimumtitlebox } > { \pnpcards@titleavailablewidth }
                    { \bool_set_true:N \l_pnpcards_title_overflow_bool }
                \dim_compare:nNnT
                    { \ht\pnpcards@minimumtitlebox + \dp\pnpcards@minimumtitlebox }
                    > { \pnpcards@titleheight }
                    { \bool_set_true:N \l_pnpcards_title_overflow_bool }
                \bool_if:NT \l_pnpcards_title_overflow_bool
                    { \fp_sub:Nn \l_pnpcards_title_scale_fp { 1 / 65536 } }
            }
        \setbox\pnpcards@titlebox=\box\pnpcards@minimumtitlebox
    }
\ExplSyntaxOff

\newcommand{\pnpcards@SetReference}[1]{%
    \pnpcards@hasreferencefalse
    \def\pnpcards@reference{#1}%
    \begingroup
        \pnpcards@IfBlank{#1}%
            {\aftergroup\pnpcards@hasreferencefalse}%
            {\aftergroup\pnpcards@hasreferencetrue}%
    \endgroup
}

\newcommand{\pnpcards@CardExplicitBreak}{%
    \par
    \global\advance\pnpcards@breakcount by 1
    \mark{EXPLICIT-CARD-BREAK}%
    \penalty-10000%
}

\newcommand{\pnpcards@PageLimitError}{%
    \PackageError{pnpcards}%
        {Card \the\pnpcards@cardindex\space exceeds two-page limit\MessageBreak
         Title: \pnpcards@cardtitletext}%
        {Reduce the card content.}%
}

\newcommand{\pnpcards@CheckSplitHeight}[2]{%
    \setbox\pnpcards@splitinspection=\vbox to #2{\unvcopy#1}%
    \ifnum\badness>10000
        \pnpcards@PageLimitError
    \fi
}

\newcommand{\pnpcards@TitleMinimumError}[1]{%
    \PackageError{pnpcards}%
        {Card \the\pnpcards@cardindex: Title requires less than 7 pt\MessageBreak
         Cause: #1}%
        {Shorten the title or reduce its height so it fits at 7 pt or larger.}%
}

\newcommand{\pnpcards@CheckTitleMinimum}{%
    \pnpcards@titleminimumwidthfailurefalse
    \pnpcards@titleminimumheightfailurefalse
    \setbox\pnpcards@minimumtitlebox=\hbox{%
        \scalebox{0.7}{\copy\pnpcards@titlebox}%
    }%
    \ifdim\wd\pnpcards@titlebox>0pt
        \ifdim\wd\pnpcards@minimumtitlebox>\dimexpr\pnpcards@titleavailablewidth+1sp\relax
            \pnpcards@titleminimumwidthfailuretrue
        \fi
    \fi
    \ifdim\pnpcards@titleboxheight>0pt
        \ifdim\dimexpr\ht\pnpcards@minimumtitlebox+\dp\pnpcards@minimumtitlebox\relax
            >\dimexpr\pnpcards@titleheight+1sp\relax
            \pnpcards@titleminimumheightfailuretrue
        \fi
    \fi
    \ifpnpcards@titleminimumwidthfailure
        \ifpnpcards@titleminimumheightfailure
            \pnpcards@TitleMinimumError{horizontally and vertically}
        \else
            \pnpcards@TitleMinimumError{horizontally}
        \fi
    \else\ifpnpcards@titleminimumheightfailure
        \pnpcards@TitleMinimumError{vertically}
    \fi\fi
}

\newcommand{\pnpcards@FrameBox}[1]{%
    \fbox{%
        \hbox to \dimexpr\wd\pnpcards@area-2\fboxsep-2\fboxrule\relax{%
            \vrule width 0pt
                height \dimexpr\ht\pnpcards@area-\fboxsep-\fboxrule\relax
                depth #1\relax
            \hfil
        }%
    }%
}

\newcommand{\pnpcards@DrawAreaFrame}[2]{%
    \begingroup
        \setlength{\fboxsep}{0pt}%
        \color{#1}%
        \dimen@=\dimexpr\dp\pnpcards@area-\fboxrule\relax
        \smash{\rlap{%
            \ifdim#2=\pnpcards@backbodyheight
                % Keep the bottom edge fixed while lowering the back frame's top edge.
                \advance\dimen@ by -\fboxrule
                \lower\fboxrule\hbox{\pnpcards@FrameBox{\dimen@}}%
            \else
                \pnpcards@FrameBox{\dimen@}%
            \fi
        }}%
    \endgroup
}

\newcommand{\pnpcards@OutputArea}[1]{%
    \hbox to \wd\pnpcards@area{%
        \ifdim#1=\pnpcards@frontbodyheight
            \smash{\rlap{\lower\pnpcards@frontcontenttopinset\copy\pnpcards@area}}%
            \vrule width 0pt height \ht\pnpcards@area depth \dp\pnpcards@area
        \else\ifdim#1=\pnpcards@backbodyheight
            \smash{\rlap{\raise\pnpcards@backcontenttopinset\copy\pnpcards@area}}%
            \vrule width 0pt height \ht\pnpcards@area depth \dp\pnpcards@area
        \else
            \rlap{\copy\pnpcards@area}%
        \fi\fi
        \hss
    }%
}

\newcommand{\pnpcards@Area}[5]{%
    \setbox\pnpcards@area=\hbox to #1{%
        \begin{minipage}[#3][#2][#3]{#1}%
            #5
        \end{minipage}%
        \hss
    }%
    \ifpnpcards@debugframes
        \hbox to \wd\pnpcards@area{%
            \pnpcards@DrawAreaFrame{#4}{#2}%
            \pnpcards@OutputArea{#2}%
        }%
    \else
        \pnpcards@OutputArea{#2}%
    \fi
}

\newcommand{\pnpcards@PrepareReference}{%
    \global\pnpcards@referencelines=0
    \setbox\pnpcards@referencebox=\vbox{%
        \hsize=\pnpcards@referencewidth
        \linewidth=\pnpcards@referencewidth
        \parindent=0pt
        \parskip=0pt
        \fontsize{9}{11}\selectfont
        \raggedright
        \let\pnpcards@referencepar\par
        \def\par{%
            \pnpcards@referencepar
            \global\advance\pnpcards@referencelines by \prevgraf
        }%
        \noindent\pnpcards@reference\par
    }%
    \ifnum\pnpcards@referencelines>2
        \PackageError{pnpcards}%
            {Reference exceeds two lines}%
            {Shorten the reference so it fits on at most two lines.}%
    \fi
    \global\pnpcards@referencewidefalse
    \setbox\pnpcards@referenceinspection=\vbox{%
        \unvcopy\pnpcards@referencebox
        \count@=\pnpcards@referencelines
        \loop\ifnum\count@>0
            \unskip\unpenalty\unkern\unskip\unpenalty
            \setbox\pnpcards@referenceline=\lastbox
            \setbox\pnpcards@referenceline=\hbox{\unhbox\pnpcards@referenceline}%
            \ifdim\wd\pnpcards@referenceline>\pnpcards@referencewidth
                \global\pnpcards@referencewidetrue
            \fi
            \advance\count@ by -1
        \repeat
    }%
    \ifpnpcards@referencewide
        \PackageError{pnpcards}%
            {Reference does not fit horizontally}%
            {Shorten the unbreakable reference text so it fits within 15 mm.}%
    \fi
    \dimen@=\dimexpr\ht\pnpcards@referencebox+\dp\pnpcards@referencebox\relax
    \ifdim\dimen@>\pnpcards@titleheight
        \PackageError{pnpcards}%
            {Reference does not fit vertically}%
            {Reduce the reference height so it fits within 15 mm.}%
    \fi
}

\newcommand{\pnpcards@PrepareTitle}[1]{%
    \setbox\pnpcards@titlebox=\hbox{%
        \fontsize{10pt}{12pt}\selectfont\bfseries #1%
    }%
    \ifpnpcards@hasreference
        \pnpcards@titleavailablewidth=\pnpcards@titlewithreferencewidth
    \else
        \pnpcards@titleavailablewidth=\pnpcards@contentwidth
    \fi
    \pnpcards@ScaleTitleBox
}

\newcommand{\pnpcards@PrintFront}[2]{%
    \thispagestyle{empty}%
    \nointerlineskip
    \pnpcards@PrepareTitle{#1}%
    \ifpnpcards@hasreference
        \pnpcards@PrepareReference
    \fi
    \vbox to \pnpcards@titleheight{%
        \hbox to \textwidth{%
            \ifpnpcards@hasreference
                \pnpcards@Area{\pnpcards@titlewithreferencewidth}{\pnpcards@titleheight}{c}{red!75!black}{%
                    \vbox to \pnpcards@titleheight{\vfil\hbox{\copy\pnpcards@titlebox}\vfil}%
                }%
                \hskip\pnpcards@frontgap
                \pnpcards@Area{\pnpcards@referencewidth}{\pnpcards@titleheight}{c}{magenta!75!black}{%
                    \unvbox\pnpcards@referencebox
                }%
            \else
                \pnpcards@Area{\pnpcards@contentwidth}{\pnpcards@titleheight}{c}{red!75!black}{%
                    \vbox to \pnpcards@titleheight{\vfil\hbox{\copy\pnpcards@titlebox}\vfil}%
                }%
            \fi
        }%
        \vss
    }%
    \vskip\pnpcards@frontgap
    \nointerlineskip
    \hbox to \textwidth{%
        \pnpcards@Area{\pnpcards@contentwidth}{\pnpcards@frontbodyheight}{t}{blue!75!black}{%
            \unvbox#2
        }%
    }%
    \newpage
}

\newcommand{\pnpcards@PrintBack}[1]{%
    \thispagestyle{empty}%
    \nointerlineskip
    \hbox to \textwidth{%
        \pnpcards@Area{\pnpcards@contentwidth}{\pnpcards@backbodyheight}{t}{green!50!black}{%
            \unvbox#1
        }%
    }%
    \newpage
}

% Public card environment.
% Usage: \begin{card}[Referenz]{Titel} ... \end{card}
%   #1 (optional) = short reference shown top-right on the front (e.g. "WdZ 102")
%   #2            = card title
% The body is typeset in an open box; rendering begins after it is fully read.
% \newpage inside the body is treated as an explicit page break to the back side.
\NewDocumentEnvironment{card}{+O{} m}{%
    \begingroup
        \global\advance\pnpcards@cardindex by 1
        \global\pnpcards@breakcount=0
        \pnpcards@SetReference{#1}%
        \def\pnpcards@cardtitle{#2}%
        \edef\pnpcards@cardtitletext{\detokenize{#2}}%
        \setlength{\pnpcards@cardtextwidth}{\textwidth}%
        \setbox\pnpcards@cardcontent=\vbox\bgroup
            \hsize=\pnpcards@cardtextwidth
            \parindent=0pt
            \parskip=0pt
            \let\newpage\pnpcards@CardExplicitBreak
}{%
        \par
        \egroup
        \ifnum\pnpcards@breakcount>1
            \pnpcards@PageLimitError
        \fi
        \setbox\pnpcards@frontcontent=\vsplit\pnpcards@cardcontent to \pnpcards@frontbodyheight
        \pnpcards@CheckSplitHeight\pnpcards@frontcontent\pnpcards@frontbodyheight
        \edef\pnpcards@actualbreak{\splitbotmark}%
        \def\pnpcards@expectedbreak{EXPLICIT-CARD-BREAK}%
        \newif\ifpnpcards@explicitbreak
        \pnpcards@explicitbreakfalse
        \ifx\pnpcards@actualbreak\pnpcards@expectedbreak
            \pnpcards@explicitbreaktrue
        \fi
        \pnpcards@PrintFront{\pnpcards@cardtitle}{\pnpcards@frontcontent}%
        \ifpnpcards@explicitbreak
            % Explicit \newpage: back side holds the content after the break.
            % The remainder box may be void if \newpage was the last thing.
            \ifvoid\pnpcards@cardcontent
                \null
                \newpage
            \else
                \setbox\pnpcards@backcontent=\vsplit\pnpcards@cardcontent to \pnpcards@backbodyheight
                \pnpcards@CheckSplitHeight\pnpcards@backcontent\pnpcards@backbodyheight
                \pnpcards@PrintBack{\pnpcards@backcontent}%
                \ifvoid\pnpcards@cardcontent
                \else
                    \pnpcards@PageLimitError
                \fi
            \fi
        \else
            % Natural overflow path (same as before).
            \ifvoid\pnpcards@cardcontent
                \null
                \newpage
            \else
                \setbox\pnpcards@backcontent=\vsplit\pnpcards@cardcontent to \pnpcards@backbodyheight
                \pnpcards@CheckSplitHeight\pnpcards@backcontent\pnpcards@backbodyheight
                \edef\pnpcards@actualbreak{\splitbotmark}%
                \ifx\pnpcards@actualbreak\pnpcards@expectedbreak
                    \pnpcards@PageLimitError
                \fi
                \pnpcards@PrintBack{\pnpcards@backcontent}%
                \ifvoid\pnpcards@cardcontent
                \else
                    \pnpcards@PageLimitError
                \fi
            \fi
        \fi
    \endgroup
}{}

\newcommand{\Card}[3][]{%
    \begin{card}[#1]{#2}%
        #3%
    \end{card}%
}
