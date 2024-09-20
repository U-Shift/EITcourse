# r5r accessibility with Rafael Pereira
# copy-paste from the website https://ipeagit.github.io/access_workshop_eit_2024


# load packages -----------------------------------------------------------

# check if jdk 21 is installed
rJavaEnv::java_check_version_rjava()


options(java.parameters = "-Xmx4G")

# load packages
library(r5r)
library(h3jsr)
library(dplyr)
library(mapview)
library(ggplot2)


# read datasets -----------------------------------------------------------

# path to data directory
data_path <- system.file("extdata/poa", package = "r5r")

# read points data
points <- read.csv(file.path(data_path, "poa_hexgrid.csv"))
head(points)


# population density ------------------------------------------------------

# retrieve polygons of H3 spatial grid
grid <- h3jsr::cell_to_polygon(
  points$id,
  simple = FALSE
)

# merge spatial grid with land use data
grid_poa <- left_join(
  grid,
  points,
  by = c('h3_address'='id')
)

# interactive map
mapview(grid_poa, zcol = 'population')


# routable network --------------------------------------------------------

# if you have r5r installed as system (not user) you need to give permissions
# sudo chmod -R 777 /usr/local/lib/R/site-library/r5r/extdata/poa

r5r_core <- r5r::setup_r5(data_path, 
                          verbose = FALSE)


# accessibility - quick approach ------------------------------------------

# routing inputs
mode <- c("walk", "transit")
max_walk_time <- 30
travel_time_cutoff <- 20
departure_datetime <- as.POSIXct("13-05-2019 14:00:00",
                                 format = "%d-%m-%Y %H:%M:%S")

# calculate accessibility
access1 <- r5r::accessibility(
  r5r_core = r5r_core,
  origins = points,
  destinations = points,
  mode = mode,
  opportunities_colnames = c("schools", "healthcare"),
  decay_function = "step", #decay function!!
  cutoffs = travel_time_cutoff,
  departure_datetime = departure_datetime,
  max_walk_time = max_walk_time,
  progress = TRUE
)

# map
# merge spatial grid with accessibility estimates
access_sf <- left_join(
  grid, 
  access1, 
  by = c('h3_address'='id')
)

# plot
ggplot() +
  geom_sf(data = access_sf, aes(fill = accessibility), color= NA) +
  scale_fill_viridis_c(direction = -1, option = 'B') +
  labs(title = 'Number of schools and hospitals accessible by public transport in 20 minutes',
       fill = 'Number of\nfacilities') +
  theme_minimal() +
  theme(axis.title = element_blank()) +
  facet_wrap(~opportunity) +
  theme_void()




# flexible approach -------------------------------------------------------

# now restart R (CTRL + SHIFT + F10)
# and clear your environment (broom)


# allocating memory to java
options(java.parameters = "-Xmx6G")

library(r5r)
library(accessibility)
library(h3jsr)
library(dplyr)
library(mapview)
library(ggplot2)

# path to data directory
data_path <- system.file("extdata/poa", package = "r5r")

# build network
r5r_core <- r5r::setup_r5(data_path, 
                          verbose = FALSE)

# read points data
points <- read.csv(file.path(data_path, "poa_hexgrid.csv"))


# compute travel time matrix ---------------------------------------------------

# routing inputs
mode <- c("walk", "transit")
max_trip_duration <- 30 # max travel time of 30 minutes
departure_datetime <- as.POSIXct("13-05-2019 14:00:00",
                                 format = "%d-%m-%Y %H:%M:%S")

# calculate travel time matrix
ttm <- r5r::travel_time_matrix(
  r5r_core = r5r_core,
  origins = points,
  destinations = points,
  mode = mode,
  departure_datetime = departure_datetime,
  max_trip_duration = max_trip_duration,
  progress = TRUE
)

head(ttm)



# accessibility commulative -----------------------------------------------
# now we use the accessibility package!

# threshold-based cumulative accessibility
access_cum_t <- accessibility::cumulative_cutoff(
  travel_matrix = ttm, 
  land_use_data = points,
  travel_cost = 'travel_time_p50',
  opportunity = 'schools',
  cutoff = 20
)

head(access_cum_t)


# interval-based cumulative accessibility
access_cum_i <- accessibility::cumulative_interval(
  travel_matrix = ttm, 
  land_use_data = points,
  travel_cost = 'travel_time_p50',
  opportunity = 'schools',
  interval = c(15,25), # time interval
  summary_function = mean # or median, or std, ... this is the average of each minute in that interval
)

head(access_cum_i)



# gravity-based accessibility ----------------------------------------------

# logistic decay
access_lgst <- gravity(
  travel_matrix = ttm,
  land_use_data = points,
  decay_function = decay_logistic(cutoff = 15, sd = 5), # we set here the decay function
  opportunity = "schools",
  travel_cost = "travel_time_p50"
)

# negative exponential decay
access_nexp <- gravity(
  travel_matrix = ttm,
  land_use_data = points,
  decay_function = decay_exponential(decay_value = 0.1),
  opportunity = "schools",
  travel_cost = "travel_time_p50"
)

