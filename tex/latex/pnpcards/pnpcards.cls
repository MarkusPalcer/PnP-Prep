% pnpprep.cls: custom class based on the standard report class
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{pnpcards}[2026/05/21 Custom report-based class]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{beamer}}
\ProcessOptions\relax

\setlength{\paperwidth}{14.8cm}
\setlength{\paperheight}{10.5cm}
\setlength{\textwidth}{14.8cm}
\setlength{\textheight}{9.5cm}    

\LoadClass{beamer}

\beamertemplatenavigationsymbolsempty
