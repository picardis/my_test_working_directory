#Load packages ####
library(DBI)
library(RSQLite)

?DBI

#Consult vignettes ####
vignette(package = "DBI") #to brouwse list of vignettes
vignette("DBI", package = "DBI") # to open a specific vignette
#^ in this case, the name of the vignette is the same as the package

#Connect to dragons database ####
#^ four # as above creates a bookmark in code so can go back

?dbConnect
# arrow is an assignment object, alt dash to insert
# package :: function to specify which package want to work from 
#^ (helpful if two different packages have same function name
#^^[or if don't load package in lib])
#dragons_db <- creating a new object in R called dragons_db
dragons_db <- dbConnect(RSQLite::SQLite(),"../dragons.db") # step 1, will create new name for .db
#another option if have trouble navigating to correct file path and quick navigate:
dragons_db <- dbConnect(RSQLite::SQLite(),"C:/Users/stei0696/OneDrive - University of Idaho/Fall 2024/WLF 553 Reproducible Data Science/dragons.db") # step 1, will create new name for .db

# Query from the database ####
?dbGetQuery
#Get all data from dragons table
dragons <- dbGetQuery(conn = dragons_db, statement = "SELECT * FROM dragons;")

class(dragons)

#Get all data from the capture sites table
capture_sites <- dbGetQuery(conn = dragons_db, 
                            statement = "SELECT * FROM capture_sites;")

dbGetQuery(dragons_db, "SELECT DISTINCT dragon_id from dragons;")
#not creating anything from R, but in console will show output
           
#Create tables ####
?dbExecute
dbExecute(dragons_db, "CREATE TABLE fake_table ( #step 2
          name varchar NOT NULL PRIMARY KEY,
          number real,
          animal varchar,
          ); ")

?dbWriteTable #fill data into the table #step 3 (thurs class)
