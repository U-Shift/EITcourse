#install qpdf
# sudo apt install qpdf
cd _book

# delete from page 3 to the end of covertitle.pdf
# qpdf /media/rosa/Dados/GIS/Qtests/_book/covertitle.pdf --pages . 1-2 -- /media/rosa/Dados/GIS/Qtests/_book/output.pdf


# merge and extract pages
qpdf EITcourse_GetYourDatasetReady2024.pdf --pages covertitle.pdf 1-2 EITcourse_GetYourDatasetReady2024.pdf 2-z -- result.pdf  
