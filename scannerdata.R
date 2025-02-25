generate_scanner_data <- function(n) {
  # Load necessary libraries
  library(dplyr)
  library(ggplot2)
  
  # Generate synthetic variables
  Chain <- sample(1:2, n, replace = TRUE)  # 2 different chains
  Brand <- sample(1:10, n, replace = TRUE) # 10 different brands
  Week <- sample(1:52, n, replace = TRUE)  # 52 weeks in a year
  Temperature <- rnorm(n, mean = 20, sd = 5) # Temperature in Celsius
  
  # Generate price variables
  BasePrice <- runif(n, 2, 10)  # Random base price between 2 and 10
  Discount <- runif(n, 0, 0.5)  # Discount percentage (0% to 50%)
  Price_with_discount <- BasePrice * (1 - Discount)
  Price_without_discount <- BasePrice  # Base price without discount
  
  # Define the true DGP
  beta_0 <- 500  # Intercept
  beta_price_discount <- -2  # Price with discount effect
  beta_price_no_discount <- -1.5  # Price without discount effect
  beta_temp <- 20  # Effect of temperature on sales
  beta_chain <- rnorm(2, 0, 50)  # Chain-specific random effects
  beta_brand <- rnorm(10, 0, 30) # Brand-specific random effects
  beta_week <- sin(2 * pi * Week / 52) * 100  # Seasonal effect over 52 weeks
  
  # Generate sales using the defined DGP
  UnitSales <- beta_0 + 
    beta_price_discount * Price_with_discount +
    beta_price_no_discount * Price_without_discount +
    beta_temp * Temperature + 
    beta_chain[Chain] + 
    beta_brand[Brand] + 
    beta_week + 
    rnorm(n, mean = 0, sd = 5)  # Add random noise
  
  # Create a dataframe
  data <- data.frame(Chain = factor(Chain), 
                     Brand = factor(Brand), 
                     Week, 
                     Temperature, 
                     Price_with_discount, 
                     Price_without_discount, 
                     UnitSales)
  
  # Return the generated dataset
  return(data)
}
