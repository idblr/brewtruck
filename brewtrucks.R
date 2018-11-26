###############################################
# Today's Food Trucks at Golden, Colorado Breweries
# Web Calendar Scrape
# 
# Created by: Ian Buller (@idblr)
# Created on: November 26, 2018
#
# Modified by:
# Modified on:
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
today <- c(format(Sys.time(), "%d"), format(Sys.time(), "%B"), format(Sys.time(), "%Y"))

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

# Holidaily
# NOT PERFECT BECAUSE
# Food truck is not always first event listed on calendar
# Somehow pick the correct <tr> that is a food truck
today_hb <- "https://holidailybrewing.com/calendar/"
remDr$navigate(today_hb)
brew_cal <- NULL
while(is.null(brew_cal)){
  brew_cal <- tryCatch({remDr$findElement(using = "xpath", '//table[thead/tr/td[contains(concat( " ", @class, " " ), concat( " ", "fc-today", " " ))]]/tbody/tr[1]/td[count(//table/thead/tr/td[contains(concat( " ", @class, " " ), concat( " ", "fc-today", " " ))])+1]')},
                       error = function(e){NULL})
  #loop until element with name <value> is found in <webpage url>
}
#brew_cal <- remDr$findElement(using = "xpath", '//table[thead/tr/td[contains(concat( " ", @class, " " ), concat( " ", "fc-today", " " ))]]/tbody/tr/td[count(//table/thead/tr/td[contains(concat( " ", @class, " " ), concat( " ", "fc-today", " " ))])]')
hb <- sub(".*\n", "", brew_cal$getElementText())
time_hb <- gsub(" .*$", "", hb)
truck_hb <- gsub("^\\S+\\s+", "", hb)

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

## Compile
golden_breweries <- as.data.frame(cbind(golden, c(truck_ccb, truck_hb, truck_mtb, truck_ntb), c(time_ccb, time_hb, time_mtb, time_ntb)))
names(golden_breweries) <- c("Brewery", "Food Truck", "Opening")
golden_breweries

## Close remote driver
remDr$close()
remDr$server$stop()
remDr$close()
rm(remDr)
gc()


####### End of Code #######