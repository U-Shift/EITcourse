library(dplyr)

data = readRDS("data/TRIPSmode_mun.Rds")

glimpse(data)

data_new = select(data, Origin_mun, Walk, Bike, Total) # the first argument is the dataset

data_new = select(data_new, -Total) # dropping the Total column

data_new = data |> select(Origin_mun, Walk, Bike, Total)

# this converts this quarto to a plain r script
knitr::purl("data-manipulation.qmd", "code/data-manipulation.R", documentation = 0)
