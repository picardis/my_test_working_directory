#Load packages ####
library(DBI)
library(RSQLite)

?DBI

#Consult vignettes ####
vignette(package = "DBI") #to browse list of vignettes
vignette("DBI", package = "DBI") # to open a specific vignette
#^ in this case, the name of the vignette is the same as the package

#Connect to dragons database ####
#^ four # as above creates a bookmark in code so can go back

?dbConnect
# arrow is an assignment object, alt dash to insert

#dragons_db <- creating a new object in R called dragons_db
dragons_db <- dbConnect(RSQLite::SQLite(),"../dragons.db") 
# :: --> the colon colon means the function SQLite from the package RSQLite
#^may not always need this if the function name is unique and don't need to specify the package
#^ (helpful if two different packages have same function name
#^^[or if don't load package in lib])
#SQLite is specifying that it is an SQLite db (driver), "path to db"

#if do db_connect on a db that doesn't exist, will create new .db in working directory
#asignment 6 step 1, will create new name for .db]

#another option if have trouble navigating to correct file path and quick navigate:
dragons_db <- dbConnect(RSQLite::SQLite(),"C:/Users/stei0696/OneDrive - University of Idaho/Fall 2024/WLF 553 Reproducible Data Science/dragons.db") # step 1, will create new name for .db

# Query from the database ####
?dbGetQuery
#Get all data from dragons table
dbGetQuery(conn = dragons_db, statement = "SELECT * FROM dragons;")
#^because didn't assign to anything, will show in the console
#... if want to show in the environments, assign to an object:
dragons <- dbGetQuery(conn = dragons_db, statement = "SELECT * FROM dragons;")

class(dragons)

#Get all data from the capture sites table
capture_sites <- dbGetQuery(conn = dragons_db, 
                            statement = "SELECT * FROM capture_sites;")

#List of tables in database ####
dbListTables(dragons_db)

#want to pull in ad many tables as you want to analze then go from there

dbGetQuery(dragons_db, "SELECT DISTINCT dragon_id from dragons;")
#not creating anything from R, but in console will show output
           
#Create tables ####
?dbExecute
dbExecute(dragons_db, "CREATE TABLE fake_table ( 
          name varchar NOT NULL PRIMARY KEY,
          number real,
          animal varchar
          );")
#erything that you can write in SQL code will go in quotes
##assignment 6 step 2; use SQL queries that already wrote, each table have diff line]

?dbWriteTable #fill data into the table [assignment 6 step 3; next class)
