#Class 2024.11.07
#Pigmy rabbit Case Study

# Load packages ####
library(tidyverse)
library(readxl)

# Load Data####

sheet1 <- readxl::read_xlsx("Pigmy-rabbit_Case_Study/pygmy-rabbit_extra-messy.xlsx",
                            sheet =1)
head(sheet1) #see what it looks like; see that the header title is read but other columns don't have header

sheet2 <- readxl::read_xlsx("Pigmy-rabbit_Case_Study/pygmy-rabbit_extra-messy.xlsx",
                         sheet =2)
head(sheet2) #correctly read in next sheet; same thing

#Can we automate reading in all of the sheets? 

# For loop
length(readxl::excel_sheets("Pigmy-rabbit_Case_Study/pygmy-rabbit_extra-messy.xlsx")) #12 sheets

my_file <- "Pigmy-rabbit_Case_Study/pygmy-rabbit_extra-messy.xlsx"
my_list <-list() #create empty list to fill

for (i in 1:length(readxl::excel_sheets("Pigmy-rabbit_Case_Study/pygmy-rabbit_extra-messy.xlsx"))) {
  my_list[[i]] <- read_xlsx(my_file, sheet = i)
}
#how long did that take?
system.time({
  for (i in 1:length(readxl::excel_sheets("Pigmy-rabbit_Case_Study/pygmy-rabbit_extra-messy.xlsx"))) {
    my_list[[i]] <- read_xlsx(my_file, sheet = i)
  }
}) #24 seconds; because we pre-allocated the list, that mayyy be why took shorter than lapply

# Apply Family 
#don't need to create an empty container because lapply creates a list
my_other_list <- lapply(excel_sheets(my_file), FUN = function(x){
  read_xlsx(my_file, sheet = x)
})
#a little bit more clean and straighforward to code

#how long did that take?
system.time({
  my_other_list <- lapply(excel_sheets(my_file), FUN = function(x){
    read_xlsx(my_file, sheet = x)
  })
}) #34.85 seconds

#take a look and how to transpose
dim(my_list[[1]][, -1]) #there are 51 rows and 4 columns in the data (not including headers)
test <- data.frame(matrix(ncol = nrow(my_list[[1]]),
                          nrow = ncol(my_list[[1]])
                          )) #creating a data frame which will be filled
colnames(test) <- my_list[[1]]$Question #fill in in the headers with info from first column
test[1, ] <- as.vector(my_list[[1]][, 2])[[1]] #CHECK WHAT THIS IS DOING

# Need to do above for each column, so can automate
for (i in 2:ncol(my_list[[1]])) {
  test[i-1, ] <-  as.vector(my_list[[1]][, i][[1]])
}
#Need to do this for each sheet #LOOK MORE
for (j in 1:length(my_list)) {
  #FILL OUT
  test[i-1, ] <-  as.vector(my_list[[1]][, i][[1]])
}


lapply(transposed_list, ncol)
lapply(transposed_list, function(x) {unique(x$'Site Number')})



normal_sheets <- c(1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12)

lapply(normal_sheets, function(x) {
  pivot_longer(transposed_list[[x]],
               )
})
