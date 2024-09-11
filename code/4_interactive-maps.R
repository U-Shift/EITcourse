
library(sf)
library(mapview)

TRIPSgeo = st_read("data/TRIPSgeo.gpkg")

plot(TRIPSgeo)

mapview(TRIPSgeo)

mapview(TRIPSgeo, zcol = "Total")

mapview(TRIPSgeo, zcol = "Municipality", alpha.regions = 0.4) # also add transparency

