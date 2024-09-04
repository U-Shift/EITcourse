1+1

5-2

2*2

8/2

round(3.14)
round(3.14, 1) # The "1" indicates to round it up to 1 decimal digit.

c(1, 2, 3)
c(1:3) # The ":" indicates a range between the first and second numbers. 

# Comments help you organize your code. The software will not run the comment. 

modes <- c("car", "PT", "walking", "cycling") # you can use "=" or "<-"
Trips = c(200, 50, 300, 150) # uppercase letters modify


table_example = data.frame(modes, Trips)

View(table_example)

data = readRDS("data/TRIPSmode_mun.Rds")

summary(data)

str(data)

data # first 10 values
head(data, 3) # first 3 values

nrow(data)
ncol(data)

View(data)

sum(data$Total)

sum(data$Car)/sum(data$Total) * 100

(sum(data$Walk) + sum(data$Bike)) / sum(data$Total) * 100

data$Active = data$Walk + data$Bike

data_Lisbon = data[data$Origin_mun == "Lisboa",]

data_out_Lisbon = data[data$Origin_mun != "Lisboa",]

data_in_Out_Lisbon = data[data$Origin_mun == "Lisboa" & data$Destination_mun == "Lisboa",]

data[1,] #rows and columns start from 1

data[1,1]

data = data[ ,-1] #first column

names(data)

data_walk2 = data[ ,c(1,2,4)]

data_walk3 = data[ ,-c(3,5:9)]

write.csv(data, 'data/dataset.csv', row.names = FALSE)
saveRDS(data, 'data/dataset.Rds') #Choose a different file. 

csv_file = read.csv("data/dataset.csv")
rds_file = readRDS("data/dataset.Rds")

# this coverts this quarto to a plain r script
knitr::purl("r-basics.qmd", "code/r-basics.R", documentation = 0)

