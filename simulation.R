# This script contains simulated analyses to assess the Type I error rate
# for using the different quantifications for the Competitive Reaction
# Time Task

# This script was authored by Dr. Randy McCarthy (12/15)
# any question can be sent to rmccarthy3@niu.edu 

###############################################################################
# load these packages prior to starting 
###############################################################################

library("ggplot2")

###############################################################################
# first, set up the characteristics of your simulations
###############################################################################

nSims <- 3000             #number of simulated experiments
n <- 100                  #number of toal participants 

###############################################################################
# second, set up some empty buckets for your simulations to fill 
###############################################################################

# each of these "buckets" is for a different quantification of the CRTT
# description of each quantification follows the "bucket" 

p1 <- numeric(nSims)    # storage bin for round 1 sound blast
p2 <- numeric(nSims)    # storage bin for mean sound blast trials 1-25
p3 <- numeric(nSims)    # storage bin for number of 8's, 9's, and 10's
p4 <- numeric(nSims)    # storage bin for number of 9's, and 10's
p5 <- numeric(nSims)    # storage bin for sqrt of number of 8's, 9's, and 10's
p6 <- numeric(nSims)    # storage bin for round 1 duration
p7 <- numeric(nSims)    # storage bin for mean duration trials 1-25
p8 <- numeric(nSims)    # mean sound blast and duration trials 1-25
p9 <- numeric(nSims)    # mean of trial 1 sound blast and duration
p10 <- numeric(nSims)   # mean of Volume * duration, trials 1-25
p11 <- numeric(nSims)   # mean of Volume * log(duration), trials 1-25
p12 <- numeric(nSims)   # mean of Volume * sqrt(duration), trials 1-25
pmin <- numeric(nSims)

###############################################################################
# third, run your simulations 
###############################################################################

for(i in 1:nSims){        # for each simulated experiment
                          # generate data for trials 1-25
  group <- c(rep (0,(n/2)), rep (1,(n/2)))
  group <- factor(group, levels = c(0:1), labels = c("control", "experimental"))
  soundBlast <- replicate(25, sample(1:10, n, replace = TRUE))
  duration <- replicate(25, sample(1:10, n, replace = TRUE))
                         # compute dvs
  meanSB <- rowMeans(soundBlast)
  numHigh <- rowSums(soundBlast > 7)
  numHigh2 <- rowSums(soundBlast > 8)
  sqrtNumHigh <- sqrt(numHigh)
  meanDuration <- rowMeans(duration)
  meanSBDuration <- rowMeans(soundBlast, duration)
  meanT1 <- rowMeans(cbind(soundBlast[,1], duration[,1]))
  meanProd <- rowMeans(soundBlast*duration)
  meanProdLog <- rowMeans(soundBlast*log(duration))
  meanProdSqrt <- rowMeans(soundBlast*sqrt(duration))
  
                            # gather those variables in a data.frame
  df <- data.frame(group, soundBlast, duration, meanSB, numHigh, numHigh2,
                   sqrtNumHigh, meanDuration, meanSBDuration, meanT1, meanProd,
                   meanProdLog, meanProdSqrt)
                            # p-value using first trial sound blast
  p1[i] <- t.test(df$X1 ~ df$group)$p.value  
                         # p-value using mean sound blast of trials 1-25
  p2[i] <- t.test(df$meanSB ~ df$group)$p.value  
                         # p-value using number of 8's, 9's, and 10's
  p3[i] <- t.test(df$numHigh ~ df$group)$p.value 
                         # p-value using number of 9's, and 10's
  p4[i] <- t.test(df$numHigh2 ~ df$group)$p.value 
                         # p-value using sqrt of number of 8's, 9's, and 10's
  p5[i] <- t.test(df$sqrtNumHigh ~ df$group)$p.value 
                        # p-value using first trial sound blast
  p6[i] <- t.test(df$X1.1 ~ df$group)$p.value 
                        # p-value using mean duration of trials 1-25
  p7[i] <- t.test(df$meanDuration ~ df$group)$p.value 
                       # p-value using mean of mean blast & mean duration of trials 1-25
  p8[i] <- t.test(df$meanSBDuration ~ df$group)$p.value 
                        # mean of trial 1 sound blast and duration
  p9[i] <- t.test(df$meanT1 ~ df$group)$p.value 
                        # mean of Volume * duration, trials 1-25
  p10[i] <- t.test(df$meanProd ~ df$group)$p.value
                        # mean of Volume * log(duration), trials 1-25
  p11[i] <- t.test(df$meanProdLog ~ df$group)$p.value
                        # mean of Volume * sqrt(duration), trials 1-25
  p12[i] <- t.test(df$meanProdSqrt ~ df$group)$p.value
                         # min p-value of different quantifications
  pmin[i] <- min(p1[i], p2[i], p3[i], p4[i], p5[i], p6[i], p7[i], p8[i], p9[i], p10[i], 
                 p11[i], p12[i])
}

###############################################################################
# fourth, gathering p-values and graphing results 
###############################################################################

d <- data.frame(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, pmin)

# histogram for round 1 sound blast levels 
p1result <- ifelse(p1 <= .05,
                   "significant",
                   "non-significant")

p1Hist <- ggplot(d, aes(p1, fill = p1result)) 
p1Hist + geom_histogram(binwidth = .01, color = "black") +
  scale_fill_manual (values = c("blue", "red")) +
  labs(x = "observed p-value") + 
  ggtitle("p-values for trial 1 sound blast levels") +
