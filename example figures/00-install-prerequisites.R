# install packages used by the other R scripts in this directory

# edgeR is distributed through BioConductor - install it if necessary, then get edgeR
# https://bioconductor.org/packages/release/bioc/html/edgeR.html
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("edgeR")

# Rmarkdown/knitr uses a TeX install
install.packages('tinytex')
tinytex::install_tinytex()
# to uninstall TinyTeX, run tinytex::uninstall_tinytex() 

# install packages from CRAN
install.packages("ggplot2")
install.packages("drc")		       # dose-response curve package
install.packages("rmarkdown")    # used for report generation
#install.packages("tidyverse")
