% pnpcards.cls: Class to create flash-card-like documents
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{pnpcards}[2026/10/06 Custom flash cards]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\LoadClass{article}
\RequirePackage[a6paper,landscape,margin=5mm,noheadfoot]{geometry}
\RequirePackage{environ}

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

\newcommand{\pnpcards@PrintFront}[2]{%
    \thispagestyle{empty}%
    \nointerlineskip
    \hbox to \textwidth{%
        \pnpcards@Area{\pnpcards@contentwidth}{\pnpcards@titleheight}{c}{%
            \textbf{#1}%
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
        \newif\ifpnpcards@explicitbreak
        \pnpcards@explicitbreakfalse
        \ifx\pnpcards@actualbreak\pnpcards@expectedbreak
            \pnpcards@explicitbreaktrue
        \fi
        \pnpcards@PrintFront{#1}{\pnpcards@frontcontent}%
        \ifpnpcards@explicitbreak
            % Explicit \newpage: back side holds the content after the break.
            % The remainder box may be void if \newpage was the last thing.
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
                        {Reduce the card content.}%
                \fi
            \fi
        \else
            % Natural overflow path (same as before).
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
                        {Reduce the card content.}%
                \fi
            \fi
        \fi
    \endgroup
}

% Public card environment.
% Usage: \begin{card}{Titel}[Referenz] ... \end{card}
%   #1 (optional) = short reference shown top-right on the front (e.g. "WdZ 102")
%   #2            = card title
% The body is collected in full before rendering begins (via the environ package).
% \newpage inside the body is treated as an explicit page break to the back side.
\NewEnviron{card}[2][]{%
    \RunCard{#2}{\BODY}%
}
