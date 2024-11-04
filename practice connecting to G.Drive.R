#Marina Steiner
#Trying to sync R with Google Drive
#Started 10/8/24; revisited 10/25/2024

#Install and load required packages ####
#install.packages("googledrive") #already done
#install.packages("readxl") #already done
library("googledrive")
library(readxl)

#Find, download and read the file ####

# practice with methods:
  #drive_find(n_max = 30) 
# trying to find file:
  #drive_find(pattern = "processed_data (1)") 
  #drive_find(pattern = "2024-09-30_questionable-data_water-source-cat.xlsx") 
    #retrieves two files with different IDs
  #files <- drive_find(pattern = 
  #"2024-09-30_questionable-data_water-source-cat")
    #also retrieves two files with different IDs
  #drive_get
  #(https://drive.google.com/drive/folders/1Ma7fU8Yy-vY2gBzpCxlh-Hqx9Z-piAft)

# practice on 'In-progress copy' :
# 1.0 Find specific  file in Google Drive:
  file <- drive_get(as_id("1VGArl9F1oj2Ury_TxTfsckGSlRiocHSp")) 
# 1.1 If having issues with drive_get, reauthorize :
drive_auth()
drive_auth(scopes = "https://www.googleapis.com/auth/drive")
drive_auth(email = "mrsteiner5@gmail.com", cache = FALSE)  
  
# 2.0 Download the file to your current working directory 
drive_download(file, path = 
      "C:/Users/stei0696/Desktop/practice_drive_file.xslx", overwrite = TRUE) 
    #just saving to Desktop for now, can change location

# 3.0 Load the Excel file into R
data <- read_excel("C:/Users/stei0696/Desktop/practice_drive_file.xslx") 
  #got many warnings
# 3.1 Save the .xslx as a .csv and try reading in that way instead
write.csv(data, "C:/Users/stei0696/Desktop/practice_drive_file.csv", 
          row.names = FALSE)
data <- read.csv("C:/Users/stei0696/Desktop/practice_drive_file.csv")
head(data) # View the first few rows of the data


#Practice download and read latest version of data spreadsheet ####
file <- drive_get(as_id("1vhEA8AlJb8Fh41d8i4eApUsWvTp892MU")) 
drive_download(file, path = 
 "C:/Users/stei0696/Desktop/2024-09-30_questionable-data_water-source-cat.xlsx",
 overwrite = TRUE) 
data <- read_excel(
  "C:/Users/stei0696/Desktop/2024-09-30_questionable-data_water-source-cat.xlsx") 
#got many warnings
write.csv(data,
  "C:/Users/stei0696/Desktop/2024-09-30_questionable-data_water-source-cat.csv",
  row.names = FALSE)
data <- read.csv(
  "C:/Users/stei0696/Desktop/2024-09-30_questionable-data_water-source-cat.csv")
head(data) # View the first few rows of the data
View(data)
dim(data)
summary(data)
sort(unique(data$Address))
table(data$Address)
#other ideas from Sandra on how to read in .csv:
#library(data.table)
#fread()

#Stopped here ####



#Reuploading to Google Drive:
#install.packages("writexl") #done
library(writexl)
# turn .csv back into .xlsx
write_xlsx(data, "2024-09-30_questionable-data_water-source-cat.xlsx")
drive_auth()  # Authenticate if not done already
# Upload the modified Excel file
drive_upload(
  media = 
    "C:/Users/stei0696/Desktop/2024-09-30_questionable-data_water-source-cat.xlsx",
  path = as_id("1Ma7fU8Yy-vY2gBzpCxlh-Hqx9Z-piAft")  # Adjust if needed
  )
  #got many errors, so try re-authenticating:

# Authenticate with the correct scope
drive_auth(scopes = c("https://www.googleapis.com/auth/drive.file"))
# Clear any old cached tokens
drive_auth(cache = FALSE) 
drive_auth()
# the drive upload still didn't work

#Testing for upload with made simple files:
# Test 1
  writeLines("Test content", "test.txt")
  drive_upload(media = "test.txt", 
               path = as_id("1Ma7fU8Yy-vY2gBzpCxlh-Hqx9Z-piAft"))
#  Test 2
  writeLines("Test upload", "test_upload.txt")
# Try uploading the simple text file
  drive_upload(
    media = "test_upload.txt",
    path = as_id("1Ma7fU8Yy-vY2gBzpCxlh-Hqx9Z-piAft")  # Use the correct folder ID
    )
# Test 3 with .csv
  write.csv(data.frame(test = 1:5), "test_upload.csv")
  drive_upload(
  media = "test_upload.csv",
  path = as_id("1Ma7fU8Yy-vY2gBzpCxlh-Hqx9Z-piAft")
  )

  #all this still didn't work so will save locally and manually upload to Drive


#Next Steps ####
#Haven't done these next step yet but documenting found code for guidance:

#Starting to modify the data ####
# Read the Excel file while converting non-numeric entries to NA
data <- read_excel("C:/Users/stei0696/Desktop/practice_drive_file.xslx",
                   col_types = "text") #read everything as text

# Replace non-numeric entries in the specific column with NA
#need to change 2 to specific position/column in file
data[[2]] <- as.numeric(gsub("-", NA, data[[2]])) # Replace '-' with NA and convert to numeric
#OR can also reference columns by their names:
data$Age <- as.numeric(gsub("-", NA, data$Age))

#replace multiple columns in the data:

##Option 1: Using a loop (useful for small number of columns) ####
library(readxl)
# Read the Excel file treating all columns as text
data <- read_excel("file_name.xlsx", col_types = "text")
# Specify the columns you want to process (by index or by name)
columns_to_process <- c(2, 3)  # Example: processing the 2nd and 3rd columns
# Alternatively: columns_to_process <- c("Age", "Score")  # By column names
# Loop through the specified columns
for (col in columns_to_process) {
  data[[col]] <- as.numeric(gsub("-", NA, data[[col]]))  # Replace '-' with NA and convert to numeric
}
# Check the resulting data
head(data)

##Option 2: Using lapply function (More concise for larger datasets) ####
library(readxl)
# Read the Excel file treating all columns as text
data <- read_excel("file_name.xlsx", col_types = "text")
# Specify the columns you want to process (by index or by name)
columns_to_process <- c(2, 3)  # Example: processing the 2nd and 3rd columns
# Alternatively: columns_to_process <- c("Age", "Score")  # By column names
# Use lapply to process multiple columns
data[columns_to_process] <- lapply(data[columns_to_process], function(x) {
  as.numeric(gsub("-", NA, x))  # Replace '-' with NA and convert to numeric
})
# Check the resulting data
head(data)

##Option 3: using dplyr for a tidy approach (Offers a clean and readable approach, especially for data manipulation)####
library(readxl)
library(dplyr)
# Read the Excel file treating all columns as text
data <- read_excel("file_name.xlsx", col_types = "text")
# Specify the columns you want to process by index or by name
columns_to_process <- c(2, 3)  # Example: processing the 2nd and 3rd columns
# Alternatively: columns_to_process <- c("Age", "Score")  # By column names
# Using dplyr to replace non-numeric entries with NA
data <- data %>%
  mutate(across(all_of(columns_to_process), 
                ~ as.numeric(gsub("-", NA, .))))
# Check the resulting data
head(data)

# Check for NA values
summary(data)