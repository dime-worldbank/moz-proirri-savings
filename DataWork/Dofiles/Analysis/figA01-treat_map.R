  
  # Clear memory
  rm(list=ls())
  
  # IF YOU'RE RUNNING THIS SCRIPT FOR THE FIRST TIME IN YOUR COMPUTER, ACTIVATE THIS
  # SWITCH TO INSTALL THE NECESSARY PACKAGES
  PACKAGES <- 1
  
  # PART 0: Load packages ------------------------------------------------------------
  
  # Before running this you need to have installed at least Rtools 3.3 from here https://cran.r-project.org/bin/windows/Rtools/
  
  # List packages used
  packages  <- c("dplyr",
                 "sp", "rgdal", "rgeos",
                 "ggmap",
                 "leaflet", "geosphere", "foreign")
  
  # If you selected the option to install packages, install them
  if (PACKAGES) {
    install.packages(packages,
                     dependencies = TRUE)
  }
  
  # If the package installation fails, install separately leaflet by running 'install.packages("shiny", type="binary")' directly in the console 
  
  # Load all packages -- this is equivalent to using library(package) for each 
  # package listed before
  sapply(packages, library, character.only = TRUE)
  
  
  # PART 1: File paths ---------------------------------------------------------------
  
  # List users: To find out what is your userame, type Sys.getenv("USERNAME") 

  if (Sys.getenv("USERNAME") == "ruzza") {
    dataFolder <- "C:/Users/ruzza/Dropbox/PROIRRI Financial Literacy - DIME Analytics Code Review"
    githubRepo <- "C:/Users/ruzza/OneDrive/Documenti/GitHub/moz-proirri-savings"
  }
  
  if (Sys.getenv("USERNAME") == "") {
    dataFolder <- ""
    githubRepo <- ""
  }
  
  # PART 2: Create Map ------------------------------------------------------------------
  
  out     <- file.path(dataFolder, "DataWork", "Outputs")
  out_fig <- file.path(githubRepo, "Figures")
  
  # Load CSV data
  GPS_coordinates_all_assocs <- read.csv(file.path(dataFolder, 
                                                   "GPS_assoc.csv"), 
                                          header = T)
  
  # Input Google API key
  register_google(key = "")

  # Get a map
  map <- get_map(location = c(32, -20.5, 38, -16),
                 zoom     = 8,
                 maptype  = "roadmap",
                 source   = "google")
  
  # When you draw a figure, you limit lon and lat.      
  foo <- ggmap(map)+
    geom_point(data=GPS_coordinates_all_assocs,
               size=1.5,
               aes(x=gpslongitude,y=gpslatitude,group=treatment))
  foo
  
  # Produce base map
  baseMap <- get_map(c(32, -20.5, 38, -16))
  
  library(RColorBrewer)
  
  # Overlay associaton GPS coodinates and other figure options
  treatMap <-
    ggmap(baseMap,
          extent = "panel") + 
    geom_point(data=GPS_coordinates_all_assocs,
               size=3,
               aes(x=gpslongitude,
                   y=gpslatitude,
                   group=treatment,
                   shape = factor(treatment),
                   color = factor(treatment)))  +
    xlab("Longitude") + 
    ylab("Latitude")  +
    scale_color_manual(name = "Group", # or name = element_blank()
                       labels = c("Control", "Treatment"),
                       values = c((rgb(26,  71, 111, maxColorValue = 255)),
                                  (rgb( 0, 139, 188, maxColorValue = 255)))) +
    scale_shape_manual(name = "Group",
                       labels = c("Control", "Treatment"),
                       values = c(16, 17))
  
  # Plot map in R
  treatMap
  
  # Save figure in .PNG format
  ggsave(file.path(out_fig, "figA01-treat_map.png"))
  
  
