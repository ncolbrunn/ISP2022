#import libraries
library(shiny)
library(igraph)
library(multiweb)
library(dplyr)

#convert dataFrame into iGraph
dat <- read.csv("283_3_283_2_FoodWebDataBase_2018_12_10.csv", header = TRUE, na.strings="NA")
foodWebDF <- dat %>% 
  select(res.taxonomy, con.taxonomy, foodweb.name)

#unique(dat$foodweb.name)
#split into lists based on foodweb name
foodWebList <- split( foodWebDF , f = dat$foodweb.name )

#combine iGraph data
iglist <- mapply(graph_from_data_frame, d=foodWebList, directed=TRUE)
igmulti <- multiweb::netData
igcomplete <- c(iglist, igmulti)

connectanceList <- igcomplete[1]...length()
