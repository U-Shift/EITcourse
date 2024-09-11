library(dplyr)

# get survey data
SURVEY = read.csv("data/SURVEY.txt", sep = "\t") # tab delimiter
names(SURVEY)

library(sf)

#transform from data.frame to sf
SURVEYgeo = st_as_sf(SURVEY, coords = c("lon", "lat"), crs = 4326) # convert to as sf data


# create a single point
UNIVERSITY = data.frame(place = "IST",
                        lon = -9.1397404,
                        lat = 38.7370168) |>  # first a dataframe
  st_as_sf(coords = c("lon", "lat"), # then a spacial feature
           crs = 4326)

library(mapview)
mapview(SURVEYgeo, zcol = "MODE") + mapview(UNIVERSITY, col.region = "red", cex = 12)


# create a line between the survey points and the university
SURVEYeuclidean = st_nearest_points(SURVEYgeo, UNIVERSITY, pairwise = TRUE) |>
  st_as_sf() # this creates lines

mapview(SURVEYeuclidean)

# compute the line length and add directly in the first survey layer
SURVEYgeo = SURVEYgeo |>
  mutate(distance = st_length(SURVEYeuclidean))

# remove the units - can be useful
SURVEYgeo$distance = units::drop_units(SURVEYgeo$distance)


# or get the distances (but not the lines)
SURVEYgeo = SURVEYgeo |> 
  mutate(distance = st_distance(SURVEYgeo, UNIVERSITY)[,1] |>  # in meters
           units::drop_units()) |>  # remove units
  mutate(distance = round(distance)) # round to integer

summary(SURVEYgeo$distance)


## routing
# prepare network for r5r
options(java.parameters = "-Xmx4G") # allocate memory
url = "https://github.com/U-Shift/EITcourse/releases/download/2024.09/network.dat"
download.file(url, destfile = "data/network.dat", mode = "wb")

library(r5r)
r5r_network = setup_r5("data/", overwrite = FALSE) # load existing network


# less od pairs
SURVEYsample = SURVEYgeo |> filter(distance <= 2000)
nrow(SURVEYsample)

# create id columns for both datasets
SURVEYsample = SURVEYsample |> 
  mutate(id = c(1:nrow(SURVEYsample))) # from 1 to the number of rows
UNIVERSITY = UNIVERSITY |> 
  mutate(id = 1) # only one row

# route car
SURVEYcar = detailed_itineraries(
  r5r_core = r5r_network,
  origins = SURVEYsample,
  destinations = UNIVERSITY,
  mode = "CAR",
  all_to_all = TRUE # if false, only 1-1 would be calculated
)

names(SURVEYcar)

# route walk
SURVEYwalk = detailed_itineraries(
  r5r_core = r5r_network,
  origins = SURVEYsample,
  destinations = UNIVERSITY,
  mode = "WALK",
  all_to_all = TRUE # if false, only 1-1 would be calculated
)


# route PT (takes more time!)
SURVEYtransit = detailed_itineraries(
  r5r_core = r5r_network,
  origins = SURVEYsample,
  destinations = UNIVERSITY,
  mode = "TRANSIT",
  mode_egress = "WALK",
  max_trip_duration = 60, # The maximum PT trip duration in minutes
  max_rides = 1, # The maximum PT rides allowed in the same trip
  departure_datetime =  as.POSIXct("20-09-2023 08:00:00",
                                 format = "%d-%m-%Y %H:%M:%S"),
  all_to_all = TRUE # if false, only 1-1 would be calculated
)

summary(SURVEYsample$distance) # Euclidean
summary(SURVEYwalk$distance) # Walk
summary(SURVEYcar$distance) # Car


# compare single route
mapview(SURVEYeuclidean[165,], color = "black") + # 1556 meters
  mapview(SURVEYwalk[78,], color = "red") + # 1989 meters
  mapview(SURVEYcar[78,], color = "blue") # 2565 meters

mapview(SURVEYwalk, alpha = 0.3)
mapview(SURVEYcar, alpha = 0.3, color = "red")


## overline
# we create a value that we can later sum
# it can be the number of trips represented by this route
SURVEYwalk$trips = 1 # in this case is only one respondent per route

SURVEYwalk_overline = stplanr::overline(
  SURVEYwalk,
  attrib = "trips",
  fun = sum
)

mapview(SURVEYwalk_overline, zcol = "trips", lwd = 3)
