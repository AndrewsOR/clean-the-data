# About "run_analysis.R"

## Overview

The script run_analysis.R combines, labels, selects, and aggregates a Human Activity Recognition dataset, and exports a summary dataset to a text file.

### About the Raw Dataset

A group of academic researchers in the field of Human Activity Recognition (HAR) created a dataset of measured activities to develop supervised machine learning algorithms.  To produce this dataset, they fitted a group of thirty human subjects with accelerometers and gyroscopes while they performed six activities, measuring their directional and rotational motion.[^har]  

The dataset is available (along with a full description) at <http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>.

According to the principles of "tidy data", this HAR dataset is "messy" because observational units span multiple tables.[^hadley]  Training and test data are in separate tables, and the activity identifiers _y_ are separate from the activity measurements _X_ and the subject identifiers:   


  |     X         | y             | subject          |
  |:--------------|:--------------|:-----------------|
  | X_train (70%) | y_train (70%) | subj_train (70%) |
  | X_test (30%)  | y_test (30%)  | subj_test (30%)  |
  
Once this table is re-assembled from its parts, it is no longer "messy," but for our purposes it is still not very useful: the activity names are in a separate table from the activity identifiers, and the measurement variable names are in a separate table from the measurement values.  Furthermore, the measurements are a mixture of means and standard deviations, which does not violate tidy-ness but is still rather confusing.  

### About the Script

In accordance with the assignment, the script performs the following tasks:

* Downloads, unzips, and reads the data files.
* Merges the training and the test sets (see table above) to create one data set.  (Task 1)
* Extracts only the measurements on the mean and standard deviation for each measurement. (Task 2)
* Uses descriptive activity names to name the activities in the data set. (Task 3)
* Appropriately labels the data set with descriptive variable names. (Task 4)
* Creates the tidy activity data set.
* From the data activity data set, creates a tidy summary data set with the average of each variable for each activity and each subject. (Task 5)
* Exports the summary data set.
* Writes column attributes of the summary data set to the codebook.

Because it's easier to extract measurements (Task 2) once the descriptive variable names have been applied (Task 4), we're going to do things a little out of order.  Here is the order that the script actually takes:

##### Download, unzip, and read data files

We first download the zipped dataset from the Coursera website.  We then (manually) inspect the file structure to determine how to reference the dataset component files.  Noting that the file names are of the pattern "a_b.txt" where _a_ takes values _X_, _y_, and _subject_, and _b_ takes values _test_ and _train_ and determines which subfolder the files are in, a nested loop concisely handles these reading steps.  We then read in two other files, the activity and feature labels. 

##### Merge the training and test sets

We _rbind_ the X train and test tables, then copy the merged activity and subject identifier columns into X.

##### Name the activities

We create a new factor variable for activity name using the _activity_id_ from the _y_ tables as the index and the activity labels ("walking," etc.) as the levels.  Using a factor is almost as efficient, storage-wise, as the integer identifier, but is more intelligible in subsetting and output (and is correctly interpreted under default settings by regression models, if we were doing that).
  
##### Provide descriptive variable names

We use a couple regexes to make the measurement (or "feature") labels acceptable variable names, then replace the default variable names (V1, V2, etc.) with the feature names.

##### Extract only the mean and standard deviation measurements

Now that we have the descriptive variable names in X, we apply a regex to them to keep only the ones *ending* with "mean" or "std" (as well as the subject and activity ids).  Thus, we will keep the magnitude variables such as those that were originally "tBodyAccMag-mean()" or "fBodyAccMag-std()" but NOT directional components such as "fBodyAcc-mean()-X" or "fBodyAccJerk-meanFreq()-Z".  

This was an "open question" per the Community TA:
<https://class.coursera.org/getdata-008/forum/thread?thread_id=24>, so I am interpreting it in the easiest way.
   
##### Create the tidy activity data set "tidyX"

**Tidyr** requires a unique observation identifier, so we create _obs_id_ as the row number of X.  We then use gather, separate, mutate, arrange, and spread to create a data set "tidyX" with the columns:

* **subject_id** (integer, which subject, e.g. 30)
* **activity_nm** (factor, which activity, e.g. "WALKING")
* **obs_id** (the row number of X, e.g., 79.  This is useful because it allows you to group feature measurements that occurred simultaneously and to sequence them for a given subject.)
* **feature_nm** (factor, e.g. "tBodyAccMag," the linear or angular acceleration that the device is measuring)
* **mean_amt** (numeric, e.g. -0.1668, the mean measured amount of the feature over the time window)
* **std_amt** (numeric, e.g. -0.3996, the standard deviation of the measured amount of the feature over the time window)  

Note that the feature name and type of stat (mean vs. std) were originally given in the same column (e.g., "fBodyBodyGyroJerkMag_mean").  These attributes had to be _separated_ before the types of stat could be _spread_ over the observation.

##### Create the tidy summary data set "tidyXsumm"

Because we are asked to calculate the mean-of-mean and mean-of-standard-deviation of the above data set, grouped by activity, subject, and feature, we use _group_by_ and _summarise_ in **plyr** to summarize the data in the data frame "tidyXsumm" with the following columns:

* **feature_nm**
* **activity_nm**
* **subject_id**
* **mean_mean**, the average (across _obs_id_) of _mean_amt_
* **mean_stdev**, the average (across _obs_id_) of _std_amt_

##### Export the tidy summary data set

We write the product of the previous step to a space-delimited .txt file.  We check our factor variables (_activity_nm_ and _feature_nm_) to ensure that they do not contain spaces, which would cause problems when reading this .txt.

##### Write to codeBook.md

For convenience, we write the name and class of the columns of TidyXsumm to codeBook.md, appending if the file already exists.  If the column is a factor, the script outputs the levels.  This is **just a starting point** for writing the codebook.  We still have to add a title, explanatory notes, formatting, etc. by hand.
  
### Conclusion: Requirements for a Tidy Data Set

In a manner similar to Codd's third normal form, Hadley Wickham defines[^wic] a dataset as "tidy data" if:

* Each variable forms a column

* Each obseration forms a row

* Each type of observational unit forms a table

The data sets described above produced by this script meet these criteria.


[^har]: Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

[^wic]: Hadley Wickham.  Tidy Data.  Submitted to Journal of Statistical Software.  http://vita.had.co.nz/papers/tidy-data.pdf

