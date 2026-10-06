% pnpcards.cls: Class to create flash-card-like documents
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{pnpcards}[2026/10/06 Custom flash cards]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\LoadClass{article}
\RequirePackage[a6paper,landscape,margin=5mm,noheadfoot]{geometry}

\pagestyle{empty}
% Card areas are fixed-size boxes placed flush against the text area's top edge.
\setlength{\topskip}{0pt}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}

\newlength{\pnpcards@contentwidth}
\newlength{\pnpcards@cardtextwidth}
\newlength{\pnpcards@titleheight}
\newlength{\pnpcards@frontgap}
\newdimen\pnpcards@frontbodyheight
\newdimen\pnpcards@backbodyheight
\newif\ifpnpcards@debugframes
\pnpcards@debugframesfalse
\setlength{\pnpcards@contentwidth}{\textwidth}
\setlength{\pnpcards@titleheight}{15mm}
\setlength{\pnpcards@frontgap}{2mm}
\pnpcards@frontbodyheight=\dimexpr\textheight-\pnpcards@titleheight-\pnpcards@frontgap\relax
\pnpcards@backbodyheight=\textheight

\newcommand{\EnableCardDebugFrames}{\pnpcards@debugframestrue}

\newbox\pnpcards@cardcontent
\newbox\pnpcards@frontcontent
\newbox\pnpcards@backcontent

\newcommand{\pnpcards@CardExplicitBreak}{%
    \par
    \mark{EXPLICIT-CARD-BREAK}%
    \penalty-10000%
}

\newcommand{\pnpcards@Area}[4]{%
    \ifpnpcards@debugframes
        \fbox{%
            \begin{minipage}[#3][\dimexpr#2-2\fboxsep-2\fboxrule\relax][#3]{%
                \dimexpr\textwidth-2\fboxsep-2\fboxrule\relax
            }
                #4
            \end{minipage}%
        }%
    \else
        \begin{minipage}[#3][#2][#3]{#1}%
            #4
        \end{minipage}%
    \fi
}

\newcommand{\pnpcards@PrintFront}[3]{%
    \thispagestyle{empty}%
    \nointerlineskip
    \hbox to \textwidth{%
        \pnpcards@Area{\pnpcards@contentwidth}{\pnpcards@titleheight}{c}{%
            \textbf{#1}\par
            #3
        }%
    }%
    \vskip\pnpcards@frontgap
    \nointerlineskip
    \hbox to \textwidth{%
        \pnpcards@Area{\pnpcards@contentwidth}{\pnpcards@frontbodyheight}{t}{%
            \unvbox#2
        }%
    }%
    \newpage
}

\newcommand{\pnpcards@PrintBack}[1]{%
    \thispagestyle{empty}%
    \nointerlineskip
    \hbox to \textwidth{%
        \pnpcards@Area{\pnpcards@contentwidth}{\pnpcards@backbodyheight}{t}{%
            \unvbox#1
        }%
    }%
    \newpage
}

\newcommand{\RunCard}[2]{%
    \begingroup
        \ifpnpcards@debugframes
            \setlength{\pnpcards@cardtextwidth}{%
                \dimexpr\textwidth-2\fboxsep-2\fboxrule\relax
            }%
        \else
            \setlength{\pnpcards@cardtextwidth}{\textwidth}%
        \fi
        \setbox\pnpcards@cardcontent=\vbox{%
            \hsize=\pnpcards@cardtextwidth
            \parindent=0pt
            \parskip=0pt
            \let\newpage\pnpcards@CardExplicitBreak
            #2\par
        }%
        \setbox\pnpcards@frontcontent=\vsplit\pnpcards@cardcontent to \pnpcards@frontbodyheight
        \edef\pnpcards@actualbreak{\splitbotmark}%
        \def\pnpcards@expectedbreak{EXPLICIT-CARD-BREAK}%
        \def\pnpcards@breakstatus{}%
        \ifx\pnpcards@actualbreak\pnpcards@expectedbreak
            \def\pnpcards@breakstatus{Explicit break marker detected}%
        \fi
        \pnpcards@PrintFront{#1}{\pnpcards@frontcontent}{\pnpcards@breakstatus}%
        \ifvoid\pnpcards@cardcontent
            \null
            \newpage
        \else
            \setbox\pnpcards@backcontent=\vsplit\pnpcards@cardcontent to \pnpcards@backbodyheight
            \pnpcards@PrintBack{\pnpcards@backcontent}%
            \ifvoid\pnpcards@cardcontent
            \else
                \PackageError{pnpcards}%
                    {Card content exceeds two pages}%
                    {Reduce the card content for this test.}%
            \fi
        \fi
    \endgroup
}
