#Class 2024.10.15
#Cont. form 10.10 class

#Re-run code to populate Global Environment

# Conditional Subsetting ####
#Want to subset data based on what makes them familiar
#Syntax is the same, but instead of indicies, put conditions

#Conditional Subsetting of Character Data ####
df1[df1$animals == "dog", ] #returns the row(s) where there is dog

#Load dragons table
dragons_db <- dbConnect(RSQLite::SQLite(),"../dragons.db") 
dragons <- DBI::dbGetQuery(dragons_db, "SELECT * from dragons;")

dragons[c(1, 5, 10, 12), ] #returns dragons from just these numbered rows
#Want all conditions met but don't want to dig into each row to pull out
is.na(dragons$sex) #returns a bunch of T/F for sex
dragons[is.na(dragons$sex), ] #subset to get all NA for D sex in table w/ data
!is.na(dragons$sex) #! means opposite, so is NA is not true?
dragons[!is.na(dragons$sex), ] #subset to get no NA for D sex in table w/ data
dragons[dragons$sex == "NA", ] # get all NAs

dragons[dragons$species == "Forest Dragon", ] #get all Forest D in table w/ data
dragons[dragons$species == "Forest Dragon" | 
          dragons$species == "Mountain Dragon", ] #get all Forest and Mtn D.
#Another way to write same thing:
dragons[dragons$species %in% c("Forest Dragon", "Mountain Dragon"), ]

#Conditional Subsetting of  Numerical Data ####
df1[df1$numbers >1, ] #returns all rows where number is greater than 1

#Conditional Subsetting of Logical Data ####
df1[df1$is_wild ==TRUE] #if only run what is within brackets, returns a vector
  #FALSE FALSE TRUE
#but already have a logical condition, so don't need to write == TRUE
df1[df1$is_wild, ] #returns the one row which is TRUE ad addt'l data w/ that row
  # 3 lion  TRUE
df1[df1$is_wild == FALSE, ] #returns the two rows which are TRUE & addt'l data
df1[!df1$is_wild, ] #same as above by stating the opposite of the TRUE

#Automating Repeated Tasks ####
vec1 <- 1:10
vec1
vec1 * 2

#A lot of times when asking if need to do loop, don't actually need to do this
#Ask if can just do this with vector calculations

# EX: look at deployments table
deploy <- DBI::dbGetQuery(dragons_db, "SELECT * from deployments;")

# time difference in days between 1 row and next, vectorized across the df
lubridate::ymd(deploy$start_deployment[1:(nrow(deploy)-1)]) -
  lubridate::ymd(deploy$start_deployment[2:nrow(deploy)])
#returns all of the time differences in multiple rows
#take the 1st to second-to-last entries, subtract 2nd to last
#lubridate is to help R read the dates

#another way to write so don't have to repeat lubridate function:
#lubridate the whole table, then run code
deploy$start_deployment <- lubridate::ymd(deploy$start_deployment)
deploy$start_deployment[1:(nrow(deploy)-1)] - 
  deploy$start_deployment[2:nrow(deploy)]


# Don't always need a loop; 2 situations when appropriate
#1) next value is dependent on the previous value
#2) cascade of elements on an object

#loops are also slow
vec1 * 2 #returns 10-item vector (vec1 identified in previous class script)
#Most often, will find self writing "for" loops
for (variable in vector) {
  
}
#Ex:
for(i in 1:length(vec1)) {
 print(vec1[i] * 2)
  } 
#i means iteration
# 1:length(vec1) --> starting at the first ith, through the length of vector
#item within curly brackets is what you want the loop to do
#NOTE loops save object i in environment 
# w/o print, only returns last value

for (i in 1:nrow(deploy)) {
  print(deploy$start_deployment[i] - 
          deploy$start_deployment[i + 1])
}
#print returns results to the console rather than saving as an object
#returns each time difference in different row with label time diff.
#Ex: Time difference of -5898 days

#need to create an object before running loop and wanting to save it to an obj.
#for us to store something in an object, that object needs to already exist
time_difference <- c() # Creating an empty vector
for (i in 1:nrow(deploy)) {
  time_difference[i] <- deploy$start_deployment[i] - 
    deploy$start_deployment[i + 1]
} #populating the vector and saving as an object

deploy$time_difference <- NA #creates a new column time_difference in
#deploy data frame and initially assigns NA to every row in that column
#later, values can be assigned to each row within the loop.
for (i in 1:nrow(deploy)) {
  deploy$time_difference[i] <- deploy$start_deployment[i] - 
    deploy$start_deployment[i + 1]
}

#Another way to write loops:
?apply
mat1 <- matrix(1:25, nrow=5, ncol=5)
mat1

apply(mat1, 1, FUN = sum) #1 indicates rows, 
  #what the function will be applied over --> each row is summed
apply(mat1, 2, FUN = sum) #2 indicates columns --> each col is summed

?lapply
?mapply
?sapply
?vapply

?lapply #possibly most useful because lists are complex; 
#takes as input either a vector or a list
#NOTE lapply do not save object i in environment 

?unlist #simplifies it to produce a vector which contains all the 
#atomic components which occur in x
#think do this so can use in lapply

#x = deploy$start_deployment --> no ith, doing operation on one at at time
deploy$time_difference <- unlist(
  lapply(X = 1:length(deploy$start_deployment),
         FUN= function(x){
           deploy$start_deployment[x] - 
             deploy$start_deployment[x + 1]
         }))
#returns similar series of time diff numbers as 'for' loop

#another example of how to write lapply
unlist(lapply(vec1, FUN = function(x) {x*2}))

# Fastest: vectorization, mid: lapply; slowest: for loop

#example from textbook 10.3
l <- list(1:10, 2:20, 3:30)

lapply(l, function(x) {mean(x + 2 *456)}) #take each 'l' of the list,
#make a function and do that to each element of the list
#do the innermost parentheses and work way out 
#output is a list because using lapply