#import libraries
library(shiny)
library(igraph)
library(multiweb)
library(dplyr)
library(leaflet)
library(measurements)

#prepare to convert dataFrame into iGraph
dat <- read.csv("283_3_283_2_FoodWebDataBase_2018_12_10.csv", header = TRUE, na.strings="NA")
foodWebDF <- dat %>% 
  dplyr::select(res.taxonomy, con.taxonomy, foodweb.name, longitude, latitude, ecosystem.type, study.site) %>% 
  dplyr::filter(!foodweb.name == "Carpinteria" ) %>%
  dplyr::filter(!foodweb.name == "Weddell Sea" )


#remove duplicated foodwebs
foodWebDF["ecosystem.type"][foodWebDF["study.site"] == "Grand Caricaie"] <- "terrestrial aboveground"
foodWebDF["foodweb.name"][foodWebDF["foodweb.name"] == "Caribbean Reef"] <- "Caribbean Reef Small"

#Split duplicated network and create distinct foodweb names
carp_mar <- dat %>% 
  dplyr::filter(foodweb.name == "Carpinteria" & ecosystem.type == "marine") %>% 
  dplyr::select(res.taxonomy, con.taxonomy, foodweb.name, longitude, latitude, ecosystem.type, study.site)
carp_mar$foodweb.name <- "Carpinteria Marine"

carp_ter <- dat %>%
  dplyr::filter(foodweb.name == "Carpinteria" & ecosystem.type == "terrestrial aboveground") %>% 
  dplyr::select(res.taxonomy, con.taxonomy, foodweb.name, longitude, latitude, ecosystem.type, study.site)
carp_ter$foodweb.name <- "Carpinteria Terrestrial"

#merge dataframes
foodWebDF_up <- rbind(foodWebDF, carp_mar)
foodWebDF <- rbind(foodWebDF_up, carp_ter)

#split into lists based on foodweb name
datrescon <- foodWebDF %>% 
  dplyr::select(res.taxonomy, con.taxonomy, foodweb.name)
foodWebList <- split( datrescon , datrescon$foodweb.name )


#combine iGraph data
iglist <- mapply(graph_from_data_frame, d=foodWebList, directed=TRUE)
igmulti <- multiweb::netData
igcomplete <- c(iglist, igmulti)

#combine df data
colnames(foodWebDF)[4] <- "Longitude"
colnames(foodWebDF)[5] <- "Latitude"
colnames(foodWebDF)[3] <- "Network"
colnames(foodWebDF)[6] <- "Ecosystem"

foodWebDF["Ecosystem"][foodWebDF["Ecosystem"] == "lakes" | foodWebDF["Ecosystem"] == "streams"] <- "Dulceacuícola"
foodWebDF["Ecosystem"][foodWebDF["Ecosystem"] == "terrestrial aboveground" | foodWebDF["Ecosystem"] == "terrestrial belowground"] <- "Terrestre"
foodWebDF["Ecosystem"][foodWebDF["Ecosystem"] == "marine"] <- "Marino"

foodWebLocation1 <- foodWebDF %>% 
  dplyr::select(Longitude, Latitude, Network, Ecosystem)
foodWebLocation2 <- multiweb::metadata %>%
  dplyr::select(c(Longitude, Latitude, Network))
foodWebLocation2["Longitude"][foodWebLocation2["Network"] == "Caribbean Reef"] <- "-66 39 52.2468"
foodWebLocation2$Longitude = (measurements::conv_unit(foodWebLocation2$Longitude, from = 'deg_min_sec', to = 'dec_deg') )
foodWebLocation2$Latitude = (measurements::conv_unit(foodWebLocation2$Latitude, from = 'deg_min_sec', to = 'dec_deg') )
foodWebLocation2$Ecosystem <- "Marino"

datalist <- calc_topological_indices(igcomplete)
uniqueLocations <- (rbind(distinct(foodWebLocation1), distinct(foodWebLocation2))) %>%
  mutate_at(vars(Longitude,Latitude), as.numeric)
uniqueLocations$Size <- datalist$Size
uniqueLocations$Interactions <- datalist$Links
uniqueLocations$popup_text <- paste0("<center>",  "</br><b>", uniqueLocations$Network,  "</br><b></br><b>Tipo de ecosystema</b>: ", uniqueLocations$Ecosystem, "</br><b>Numero de especies</b>: ", uniqueLocations$Size,  "</br><b>Numero de interacciones</b>: ", uniqueLocations$Interactions,"</center>")

#plot_troph_level(igcomplete[[290]])

# tic()
# calc_QSS(igcomplete[290], nsim = 1000)
# toc()

#load(file = "~/ISP/ISP2022/R/qssResults.rda")
#qssResults

#save(igcomplete, file="igcomplete.rda")

