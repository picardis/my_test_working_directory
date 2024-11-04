#Class 2024.10.31
#Arctic Fox Case Study

#Load packages ####
library(DBI)
library(tidyverse)

#Build database ####
#Create db
fox_db <- dbConnect(RSQLite::SQLite(), 
                    "Arctic-Fox_Case-Study/fox_db.db")

#Create table
dbExecute(fox_db, "CREATE TABLE sites (
          site_id char(3) NOT NULL PRIMARY KEY,
          site varchar(20)
          );")

dbListTables(fox_db) #check that table was created
dbListFields(fox_db, "sites") #check what columns are in table

dbExecute(fox_db, "CREATE TABLE site_year_conditions (
          site_year_id integer PRIMARY KEY AUTOINCREMENT,
          site_id char(3), 
          year real,
          rodent real,
          temperature real,
          snow_depth real,
          snow_continuous real,
          FOREIGN KEY (site_id) REFERENCES sites(site_id)
          );")

dbListFields(fox_db, "site_year_conditions")

#Load data ####
phenology <- read.csv("C:/Users/stei0696/OneDrive - University of Idaho/Fall 2024/WLF 553 Reproducible Data Science/my_test_working_directory/Arctic-Fox_Case-Study/morph_phenology.csv")
moult <- read.csv("C:/Users/stei0696/OneDrive - University of Idaho/Fall 2024/WLF 553 Reproducible Data Science/my_test_working_directory/Arctic-Fox_Case-Study/seasonal_moulting_phenology.csv")
sites <- read.csv("C:/Users/stei0696/OneDrive - University of Idaho/Fall 2024/WLF 553 Reproducible Data Science/my_test_working_directory/Arctic-Fox_Case-Study/sites.csv")


head(phenology)
unique(phenology$site)
#have special characters that aren't reading in well
?read.csv
# can't find another way to read in with this code, need to manually modify

#Create Site ID ####
sites <- phenology %>% 
  select(site) %>% 
  distinct() %>% #code through here, know there are 22 unique sites 
  mutate(new_site = gsub(pattern = "�", replacement = "", site)) %>% 
  #^creates new col, new_site, which; replace � in the site names w/ empty string
  mutate(site_id = substr(new_site, 1, 3)) %>% 
  #^creates site_id column, take the first three chara from new_site
  mutate(site_id = case_when(
    new_site == "Slett H" ~ "SlH",
    new_site == "Slettg La" ~ "SlL",
    new_site == "Sletth" ~ "Sle",
    new_site == "Kjelsungbandet S" ~ "KjS",
    new_site == "Kjelsungbandet N" ~ "KjN",
    TRUE ~ site_id #for the rest, keep as-is
    )) %>% 
  #^revise 3-letter column name for those that are not unique
  select(site_id, site)
  
#Not sure what this is below
grepl(pattern = "�", phenology$site_id) 

#Populate the sites table ####
?dbWriteTable

dbWriteTable(fox_db, "sites", sites, append = TRUE)
#^this didn't work on my own

# Check for duplicates in the sites data frame
duplicate_site_ids <- sites %>%
  group_by(site_id) %>%
  filter(n() > 1)

# Print duplicate site IDs, if any
print(duplicate_site_ids)

# Remove duplicates from the sites data frame
sites <- sites %>%
  distinct(site_id, .keep_all = TRUE)  # Keep all columns, but only unique site_id values

dbWriteTable(fox_db, "sites", sites, append = TRUE)
#fixed error, but ended up going down to 21 sites instead of orignal 22


#Check: 
dbGetQuery(fox_db, "SELECT * FROM sites;")
dbListTables(fox_db)
dbListFields(fox_db, "sites")



#Create annual site conditions table ####
phenology %>% 
  left_join(sites, by = "site") %>% 
  mutate(site_id_year = paste(site_id, year, sep = "_")) %>% 
  group_by(site_id, year) %>% 
  tally() #checking code

site_year_conditions <- phenology %>% 
  left_join(sites, by = "site") %>% 
  mutate(site_id_year = paste(site_id, year, sep = "_")) %>% 
  #for fun, creating new column to combine site_id and year
  select(-c(morph, indiv_ID, start_95, median_50, end_0)) %>% 
  #drop specific columns from the dataset to get the distinct info looking for
  #looking for unique combos of snow depth, temp, ...etc.
  distinct() %>% 
  select (-site, -site_id_year) %>% #keep site_id for this info
  relocate(site_id, .before = year) #need to move up to second col to match db 

#make sure to check that the new object made matches what created for db
#b/c when created in db, set site_year_id as auto incroment,
# -- so don't need this in object b/c will be created when writing table

dbExecute(fox_db, "DROP TABLE site_year_conditions")

#Can populate now
dbWriteTable(fox_db, "site_year_conditions", site_year_conditions, 
             append = TRUE)

dbGetQuery(fox_db, "SELECT * FROM site_year_conditions;")

#Have seen process of creating database, wrangling, populating db
#Now just going to focus on wrangling for last 

#Create individuals table ####

individuals <-phenology %>% #start creating it f/ phen table
  select(indiv_ID, morph) %>% #want these two columns, 188 results
  distinct() #173 results
#then (think) need to create individuals table in db w/ auto-increment

#Create moult observations table ####

moult %>% #table doesn't have site_id
  left_join(sites, by = "site") %>% 
  #^join sites table so get site_id to join to site_year_id
  select(site_id, year, indiv_ID, moult_score, date) %>% 
  #^select what we need from this join b/c are duplicate col names
  left_join(site_year_conditions, by = c("site_id", "year")) %>%
  #^ join this table to get site_years_conditions
  select(site_year_id, indiv_ID, date, moult_score) %>% #select what we want
  #because site_year_id was an auto-increment created by SQL, read-in that 
  #newly created table:
  #site_year_conditions <- dbGetQuery(fox_db, "SELECT * FROM site_year_conditions;")
  head()
