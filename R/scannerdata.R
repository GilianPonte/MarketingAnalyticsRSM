scanner_data <- function() {
  # Load necessary libraries
  library(dplyr)
  library(ggplot2)
  
  # Set seed for reproducibility
  set.seed(123)
  
  n = 45602  # Number of observations
  
  # Define chain names
  ChainNames <- c("Albert Heijn", "Jumbo")
  
  # Define lemonade brands categorized by price and promo sensitivity
  HighPromoBrands <- c("Karvan Cévitam", "Belvoir")  # Most effective
  MediumPromoBrands <- c("Raak", "Taksi")  # Moderately effective
  LowPromoBrands <- c("AH", "AH Biologisch", "Jumbo", "Van de Boom")  # Least effective
  
  # Combine all brands
  BrandNames <- c(HighPromoBrands, MediumPromoBrands, LowPromoBrands)
  
  # Generate synthetic variables
  Chain <- sample(ChainNames, n, replace = TRUE)  # Two supermarket chains
  Brand <- sample(BrandNames, n, replace = TRUE)  # 8 brands
  Week <- as.integer(sample(1:52, n, replace = TRUE))  # 52 weeks in a year
  
  # Model realistic temperature using a sine function
  avg_temp <- 10 + 10 * sin((2 * pi * (Week - 10)) / 52)  # Seasonal pattern
  Temperature <- rnorm(n, mean = avg_temp, sd = 2)  # Add small variation
  
  # Assign base prices based on brand category
  BasePrice <- ifelse(Brand %in% HighPromoBrands, runif(n, 5, 10),
                      ifelse(Brand %in% MediumPromoBrands, runif(n, 4, 8),
                             runif(n, 2, 6)))  # Lower prices for household brands
  
  # Generate discount variables
  Discount <- runif(n, 0, 0.5)  # Discount percentage (0% to 50%)
  Price_with_discount <- BasePrice * (1 - Discount)
  Price_without_discount <- BasePrice  # Base price without discount
  
  # Generate income (ensuring no negatives)
  Income <- pmax(rnorm(n, mean = 40000, sd = 15000), 10000)  # Ensuring income ≥ €10,000
  
  # Define the true DGP (Data Generating Process)
  beta_0 <- 500  # Intercept
  beta_price_discount <- -2  # Price with discount effect
  beta_price_no_discount <- -1.5  # Price without discount effect
  beta_temp <- 20  # Effect of temperature on sales
  beta_chain <- rnorm(length(ChainNames), 0, 50)  # Chain-specific random effects
  beta_brand <- rnorm(length(BrandNames), 0, 30)  # Brand-specific random effects
  beta_week <- sin(2 * pi * Week / 52) * 100  # Seasonal effect over 52 weeks
  beta_income <- 0.0005  # Small positive effect of income on sales
  
  # Generate sales using the defined DGP (excluding Loyalty & Targeted Coupon)
  UnitSales <- beta_0 + 
    beta_price_discount * Price_with_discount +
    beta_price_no_discount * Price_without_discount +
    beta_temp * Temperature + 
    beta_chain[match(Chain, ChainNames)] +  # Corrected indexing
    beta_brand[match(Brand, BrandNames)] +  # Corrected indexing
    beta_week + 
    beta_income * Income +
    rnorm(n, mean = 0, sd = 10)  # Add random noise
  
  # Create a dataframe
  data <- data.frame(Chain = factor(Chain), 
                     Brand = factor(Brand), 
                     Week, 
                     Temperature, 
                     Price_with_discount, 
                     Price_without_discount, 
                     Income, 
                     UnitSales)
  
  # Return the generated dataset
  return(data)
}
