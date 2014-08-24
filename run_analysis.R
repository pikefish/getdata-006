## Read Training and Test data sets
xTrain <- read.table("./UCI HAR Dataset/train/X_train.txt", nrows = 7500, colClasses = "numeric")
xTest <- read.table("./UCI HAR Dataset/test/X_test.txt", nrows = 3000, colClasses = "numeric")

## Read list of all features and find all required variables (-mean() and -std())
features <- read.table("./UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)
meanVars <- grep(pattern = "-mean\\(", x = features$V2)
stdVars <- grep(pattern = "-std\\(", x = features$V2)
reqVars <- sort(c(meanVars, stdVars))

## Extract columns of interest from xTrain and xTest 
xTrain <- xTrain[, reqVars]
xTest <- xTest[, reqVars]

## Read subjects and activity for Training and Test data sets
subjTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
yTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
subjTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
yTest <- read.table("./UCI HAR Dataset/test/y_test.txt")

## Merge data sets
train <- cbind(subjTrain, yTrain, xTrain)
test <- cbind(subjTest, yTest, xTest)
df <- rbind(train, test)

## Give names to variables in data set, order data set, and give names to activities
varNames <- features[reqVars, ]$V2
varNames <- gsub("\\(\\)", "", varNames)
varNames <- gsub("\\-", "", varNames)
names(df) <- c("Subject", "Activity", varNames)
df <- df[order(df$Subject,df$Activity),]
activities <- read.table("./UCI HAR Dataset/activity_labels.txt")
df$Activity <- as.factor(df$Activity)
levels(df$Activity) <- activities$V2

## Create data set with the average of each variable for each activity and each subject
require(reshape2)
dfMelt <- melt(df, id = c("Subject","Activity"), measure.vars = varNames)
meanData <- dcast(dfMelt, Subject + Activity ~ variable, mean)

## Write obtained data set into a table
write.table(meanData, file = "./average_values.txt", row.names=FALSE, sep = "\t")
## Uncomment the line below if you want to get the data set as an .xls file
# write.table(meanData, file = "./average_values.xls", row.names=FALSE, sep = "\t")