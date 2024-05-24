# Differential Enrichment Testing

### R scripts dependecies:
The R scripts in this folder may require additional packages to be installed on your system. 
The **"00-install-prerequisites.R"** in this folder will install necessary additional packages (listed below). 
Read the script for specific details.

```
Packages required:
1.) BiocManager
2.) edgeR
3.) statmod
4.) tinytex
5.) rmarkdown
6.) dplyr
7.) stringr
```

### Using the R Scripts:
All script contained in currect folder and sub-folder(s) should be downloaded together. 
Each R script generates a text table file containing the reads, CPM, standard deviation, LogFC, p-value, and q-value. 


## Psuedocode
The script progress through several steps.
For each campaign (description of the statistical comparison to be
performed) file
   Read the campaign
   Read the dictionary and order tables in the campaign
   Read a table of pre-identified sequences and their corresponding LiGA SDBs
   For each LiGA data file (sequences and read counts ) in the campaign
       Read the file
       Convert the sequences into SDB names
       Sum the read counts for each SDB
       Append the read counts into a combined table
   Using TMM estimate the size (total number of reads) of each replicate
   Normalize the read counts the size
   Call the edgeR library to estimate the per SDB differential response: F-test, fold change, p-value
   Estimate False Discovery Rates (q-values) from the list of p-values using Benjamini-Hochberg adjustment
   Output the combined read table to disk
   Output the edgeR stats to disk
   Output a plot of the fold changes
