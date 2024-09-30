#install qpdf
# sudo apt install qpdf


# merge and extract pages
qpdf _book/GetYourDatasetReady2024.pdf --pages bookcover/_book/covertitle.pdf 1-2 _book/GetYourDatasetReady2024.pdf 2-z -- _book/EITcourse_GetYourDatasetReady2024.pdf  


# upload to github
Rscript -e "piggyback::pb_upload('_book/EITcourse_GetYourDatasetReady2024.pdf')"