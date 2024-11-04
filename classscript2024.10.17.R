#Class 2024.10.17
# Troubleshooting in R ####

#Two most common errors: 
# typos
# incorrect working directory
# then start isolating pieces of code to look at and where breaks

dragons <-read.csv("../dragons.csv")

#First for demos, load packages ####
library(DBI)
library(RSQLite)
#Load dragons table
dragons_db <- dbConnect(RSQLite::SQLite(),"../dragons.db") 
dragons <- DBI::dbGetQuery(dragons_db, "SELECT * from dragons;")

#use commas because a data frame with rows and commas so need to to subset
#with both pieces
#here, have a matrix so subsettting rows and commas, so need to ID two parts:
dragons[dragons$species == "Storm Dragon", ] #rows with S. Dragon, each column

df1 <-data.frame(numbers = 1:3, #first column 1-3
                 animals = c("dog", "cat", "lion"), #second column
                 is_wild = c(FALSE, FALSE, TRUE)) 
#another error: object is not subsettable
df[df1$animals == "dog", ] #in reality, this is just missing the 1 in df1
#get this error though because df is a function
?df
?data #data is also a function; she likes to use dat for date instead

"hello"
mean(1:10)

#keep eye out for:
# red 'x' on right indicating error
# auto-created quotes, parentheses pieces, etc.

# in console below, when have plus sign, often means parentheses or quotes are 
#missing; can press 'ESC' and just start over if can't fix there

#run small pieces of code to isolate the problem:
df2 <- data.frame(numbers = 1:5, 
                  letters = c("A", "B", "C", "D", "E", "F"),
                  animals = c("dog", "cat", "bird", "lion", "whale"))

#when Googleing part of error, remove anything specif to your project

#exploring more about loops and trouble shooting####
library(DBI)
dragons_db <- dbConnect(RSQLite::SQLite(),"../dragons.db")
morphometrics <- dbGetQuery(dragons_db, "SELECT * from morphometrics;")

#trying to figure out how to get "word" function to work
install.packages("dplyr") 
library(dplyr)#nope
install.packages("sos")
library("sos")
findFn("word") #can now enter various things in this and may return a webpage
install.packages("stringr") #part of tidyverse
library(stringr)#works

#Want to check if we have multiple measurements of the same dragon:
#quick glance in tidyverse to extract first word from a string
#start and end at first word; word is useful because variable chara.
word(morphometrics$capture_event, start = 1, end = 1, sep = "_") 
#get just dragon_id without the "_1" at end

morphometrics$dragon_id <- word(morphometrics$capture_event, start = 1, end = 1, sep = "_")
#want to know if more than one measurement per dragon in this group:
table(morphometrics$dragon_id)

#they all are one so for the purpose of this example, going to change some data
morphometrics[morphometrics$dragon_id %in% 
                c("D86", "D5", "D495"), ]$dragon_id <- "D80" 
#changing the values for some of the data
morphometrics[morphometrics$dragon_id %in% 
                c("D43", "D1", "D270"), 
]$dragon_id <- "D49" 

table(morphometrics$dragon_id)

#now we want minimum value of wingspan for dragons
#can vectorize this b/c one value for wingspan doesn't depend on other values
#but function doesn't take a vector as input, need lapply or for loop 

#need a for loop to indicate each measurement that we got
#also need to create an empty object to store wingspan
min_wingspan <-  c()
for (i in 1:length(unique(morphometrics$dragon_id))) { 
  sub <-  morphometrics[morphometrics$dragon_id == 
                          unique(morphometrics$dragon_id) [i], ]
  min_wingspan[i] <- min(sub$wingspan_cm) #for each ith element, add info to that vector
}
#subset so that loop runs for each element in the table
#can check by assigning and running little pieces of code: 
# i <- 1

#try same problem with lapply:
morph_list <-  split(morphometrics, f = morphometrics$dragon_id)
#morph_list [[1]] # look at individual examples
#split: turns morph dataframe and split into one df per dragon_id

min_wingspan_list <-  lapply(morph_list, function(x) {
  min(x$wingspan_cm)
})
#don't need to initialize empty output, just give name min_wingspan_list
length(min_wingspan_list) #returns 321, same length if list from unique

#how to troubleshoot because can't set 'i' to an input in the list
# x <-  morph_list[[1]]
#to troubleshoot, can assign x to an element on your list, and reproduce 

#whatever is in the curly bracket is temporary and not in Global Environment, 
#so need to assign x to something to run components
x <- morph_list [["D80"]]
lapply(morph_list, nrow)


#unlist() if want to go from list to vector
#do.call("rbind", ...) if you want to take a list and turn back into a dataframe
