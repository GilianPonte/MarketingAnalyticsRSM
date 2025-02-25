generate_scanner_data <- function(n) {
  # Load necessary libraries
  library(dplyr)
  library(ggplot2)
  
  # Define chain names
  ChainNames <- c("Albert Heijn", "Jumbo")
  
  # Define lemonade brands (from image + Jumbo)
  BrandNames <- c("Karvan Cévitam", "AH", "Raak", "Van de Boom", 
                  "AH Biologisch", "Belvoir", "Taksi", "Jumbo")
  
  # Generate synthetic variables
  Chain <- sample(ChainNames, n, replace = TRUE)  # Two supermarket chains
  Brand <- sample(BrandNames, n, replace = TRUE)  # 8 Dutch lemonade brands
  Week <- sample(1:52, n, replace = TRUE)  # 52 weeks in a year
  
  # Model realistic temperature using a sine function
  avg_temp <- 10 + 10 * sin((2 * pi * (Week - 10)) / 52)  # Seasonal pattern
  Temperature <- rnorm(n, mean = avg_temp, sd = 2)  # Add small variation
  
  # Generate price variables
  BasePrice <- runif(n, 2, 10)  # Random base price between 2 and 10
  Discount <- runif(n, 0, 0.5)  # Discount percentage (0% to 50%)
  Price_with_discount <- BasePrice * (1 - Discount)
  Price_without_discount <- BasePrice  # Base price without discount
  
  # Generate additional customer-related variables
  LoyaltyProgram <- sample(0:1, n, replace = TRUE)  # 0 = No, 1 = Yes
  Income <- pmax(rnorm(n, mean = 40000, sd = 15000), 10000)  # Ensuring income ≥ €10,000
  TargetedCoupon <- sample(0:1, n, replace = TRUE, prob = c(0.7, 0.3))  # 30% received a discount coupon
  
  # Define the true DGP (Data Generating Process)
  beta_0 <- 500  # Intercept
  beta_price_discount <- -2  # Price with discount effect
  beta_price_no_discount <- -1.5  # Price without discount effect
  beta_temp <- 20  # Effect of temperature on sales
  beta_chain <- rnorm(2, 0, 50)  # Chain-specific random effects
  beta_brand <- rnorm(length(BrandNames), 0, 30) # Brand-specific random effects
  beta_week <- sin(2 * pi * Week / 52) * 100  # Seasonal effect over 52 weeks
  beta_loyalty <- 50  # Loyalty program effect
  beta_income <- 0.0005  # Small positive effect of income on sales
  beta_coupon <- 30  # Targeted discount coupon effect
  
  # Generate sales using the defined DGP
  UnitSales <- beta_0 + 
    beta_price_discount * Price_with_discount +
    beta_price_no_discount * Price_without_discount +
    beta_temp * Temperature + 
    beta_chain[match(Chain, ChainNames)] + 
    beta_brand[match(Brand, BrandNames)] + 
    beta_week + 
    beta_loyalty * LoyaltyProgram + 
    beta_income * Income +
    beta_coupon * TargetedCoupon +
    rnorm(n, mean = 0, sd = 5)  # Add random noise
  
  # Create a dataframe
  data <- data.frame(Chain = factor(Chain), 
                     Brand = factor(Brand), 
                     Week, 
                     Temperature, 
                     Price_with_discount, 
                     Price_without_discount, 
                     LoyaltyProgram, 
                     Income, 
                     TargetedCoupon,
                     UnitSales)
  
  # Return the generated dataset
  return(data)
}
