#Class 2024.10.10
#R Crash Course

#Assigning objects ####
x <-  2 #will now see this in the Environment at the right
#can also use x = 2, but recommend using assignment operator

x+x
x-1
x*3
#will see these results in the console below

#Functions ####
?round #will see explanation of function in help at bottom right
#arguments are inputs that give to a function
round(5.78568, 2) # will round number to two decimal points
round(x=5.78568, digits = 2) #can specify which number is which
round(2, 5.78568) #will give different result because not correct order
round(digits =2, x=5.78568) #will give desired result because specifying numbers
round(5.78568, digits =2) #can mix and match the commands; 
# ^ natural to enter the primary number, then name the other arguments
#safe option is to always name the arguments; 
#alternative is knowing the order in which the function reads the arguments

#Data Types ####
# Numeric
x
class(x) #tells me that x is a "numeric" data type

# Integer
x <-  as.integer(x) #coercing numeric value into integer
class(x) #tells me that x is a "integer" data type

# Character
y <- "tree"
class(y) #tells me that x is a "character" data type
#Note: anything wrapped in "quotes" is a character
z <- "2"
class(z) #tells me that x is a "character" data type

# Logical
#Boolean binary data that is T/F
z <- TRUE #TRUE in all caps because is a dedicated word; lowercase doesn't work
class(z) #tells me that x is a "logical" data type

#Guidelines: don't use logical demands, functions, dedicated word,etc. as an assignment
#can check if something is one of these by ?(insert name) search

#These data are categorized in hierarcy of most specific to most general; 
#determines what can convert and what cannot

#Can you convert an integer into numeric?
class(x) #is integer
as.numeric(x) 
#can wrap function to check what you're changing something to (nesting):
class(as.numeric(x)) #is now numeric; functions work inside out
#Yes, always

# Can convert numeric to integer?
class(2) #is numeric
as.integer(2) #gives number 2
class(as.integer(2)) #is now integer
#BUT, check other example:
class(5.78568)
as.integer(5.78568) #rounds to just 5 (truncated)
#Yes, but with care of consequences

# Can I convert a numeric to character?
number <-  10
class(10) #as numeric
class(as.character(number)) #turns to character "10"
#Yes, can also put integer in quotes and turn into a chara.

# Can I convert logical to numeric?
class(z) #as logical (because above in line 44 made it TRUE)
z #returns TRUE
class(as.numeric(z)) #as numeric: get number 1; class: get numeric
z <- FALSE
class(as.numeric(z)) #as numeric: get number 0; class: get numeric
# Yes. 
z <-  as.numeric(z) #overwrite z; Z is number 0

#Can I convert numeric to logical? 
as.logical(z) #as FALSE (because in line 78 we made it FALSE)
z <- 1
as.logical(z)  #returns TRUE because any value not 0 is TRUE
z <- 2
as.logical(z)  #returns TRUE because any value not 0 is TRUE
z <-3
as.logical(z) #returns TRUE because any value not 0 is TRUE
#Yes, but with care of the consequences because might miss non-1 TRUE values
#^wouldn't recommend converting logical to numeric unless model requires
# 0 = FALSE, 1 = TRUE, any other number is TRUE (even negative:)
z <- -10
as.logical(z) #returns TRUE

z <- as.logical(z) #remake logical z for this example
z # returns TRUE (because last value given was -10 [line 94])
#Can we convert logical to character?
class(as.character(z)) #yes, as chara
z <- FALSE
class(as.character(z)) #yes, as chara

z <- as.character(z) #re-class z 

#Can we convert character to logical?
class(as.logical(z)) #returns as logical
as.logical(y) #y was "tree"; returns NA --> NO WARNING 
#Generally, NO. 
#Only if the character value happens to be "TRUE" or "FALSE" ...
#^...which generally doesn't happen unless somehow turn logical into chara.

#Recap ####
# Can turn integers into numbers
# Can turn integers into logical (BUT beware anything non-0 turns into true)
# Can turn integer into chara. because anything can be put into quotes
# Can turn numeric into integer (BUT beware any decimals will be gone)]
# Can turn numeric into chara. because anything can be put into quotes
# Can turn numeric into logical (BUT beware that unless zero is going to be TRUE)
# Can turn logical into integer, 1s and 0s
# Can turn logical into numeric, 1s and 0s
# Can turn logical into chara. because anything can be put into quotes
# Cannot turn chara. into anything else unless happens to be "number" or "T/F" (in quotes)

