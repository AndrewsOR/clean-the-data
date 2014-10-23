# Data Dictionary: tidyXsumm.Rdata

### Variables

> *__Key to Variables__*

> *Variable name: class*

> *n. factor levels (if applicable)*


feature_nm: factor

1. fBodyAccMag
2. fBodyBodyAccJerkMag
3. fBodyBodyGyroJerkMag
4. fBodyBodyGyroMag
5. tBodyAccJerkMag
6. tBodyAccMag
7. tBodyGyroJerkMag
8. tBodyGyroMag
9. tGravityAccMag


activity_nm: factor

1. WALKING
2. WALKING_UPSTAIRS
3. WALKING_DOWNSTAIRS
4. SITTING
5. STANDING
6. LAYING


subject_id: integer


mean_mean: numeric


mean_stdev: numeric


### About the Data

#### Data Source

The original Human Activity Recognition (HAR) data source is more fully described and cited in readMe.md for run_analysis.R  ("About the Raw Dataset").  It contains various measurements of the motion of human subjects performing activities.  

#### Data Attributes

The data included in this summary dataset are summary statistics (averages of mean and standard deviation) for featured measurements for the given activity as performed by the given human subject.  Note that since the data have been normalized, there are no "units."  


* **feature_nm**: factor which names the type of signal identified by the first part of the feature name given in features.txt in the HAR source.
* **activity_nm**: factor which assigns one of six activity labels corresponding to identifiers given in y_train/y_test.txt in the HAR source. 
* **subject_id**: integer which gives the subject identifier (1-30) given in subj_train/sub_test.txt in the HAR source.
* **mean_mean**: numeric which gives the average (across _obs_id_) grouped by feature, activity, and subject, of the column in X corresponding to the mean amount of the measurement of the feature.
* **mean_stdev**: numeric which gives the average (across _obs_id_) grouped by feature, activity, and subject, of the column in X corresponding to the standard deviation of the measurement of the feature.


#### Transformations 

The R script "run_analysis.R" performs several transformations on the HAR dataset:

* Merges the training and the test sets
* Extracts the measurements on the mean and standard deviation for each feature
* Names the activities in the data set
* Labels the measurement columns with feature names
* Creates and exports a tidy summary data set with the average of each variable for each activity and each subject

These transformations, as well as ancillary operations, are described in greater detail in "readMe.md." 