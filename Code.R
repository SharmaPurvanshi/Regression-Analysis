library(dplyr)
library(corrplot)
library(ggplot2)
library(olsrr)
library(ggcorrplot)
library(polycor)
data <- read.csv('/Users/purvanshisharma/Desktop/iCS2/Bikedata.csv')
data_frame=data.frame(data)



na_counts <- sapply(data, function(x) sum(is.na(x)))
data$Holiday <- as.factor(data$Holiday)

data$Seasons <- as.factor(data$Seasons)
# Print the number of NA values in each column
print(na_counts)
#Question 1
summary(data)


# Calculate correlation matrix
write.csv(data, file = "modified_dataset.csv", row.names = FALSE)
cor_matrix <- hetcor(data)
print(cor_matrix)
model.matrix(~0+., data=data) %>% 
  cor(use="pairwise.complete.obs") %>% 
  ggcorrplot(show.diag=FALSE, type="lower", lab=TRUE, lab_size=2)


#Question 2
model <- lm(log.Rented.Bike.Count ~ ., data = data)

# Print the model summary
summary(model)

par(mfrow = c(2, 2))  # Set the layout for multiple plots

# Residuals vs. Fitted Values Plot
plot(model, which = 1)

# Normal Q-Q Plot
plot(model, which = 2)

# Scale-Location Plot
plot(model, which = 3)

# Residuals vs. Leverage Plot
plot(model, which = 5)

for (col in colnames(data)) {
  if (col != "log.Rented.Bike.Count") {
    # Create a scatter plot with regression line
    p <- ggplot(data, aes_string(x = col, y = "log.Rented.Bike.Count")) +
      geom_point() +
      geom_smooth(method = "lm", se = FALSE, color = "blue") +
      labs(x = col, y = "log.Rented.Bike.Count", title = "Regression Line") +
      theme_minimal()
    
    # Print the plot
    print(p)
  }
}
#Question 3
#check for multicollinearity (VIF)

ols_step_all_possible(model)
best_subset <- ols_step_best_subset(model)
best_subset
# best model Mellows'cp is 
which.min(best_subset$cp)
# best model BIC is
which.min(best_subset$sbic)
# best model AICis
which.min(best_subset$aic)
# best model Adjusted R^2 is
which.max(best_subset$adjr)
#Question4

selected_Model <- lm(log.Rented.Bike.Count ~ Hour + Temperature + Humidity + Wind.speed + Rainfall + Seasons + Holiday, data = data)
summary(selected_Model)
plot(selected_Model)

# 2. Obtain the residuals
residuals <- resid(selected_Model)

# 3. Create residual plots
res<- data$log.Rented.Bike.Count - selected_Model$fitted.values
plot(selected_Model$fitted.values, res, xlab = ("Fitted model"),
     ylab = ("Residuals"), cex = 0.7, main = "",  cex.lab = 1.25)
abline(0,0,col="blue")
qqnorm(res,main="", xlab="Theoretical Quantiles", ylab= "Residuals", cex=0.77, cex.lab = 1.25)
qqline(res, col="blue")
#confidence intervals
car::vif(model)
conf <- confint(selected_Model, data = df, level = 0.95)
selected_Model$xlevels
round(conf,3)
xtable::xtable(conf)
coef <- coef(selected_Model)
semi_elasticity <- 100 * (exp(coef) - 1)
class(coef)
# Print the semi-elasticity effect
semi_elasticity
