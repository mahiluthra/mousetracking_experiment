
rm(list = ls())
dev.off()

library(tidyr)
library(caTools)
library(scales)
library(ggplot2)
library(dplyr)
library(magrittr)

containerSize = c(1000, 600)    # mousetracking container dimensions-- ensure that they are the same as the ones used in the experiment 

cleancommas = function(trialdata){            # cleans x and y coord data (which is stored in a weird comma separated way) and returns vector
  d = toString(trialdata)
  d = as.vector(strsplit(d, ",")[[1]])
  d = as.numeric(d)
  return(d)
}

toVector = function(string){
  return(as.numeric(strsplit(string, ",")[[1]]))
}

orgCoords = function(enterData, contSize = containerSize){             # cleans and organizes the data-- creates a long data frame
    fulldat = data.frame("ntrial" = list(), "xcoords" = list(), "ycoords" = list(), "timest" = list())
    
    for (i in seq(nrow(enterData))){     # runs through all trials of data, cleans the mouse coordinates and stores them in lists
      x = cleancommas(enterData$x.position[i])
      y = cleancommas(enterData$y.position[i])
      t = cleancommas(enterData$mice.times[i])
      
      t = t[complete.cases(x)]    # getting rid of NAs which usually occur in the beginning of any trial due to slow loading of browser
      x = x[complete.cases(x)]
      y = y[complete.cases(y)]
      
      # x and y values need to be rescaled-- the x axis goes from -50 to 50 (with starting position close to 0)
      x = rescale(x, to = c(-50, 50), from = c(0, contSize[1]))
      y = rescale(y, to = c(60,0), from = c(0, contSize[2]))
      
      xcoords = floor(x)
      ycoords = floor(y)
      timest = floor(t)
      ntrial = rep(i, length(timest))
    
      temp = data.frame("ntrial" = ntrial, "xcoords" = xcoords, "ycoords" = ycoords, "timest" = timest)    # returns list made up of lists of coordinates
      fulldat = bind_rows(fulldat, temp)
  }
  return(fulldat)
}
  
timenormalize = function(orgdat){   # normalizes x and y coordinates to contain 101 timesteps of each
  fulldat = data.frame("ntrial" = list(), "xcoords" = list(), "ycoords" = list(), "timest" = list())
  
  for (trial in c(1: orgdat$ntrial[nrow(orgdat)])){
    x = orgdat$xcoords[orgdat$ntrial==trial]
    y = orgdat$ycoords[orgdat$ntrial==trial]
    t = orgdat$timest[orgdat$ntrial==trial]
    
    normalizedx = spline(x, n = 101)$y
    normalizedy = spline(y, n = 101)$y
    normalizedt = spline(t, n = 101)$y
    
    ntrial = rep(trial, 101)
    temp = data.frame("ntrial" = ntrial, "xcoords" = normalizedx, "ycoords" = normalizedy, "timest" = normalizedt)    # returns list made up of lists of coordinates
    fulldat = bind_rows(fulldat, temp)
  }
  return(fulldat)
}

aucCalc = function(orgdat){                              # calculates area under the curve
  auc = c()                                                    # creates empty vector to store values
  
  for (trial in c(1: orgdat$ntrial[nrow(orgdat)])){                      # loops through the data to calculate auc for each trial
    x = orgdat$xcoords[orgdat$ntrial==trial]
    y = orgdat$ycoords[orgdat$ntrial==trial]
    t = orgdat$timest[orgdat$ntrial==trial]
    
    directx = c(x[1], x[length(x)])                            # direct trajectory
    directy = c(y[1], y[length(y)])
    
    totalarea = abs(trapz(x,y))                                # area under actual trajectory
    directarea = abs(trapz(directx,directy))                   # area under direct trajectory
    
    auc = c(auc, (totalarea - directarea) )                    # both are subtracted to give spatial attraction
  }
  
  return(auc)                                                  # returns vector of auc values for all trials
}

visualizeMouse = function(orgdata){                          # graphs mousetrajectories
  ggplot(orgdata, aes(x=xcoords, y=ycoords, group = ntrial)) + 
    xlim(-50, 50) + ylim(0,60) + 
    geom_rect(xmin=-48, xmax=-38, ymin=52, ymax=56) + 
    geom_rect(xmin=38, xmax=48, ymin=52, ymax=56) + 
    geom_rect(xmin=-4.0, xmax=+4.0, ymin=1, ymax=5.0) + 
    geom_point() + geom_path()
}


## running analyses on sample file

data = read.csv("mousetracking_sample_1598874777019.csv", sep = ",")  # change file name to load your file
organizedDat = orgCoords(data)
normalizedDat = timenormalize(organizedDat)
auc = aucCalc(normalizedDat)
plot = visualizeMouse(normalizedDat)

