# Install missing packages used by the other R scripts in this directory.
#
# WARNING: If many package dependancies need installation this can take ~45 minutes.
# WARNING: If you mantain specific versisons of libraries, review this script
#          before overwriting your existing install.

# choose the install library - default to first user library
install.lib <- sub(":.*$", "", Sys.getenv("R_LIBS_USER"))

# create the install library directories if they do not already exist
dir.create(path = install.lib, recursive = TRUE, showWarnings = FALSE)

# edgeR is distributed through BioConductor - install it if necessary, then get edgeR
# https://bioconductor.org/packages/release/bioc/html/edgeR.html
# if (!requireNamespace("BiocManager", quietly = TRUE))
#     install.packages("BiocManager", lib = install.lib)
# if(!"edgeR" %in% installed.packages())
#     BiocManager::install("edgeR", lib = install.lib)
# 
# # knitr/Rmarkdown, install it after tinytex (used of knitr PDF output)
# if(!"tinytex" %in% installed.packages())
#     install.packages("tinytex", lib = install.lib)
# tinytex::install_tinytex()  # to uninstall TinyTeX, run tinytex::uninstall_tinytex() 
# if(!"rmarkdown" %in% installed.packages())
#     install.packages("rmarkdown", lib = install.lib)    # used for report generation

# ggplot2 - widely used plot package
if(!"ggplot2" %in% installed.packages())
    install.packages("ggplot2", lib = install.lib)      # common graphing package

# dose-response curve package
if(!"drc" %in% installed.packages()){
    if(!"pbkrtest" %in% installed.packages()){
        # install an older version of pbkrtest (drc requirement) for greater version compatiblity
        pbkrtest.url <- "http://cran.r-project.org/src/contrib/Archive/pbkrtest/pbkrtest_0.4-7.tar.gz"
        install.packages(pbkrtest.url, repos = NULL, type = "source", lib = install.lib)
    }
    install.packages("drc", lib = install.lib)
}

#install.packages("tidyverse", lib = install.lib)
