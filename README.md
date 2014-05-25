Data cleaning and processing for Human Activity Recognition Using Smartphones 
========================================================



Environment setup

```r
rm(list = ls())
library(plyr)
library(reshape2)
```


Load test and train files in a dataframe each and change the column names to feature names from the feature.txt file

```r
featureNames <- read.table("UCI HAR Dataset/features.txt")
x_testDf <- read.table("UCI HAR Dataset/test/X_test.txt")
colnames(x_testDf) <- featureNames$V2
x_trainDf <- read.table("UCI HAR Dataset/train/X_train.txt")
colnames(x_trainDf) <- featureNames$V2
```


Combine the test and train dataset by append the rows using rbind

```r
x_mergedDf <- rbind(x_testDf, x_trainDf)
```


Read the prediction variable Y from test and train directories and combine them with row bind

```r
y_testDf <- read.table("UCI HAR Dataset/test/y_test.txt")
y_trainDf <- read.table("UCI HAR Dataset/train/y_train.txt")
y_mergedDf <- rbind(y_testDf, y_trainDf)
```


Fetch the mean and standard deviation features only from the featureset

```r
meanIndex <- grep("mean()", featureNames$V2)
stdIndex <- grep("std()", featureNames$V2)
x_mergedDf <- x_mergedDf[, c(meanIndex, stdIndex)]
```


Read and combine the subjects dataset for each of the test and train observations and assign "subject" as the column name

```r
testSubjectDf <- read.table("UCI HAR Dataset/test/subject_test.txt")
trainSubjectDf <- read.table("UCI HAR Dataset/train/subject_train.txt")
mergedSubjectDf <- rbind(testSubjectDf, trainSubjectDf)
colnames(mergedSubjectDf) <- c("subject")
```


Read the test signals dataset for each of the features and assign feature name to them with the format "<filename>_<1-128 of the features>"

```r
testSignalDirectory <- "UCI HAR Dataset/test/Inertial Signals/"
trainSignalDirectory <- "UCI HAR Dataset/train/Inertial Signals/"
testSignalFiles <- list.files(testSignalDirectory, pattern = "*.txt", full.names = TRUE)
testDirExt <- "test.txt"
testSignalTables <- lapply(testSignalFiles, function(x) data.frame(FileName = substr(x, 
    nchar(testSignalDirectory) + 2, nchar(x) - nchar(testDirExt)), read.table(x)))
testNamedTables <- lapply(testSignalTables, function(x) {
    colnames(x) <- paste(as.vector(x$FileName[1]), 0:(ncol(x) - 1), sep = "")
    x
})
testNamedTables <- lapply(testNamedTables, function(x) x[, -1])  #drop filename column
testMergedTables <- do.call(cbind, testNamedTables)
```


Similar processing for training inertial signals dataset

```r
trainSignalFiles <- list.files(trainSignalDirectory, pattern = "*.txt", full.names = TRUE)
trainDirExt <- "train.txt"
trainSignalTables <- lapply(trainSignalFiles, function(x) data.frame(FileName = substr(x, 
    nchar(trainSignalDirectory) + 2, nchar(x) - nchar(trainDirExt)), read.table(x)))
trainNamedTables <- lapply(trainSignalTables, function(x) {
    colnames(x) <- paste(as.vector(x$FileName[1]), 0:(ncol(x) - 1), sep = "")
    x
})
trainNamedTables <- lapply(trainNamedTables, function(x) x[, -1])  #drop filename column
trainMergedTables <- do.call(cbind, trainNamedTables)
```


Merging the train and test Inertial signals dataset

```r
mergedSignalsTables <- rbind(testMergedTables, trainMergedTables)
```


Adding the descriptive activity names to the dataset replacing the ids

```r
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", colClasses = c("numeric", 
    "character"))
colnames(activityLabels) <- c("index", "name")
y_mergedDf <- data.frame(activity = activityLabels$name[y_mergedDf$V1])
```


Binding all the merged test and train dataset columnwise

```r
finalDf <- cbind(x_mergedDf, y_mergedDf, mergedSubjectDf, mergedSignalsTables)
```


Using reshape to melt the data based on activity and subject combinations.
Using dcast to find the mean for all features with respect to subject and activity combinations.

```r
meltDf <- melt(finalDf, id = c("activity", "subject"))
tidyDf <- dcast(meltDf, activity + subject ~ variable, mean)
```


Writing tidy dataset to the tidy_dataset file

```r
write.table(tidyDf, file = "tidy_dataset.txt")
```

