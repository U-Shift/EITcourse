library(sf)
library(dplyr)

Municipalities_geo = st_read("data/Municipalities_geo.gpkg")

st_crs(Municipalities_geo)

Municipalities_projected = st_transform(Municipalities_geo, crs = 3857)




TRIPSmun = readRDS("data/TRIPSmun.Rds")
class(TRIPSmun)
class(Municipalities_geo)


TRIPSgeo =
  TRIPSmun |> 
  left_join(Municipalities_geo)

class(TRIPSgeo)


TRIPSgeo = TRIPSgeo |> st_as_sf()
class(TRIPSgeo)


SURVEY = read.csv("data/SURVEY.txt", sep = "\t") # tab delimiter
class(SURVEY)

SURVEYgeo = st_as_sf(SURVEY, coords = c("lon", "lat"), crs = 4326) # create spatial feature
class(SURVEYgeo)

plot(TRIPSgeo) # all variables

plot(TRIPSgeo["Municipality"])

plot(TRIPSgeo["Total"])

plot(TRIPSgeo["Car"])


# plot pointy data
plot(SURVEYgeo)



# export geo data -----------------------------------------------------------------------------

st_write(TRIPSgeo, "data/TRIPSgeo.gpkg") # as geopackage
st_write(TRIPSgeo, "data/TRIPSgeo.shp") # as shapefile
st_write(TRIPSgeo, "data/TRIPSgeo.geojson") # as geojson
st_write(TRIPSgeo, "data/TRIPSgeo.csv", layer_options = "GEOMETRY=AS_WKT") # as csv, with WKT geometry
