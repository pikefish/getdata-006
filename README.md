# This is an R Markdown document that expains how the script run_analysis.R works. You can also find some comments in the script's code. 

The first chunk of code

```{r}
xTrain <- read.table("./UCI HAR Dataset/train/X_train.txt", nrows = 7500, colClasses = "numeric")
xTest <- read.table("./UCI HAR Dataset/test/X_test.txt", nrows = 3000, colClasses = "numeric")
```

just reads both data sets and stores them in variables xTrain and xTest. Note that arguments colClasess and nrows are specified to (hopefully :)) save some time on importing data.

Next chunk of code reads all features from the file features.txt and finds those that contain either string "-mean(" or string "-std(" since we focus only on these two measurements. Vector reqVars stores ids of such variables.

```{r}
features <- read.table("./UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)
meanVars <- grep(pattern = "-mean\\(", x = features$V2)
stdVars <- grep(pattern = "-std\\(", x = features$V2)
reqVars <- sort(c(meanVars, stdVars))
```

Using vector reqVars, the next chunk of code extracts corresponding columns from xTrain and xTest data frames. (It is easy to check that the number of columns in these two data frames equals to the total number of features.)

```{r}
xTrain <- xTrain[, reqVars]
xTest <- xTest[, reqVars]
```

Next chunk of code reads the lists of subject who performed the activity and training labels, and stores these data sets in four variables subjTrain, yTrain, subjTest and yTest

```{r}
subjTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
yTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
subjTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
yTest <- read.table("./UCI HAR Dataset/test/y_test.txt")
```

Then all the available data sets are merged into a single data set named df

```{r}
train <- cbind(subjTrain, yTrain, xTrain)
test <- cbind(subjTest, yTest, xTest)
df <- rbind(train, test)
```

Next chunk of code extracts variable names form the features list

```{r}
varNames <- features[reqVars, ]$V2
```

removes parentheses and dashes from the variable names

```{r}
varNames <- gsub("\\(\\)", "", varNames)
varNames <- gsub("\\-", "", varNames)
```

and labels the data set df with descriptive variable names (it gives names Subject and Activity to the first two columns, and names each measurement column with corresponding measurement name from varNames). It also orders the data set (first by subjects and then by activities) to improve data set's readability.

```{r}
names(df) <- c("Subject", "Activity", varNames)
df <- df[order(df$Subject,df$Activity),]
```

Next chunk of code replaces activities codes (numeric values from 1 to 6) with descriptive activity names given in the file activity_labels.txt. This is done by changing the class of Activity column to a factor and replacing its factor levels with the required ones (from activities data frame).

```{r}
activities <- read.table("./UCI HAR Dataset/activity_labels.txt")
df$Activity <- as.factor(df$Activity)
levels(df$Activity) <- activities$V2
```

Next chunk of code converts df into a molten data frame with two id variables and 66 measure variables that correspond to the measurements of the mean and standard deviation. Then it creates new data frame using dcast function and casting formula that computes the average of each measure variable for each subject and each activity

```{r}
require(reshape2)
dfMelt <- melt(df, id = c("Subject","Activity"), measure.vars = varNames)
meanData <- dcast(dfMelt, Subject + Activity ~ variable, mean)
```

Final chunk of code writes the obtained data set into a text file average_values.txt

```{r}
write.table(meanData, file = "./average_values.txt", row.names=FALSE, sep = "\t")
```

