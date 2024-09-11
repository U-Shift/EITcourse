

TRIPSmode = readRDS("data/TRIPSmode.Rds")

library(sf)
Municipalities_geo = st_read("data/Municipalities_geo.gpkg", quiet = TRUE) # supress mesage

# Create desire lines
# install.packages("od")
library(od)
TRIPSdlines = od_to_sf(TRIPSmode, z = Municipalities_geo) # z for zones

library(mapview)
mapview(TRIPSdlines, zcol = "Total")



# remove noise

library(dplyr)

# remove trips with origin & destination in the same zone
TRIPSdlines_inter = TRIPSdlines |> 
  filter(Origin != Destination) |> # remove intrazonal trips
  filter(Total > 5000) # remove noise

mapview(TRIPSdlines_inter, zcol = "Total", lwd = 5)


# remove Lisbon
TRIPSdl_noLX = TRIPSdlines_inter |> 
  filter(Origin != "Lisboa", Destination != "Lisboa")

mapview(TRIPSdl_noLX, zcol = "Total", lwd = 8) # larger line width

# representation with only onle line 2ways
nrow(TRIPSdlines)
TRIPSdlines_oneway = od_oneway(TRIPSdlines)
nrow(TRIPSdlines_oneway)

# see the process
head(TRIPSdlines_oneway[,c(1,2)]) # just the first 2 columns
tail(TRIPSdlines_oneway[,c(1,2)])



TRIPSdlines_oneway_noLX = TRIPSdlines_oneway |> 
  filter(o != d) |> # remove intrazonal trips
  filter(PTransit > 5000) # reduce noise

mapview(TRIPSdlines_oneway_noLX, zcol = "PTransit", lwd = 8)


## desire lines with weighted centroids
# rescue this from last section
# Centroid_pop = st_read("data/Centroid_pop.gpkg") # if you don't have it already

TRIPSdlines_pop = od_to_sf(TRIPSmode, z = Centroid_pop) |>  # works the same way
  od_oneway() # oneway

TRIPSdlines_geo_LX = TRIPSdlines_oneway |> 
  filter(o == "Lisboa" | d == "Lisboa") # or condition
TRIPSdlines_pop_LX = TRIPSdlines_pop |> 
  filter(o == "Lisboa" | d == "Lisboa")

mapview(TRIPSdlines_geo_LX, color = "blue") + mapview(TRIPSdlines_pop_LX, color = "red")