#Anything can be a chara: most flexible
#Most specific: logical; conversions still work but restrictive
#will do these conversions a lot so need to remember what can be converted to what 


# Object types ####
#Data type is content; object type are the features (dimensions and what kind of data)

# Most common objects you'll see used in R:
# Vector - like a line, collection of elements of same data type (numbs,T/'F, etc,)
vec1 <- c(1, 2, 3) #c means to combine, which creates a vector
class(vec1) #returns numeric; even though are integers, R defaults to numeric
length(vec1) #returns 3
length(y) #returns 1
length(x) #returns 1
length(z) #returns 1
vec1 <- 1:10 #another way to create a vector of sequential numbers; will be integers because whole numbers
#only ONE dimension (length), only objects of SAME data type
vec2 <- c(2,1,0,FALSE,TRUE)
class(vec2) #returns numeric because can turn T/F into numbers which is most encompassing of these values
vec3 <- c(2, TRUE, FALSE, 5, "tree")
class(vec3) #returns character because is most encompassing for these values (can't turn tree into anything else)

# Matrix - two dimensions, tabular with rows and columns, same data types
mat1 <- matrix(1:25, nrow=5, ncol=5)
class(mat1) #returns "matrix" "array"
#^class normally tells object type on anything, except in case of vectors: object type
mode(mat1) #returns "numeric"; mode tells you data type  
mode(vec1) #returns "numeric"

#can check dimensions:
dim(mat1) #returns 5 5
dim(vec1) #returns NULL; vectors just have length

# Array - three dimensions, like deck of cards, stacks of matricies
array1 <- array(1:75, dim = c(5,5,3)) #c is vector of dimensions

# Data Frames - like a matrix (2D), but can contain diff data types in diff columns
#can make dataframe from scratch:
#third column
  #can create different data types per column

#anytime upload data into R (via .csv or SQL), will be as data frame
dragons <- read.csv("../dragons.csv") #relative path (example)
dragons <- read.csv("C:/Users/stei0696/OneDrive - University of Idaho/Fall 2024/WLF 553 Reproducible Data Science/dragons.csv")
class(dragons) #returns "data.frame"

# Lists - most flexible, any data type, but hard to use because of this --> more specific code
list1 <-  list(vec1, mat1, df1) #returns list with vector, matrix, and data frame

# Factor - like a vector, used to categorize data
factor1 <-  factor(x = c("A", "B", "C")) 
#looks like a vectors, but have Levels are the possible values that vectors can take
factor2 <- factor(c("A", "A", "C", "B", "A", "B", "A"))
#for both of these factors, the possible values are A, B, and C
#useful for plotting an visualizing data (figuring out levels to assign colors to)


#Positional subsetting ####
#may want to focus specific elements in an object; think about the dimensions
#subsetting with one dimension:
vec1[4] #returns 4; 4th element of the vector
vec3 <-  LETTERS [1:10]
vec3[3] #returns "C"; 3rd element of this vector
vec3[1] #returns "A"; 1st element of this vector
vec3[1:3] #returns "A" "B" "C" ; can ask for many at a time
vec3[c(3,1,2)] #returns "C" "A" "B" ; can ask for them out of order: positional indicies

#ex: want third element of first vector
list1[[1]][3] #first vector (double brackets to get into that bucket), third item
#double bracket are specific for lists

#subsetting with a 2D object: always row, column, column
mat2[2,2] # returns "07"; row to column

#want number 31:
array1[1,2,2]

#also works for data frames:
df1[1, 2] #returns dog
#want dog and cat:
df1[1:2, 2]#rows one and two, of columns 2, of the data frame --> "dog" and "cat"
#OR can also write as: 
df1[c(1,2), 2] #returns "dog" and "cat"
#can specify many:
df1[c(1, 3, 1, 1, 1), 2] #returns  "dog"  "lion" "dog"  "dog"  "dog" 
