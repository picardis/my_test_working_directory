#Class 2024.11.12
#Data visualization with ggplot2

install.packages("viridis")
# Load packages ####

library(tidyverse)
library(DBI)
library(viridisLite)

# Load Data ####

# Establish connection with database
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

# ggplot2 ####

# Scatterplot ####
ggplot(data = morphometrics, #data
       mapping = aes(x = total_body_length_cm, #aesthetics
                     y = wingspan_cm)) + #layer the geometries below
  geom_point()

#Make this prettier
ggplot(data = morphometrics, #data
       mapping = aes(x = total_body_length_cm, #aesthetics
                     y = wingspan_cm)) + #layer the geometries below
   geom_point() +
  labs(x = "Total body length (cm)",
       y = "Wingspan (cm)") +
  theme_light()
       
# Colors ####
#if w/ variable, go in aesthetics
#if w/ other components with design, go in geometries?

#If the colors are not encoding a variable
ggplot(data = morphometrics, 
       mapping = aes(x = total_body_length_cm, 
                     y = wingspan_cm)) +
  geom_point(col = "darkseagreen") + #can also add in a hexcode here
  labs(x = "Total body length (cm)",
       y = "Wingspan (cm)") +
  theme_light()

#If the colors are encoding a specific variable
morphometrics %>% 
  left_join(captures, by = "capture_event") %>% #can pipe straight into ggplot
ggplot(mapping = aes(x = total_body_length_cm, #don't need to designate data because piping from data
                     y = wingspan_cm,
                     color = age_at_capture)) + 
  geom_point() +
  labs(x = "Total body length (cm)",
       y = "Wingspan (cm)",
       color = "Age") + #modify legend title
  theme_light() +
  scale_color_viridis_d(begin = 0.2, end = 0.8) #designate with specific gradient

#Color packages
# https://github.com/kevinsblake/NatParksPalettes/blob/main/README.md
# https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html

#Other viridis packages
morphometrics %>% 
  left_join(captures, by = "capture_event") %>% 
  ggplot(mapping = aes(x = total_body_length_cm, 
                       y = wingspan_cm,
                       color = age_at_capture)) + 
  geom_point() +
  labs(x = "Total body length (cm)",
       y = "Wingspan (cm)",
       color = "Age") + #modify legend title
  theme_light() +
  scale_color_viridis_d(option = "inferno", #other viridis color packages to use
                        begin = 0.2, end = 0.8)
  # scale_color_manual()

# Make the size of points proportional to tarsus length
morphometrics %>% 
  left_join(captures, by = "capture_event") %>% #
  ggplot(mapping = aes(x = total_body_length_cm, 
                       y = wingspan_cm,
                       color = age_at_capture,
                       size = tarsus_length_cm)) + 
  geom_point() +
  labs(x = "Total body length (cm)",
       y = "Wingspan (cm)",
       color = "Age", 
       size = "Tarsus Length (cm)") + #modify legend title
  theme_light() +
  scale_color_viridis_d(option = "inferno", 
                        begin = 0.2, end = 0.8)

# Use different shapes for makes and females 
morphometrics %>% 
  left_join(captures, by = "capture_event") %>% 
  left_join(dragons, by = "dragon_id") %>% 
  mutate(sex = case_when( #b/c juvenile sex is NA, need to manually include and label it 
    is.na(sex) ~ "Unknown", 
    TRUE ~ sex
  )) %>% 
  ggplot(mapping = aes(x = total_body_length_cm, 
                       y = wingspan_cm,
                       color = age_at_capture,
                       size = tarsus_length_cm, 
                       shape = sex)) + 
  geom_point() +
  labs(x = "Total body length (cm)",
       y = "Wingspan (cm)",
       color = "Age", 
       size = "Tarsus Length (cm)",
       shape = "Sex") + 
  theme_light() +
  scale_color_viridis_d(option = "inferno", 
                        begin = 0.2, end = 0.8)

#Make different panels for different species
morphometrics %>% 
  left_join(captures, by = "capture_event") %>% 
  left_join(dragons, by = "dragon_id") %>% 
  mutate(sex = case_when( 
    is.na(sex) ~ "Unknown", 
    TRUE ~ sex
  )) %>% 
  ggplot(mapping = aes(x = total_body_length_cm, 
                       y = wingspan_cm,
                       color = age_at_capture,
                       size = tarsus_length_cm, 
                       shape = sex)) + 
  geom_point() +
  facet_wrap(~species) + #here is where to make new panel
  labs(x = "Total body length (cm)",
       y = "Wingspan (cm)",
       color = "Age", 
       size = "Tarsus Length (cm)",
       shape = "Sex") + 
  theme_light() +
  scale_color_viridis_d(option = "inferno", 
                        begin = 0.2, end = 0.8) +
  scale_shape_manual(values = c(7, 8, 9))
  
#don't need to create a single intermediate object!
  

# Histogram ####
ggplot(data = morphometrics, 
       aes(x = wingspan_cm)) +
    geom_histogram() +
    labs(x = "Wingspan (cm)", 
         y = "Frequency") +
    theme_light()
  
# Density ####
  ggplot(data = morphometrics, 
         aes(x = wingspan_cm)) +
    geom_density(size = 3) +
    labs(x = "Wingspan (cm)", 
         y = "Frequency") +
    theme_light()
  
# Boxplots #### 
  ggplot(data = morphometrics, 
         aes(x = wingspan_cm)) +
    geom_boxplot(color = "darkseagreen") +
    labs(y = "Frequency") +
    theme_light()

#REVIST this isn't working for me to rotate hist axis
  ggplot(data = morphometrics, 
         aes(x = wingspan_cm)) +
    geom_boxplot(color = "darkseagreen") +
    labs(y = "Frequency") +
    theme_light() +
    theme(axis.test.x = element_blank(), 
          axis.ticks.x = element_blank()) +
    scale_y_continuous(breaks = seq(0, max(morphometrics$wingspan_cm, 
                                           na.rm = TRUE),
                                    length.out = 10))

#Make one boxplot per age class #NEED TO FINISH
  morphometrics %>% 
    left_join(captures, by = "capture_event") %>% 
    mutate(age_at_capture = factor(age_at_capture, 
                                   levels = c("Juvenile", 
                                              "Subadult",
                                              "Adult"))) %>% 
    ggplot(aes(y = wingspan_cm, x = age_at_capture)) +
    geom_boxplot(fill = "darkseagreen") +
    labs(y = "Wingspan (cm)", x ="") +
    theme_light() +
    scale_y_continuous(breaks = c(1, 500, 1000, 1500, 200, 2500, 3000))
  
morphometrics %>% 
  left_join(captures, by = "capture_event") %>% 
