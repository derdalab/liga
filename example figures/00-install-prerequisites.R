# install missing packages used by the other R scripts in this directory
# if many package dependancies need installation this can take ~45 minutes

# choose the install library - default to first user library
install.lib <- sub(":.*$", "", Sys.getenv("R_LIBS_USER"))

# create the install library directories if they do not already exist
dir.create(path = install.lib, recursive = TRUE, showWarnings = FALSE)

# edgeR is distributed through BioConductor - install it if necessary, then get edgeR
# https://bioconductor.org/packages/release/bioc/html/edgeR.html
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager", lib = install.lib)
if(!"edgeR" %in% installed.packages()[,"Package"])
    BiocManager::install("edgeR", lib = install.lib)

# knitr/Rmarkdown, install it after tinytex (used of knitr PDF output)
if(!"tinytex" %in% installed.packages()[,"Package"])
    install.packages("tinytex", lib = install.lib)
tinytex::install_tinytex()  # to uninstall TinyTeX, run tinytex::uninstall_tinytex() 
if(!"rmarkdown" %in% installed.packages()[,"Package"])
    install.packages("rmarkdown", lib = install.lib)    # used for report generation

# install packages from CRAN if they are not already installed
if(!"ggplot2" %in% installed.packages()[,"Package"])
    install.packages("ggplot2", lib = install.lib)      # common graphing package
if(!"drc" %in% installed.packages()[,"Package"])
    install.packages("drc", lib = install.lib)          # dose-response curve package
#install.packages("tidyverse", lib = install.lib)
