scanner_data <- function() {
  # Load necessary libraries
  library(dplyr)
  library(ggplot2)
  
  # Set seed for reproducibility
  set.seed(123)
  
  n = 45602  # Number of observations (individual customers)
  
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
  
  # Generate customer-level characteristics
  Income <- pmax(rnorm(n, mean = 40000, sd = 15000), 10000)  # Income ≥ €10,000
  Age <- sample(18:80, n, replace = TRUE)  # Age between 18 and 80
  HouseholdSize <- sample(1:6, n, replace = TRUE, prob = c(0.2, 0.3, 0.2, 0.15, 0.1, 0.05))  # Family size
  Education <- sample(c("No Degree", "High School", "Bachelor's", "Master's", "PhD"), 
                      n, replace = TRUE, prob = c(0.1, 0.4, 0.3, 0.15, 0.05))
  
  # Convert categorical variables into factors
  Education <- factor(Education, levels = c("No Degree", "High School", "Bachelor's", "Master's", "PhD"))
  
  # **Loyalty Program Membership Probability Model**
  loyalty_prob <- plogis(-3 + 0.00003 * Income + 1.5 * (Chain == "Albert Heijn") + 0.05 * Week)
  LoyaltyProgram <- rbinom(n, 1, loyalty_prob)  # Assign membership using binomial draw
  
  # **Assign Targeted Coupon RANDOMLY**
  TargetedCoupon <- rbinom(n, 1, 0.3)  # 30% probability of receiving a coupon, independent of covariates
  
  # Define the true DGP (Data Generating Process) for **individual-level revenue**
  beta_0 <- 0.5  # Small intercept for individual-level revenue
  beta_price_discount <- -0.3  # Smaller effect per unit purchase
  beta_price_no_discount <- -0.2  # Still influences revenue, but less extreme
  beta_temp <- 0.1  # Small but noticeable effect of temperature
  beta_chain <- rnorm(length(ChainNames), 0, 0.2)  # Chain-specific small effects
  beta_brand <- rnorm(length(BrandNames), 0, 0.3)  # Brand-specific small effects
  beta_week <- sin(2 * pi * Week / 52) * 0.5  # Seasonal revenue variations
  beta_loyalty <- 0.8  # Loyalty members tend to buy slightly more
  beta_income <- 0.00001  # Minor effect of income on revenue
  beta_coupon <- 1.5  # Coupons increase revenue but on a small scale
  beta_age <- 0.002  # Older customers may spend slightly more
  beta_household <- 0.3  # Larger households buy more lemonade
  beta_education <- c("No Degree" = -0.2, "High School" = 0, "Bachelor's" = 0.1, "Master's" = 0.2, "PhD" = 0.3)  # Education impact
  
  # Generate revenue per customer
  Revenue <- pmax(0, beta_price_discount * Price_with_discount +
                    beta_price_no_discount * Price_without_discount +
                    beta_temp * Temperature + 
                    beta_chain[match(Chain, ChainNames)] +  
                    beta_brand[match(Brand, BrandNames)] +  
                    beta_week + 
                    beta_loyalty * LoyaltyProgram + 
                    beta_income * Income +
                    beta_coupon * TargetedCoupon +
                    beta_age * Age +
                    beta_household * HouseholdSize +
                    beta_education[as.character(Education)] +
                    rnorm(n, mean = 0, sd = 0.5))  # Small variation in revenue
  
  # Create a dataframe
  data <- data.frame(Chain = factor(Chain), 
                     Brand = factor(Brand), 
                     Week, 
                     Temperature, 
                     Price_with_discount, 
                     Price_without_discount, 
                     LoyaltyProgram, 
                     Income, 
                     Age, 
                     HouseholdSize,
                     Education,
                     TargetedCoupon,
                     Revenue)
  
  # Return the generated dataset
  return(data)
}
