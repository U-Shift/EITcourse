library(dplyr)
library(sf)
library(mapview)

Municipalities_geo = st_read("data/Municipalities_geo.gpkg", quiet = TRUE)

# create geometric centroids
Centroids_geo = st_centroid(Municipalities_geo)

mapview(Centroids_geo)
mapview(Centroids_geo) + mapview(Municipalities_geo, alpha.regions = 0) # both maps, with full transparency in polygons



# Weighted centroids

Census = st_read("data/census.gpkg", quiet = TRUE)

mapview(Census |> filter(Municipality == "Lisboa"), zcol = "Population")


library(centr)
Centroid_pop = Census |> 
  mean_center(group = "Municipality", weight = "Population")

Centroid_build = Census |> 
  mean_center(group = "Municipality", weight = "Buildings")



mapview(Centroids_geo, col.region = "blue") +
  mapview(Centroid_pop, col.region = "red") +
  mapview(Centroid_build, col.region = "black") +
  mapview(Municipalities_geo, alpha.regions = 0) # polygon limits

# check crs
st_crs(Centroids_geo) # 4326 WGS84
st_crs(Centroid_pop) # 3763 Portugal TM06

# transform to the same crs
Centroid_pop = st_transform(Centroid_pop, crs = 4326)
Centroid_build = st_transform(Centroid_build, crs = 4326)



## Compare
# Plot the Municipalities_geo polygons first (with no fill)
plot(st_geometry(Municipalities_geo), col = NA, border = "black")

# Add the Centroids_geo points in blue
plot(st_geometry(Centroids_geo), col = "blue", pch = 16, add = TRUE) # add!

# Add the Centroid_pop points in red
plot(st_geometry(Centroid_pop), col = "red", pch = 16, add = TRUE)

# Add the Centroid_build points in black
plot(st_geometry(Centroid_build), col = "black", pch = 16, add = TRUE)
