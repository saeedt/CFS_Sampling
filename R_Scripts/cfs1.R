# Install SamplingStrata library by clicking on Tools>Install Packages and Typing "SamplingSTrata"
# in the search box. Choose "Repository (CRAN)" as source. 
library(SamplingStrata)

# Read the input frame data from 100K_Frame.csv file
CFSFrameData <- read.csv(file="./100K_Frame.csv", header=TRUE, sep=",")

# Build the frame using estno column as identifier, state, county, and naics 
# as auxiliary variables and value as target variable
CFSFrame <- buildFrameDF(df = CFSFrameData,
                         id = "estno",
                         X = c("state",
                               "county",
                               "naics"),
                         Y = c("value"
                         ),
                         domainvalue = "naics")

# Converting value to 15 categories and using it as the fourth auxiliary variable in the frame
CFSFrame$X4 <- var.bin(CFSFrameData$value, bins=15)

# Building the atomic strat based on the frame
AtomicStrata <- buildStrataDF(CFSFrame,  progress = TRUE)

# Uncomment and run the following line to view the atomic strata
#str(AtomicStrata)

# Read the CV constraints from CV.csv file
CVConst <- read.csv("./CV.csv", header=TRUE, sep=",")

# Check the input data for errors
checkInput(errors = CVConst, 
           strata = AtomicStrata,                               
           sampframe = CFSFrame)

# Optimization of stratification
solution <- optimizeStrata(
  errors = CVConst, 
  strata = AtomicStrata,
  parallel = TRUE,
  iter = 100,
  writeFiles = FALSE,
  showPlot = FALSE)

# Writing the stratification and allocation results to csv files
write.table(solution$aggr_strata,file="./aggr_strata.csv", sep=",")
write.table(solution$indices,file="./indices.csv", sep=",")

# Use an improved the initial solution based on kmeans
KmeansInit <- KmeansSolution(AtomicStrata,
                             CVConst,
                             nstrata=NA,
                             minnumstrat=2,
                             maxclusters=NA,
                             showPlot=FALSE)

# Run the algorithm again based on the improved initial solution
solutionkmeans <- optimizeStrata(
  errors = CVConst,
  strata = AtomicStrata,
  suggestions = KmeansInit,
  parallel = TRUE,
  writeFiles = FALSE,
  showPlot = FALSE)

# Writing the stratification and allocation results for the improved initial solution
# to csv files
write.table(solutionkmeans$aggr_strata,file="kmeansaggr_strata.csv", sep=",")
write.table(solution_with_kmeans$indices,file="kmeansindices.csv", sep=",")