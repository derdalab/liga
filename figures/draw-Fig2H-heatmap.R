# routine to run the process data files to produce Figure 2H heatmap
library(ggplot2)

# set some parameters
data.dir <- "LiGA data for figures"
filename.pattern <- "Figure2H.*"
q.threshold <- 0.05
fc.threshold.1 <- 2.0
fc.threshold.2 <- 3.8

# set the output file
# height and width are in inches, 7 in is about a two-column figure width
cairo_pdf(file = "Figure2H-heatmap.pdf", width = 7, height = 4.325)


# create an empty data frame to hold the data
long.data <- data.frame(Glycan.Rank = integer(), Glycan.Label = character(),
                        Case.Rank = integer(), Case.Label = character(),
                        logFC = numeric(), PValue = numeric())

input_filename_list <- file.path(data.dir,
                           list.files(path = data.dir, pattern = filename.pattern))
for(filenumber in 1:length(input_filename_list)){
    filename <- input_filename_list[filenumber]

    # extract a case label from the filename
    case.label <- sub("-.*", "", sub("^[^_]*_", "", filename))

    # read the file
    file.data <- read.table(file = filename, header = TRUE, check.names = FALSE)
 
    # append the data need for plotting to the long table
    long.data <- rbind(
        long.data,
        data.frame(Glycan.Rank = 1:NROW(data), Glycan.Label = file.data$sequence,
                   Case.Rank = filenumber, Case.Label = case.label,
                   logFC = file.data$logFC, PValue = file.data$PValue)
        )
}


# set up a colour scheme - smooth gradient to 40 and then very quick shifts
# to a new colour and then a large step at a constant colour
break.list <- c(0:8, 10, 15, 20, 25, 30, 35, 40, 50, 60, 70)
colour_steps2 <- c("white", "#E8E8B4", "#C08080", "#744646", "#1D0000",
          "#500050", "#500050", "#480080", "#480080", "#2000A0", "#2000A0")
colour.intervals.A <- c(0, 1e-4, 0, 1e-4, 0, 1e-4, 0) +
                      (sqrt(c(40, 40, 50, 50, 60, 60, 70))-1) / (sqrt(70)-1)
colour.intervals.B <- c(0, 0.1, 0.568, 0.856) * colour.intervals.A[1]
colour_intervals <- c(colour.intervals.B, colour.intervals.A)

# compute p-value adjustment and identify significant cases
long.data$QValue <- p.adjust(long.data$PValue, method = "BH")
significant.rows.1 <- long.data$QValue <= q.threshold & log2(fc.threshold.1) <= long.data$logFC & long.data$logFC < log2(fc.threshold.2)
significant.rows.2 <- long.data$QValue <= q.threshold & log2(fc.threshold.2) <= long.data$logFC

# round fold-changes less than 1 up to 1
long.data$logFC[long.data$logFC < 0] <- 0

# create the plot
heatmap <- ggplot(long.data,
             aes(x = reorder(Glycan.Label, Glycan.Rank),
                 y = reorder(Case.Label, -Case.Rank))) +
  theme_light() +
  theme(text = element_text(family = "Arial"), panel.grid = element_blank(),
        axis.ticks.x = element_blank(), panel.background = element_blank()) +
  coord_fixed() +
  geom_tile(aes(fill = 2^logFC), colour = "black", size = 0.2) +
  scale_fill_gradientn(colours = colour_steps2, values = colour_intervals,
                       limits = c(1, 70), trans = "sqrt", breaks = break.list,
                       na.value = "red", guide = guide_colorbar(nbin = 1000)) +
  geom_text(label = "\u25e6", hjust = 0.5, vjust = 0.50, color = "#808080",
            data = long.data[significant.rows.1,]) +
  geom_text(label = "*",      hjust = 0.5, vjust = 0.75, color = "#808080",
            data = long.data[significant.rows.2,]) +
  labs(x = "Glycan", y =  "Binding Target") +
  theme(axis.text.x  = element_text(face = "bold", hjust = 1, vjust = 0.5, angle = 90, size = 6.5),
        axis.text.y  = element_text(face = "bold", hjust = 1, size = 6.5),
        legend.position = "top",
        legend.title = element_blank(),
        legend.text = element_text(size = 10),
        legend.key.size = unit(0.3, "cm"),
        legend.key.width = unit(2.5, "cm"))

# now output the image
print(heatmap)

# end the PDF file generation
dev.off()

