# library(tidyverse)
library(dplyr)

# data preparation
TABLE = readRDS(url("https://github.com/U-Shift/MQAT/raw/main/data/IMOBmodel0.Rds"))
TABLE = TABLE |> 
  rename(Origin = "Origin_dicofre16",
         Lisbon = "Lisboa",
         Internal = "internal") |> 
  select(1,3:8,2,9)
saveRDS(TABLE, "data/TRIPSorigin.Rds")

Municipalities = readRDS(url("https://github.com/U-Shift/MQAT/raw/main/data/Dicofre_names.Rds"))
Municipalities = Municipalities |> 
  rename(Mun_code = "DTCC",
         Neighborhood_code = "Dicofre",
         Municipality = "Concelho",
         Neighborhood = "Freguesia")
saveRDS(Municipalities, "data/Municipalities_names.Rds")
write.table(Municipalities, "data/Municipalities_names.txt", row.names = FALSE, sep = "\t")

TRIPS = readRDS("data/TRIPSorigin.Rds")

glimpse(TRIPS)

TRIPS_new = select(TRIPS, Origin, Walk, Bike, Total) # the first argument is the dataset

TRIPS_new = select(TRIPS_new, -Total) # dropping the Total column

TRIPS_new = TRIPS |> select(Origin, Walk, Bike, Total)

TRIPS2 = TRIPS[TRIPS$Total > 25000,] # using r-base, you cant forget the comma
TRIPS2 = TRIPS2 |> filter(Total > 25000) # using dplyr, it's easier

summary(TRIPS$Total)
TRIPS3 = TRIPS |> filter(Total > median(Total)) 

TRIPS$Car_perc = TRIPS$Car/TRIPS$Total * 100 # using r-base

TRIPS = TRIPS |> mutate(Car_perc = Car/Total * 100) # using dplyr

class(TRIPS$Origin)
TRIPS = TRIPS |> 
  mutate(Origin_num = as.integer(Origin)) # you can use as.numeric() as well
class(TRIPS$Origin_num)

TRIPS = TRIPS |> 
  mutate(Lisbon_factor = factor(Lisbon, labels = c("No", "Yes")),
         Internal_factor = factor(Internal, labels = c("Inter", "Intra")))

unique(TRIPS$Lisbon) # this will show all the different values
table(TRIPS$Lisbon) # this will show the frequency of each value
table(TRIPS$Lisbon_factor)

Municipalities = readRDS("data/Municipalities_names.Rds")

head(TRIPS)
tail(Municipalities)

TRIPSjoin = TRIPS |> left_join(Municipalities, by = c("Origin" = "Neighborhood_code"))

Municipalities = Municipalities |> rename(Origin = "Neighborhood_code") # change name
TRIPSjoin = TRIPS |> left_join(Municipalities) # automatic detects common variable

TRIPSredux = TRIPSjoin |> select(Origin, Municipality, Internal, Car, Total)
head(TRIPSredux)

TRIPSsum = TRIPSredux |> 
  group_by(Municipality) |> # you won't notice any chagne with only this
  summarize(Total = sum(Total))
head(TRIPSsum)

TRIPSsum2 = TRIPSredux |> 
  group_by(Municipality, Internal) |> 
  summarize(Total = sum(Total),
            Car = sum(Car))
head(TRIPSsum2)

TRIPS2 = TRIPSsum2 |> arrange(Total)
TRIPS2 = TRIPSsum2 |> arrange(-Total) # descending

TRIPS2 = TRIPSsum2 |> arrange(Municipality) # alphabetic

TRIPS4 = TRIPS |> arrange(Lisbon_factor, Total) # more than one variable

TRIPS_pipes = TRIPS |> 
  select(Origin, Internal, Car, Total) |> 
  
  mutate(Origin_num = as.integer(Origin)) |> 
  mutate(Internal_factor = factor(Internal, labels = c("Inter", "Intra"))) |> 
  
  filter(Internal_factor == "Inter")|>
  
  left_join(Municipalities) |>
  
  group_by(Municipality) |>
  summarize(Total = sum(Total),
            Car = sum(Car),
            Car_perc = Car/Total * 100) |> 
  ungroup() |> 
  
  arrange(desc(Car_perc))

TRIPS_pipes

pivot = data.frame(Origins = c("A", "A", "B", "C", "C"),
                   Destinations = c("B", "C", "A", "C", "A"),
                   Trips = c(20, 45, 10, 5, 30))
knitr::kable(pivot, caption = "OD matrix in long format")

matrix = pivot |> 
  tidyr::pivot_wider(names_from = Destinations,
                                     values_from = Trips,
                                     names_sort = TRUE) |> 
  dplyr::rename(Trips = "Origins")
knitr::kable(matrix, caption = "OD matrix in wide format")

# this converts this quarto to a plain r script
knitr::purl("data-manipulation.qmd", "code/data-manipulation.R", documentation = 0)
