#Class 2024.10.29
# tidyverse (cont.) ####
#Will continue looking at reminder of tidyverse functions
#everything can do in tidyverse can do in Base R, but goa is more readable

#double-checking wd:
getwd() # all good (my_test_working_directory)

# Load packages ####
library(tidyverse)
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


#took code from previous class and assigned to new object morph_join
morph_join <- morphometrics %>% 
  filter(total_body_length_cm > 1000) %>% #equivalent of conditional subset
  mutate(total_body_length_cm = total_body_length_cm/100, 
         wingspan_m = wingspan_cm/100) %>% 
  select(capture_event, 
         total_body_length_cm,
         wingspan_cm) %>% 
  left_join(captures, by = "capture_event") %>% 
  left_join(dragons, by = "dragon_id") %>% 
  as_tibble()

#Reorder columns ####

morph_join %>% 
  relocate(dragon_id, .before = capture_event) %>% 
  relocate(date:species, .after = capture_event)

#consider how much time may be save using select vs relocate
#how many want to rearrange

morph_join %>% 
  select(dragon_id, capture_event, date, site, age_at_capture, sex, 
         species, total_body_length_cm, wingspan_cm)


# Rename columns ####

morph_join %>% 
  relocate(dragon_id, .before = capture_event) %>% 
  relocate(date:species, .after = capture_event) %>% 
  rename(dragon = dragon_id)

#again, think about which to use between rename and select,
# what are already doing in the code?
#If only need to do one particular thing, rename and relocate are good


# Extract columns as vectors ####
#select first two columns 4 different ways
class(morphometrics[ ,1]) #returns a vector
class(morphometrics[1]) #returns a data.frame
class(morphometrics$measurement_id) #returns a vector
class(morphometrics[ ,c(1:2)]) #returns a data.frame, asking for >1
#class doesn't tell you the object type it tells you the data type
#if returns a data type, then knows it's a vector

#select returns a data.frame
morphometrics %>% 
  select(measurement_id) %>% 
  class()

#$ is equivalent to pull; returns a vector
morphometrics %>% 
  pull(measurement_id) %>% 
  class()

#sometimes want to use pull to create vector to plug into loop
keepers <-  morphometrics %>% 
  filter(total_body_length_cm > 1000) %>% 
  left_join(captures) %>% 
  left_join(dragons) %>% 
  pull(dragon_id)

for (i in 1:length(keepers)) {
  #...
}


#Switch between long and wide format ####
aza <-read.csv("aza_example.csv")
head(aza)
#data are not tidy, need to get last 6 columns down to 4
#observational unit should be species and sex, not just species

#visualize how want to clean data
target <- data.frame(common_name = NA,
                     latin_name = NA,
                     class = NA,
                     mle = NA,
                     lwr_ci  = NA,
                     upr_ci  = NA,
                     sex = NA)

#go from wide to long
?pivot_longer #beware is a confusing file

mle <- pivot_longer(aza,
             cols = mle_m:mle_f, #this is going to stack these columns
             values_to = "mle",
             names_to = "sex") %>% 
  select(common_name, latin_name, class, sex, mle) 
#finish with a select statement for what we want

#do same for lower and upper then stitch all 3 back together:
lwr <- pivot_longer(aza,
                cols = lwr_ci_m:lwr_ci_f, 
               values_to = "lwr_ci",
               names_to = "lwr_sex") %>% 
  select(common_name, latin_name, class, lwr_sex, lwr_ci)

upr <- pivot_longer(aza, cols = upr_ci_m:upr_ci_f, 
                    values_to = "upr_ci",
                    names_to = "upr_sex") %>% 
  select(common_name, latin_name, class, upr_sex, upr_ci)
#can't do upper because there are spaces and dashes in the upr_ci_f
View(aza)
unique(aza$upr_ci_f)
#clean the data (for upr):

# Conditional values assignment #### 
#assigning value depending on logical condition
aza %>% 
  mutate(upr_ci_f = case_when( #assign it to a value depending on current value
    upr_ci_f %in% c("-", "") ~ NA_character_, #assign chara NA to those rows
    #need to assign what type of NA; in this case, NA_character_ b/c
    # column is character
    TRUE ~ upr_ci_f #for the rest, keep as-is the current value
  #TRUE means in every other case
    )) %>% 
  mutate(upr_ci_f = as.numeric(upr_ci_f)) #now can turn into character

#another way to combine the mutate functions into one statement
aza %>% 
  mutate(upr_ci_f = case_when( 
    upr_ci_f %in% c("-", "") ~ NA_character_, 
    TRUE ~ upr_ci_f 
  ),
 upr_ci_f = as.numeric(upr_ci_f)) 

#another way to pipe w/ as numeric inside case_when
aza %>% 
  mutate(upr_ci_f = as.numeric(case_when( 
    upr_ci_f %in% c("-", "") ~ NA_real_,
    TRUE ~ upr_ci_f) 
  )) %>% 
  mutate(upr_ci_f = as.numeric(upr_ci_f)) 

#Pipe this conditional values to making the upr section
upr <- aza %>% 
  mutate(upr_ci_f = case_when( 
    upr_ci_f %in% c("-", "") ~ NA_character_, 
    TRUE ~ upr_ci_f 
  ),
  upr_ci_f = as.numeric(upr_ci_f)) %>% 
  pivot_longer(cols = upr_ci_m:upr_ci_f, #remove aza b/c data piped from prev.
               values_to = "upr_ci",
               names_to = "upr_sex") %>% 
  select(common_name, latin_name, class, upr_sex, upr_ci)


#Now combine the mle, lwr, and upr data.frames that were created. 

#can match based on species, latin.name, etc, BUT
#need to make a shared sex column because doesn't know which one to match
#another conditional values assignment
mle <-  mle %>% 
  mutate(sex = case_when(
    sex == "mle_m" ~ "M", 
    sex == "mle_f" ~ "F"
  ))

lwr <-  lwr %>% 
  mutate(sex = case_when(
    lwr_sex == "lwr_ci_m" ~ "M", 
    lwr_sex == "lwr_ci_f" ~ "F"
  )) %>% 
  select(-lwr_sex) #remove the unnecessary sex column now b/c created new col

upr <-  upr %>% 
  mutate(sex = case_when(
    upr_sex == "upr_ci_m" ~ "M", 
    upr_sex == "upr_ci_f" ~ "F"
  )) %>% 
  select(-upr_sex)
 
#Now, combine all three to make cleaned up version of aza
new_aza <- mle %>% 
  left_join(lwr) %>%
  left_join(upr)


#Overall, have to take many steps
#Split into three sections to pivot three variables
#fix issue with the data (bonus)
#Conditional value assignment three times for sex in three tables
#then left join

#^a lot of work --> why tidy data pays off!
