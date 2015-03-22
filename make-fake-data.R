#!/usr/bin/Rscript --vanilla

require(uuid)
require(jsonlite)

rand_uuid <- UUIDgenerate()
rand_BMI  <- runif(n=1,min=10,max=40)
rand_HasDiabetes <- sample(x=c(0,1), prob=c(0.8,0.2), size=1)
rand_Age <- round(runif(min=18,max=80, n=1))

pdata <- list(
    PatientGUID = rand_uuid,
    BMI = rand_BMI,
    HasDiabetes = rand_HasDiabetes,
    Age = rand_Age
    )


output_fname <- paste("/sps/newData/", rand_uuid, "__input.json", sep="")
output_json  <- toJSON(pdata)

fileConn<-file(output_fname)
writeLines(output_json, fileConn)
close(fileConn)

