# routine to run the process data files to produce Figure 5 bar charts
library(ggplot2)
library(grid)

# set some parameters
data.dir <- "LiGA data for figures"
filename.pattern <- "Figure5.*"

# set the output file
# height and width are in inches, 7 inches is about a two-column figure width
pdf(file = "Figure5-barchart.pdf", width = 5, height = 7)


# # create an empty data frame to hold the data
# long.data <- data.frame(Glycan.Rank = integer(), Glycan.Label = character(),
#                         Case.Rank = integer(), Case.Label = character(),
#                         logFC = numeric(), PValue = numeric())
input_filename_list <- file.path(data.dir,
                       list.files(path = data.dir, pattern = filename.pattern))
diff.tests <- list()
for(filenumber in 1:length(input_filename_list)){
    filename <- input_filename_list[filenumber]

    # extract a case label from the filename
    case.label <- sub("-.*", "", sub("^.*_", "", filename))

    # read the file
    file.data <- read.table(file = filename, header = TRUE, check.names = FALSE)
    
    # append the data needed for plotting to the data table
    file.data$Valid <- TRUE
    diff.tests[[length(diff.tests)+1]] <- file.data
}


# extract the valid group p-values and calculate
# the q-values (and their subranges)
p_values <- lapply(diff.tests, function(x){ifelse(x$Valid, x$PValue, NA)})
q_values <- p.adjust(unlist(p_values), method = "BH")
q_indices <- c(0, cumsum(lapply(p_values, length)))


grob_list = list()
for(subpanel in 1:length(diff.tests)){
    output_df <- diff.tests[[subpanel]]
    output_df$logFC <- diff.tests[[subpanel]]$logFC
    output_df$QValue <- q_values[(1+q_indices[subpanel]):q_indices[subpanel+1]]
    # estimates of relative noise - would probably be better to directly take
    # the means for this purpose rather than the log-transformed QL-fit values
    # but that value is not available
    relative.noise <- sqrt((output_df$sd_test / output_df$test_CPM)**2 +
                           (output_df$sd_control / output_df$control_CPM)**2)

    plot_data <- data.frame(
                Label = reorder(factor(output_df$sequence), 1:nrow(output_df)),
                #Rank = output_df$Rank,
                Order = 1:nrow(output_df),
                Enrichment = 2 ** output_df$logFC,
                QValue = output_df$QValue,
                Noise = (2 ** output_df$logFC) * (1 + relative.noise),
                Valid = output_df$Valid
                )


    bar_plot <- ggplot(data = plot_data,
                     aes(x = Label, y = Enrichment)) +
            theme_light() + theme(text = element_text(family = "Arial"),
                                  panel.grid.major.x = element_blank(),
                                  panel.grid.minor.y = element_blank()) +
            labs(x = "Glycan", y = "Enrichment") +
            scale_y_sqrt(expand = expand_scale(mult = c(0, 0.08))) +
            geom_hline(yintercept = 1) + 
            geom_col(position = "dodge", colour = "black", size = 0.0,
                     width = 0.80, fill = "black") +
            geom_errorbar(aes(ymin = Noise, ymax = Noise, width = 2/3)) +
            geom_linerange(aes(ymin = Enrichment, ymax = Noise)) +
            geom_text(aes(y = Noise), label = "*", hjust = 0.4,
                data = plot_data[plot_data$QValue <= 0.05 & plot_data$Valid,]) +
            theme(axis.text.y  = element_text(face = "bold"))

    # include the label text under the last two panels only
    if(subpanel >= length(diff.tests)-1){
        bar_plot <- bar_plot + theme(
            axis.text.x = element_text(face = "bold", angle = 90, hjust = 1,
                                       vjust = 0.5, size = 6.0))
    } else {
        bar_plot <- bar_plot + theme(axis.text.x = element_blank(),
                                     axis.ticks.x = element_blank(),
                                     axis.title.x = element_blank())
    }

    grob_list[[subpanel]] <- ggplotGrob(bar_plot)
}
page <- do.call(rbind, c(grob_list, size = "first"))
grid.newpage()
grid.draw(page)

dev.off()



