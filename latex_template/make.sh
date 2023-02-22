#!/bin/bash

# this is a makefile for large Latex projects

#############################################
#set filename of master file without extension
filename="main"
echo "The name of the Mainfile is:"
echo "$filename".tex
echo ""
#############################################
echo  -e '\n'################################
echo "step 1"
echo "run pdflatex (first run can have several errors which is ok, since there are further pdflatex runs)"
echo ""
pdflatex -synctex=1 -interaction=nonstopmode "$filename"  || echo "das programm pdflatex ist nicht installiert oder funktioniert nicht"

#############################################
echo  -e '\n'################################
echo "step 2"
echo "run biber (make bibliography)"
echo ""
biber "$filename" || echo "biber ist nicht installiert oder funktioniert nicht"

#############################################
echo  -e '\n'################################
echo "step 3"
echo "make glossaries (make nomenclature and acronyms)"
echo ""
makeglossaries "$filename"  || echo "das programm makeglossaries ist nicht installiert oder funktioniert nicht"

#############################################
echo  -e '\n'################################
echo "step 4"
echo "run pdflatex (second before last run; can have some errors, which is ok)"
echo ""
pdflatex -synctex=1 -interaction=nonstopmode "$filename"  || echo "das programm pdflatex ist nicht installiert oder funktioniert nicht"

#############################################
echo  -e '\n'################################
echo "step 5"
echo "run pdflatex (final run there should be no errors anymore)"
echo ""
pdflatex -synctex=1 -interaction=nonstopmode "$filename"  || echo "das programm pdflatex ist nicht installiert oder funktioniert nicht"

#############################################
echo  -e '\n'################################
echo "step 6 (delete help files)"
echo "1) delete help files in main directory"
rm *.acn *.aux *.bbl *.blg *.glo *.lof *.out *.xml  *.bcf *.gz *.toc *.xdy *.acr *.alg *.glg *.gls *.log *.lot
echo "2) delete .aux files in subdirectories"
find . -name "*.aux" -delete
#############################################
echo -e '\n'#################################
echo "step 7"
echo "open pdf file in okular"
echo ""
xdg-open "$filename".pdf || echo "das programm okular ist nicht installiert oder funktioniert nicht"
echo "compilation finished"
