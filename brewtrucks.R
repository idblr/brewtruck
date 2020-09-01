###############################################
# Today's Food Trucks at Golden, Colorado Breweries
# Web Calendar Scrape
# 
# Created by: Ian Buller (@idblr)
# Created on: November 26, 2018
#
# Most recently modified by: Ian Buller
# Most recently modified on: December 3, 2018
#
# Notes:
# A) Using RSelenium package
# B) Scrape today's food truck at various Golden, CO breweries
# C) Issues:
#     1) Unable to handle mulitple trucks
#     2) Unable to handle mulitple events (i.e. if food truck isn't first event)
#     3) Unable to scrape Google Calendar from Golden City Brewing
# D) Expansions:
#     1) Golden City Brewing
#     2) Shiny web application
# E) Recent modifications
#     1) Added functionality for duplicate events at Holidaily Brewing
###############################################

## Packages
library(RSelenium)

## Load remote driver
rD <- rsDriver() # runs a chrome browser, wait for necessary files to download
remDr <- rD$client

## Short list of breweries in Golden, Colorado with regular food trucks
golden <- c("Cannonball Creek Brewing", "Holidaily Brewing", "Mountain Toad Brewing", "New Terrain Brewing")

## Today's date
# For some websites
today <- c(format(Sys.time(), "%d"), format(Sys.time(), "%m"), format(Sys.time(), "%Y"))

## Web scrape 
# As of 11.25.18 CCB, MTB, and NTB use Square Space for their calendars
# As of 11.25.18 HB uses full calendar
# As of 11.25.18 Golden City Brewing uses google calendar (another method necessary)

# Cannonball Creek
today_ccb <- "http://www.cannonballcreekbrewing.com/"
remDr$navigate(today_ccb)
brew_cal <- NULL
while(is.null(brew_cal)){
  brew_cal <- tryCatch({remDr$findElement(using = "xpath", '//*[contains(concat( " ", @class, " " ), concat( " ", "today", " " ))]')},
                       error = function(e){NULL})
  #loop until element with name <value> is found in <webpage url>
}
ccb <- sub(".*\n", "", brew_cal$getElementText())
time_ccb <- gsub(" .*$", "", ccb)
truck_ccb <- gsub("^\\S+\\s+", "", ccb)
truck_time_ccb <- paste(truck_ccb, " at ", time_ccb, "m", sep = "")

# Holidaily
# NOT PERFECT BECAUSE
# Food truck is not always first event listed on calendar
# Somehow pick the correct <tr> that is a food truck
today_hb <- "https://holidailybrewing.com/taproom/"
remDr$navigate(today_hb)
brew_cal1 <- NULL
while(is.null(brew_cal1)){
  brew_cal1 <- tryCatch({remDr$findElement(using = "xpath", '//table[thead/tr/td[contains(concat( " ", @class, " " ), concat( " ", "fc-today", " " ))]]/tbody/tr[1]/td[count(//table/thead/tr/td[contains(concat( " ", @class, " " ), concat( " ", "fc-today", " " ))])+1]')},
                       error = function(e){NULL})
  #loop until element with name <value> is found in <webpage url>
}
brew_cal2 <- NULL
while(is.null(brew_cal2)){
  brew_cal2 <- tryCatch({remDr$findElement(using = "xpath", '//table[thead/tr/td[contains(concat( " ", @class, " " ), concat( " ", "fc-today", " " ))]]/tbody/tr[1]/td[count(//table/thead/tr/td[contains(concat( " ", @class, " " ), concat( " ", "fc-today", " " ))])+1]')},
                       error = function(e){NULL})
  #loop until element with name <value> is found in <webpage url>
}
#brew_cal <- remDr$findElement(using = "xpath", '//table[thead/tr/td[contains(concat( " ", @class, " " ), concat( " ", "fc-today", " " ))]]/tbody/tr/td[count(//table/thead/tr/td[contains(concat( " ", @class, " " ), concat( " ", "fc-today", " " ))])]')
hb1 <- sub(".*\n", "", brew_cal1$getElementText())
time_hb1 <- gsub(" .*$", "", hb1)
truck_hb1 <- gsub("^\\S+\\s+", "", hb1)
hb2 <- sub(".*\n", "", brew_cal2$getElementText())
time_hb2 <- gsub(" .*$", "", hb2)
truck_hb2 <- gsub("^\\S+\\s+", "", hb2)
ifelse(truck_hb1 == truck_hb2, truck_hb2 <- NA, truck_hb2)
ifelse(is.na(truck_hb2), time_hb2 <- NA, time_hb2)
ifelse(is.na(truck_hb2), 
       truck_time_hb <- paste(truck_hb1, " at ", time_hb1, "m", sep = ""),
       truck_time_hb <- paste(truck_hb1, " at ", time_hb1, "m and ", truck_hb1, " at ", time_hb1, "m", sep = "")
       )

# Mountain Toad          
today_mtb <- paste("http://mountaintoadbrewing.com/events/?view=calendar&month=",today[2],"-",today[3], sep = "")
remDr$navigate(today_mtb)
brew_cal <- NULL
while(is.null(brew_cal)){
  brew_cal <- tryCatch({remDr$findElement(using = "xpath", '//*[contains(concat( " ", @class, " " ), concat( " ", "today", " " ))]')},
                       error = function(e){NULL})
  #loop until element with name <value> is found in <webpage url>
}
mtb <- sub(".*\n", "", brew_cal$getElementText())
time_mtb <- gsub(" .*$", "", mtb)
truck_mtb <- gsub("^\\S+\\s+", "", mtb)
truck_time_mtb <- paste(truck_mtb, " at ", time_mtb, "m", sep = "")

# New Terrain
today_ntb <- "http://newterrainbrewing.com/food-truck-schedule/"
remDr$navigate(today_ntb)
brew_cal <- NULL
while(is.null(brew_cal)){
  brew_cal <- tryCatch({remDr$findElement(using = "xpath", '//*[contains(concat( " ", @class, " " ), concat( " ", "today", " " ))]')},
                       error = function(e){NULL})
  #loop until element with name <value> is found in <webpage url>
}
#brew_cal <- remDr$findElement(using = "xpath", '//*[contains(concat( " ", @class, " " ), concat( " ", "today", " " ))]')
ntb <- sub(".*\n", "", brew_cal$getElementText())
time_ntb <- gsub(" .*$", "", ntb)
truck_ntb <- gsub("^\\S+\\s+", "", ntb)
truck_time_ntb <- paste(truck_ntb, " at ", time_ntb, "m", sep = "")

## Compile
golden_breweries <- as.data.frame(cbind(golden, c(truck_time_ccb, truck_time_hb, truck_time_mtb, truck_time_ntb)))
names(golden_breweries) <- c("Brewery", "Food Truck(s)")
golden_breweries

## Close remote driver
rD$server$stop()
remDr$close()
rm(remDr)
gc()


####### End of Code #######