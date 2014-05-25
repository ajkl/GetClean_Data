rm(list=ls())
library(plyr)
testSignalDirectory<-"UCI HAR Dataset/test/Inertial Signals/"
trainSignalDirectory<-"UCI HAR Dataset/train/Inertial Signals/"
featureNames<-read.table("UCI\ HAR\ Dataset/features.txt")
x_testDf<-read.table("UCI\ HAR\ Dataset/test/X_test.txt")
colnames(x_testDf)<-featureNames$V2
x_trainDf<-read.table("UCI\ HAR\ Dataset/train/X_train.txt")
colnames(x_trainDf)<-featureNames$V2
x_mergedDf<-rbind(x_testDf, x_trainDf)

y_testDf<-read.table("UCI\ HAR\ Dataset/test/y_test.txt")
y_trainDf<-read.table("UCI\ HAR\ Dataset/train/y_train.txt")
y_mergedDf<-rbind(y_testDf, y_trainDf)

meanIndex<-grep("mean()", featureNames$V2)
stdIndex<-grep("std()", featureNames$V2)
x_mergedDf<-x_mergedDf[,c(meanIndex, stdIndex)]

testSubjectDf<-read.table("UCI\ HAR\ Dataset/test/subject_test.txt")
trainSubjectDf<-read.table("UCI\ HAR\ Dataset/train/subject_train.txt")
mergedSubjectDf<-rbind(testSubjectDf, trainSubjectDf)
colnames(mergedSubjectDf)<-c("subject")

testSignalFiles<-list.files(testSignalDirectory, pattern="*.txt", full.names=TRUE)
testDirExt<-"test.txt"
testSignalTables<-lapply(testSignalFiles, function(x) data.frame(FileName=substr(x, nchar(testSignalDirectory)+2, nchar(x)-nchar(testDirExt)), read.table(x)))
testNamedTables<-lapply(testSignalTables, function(x) {colnames(x)<-paste(as.vector(x$FileName[1]), 0:(ncol(x)-1), sep=""); x})
testNamedTables<-lapply(testNamedTables, function(x) x[,-1]) #drop filename column
testMergedTables<-do.call(cbind, testNamedTables)

trainSignalFiles<-list.files(trainSignalDirectory, pattern="*.txt", full.names=TRUE)
trainDirExt<-"train.txt"
trainSignalTables<-lapply(trainSignalFiles, function(x) data.frame(FileName=substr(x, nchar(trainSignalDirectory)+2, nchar(x)-nchar(trainDirExt)), read.table(x)))
trainNamedTables<-lapply(trainSignalTables, function(x) {colnames(x)<-paste(as.vector(x$FileName[1]), 0:(ncol(x)-1), sep=""); x})
trainNamedTables<-lapply(trainNamedTables, function(x) x[,-1]) #drop filename column
trainMergedTables<-do.call(cbind, trainNamedTables)

mergedSignalsTables<-rbind(testMergedTables, trainMergedTables)


activityLabels<-read.table("UCI\ HAR\ Dataset/activity_labels.txt", colClasses=c("numeric", "character"))
colnames(activityLabels)<-c("index", "name")
y_mergedDf<-data.frame("activity"=activityLabels$name[y_mergedDf$V1])

finalDf<-cbind(x_mergedDf, y_mergedDf, mergedSubjectDf, mergedSignalsTables)


library(reshape2)
meltDf<-melt(finalDf, id=c("activity", "subject"))
tidyDf<-dcast(meltDf, activity+subject~variable, mean)
write.table(tidyDf, file="tidy_dataset.txt")
