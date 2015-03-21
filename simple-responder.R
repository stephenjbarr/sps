#!/usr/bin/Rscript

## Stephen J. Barr
## 20 Mar 2015

## This is a proof-of-concept of how the responder should work.
## The program does the following
##

##     1. SPS receives command line argument for location of new data in JSON format
##     2. Uses =jsonlite= to parse the data
##     3. Loads a saved system state
##     4. Creates a prediction based on the new data
##     5. Generates a UUID to identify the processed task
##     6. Saves the prediction as an output JSON file (tagged with UUID), using =uuid= package, =UUIDgenerate()= function
##     7. Creates a plot and saves as =uuid__plot-1.png=


## Step 0.0, load requirements
require(uuid)
require(jsonlite)
require(ggplot2)



## Step 0.1, load system state
ROOT_PATH <- "/sps/"
STATE_FILE <- paste(ROOT_PATH, "state/state_0.RObj", sep="")
stopifnot(file.exists(STATE_FILE))
OUTPUT_DIR <- paste(ROOT_PATH, "output/", sep="")
OUTPUT_PLOTS_DIR <- paste(ROOT_PATH, "output_plots/", sep="")

## Step 1
args   <- commandArgs(trailingOnly = TRUE)
infile <- paste(ROOT_PATH, "data/13329152-e4af-4aa2-a7c8-6bbf1d810844__input.json", sep="")
if(length(args) > 0) {
    infile <- args[1];
}

## make sure that it exists
stopifnot(file.exists(infile))

## Step 2
in_data <- fromJSON(infile)

## Step 3
load(file=STATE_FILE)

## Step 4 - Prediction
x_new <- as.data.frame(in_data)
y_new <- predict.lm(object=sample_model, newdata=x_new)

## Step 5 - task UUID
uuid.task <- UUIDgenerate()

## Step 6 - Generate output file
new_str <- list(
    JobUUID     = uuid.task,
    PatientGuid = in_data$PatientGUID,
    Prediction  = y_new
    )
new_json <- toJSON(new_str)
NEW_JSON_FNAME <- paste(OUTPUT_DIR, in_data$PatientGUID, "____", uuid.task, ".json", sep="")

fileConn<-file(NEW_JSON_FNAME)
writeLines(new_json, fileConn)
close(fileConn)

## Step 7 - make a plot and save it
NEW_PLOT_FNAME <- paste(OUTPUT_PLOTS_DIR, in_data$PatientGUID, "____", uuid.task, ".png", sep="")
ydata <- data.frame(prediction=rnorm(n=100, mean=y_new,sd=2))

m <- ggplot(ydata, aes(x = prediction))
m <- m + geom_density()
m <- m + ggtitle(in_data$PatientGUID)
ggsave(plot=m, filename = NEW_PLOT_FNAME)
dev.off()

print(paste("SUCCESSFULLY PROCESSED", in_data$PatientGUID))
