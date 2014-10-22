###############################################################################
#  Run_analysis.R (Getting & Cleaning Data Course Project)       22 Oct 2014  #
#                                                                             #
#  The script has the following parts, required by the assignment:            # 
#                                                                             #
#  0. (Implicit requirement) Downloads, unzips, and reads the data files.     #
#                                                                             #
#  1. Merges the training and the test sets to create one data set.           #
#                                                                             #
#  2. Extracts only the measurements on the mean and standard deviation for   # 
#     each measurement.                                                       #
#                                                                             #
#  3. Uses descriptive activity names to name the activities in the data set  #
#                                                                             #
#  4. A. Appropriately labels the data set with descriptive variable names.   #
#     B. (Implicit requirement) Creates the first tidy activity data set.     #
#                                                                             #
#  5. From the data set in step 4, creates [and exports] a second,            #  
#     independent tidy data set with the average of each variable for each    # 
#     activity and each subject.                                              #
#                                                                             #
#     ... but please note that the order of parts is 0-1-3-4A-2-4B-5          #
###############################################################################

# _____________________________________________________________________________
# 0)  Download, unzip, and read the "Human Activity Recognition Using 
#     Smartphones Data Set"
#
  #setwd("YOUR_WORKING_DIRECTORY_GOES_HERE")
  url <- paste0("https://d396qusza40orc.cloudfront.net/getdata%2F",
                "projectfiles%2FUCI%20HAR%20Dataset.zip ")
  f = "har.zip"
  download.file(url, f, method="curl")
  unzip(f)
  har_loc = "./UCI HAR Dataset/"
  
  # Read the activity labels into act_labs
  act_labs <- read.table(paste0(har_loc,"activity_labels.txt"),
                         col.names=c("activity_id","activity_nm"),
                         colClasses=c("integer","character"))
  # Read the feature vector labels into feat_labs
  feat_labs <- read.table(paste0(har_loc,"features.txt"),
                          col.names=c("feature_id","feature_nm"),
                          colClasses=c("integer","character"))
  # Read the training and test sets
  for(set in c("test","train")){
    subj_file_nm <- paste0(har_loc,set,"/subject_",set,".txt")
    cat("Reading ",subj_file_nm,"...\n")
    subj_df_nm <- paste0("subj_",set)
    assign(subj_df_nm, read.table(subj_file_nm))
    for(dim in c("X","y")){
      act_file_nm <- paste0(har_loc,set,"/",dim,"_",set,".txt")
      act_df_nm <- paste0(dim,"_",set)
      cat("Reading ",act_file_nm,"...\n")
      assign(act_df_nm, read.table(act_file_nm))
    }
  }
#                                                                 End of part 0
# -----------------------------------------------------------------------------

# _____________________________________________________________________________
# 1)   Merge the training and the test sets to create one data set (named "X")
#      Combine the training and the test sets with activity and subject ids
#
  X <- rbind(X_test,X_train)
  y <- rbind(y_test,y_train)
  subj <- rbind(subj_test, subj_train)
  names(y)<-"activity_id"
  names(subj)<-"subject_id"
#|                                                                End of part 1
# -----------------------------------------------------------------------------


# _____________________________________________________________________________
# 3)   Use descriptive activity names to name the activities in the data set.
#      Use activity labels as factors instead of their respective activity_ids
#      (originally found in the "y" activity label files).
#
  X$activity_nm <- factor(act_labs$activity_nm[y$activity_id], 
                         levels = act_labs$activity_nm)
  X$subject_id <- subj$subject_id
#                                                                 End of part 3
# -----------------------------------------------------------------------------

# _____________________________________________________________________________
# 4A)  Appropriately label the data set with descriptive variable names. 
#      Clean feature labels to use as variable names 
#      (A more thorough regex would check for leading numbers and ensure
#      uniqueness after cleaning. But for now we will just strip punctuation.)
#
  feature_names <- gsub("\\(|\\)", "", feat_labs$feature_nm) # Remove ()'s
  feature_names<- gsub("([[:punct:]]|\\s)+", "_", feature_names) # punct => _
  names(X)[grepl("^V\\d+$",names(X))] <- feature_names # replace V1, V2...
#                                                               End of part 4A
# -----------------------------------------------------------------------------

# _____________________________________________________________________________
# 2)   Extract only the measurements on the mean and standard deviation. 
#      Keep only activity_nm and vars *ending* with "mean" or "std".  Thus,
#      we will keep variables that were originally "tBodyAccMag-mean()" or
#      "fBodyAccMag-std()" but NOT "fBodyAcc-mean()-X" or 
#      "fBodyAccJerk-meanFreq()-Z".  This was an "open question" per the 
#       Community TA:
#       https://class.coursera.org/getdata-008/forum/thread?thread_id=24
#
  X <- X[,grepl("^activity_nm$|^subject_id$|^.+_(mean|std)$", names(X),
                ignore.case=TRUE)]
#                                                                 End of part 2
# -----------------------------------------------------------------------------

# _____________________________________________________________________________
# 4B)   Produce tidy data set "tidyX"
#
  X$obs_id <- 1:nrow(X)   # uniquely identifies a set of measurements in same row             
  library(tidyr)          # which we treat as parts of a single "observation"
  library(dplyr)
  X %>%  gather(key=metric, value=amount, -activity_nm, -subject_id, -obs_id) %>%
    separate(col=metric, into=c("factor_nm","stat")) %>%
    mutate(stat = paste0(stat,"_amt")) %>%
    arrange(activity_nm, subject_id, factor_nm, stat, obs_id) %>%
    spread(stat, amount) -> tidyX
#                                                                End of part 4B
# -----------------------------------------------------------------------------

# _____________________________________________________________________________
# 5)  Create summary "tidyXsumm" from 4B with average of each variable for each 
#     activity and each subject.  Write it to .txt file.
#
  tidyX %>% group_by(factor_nm, activity_nm, subject_id)  %>%
            summarise(mean_mean=mean(mean_amt), 
                      mean_stdev = mean(std_amt)) -> tidyXsumm
  write.table(x=tidyXsumm, file="tidy_step_5.txt",row.names=FALSE)
#                                                                 End of part 5
# -----------------------------------------------------------------------------
  