

SAVED_MODEL_FILE <- "state/state_0.RObj"

unifize <- function(x) { x / max(x) }

make_rand_SPS_data <- function(N_samples =100) {

    rand_BMI         <- runif(n=N_samples, min=10, max=40)
    rand_Age         <- round(runif(min=18,max=80, n=N_samples))

    diab_probs <- (rand_Age + rand_BMI)/( (40) + (80))

    diabetes_samples <- unlist(lapply(X=as.list(diab_probs), FUN=function(x)
        { sample(x=c(0,1), prob=c(1-x,x), size=1) }
                               ))
    rdata <- cbind(BMI = rand_BMI,
                   Age = rand_Age,
                   HasDiabetes = diabetes_samples
                   )

    trans <- (apply(X=rdata, MARGIN=2, FUN=unifize)) * (1 / ncol(rdata))
    tsum  <- apply(X=trans, MARGIN=1, FUN=sum)
    HasCopd <- (tsum > 0.8)
    rdata <- data.frame(cbind(rdata, HasCopd))
    return(rdata)
}

sample_data <- make_rand_SPS_data();
sample_model <- lm(formula = HasCopd ~ ., data=sample_data)
save(sample_model, file=SAVED_MODEL_FILE)
