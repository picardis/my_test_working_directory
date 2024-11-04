#Class 2024.10.24
# tidyverse ####

setwd("C:/Users/stei0696/OneDrive - University of Idaho/Fall 2024/
      WLF 553 Reproducible Data Science/my_test_working_directory")
#for some reason, I need to reset the wd each time
list.files() #this shows all of the files in my wd
getwd()

# Load packages ####

library(tidyverse)
#warning with conflicts: meaning there are two packages with the same function
#R doesn't know which one to use; R would use the one most recently 
#best to always indicate which package the function belongs to
library(DBI)

# Load Data ####

dragons_db <- dbConnect(RSQLite::SQLite(),"../dragons.db") 

dragons <- DBI::dbGetQuery(dragons_db, "SELECT * from dragons;")
capture_sites <- DBI::dbGetQuery(dragons_db, "SELECT * from capture_sites")
captures <- DBI::dbGetQuery(dragons_db, "SELECT * from captures")
morphometrics <- DBI::dbGetQuery(dragons_db, "SELECT * from morphometrics")
diet_contents <- DBI::dbGetQuery(dragons_db, "SELECT * from diet_contents")
diet_samples <- DBI::dbGetQuery(dragons_db, "SELECT * from diet_samples")
deployments <- DBI::dbGetQuery(dragons_db, "SELECT * from deployments")
gps <- DBI::dbGetQuery(dragons_db, "SELECT * from gps_data")
mortalities <- DBI::dbGetQuery(dragons_db, "SELECT * from mortalities")
tags <- DBI::dbGetQuery(dragons_db, "SELECT * from tags")

#To see the list of tables in the .db so we can load all of them above
dbListTables(dragons_db)


# Select Columns from a data frame ####

morphometrics #look at morph. table
class(morphometrics) #data.frame

select(morphometrics, 
       capture_event, 
       total_body_length_cm,
       wingspan_cm)
#returns a data.frame


# Filter rows in a data frame ####

filter(morphometrics, 
       total_body_length_cm > 1000)
#another way to write: 
morphometrics[morphometrics$total_body_length_cm > 1000, ]

#if want to filter then also keep the three columns:
#assign filtered part as object:

step1 <- filter(morphometrics, 
                  total_body_length_cm > 1000)
select(step1, 
       capture_event, 
       total_body_length_cm,
       wingspan_cm
       )

#HOWEVER, one great feature of the tidyverse is that don't need to save 
#intermediate objects, link them with a pipe:

# The pipe! #### %>% <- Ctrl+Shift+M
#helps not clutter working environment with objects don't actually need
#takes output of previous function and puts as input for next

morphometrics %>% 
  filter(total_body_length_cm > 1000) %>% 
  #all that need to put in function is the condition
  select(capture_event, 
               total_body_length_cm,
               wingspan_cm)
#first argument feeds the next pipe which feeds the next, and so on

# Creating new columns #### <- mutate
morphometrics %>% 
  filter(total_body_length_cm > 1000) %>% #'filter' to select rows
  select(capture_event, #'select' to select columns
         total_body_length_cm,
         wingspan_cm) %>% 
  mutate(total_body_length_m = total_body_length_cm/100, #new column + content 
         wingspan_m = wingspan_cm/100) %>% #new column + content 
  select(-total_body_length_cm, # - to remove the columns with cm
         -wingspan_cm)

#other option:
morphometrics %>% 
  filter(total_body_length_cm > 1000) %>% #filter is conditional subsetting,
                                          #based on a logical condition
  mutate(total_body_length_m = total_body_length_cm/100, 
         wingspan_m = wingspan_cm/100) %>% 
  select(capture_event, 
         total_body_length_m,
         wingspan_m) %>% 
  slice(1:5) #only print first 5 rows; equivalent of positional subset for rows
  #(helpful to take a look at intermediate objects w/o having to save to env):
  #can also use head(), colnames(), view()

#can slice things that aren't consecutive
obj1 <- morphometrics %>% 
  filter(total_body_length_cm > 1000) %>% #filter is conditional subsetting,
  #based on a logical condition
  mutate(total_body_length_m = total_body_length_cm/100, 
         wingspan_m = wingspan_cm/100) %>% 
  select(capture_event, 
         total_body_length_m,
         wingspan_m)
obj1[c(1, 10, 100), ]

#another way to look at a couple parts of data:
glimpse(obj1)

class(obj1) #still a date.frame, part of tibble component of tidyverse

# Tibbles ####
#tibbles always only show top 10 rows
obj1 <- as_tibble(obj1)
class(obj1) #returns  "tbl_df" "tbl" "data.frame"
            #still a d.f but a more specific one optimized for tidyverse
#anything that can do to a data frame, can also do to a tibble


#Joining tables ####
obj1 %>% 
  left_join(captures, by = "capture_event") %>% 
  left_join(dragons, by = "dragon_id")
#safe to always specify what want to join by

#could have done this whole thing without assigning an object: 
morphometrics %>% 
  filter(total_body_length_cm > 1000) %>% #equivalent of conditional subset
  mutate(total_body_length_cm = total_body_length_cm/100, 
         wingspan_m = wingspan_cm/100) %>% 
  select(capture_event, 
         total_body_length_cm,
         wingspan_cm) %>% 
  left_join(captures, by = "capture_event") %>% 
  left_join(dragons, by = "dragon_id") %>% 
  as_tibble()
#then could save desired result in the end

#Calculate summary stats by group:

#Count number of dragons by species:
morphometrics %>% 
  filter(total_body_length_cm > 1000) %>% #equivalent of conditional subset
  mutate(total_body_length_cm = total_body_length_cm/100, 
         wingspan_m = wingspan_cm/100) %>% 
  select(capture_event, 
         total_body_length_cm,
         wingspan_cm) %>% 
  left_join(captures, by = "capture_event") %>% 
  left_join(dragons, by = "dragon_id") %>% 
  as_tibble() %>% 
  group_by(species) %>% 
  tally %>% 
  arrange(desc(n))
#first example of an aggregate function

# Mean wingspan by sex
morphometrics %>% 
  filter(total_body_length_cm > 1000) %>% #equivalent of conditional subset
  mutate(total_body_length_m = total_body_length_cm/100, 
         wingspan_m = wingspan_cm/100) %>% 
  select(capture_event, 
         total_body_length_m,
         wingspan_m) %>% 
  left_join(captures, by = "capture_event") %>% 
  left_join(dragons, by = "dragon_id") %>% 
  as_tibble() %>% 
  group_by(sex) %>% #this function automatically turns the d.f to a table
  summarize(mean_wingspan_m = mean(wingspan_m),
            min_wingspan_m = min(wingspan_m),
            max_wingspan_m = max(wingspan_m),
            sd_wingspan_m = sd(wingspan_m)
     )
  
#when at end and have pipe chain done, can assign object to save whole part