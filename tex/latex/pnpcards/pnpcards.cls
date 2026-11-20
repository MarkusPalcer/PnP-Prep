% pnpcards.cls: Class to create flash-card-like documents
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{pnpcards}[2026/10/06 Custom flash cards]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\LoadClass{article}
\RequirePackage[a6paper,landscape,margin=5mm,noheadfoot]{geometry}
\RequirePackage{environ}
\RequirePackage{xcolor}

\pagestyle{empty}
% Card areas are fixed-size boxes placed flush against the text area's top edge.
\setlength{\topskip}{0pt}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}

\newlength{\pnpcards@contentwidth}
\newlength{\pnpcards@cardtextwidth}
\newlength{\pnpcards@titleheight}
\newlength{\pnpcards@frontgap}
\newlength{\pnpcards@frontcontenttopinset}
\newlength{\pnpcards@backcontenttopinset}
\newdimen\pnpcards@frontbodyheight
\newdimen\pnpcards@backbodyheight
\newif\ifpnpcards@debugframes
\pnpcards@debugframesfalse
\setlength{\pnpcards@contentwidth}{\textwidth}
\setlength{\pnpcards@titleheight}{15mm}
\setlength{\pnpcards@frontgap}{2mm}
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
\newbox\pnpcards@area

\newcommand{\pnpcards@CardExplicitBreak}{%
    \par
    \mark{EXPLICIT-CARD-BREAK}%
    \penalty-10000%
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
    \setbox\pnpcards@area=\hbox{%
        \begin{minipage}[#3][#2][#3]{#1}%
            #5
        \end{minipage}%
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

\newcommand{\pnpcards@PrintFront}[2]{%
    \thispagestyle{empty}%
    \nointerlineskip
    \hbox to \textwidth{%
        \pnpcards@Area{\pnpcards@contentwidth}{\pnpcards@titleheight}{c}{red!75!black}{%
            \textbf{#1}%
        }%
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
% Usage: \begin{card}{Titel}[Referenz] ... \end{card}
%   #1 (optional) = short reference shown top-right on the front (e.g. "WdZ 102")
%   #2            = card title
% The body is collected in full before rendering begins (via the environ package).
% \newpage inside the body is treated as an explicit page break to the back side.
\NewEnviron{card}[2][]{%
    \begingroup
        \setlength{\pnpcards@cardtextwidth}{\textwidth}%
        \setbox\pnpcards@cardcontent=\vbox{%
            \hsize=\pnpcards@cardtextwidth
            \parindent=0pt
            \parskip=0pt
            \let\newpage\pnpcards@CardExplicitBreak
            \BODY\par
        }%
        \setbox\pnpcards@frontcontent=\vsplit\pnpcards@cardcontent to \pnpcards@frontbodyheight
        \edef\pnpcards@actualbreak{\splitbotmark}%
        \def\pnpcards@expectedbreak{EXPLICIT-CARD-BREAK}%
        \newif\ifpnpcards@explicitbreak
        \pnpcards@explicitbreakfalse
        \ifx\pnpcards@actualbreak\pnpcards@expectedbreak
            \pnpcards@explicitbreaktrue
        \fi
        \pnpcards@PrintFront{#2}{\pnpcards@frontcontent}%
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

\newcommand{\Card}[2]{%
    \begin{card}{#1}%
        #2%
    \end{card}%
}
