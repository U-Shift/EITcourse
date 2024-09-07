# 
# # R basics
# 
# In this chapter we will introduce to the R basics and some exercises to get familiar to how R works.
# 
# ## Simple operations
# 
# ### Math operations
# 
# #### Sum
# 

1+1

# 
# #### Subtraction
# 

5-2

# 
# #### Multiplication
# 

2*2

# 
# #### Division
# 

8/2

# 
# #### Round the number
# 

round(3.14)
round(3.14, 1) # The "1" indicates to round it up to 1 decimal digit.

# 
# You can use help `?round` in the console to see the description of the function, and the default arguments.
# 
# ### Basic shortpaths
# 
# #### Perform Combinations
# 

c(1, 2, 3)
c(1:3) # The ":" indicates a range between the first and second numbers. 

# 
# #### Create a comment with `ctrl + shift + m`
# 

# Comments help you organize your code. The software will not run the comment. 

# 
# #### Create a table
# 
# A simple table with the number of trips by car, PT, walking, and cycling in a hypothetical street segment at a certain period.
# 
# Define variables
# 

modes <- c("car", "PT", "walking", "cycling") # you can use "=" or "<-"
Trips = c(200, 50, 300, 150) # uppercase letters modify


# 
# Join the variables to create a table
# 

table_example = data.frame(modes, Trips)

# 
# Take a look at the table
# 
# Visualize the table by clicking on the "Data" in the "Environment" page or use :
# 

View(table_example)

# 
# ## Practical exercise
# 
# Dataset: the number of trips between all municipalities in the Lisbon Metropolitan Area, Portugal [@IMOB].
# 
# #### Import dataset
# 
# You can click directly in the file under the "Files" pan, or:
# 

data = readRDS("data/TRIPSmode.Rds")

# 
# > Note that after you type `"` you can use `tab` to navigate between folders and files and `enter` to autocomplete.
# 
# #### Take a first look at the data
# 
# Summary statistics
# 

summary(data)

# 
# Check the structure of the data
# 

str(data)

# 
# Check the first values of each variable
# 

data

head(data, 3) # first 3 values

# 
# Check the number of rows (observations) and columns (variables)
# 

nrow(data)
ncol(data)

# 
# Open the dataset
# 

View(data)

# 
# #### Explore the data
# 
# Check the total number of trips
# 
# Use `$` to select a variable of the data
# 

sum(data$Total)

# 
# Percentage of car trips related to the total
# 

sum(data$Car)/sum(data$Total) * 100

# 
# Percentage of active trips related to the total
# 

(sum(data$Walk) + sum(data$Bike)) / sum(data$Total) * 100

# 
# #### Modify original data
# 
# Create a column with the sum of the number of trips for active modes
# 

data$Active = data$Walk + data$Bike

# 
# Filter by condition (create new tables)
# 
# Filter trips only with origin from Lisbon
# 

data_Lisbon = data[data$Origin_mun == "Lisboa",]

# 
# Filter trips with origin different from Lisbon
# 

data_out_Lisbon = data[data$Origin_mun != "Lisboa",]

# 
# Filter trips with origin and destination in Lisbon
# 

data_in_Out_Lisbon = data[data$Origin_mun == "Lisboa" & data$Destination_mun == "Lisboa",]

# 
# Remove a column
# 
# Look at the first row
# 

data[1,] #rows and columns start from 1

# 
# Look at first row and column
# 

data[1,1]

# 
# Remove the first column
# 

data = data[ ,-1] #first column

# 
# Create a table only with origin, destination and walking trips
# 
# There are many ways to do the same operation.
# 

names(data)

# 

data_walk2 = data[ ,c(1,2,4)]

# 

data_walk3 = data[ ,-c(3,5:9)]

# 
# #### Export data
# 
# Save data in .csv and .Rds
# 

write.csv(data, 'data/dataset.csv', row.names = FALSE)
saveRDS(data, 'data/dataset.Rds') #Choose a different file. 

# 
# #### Import data
# 

csv_file = read.csv("data/dataset.csv")
rds_file = readRDS("data/dataset.Rds")



