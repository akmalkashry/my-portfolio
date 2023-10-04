# Load necessary libraries
library(tidyverse)
library(mice)
library(dplyr)
library(leaflet)
library(sf)
library(corrplot)
library(caret)
library(glmnet)
library(pROC)
library(ggplot2)


# Step 1: Load the dataset
accidents <- read.csv("D:\Portfolio\US_Accidents\Result\US_Accidents_March23.csv")


# Step 2: Check for missing values in specific columns
null_counts_state <- sum(is.na(accidents$State))
null_counts_severity <- sum(is.na(accidents$Severity))
null_counts_temperature <- sum(is.na(accidents$Temperature.F.))
null_counts_windchill <- sum(is.na(accidents$Wind_Chill.F.))
# Print the counts of missing values
cat("Missing values in 'State' column:", null_counts_state, "\n")
cat("Missing values in 'Severity' column:", null_counts_severity, "\n")
cat("Missing values in 'Temperature' column:", null_counts_temperature, "\n")
cat("Missing values in 'Wind Chill' column:", null_counts_windchill, "\n")


# Step 3: Impute Missing Values for Specific Columns
# Specify the number of imputed datasets (m), maximum iterations (maxit), method, and seed
imputed_data <- mice(accidents[, c("Temperature.F.", "Wind_Chill.F.")], m = 1, maxit = 5, method = "pmm", seed = 42) #Adjusted the m, and maxit values to get precise data. The higher values, the higher accuracy but higher time consuming
# Step 3.1: Combine the Imputed Datasets
imputed_data <- complete(imputed_data)
# Now, missing values will be imputed with the values set
# Step 3.2: Check for missing values in specific columns after imputation
null_counts_temperature <- sum(is.na(imputed_data$Temperature.F.))
null_counts_wind_chill <- sum(is.na(imputed_data$Wind_Chill.F.))  
# Print the counts of missing values in the specified columns
cat("Missing values in 'Temperature' column after imputation:", null_counts_temperature, "\n")
cat("Missing values in 'Wind Chill' column after imputation:", null_counts_wind_chill, "\n")
# Step 3.3: Extract the 'State', and 'Severity' columns from the original dataset
state_column <- accidents$State
severity_column <- accidents$Severity
# Step 3.4: Add these columns to the imputed dataset
imputed_data <- cbind(imputed_data, State = state_column, Severity = severity_column)
# Review the column
print(imputed_data)


# Step 4: Clean Data for consistency
imputed_data <- imputed_data %>%
  mutate(State = toupper(State))


# Step 5: EDA based on factor
# Location Analysis (Heatmap)
state_accidents <- imputed_data %>%
  group_by(State) %>%
  summarise(NumAccidents = n())
ggplot(state_accidents, aes(x = State, y = 1, fill = NumAccidents)) +
  geom_tile() +
  labs(title = "Accidents by State (Heatmap)",
       x = "State",
       y = "") +
  scale_fill_gradient(low = "white", high = "red") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
# Severity Distribution (Bar Chart)
imputed_data$Severity <- factor(imputed_data$Severity)
severity_distribution <- imputed_data %>%
  group_by(Severity) %>%
  summarise(Count = n())
ggplot(severity_distribution, aes(x = Severity, y = Count, fill = Severity)) +
  geom_bar(stat = "identity") +
  labs(title = "Severity Distribution of Accidents",
       x = "Severity",
       y = "Count") +
  scale_fill_discrete(name = "Severity Level")
# Correlation Analysis (Correlation Matrix)
correlation_matrix <- cor(imputed_data[, c("Temperature.F.", "Wind_Chill.F.")], use = "complete.obs")
corrplot(correlation_matrix, method = "color", type = "upper", addCoef.col = "black")


