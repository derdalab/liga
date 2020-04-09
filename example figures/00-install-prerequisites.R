# install packages used by the other R scripts in this directory

# choose the install library - default to first user library
install.lib <- sub(":.*$", "", Sys.getenv("R_LIBS_USER"))

# create the install library if it does not already exist
dir.create(path = install.lib, showWarnings = FALSE, recursive = TRUE)

# edgeR is distributed through BioConductor - install it if necessary, then get edgeR
# https://bioconductor.org/packages/release/bioc/html/edgeR.html
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager", lib = install.lib)
BiocManager::install("edgeR", lib = install.lib)

# Rmarkdown/knitr uses a TeX install
install.packages('tinytex", lib = install.lib)
tinytex::install_tinytex()
# to uninstall TinyTeX, run tinytex::uninstall_tinytex() 

# install packages from CRAN
install.packages("ggplot2", lib = install.lib)
install.packages("rmarkdown", lib = install.lib)    # used for report generation
install.packages("drc", lib = install.lib)          # dose-response curve package
#install.packages("tidyverse", lib = install.lib)
