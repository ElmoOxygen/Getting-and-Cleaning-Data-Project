library(dplyr)

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")
unzip("getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")

##Read in txt files with pertinent data
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "activity_code")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "activity_code")

##Merge data into one dataframe
X_df <- rbind(x_train, x_test)
Y_df <- rbind(y_train, y_test)
subject <- rbind(subject_train, subject_test)
all_data <- cbind(subject, X_df, Y_df)

#Pull out mean and std columns
grab_columns <- grep("subject|activity_code|mean|std", colnames(all_data), ignore.case = TRUE)
data_tidy <- all_data[,grab_columns]

##Give activities names
data_tidy$activity_code <- activities[data_tidy$activity_code, "activity"]

##Making feature names readable
colnames(data_tidy) <- gsub("^t|\\.t", "Time", colnames(data_tidy))
colnames(data_tidy) <- gsub("^f", "Frequency", colnames(data_tidy))
colnames(data_tidy) <- gsub("\\.{2,}", ".", colnames(data_tidy))
colnames(data_tidy) <- gsub("\\.$", "", colnames(data_tidy))
colnames(data_tidy) <- gsub("Acc", "Accelerometer", colnames(data_tidy))
colnames(data_tidy) <- gsub("Gyro", "Gyroscope", colnames(data_tidy))
colnames(data_tidy) <- gsub("Mag", "Magnitude", colnames(data_tidy))
colnames(data_tidy) <- gsub("angle", "Angle", colnames(data_tidy))
colnames(data_tidy) <- gsub("gravity", "Gravity", colnames(data_tidy))

##Bring activity_code feature to the front
data_tidy <- data_tidy[, c(1, ncol(data_tidy), c(3:ncol(data_tidy)-1))]

##Create table with means grouped by subject and activity
dataSummary <- data_tidy %>% group_by(subject, activity_code) %>% summarise_all(mean)
write.table(dataSummary, "DataSummary.txt", row.names = FALSE)