# Step 6: Outliers
# Calculate the IQR for Temperature.F.
Q1_temp <- quantile(imputed_data$Temperature.F., 0.25)
Q3_temp <- quantile(imputed_data$Temperature.F., 0.75)
IQR_temp <- Q3_temp - Q1_temp
# Define lower and upper bounds for Temperature.F. outliers
lower_bound_temp <- Q1_temp - 1.5 * IQR_temp
upper_bound_temp <- Q3_temp + 1.5 * IQR_temp
# Identify outliers for Temperature.F.
temperature_outliers <- imputed_data$Temperature.F. < lower_bound_temp | imputed_data$Temperature.F. > upper_bound_temp
# Calculate the IQR for Wind_Chill.F.
Q1_windchill <- quantile(imputed_data$Wind_Chill.F., 0.25)
Q3_windchill <- quantile(imputed_data$Wind_Chill.F., 0.75)
IQR_windchill <- Q3_windchill - Q1_windchill
# Define lower and upper bounds for Wind_Chill.F. outliers
lower_bound_windchill <- Q1_windchill - 1.5 * IQR_windchill
upper_bound_windchill <- Q3_windchill + 1.5 * IQR_windchill
# Identify outliers for Wind_Chill.F.
windchill_outliers <- imputed_data$Wind_Chill.F. < lower_bound_windchill | imputed_data$Wind_Chill.F. > upper_bound_windchill
# Create a new column to flag outliers
imputed_data$Temperature_Outlier <- temperature_outliers
imputed_data$Wind_Chill_Outlier <- windchill_outliers
# Summary of outliers
outlier_summary <- summarise(imputed_data,
                             Temp_Outliers = sum(Temperature_Outlier),
                             Wind_Chill_Outliers = sum(Wind_Chill_Outlier))
# Box plot for Temperature.F.
ggplot(imputed_data, aes(y = Temperature.F.)) +
  geom_boxplot() +
  labs(title = "Box Plot for Temperature.F.",
       y = "Temperature (Fahrenheit)")
# Box plot for Wind_Chill.F.
ggplot(imputed_data, aes(y = Wind_Chill.F.)) +
  geom_boxplot() +
  labs(title = "Box Plot for Wind_Chill.F.",
       y = "Wind Chill (Fahrenheit)")
print(outlier_summary)


# Step 7: Create a modelling machine laerning using Logistic Regression
#Split the Data into Training and Testing Sets
set.seed(123)  # Set a random seed for reproducibility
train_index <- createDataPartition(imputed_data$Severity, p = 0.7, list = FALSE) #Adjusted the p for training dataset
train_data <- imputed_data[train_index, ]
test_data <- imputed_data[-train_index, ]
#Define and Train the Model
model <- glm(Severity ~ Temperature.F. + Wind_Chill.F. + State, data = train_data, family = binomial)


# Step 8: Model Evaluation
# 8.1: Predict on the Test Data
predictions <- predict(model, newdata = test_data, type = "response")
# 8.2: Evaluate Model Performance (ROC and AUC)
library(pROC)  # Load pROC library
roc_obj <- roc(test_data$Severity, predictions)
auc <- auc(roc_obj)
# Print AUC
cat("AUC (Area Under the ROC Curve):", auc, "\n")
# 8.3: Create ROC Curve
roc_curve <- ggroc(roc_obj)
print(roc_curve)
# 8.4: Model Evaluation (Confusion Matrix, Precision, Recall, F1-Score)
threshold <- 0.5  # Adjust threshold as needed
binary_predictions <- ifelse(predictions > threshold, "high", "low")
# Calculate confusion matrix
conf_matrix <- table(Actual = test_data$Severity, Predicted = binary_predictions)
# Check the structure of the confusion matrix
print(conf_matrix)


# Step 9: Model Use (Making Predictions)
new_data_point <- data.frame(Temperature.F. = 75, Wind_Chill.F. = 70, State = "NY") #Adjusted the values to check if severity is high and low
predicted_severity <- predict(model, new_data_point, type = "response")
# Interpret the predicted_severity value
if (predicted_severity > threshold) {
  cat("Predicted Severity: high\n")
} else {
  cat("Predicted Severity: low\n")
}