theme_classic()

# proportion of p-values less than .05 for round 1 sound blast levels
type1 <- cat("the proportion of significant results is",
             (sum(p1 <= 0.05)/nSims*100),"%")

# histogram for p-values for mean sound blast of trials 1-25
p2result <- ifelse(p2 <= .05,
                   "significant",
                   "non-significant")

p2Hist <- ggplot(d, aes(p2, fill = p2result)) 
p2Hist + geom_histogram(binwidth = .01, color = "black") +
  scale_fill_manual (values = c("blue", "red")) +
  labs(x = "observed p-value") + 
  ggtitle("p-values for mean sound blast levels: trials 1-25") +
  theme_classic()

# proportion of p-values less than .05 for mean sound blast of trials 1-25
type1 <- cat("the proportion of significant results is",
             (sum(p2 <= 0.05)/nSims*100),"%")

# histogram for p-values for number of 8's, 9's, and 10's
p3result <- ifelse(p3 <= .05,
                   "significant",
                   "non-significant")

p3Hist <- ggplot(d, aes(p3, fill = p3result)) 
p3Hist + geom_histogram(binwidth = .01, color = "black") +
  scale_fill_manual (values = c("blue", "red")) +
  ggtitle("p-values for number of sound blast levels 8, 9, and 10") +
  labs(x = "observed p-value") + 
  theme_classic()

# proportion of p-values less than .05 for number of 8's, 9's, and 10's
type1 <- cat("the proportion of significant results is",
             (sum(p3 <= 0.05)/nSims*100),"%")

# histogram for p-values for number of 9's, and 10's
p4result <- ifelse(p4 <= .05,
                   "significant",
                   "non-significant")

p4Hist <- ggplot(d, aes(p4, fill = p4result)) 
p4Hist + geom_histogram(binwidth = .01, color = "black") +
  scale_fill_manual (values = c("blue", "red")) +
  labs(x = "observed p-value") + 
  ggtitle("p-values for number of sound blast levels 9 and 10") +
  theme_classic()

# proportion of p-values less than .05 for number of 9's, and 10's
type1 <- cat("the proportion of significant results is",
             (sum(p4 <= 0.05)/nSims*100),"%")

# histogram for p-values for sqrt of number of 8's, 9's, and 10's
p5result <- ifelse(p5 <= .05,
                   "significant",
                   "non-significant")

p5Hist <- ggplot(d, aes(p5, fill = p5result)) 
p5Hist + geom_histogram(binwidth = .01, color = "black") +
  scale_fill_manual (values = c("blue", "red")) +
  labs(x = "observed p-value") + 
  ggtitle("p-values for square root of number of sound blast levels 8, 9, and 10") +
  theme_classic()

# proportion of p-values less than .05 for sqrt of number of 8's, 9's, and 10's
type1 <- cat("the proportion of significant results is",
             (sum(p5 <= 0.05)/nSims*100),"%")

# histogram for round 1 sound blast duration 
p6result <- ifelse(p6 <= .05,
                   "significant",
                   "non-significant")

p6Hist <- ggplot(d, aes(p6, fill = p6result)) 
p6Hist + geom_histogram(binwidth = .01, color = "black") +
  scale_fill_manual (values = c("blue", "red")) +
  labs(x = "observed p-value") + 
  ggtitle("p-values for sound blast 1 duration") +
  theme_classic()

# proportion of p-values less than .05 for round 1 sound blast duration
type1 <- cat("the proportion of significant results is",
             (sum(p6 <= 0.05)/nSims*100),"%")

# histogram for p-values for mean duration of trials 1-25
p7result <- ifelse(p7 <= .05,
                   "significant",
                   "non-significant")

p7Hist <- ggplot(d, aes(p7, fill = p7result)) 
p7Hist + geom_histogram(binwidth = .01, color = "black") +
  scale_fill_manual (values = c("blue", "red")) +
  labs(x = "observed p-value") + 
  ggtitle("p-values for mean duration for trials 1-25") +
  theme_classic()

# proportion of p-values less than .05 for mean duration of trials 1-25
type1 <- cat("the proportion of significant results is",
             (sum(p7 <= 0.05)/nSims*100),"%")

# histogram for p-values for mean sound blasts and duration of trials 1-25
p8result <- ifelse(p8 <= .05,
                   "significant",
                   "non-significant")

p8Hist <- ggplot(d, aes(p8, fill = p8result)) 
p8Hist + geom_histogram(binwidth = .01, color = "black") +
  scale_fill_manual (values = c("blue", "red")) +
  labs(x = "observed p-value") + 
  ggtitle("p-values for mean sound blast and duration trials 1-25") +
  theme_classic()

# proportion of p-values less than .05 for mean duration of trials 1-25
type1 <- cat("the proportion of significant results is",
             (sum(p8 <= 0.05)/nSims*100),"%")

###############################################################################

# histogram for minimum p-values
pminresult <- ifelse(pmin <= .05,
                     "significant",
                     "non-significant")

pminHist <- ggplot(d, aes(pmin, fill = pminresult)) 
pminHist + geom_histogram(binwidth = .01, color = "black") +
  scale_fill_manual (values = c("blue", "red")) +
  labs(x = "minimum observed p-value") +
  ggtitle("minimum observed p-value from any CRTT quantification") +
  theme_classic()

# proportion of any p-values less than .05 
type1 <- cat("the proportion of any significant result is",
             (sum(pmin <= 0.05)/nSims*100),"%")