## plot both to compare
negative_exp <- decay_exponential(decay_value = 0.1)
logistic <- decay_logistic(cutoff = 15, sd = 5)

travel_costs <- seq(0, 30, 0.1)

weights <- data.frame(
  minutes = travel_costs,
  negative_exp = negative_exp(travel_costs)[["0.1"]],
  logistic = logistic(travel_costs)[["c15;sd5"]]
)

# reshape data to long format
weights <- tidyr::pivot_longer(
  weights,
  cols = c('negative_exp',  'logistic'),
  names_to = "decay_function",
  values_to = "weights"
)

ggplot(weights) +
  geom_line(aes(minutes, weights, color = decay_function),
            show.legend = FALSE) +
  facet_wrap(. ~ decay_function, ncol = 2) +
  theme_minimal()



# map with all the results ------------------------------------------------

# rbind all accessibility results in a single data.frame
access_cum_t$metric <- 'cum_threshold'
access_cum_i$metric <- 'cum_interval'
access_lgst$metric <- 'grav_logistic'
access_nexp$metric <- 'grav_exponential'

df <- rbind(access_cum_t,
            access_cum_i,
            access_lgst,
            access_nexp
)

# retrieve polygons of H3 spatial grid
grid <- h3jsr::cell_to_polygon(
  points$id, 
  simple = FALSE
)

# merge accessibility estimates
access_sf <- left_join(
  grid, 
  df, 
  by = c('h3_address'='id')
)

# plot
ggplot() +
  geom_sf(data = access_sf, aes(fill = schools), color= NA) +
  scale_fill_viridis_c(direction = -1, option = 'B') +
  labs(title = "Access to schools by public transport using different accessibility metrics", fill = "Access\nscore") +
  theme_minimal() +
  theme(axis.title = element_blank()) +
  facet_wrap(~metric) +
  theme_void()

# watch out the common scale!
# maybe not the best option to compare results in the same plot



# equity measures in accessibility ----------------------------------------

# now restart R (CTRL + SHIFT + F10)
# and clear your environment (broom)


library(accessibility)
library(ggplot2)
library(dplyr)

# path to data
data_dir <- system.file("extdata", package = "accessibility")

# read travel matrix and land use data
ttm <- readRDS(file.path(data_dir, "travel_matrix.rds"))
lud <- readRDS(file.path(data_dir, "land_use_data.rds"))

# calculate threshold-based cumulative access
access_df <- cumulative_cutoff(
  travel_matrix = ttm,
  land_use_data = lud,
  opportunity = "jobs",
  travel_cost = "travel_time",
  cutoff = 30
)

head(access_df)

# merge acces and land use data
df <- access_df |>
  rename(jobs_access = jobs) |>
  left_join(lud, by='id')

# remove spatial units with no population
df <- filter(df, population > 0)

# box plot
ggplot(data = df) +
  geom_boxplot(show.legend = FALSE,
               aes(x = income_decile, 
                   y = jobs_access / 1000, 
                   weight = population, 
                   color = income_decile)) +
  scale_colour_brewer(palette = 'RdBu') + 
  labs(subtitle = 'Number of jobs accessible in 30 minutes by public transport',
       x = 'Income decile', y = 'Jobs (in thousands)') +
  scale_x_discrete(labels = c("D1\npoorest", 
                              paste0("D", 2:9), 
                              "D10\nwealthiest")) +
  theme_minimal()

# interpret these results!


# inequality measures -----------------------------------------------------

# palma ratio
palma <- palma_ratio(
  accessibility_data = access_df,
  sociodemographic_data = lud,
  opportunity = "jobs",
  population = "population",
  income = "income_per_capita"
)

palma
# if 3: rich people can reach 3x more jobs than poor people


# concentration index
ci <- accessibility::concentration_index(
  accessibility_data = access_df,
  sociodemographic_data = lud,
  opportunity = "jobs",
  population = "population",
  income = "income_per_capita",
  type = "corrected"
)

ci
# varies from -1 to 1
# if 1: all the accessibility to jobs are concentrated in rich people 


# accessibility poverty

# get the 25th percentile of access
quant25 <- quantile(access_df$jobs, .25)

poverty <- fgt_poverty(
  accessibility_data =  access_df,
  sociodemographic_data = lud,
  opportunity = "jobs",
  population = "population",
  poverty_line = quant25
)

# FGT0: number of people below poverty line
# FGT1: average percentage distance between the poverty line and the
#       accessibility of individuals below it
# FGT2: average percentage distance between the poverty line weighted
#       by the size of the accessibility shortfall relative to the poverty line

poverty
# quick interpretation

# FGT0: 14.8% of the population are in accessibility poverty
# FGT1: the accessibility of those living in accessibility poverty is on average 5% lower than the poverty line
# FGT2: it has no clear interpretation, but one could say that the overall poverty level/intensity is 2.8%.
