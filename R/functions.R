#' Download and Load RFM Data from GitHub
#'
#' This function downloads the rfm.rda file from GitHub and loads it into the global environment.
#' 
#' @return Loads the rfm dataset into the global environment.
#' @export
download_rfm_data <- function() {
  url <- "https://raw.githubusercontent.com/GilianPonte/MarketingAnalyticsRSM/main/data/rfm.rda"
  destfile <- tempfile(fileext = ".rda")
  
  # Download the file
  download.file(url, destfile, mode = "wb")
  
  # Load the dataset into the global environment
  load(destfile, envir = .GlobalEnv)
}

#' Generate RFM Metrics from Transactions Data
#'
#' This function calculates Recency, Frequency, and Monetary (RFM) metrics 
#' from a transaction dataset.
#'
#' @param transactions A dataframe with columns ID, week, and revenue.
#' @return A tibble with columns:
#'   \item{x}{Number of transactions per customer}
#'   \item{t.x}{Last transaction week for each customer}
#'   \item{m.x}{Average revenue per transaction}
#'   \item{n.cal}{Fixed calendar period (52 weeks)}
#' @export
rfm_from_transactions <- function(transactions) {
  transactions %>%
  dplyr::mutate(
    transaction = revenue > 0  # Create a logical column indicating valid transactions
  ) %>%
  dplyr::group_by(ID) %>%
  dplyr::summarise(
    x = sum(transaction),  # Count the number of transactions per customer
    t.x = ifelse(x > 0, max(week[transaction], na.rm = TRUE), 0),  # Ensure `t.x` is 0 if no transactions
    m.x = ifelse(x > 0, sum(revenue[transaction]) / x, 0),  # Compute mean revenue safely
    n.cal = 52  # Fixed calendar period (52 weeks)
  ) %>%
  dplyr::mutate(m.x = dplyr::coalesce(m.x, 0))  # Replace any NA values in m.x with 0
}

#' Generate Synthetic Scanner Data for Customer Transactions
#'
#' This function simulates scanner data, including customer demographics, 
#' purchasing behavior, pricing, discount effects, and revenue. 
#'
#' @return A dataframe with synthetic scanner data.
#' @export
scanner_data <- function() {
  # Load necessary libraries
  library(dplyr)
  library(ggplot2)
  
  # Set seed for reproducibility
  set.seed(123)
  
  n <- 45602  # Number of observations (individual customers)
  
  # Define supermarket chains
  ChainNames <- c("Albert Heijn", "Jumbo")
  
  # Define lemonade brands categorized by price & promo sensitivity
  HighPromoBrands <- c("Karvan Cévitam", "Belvoir")    # High promo effect
  MediumPromoBrands <- c("Raak", "Taksi")             # Medium promo effect
  LowPromoBrands <- c("AH", "AH Biologisch", "Jumbo", "Van de Boom")  # Low promo effect
  
  # Combine all brand names
  BrandNames <- c(HighPromoBrands, MediumPromoBrands, LowPromoBrands)
  
  # Generate categorical variables
  Chain <- sample(ChainNames, n, replace = TRUE)  # Two supermarket chains
  Brand <- sample(BrandNames, n, replace = TRUE)  # 8 different brands
  Week <- sample(1:52, n, replace = TRUE)         # Week of the year (1-52)
  
  # Model seasonal temperature using a sine function
  avg_temp <- 10 + 10 * sin((2 * pi * (Week - 10)) / 52)  # Seasonal pattern
  Temperature <- rnorm(n, mean = avg_temp, sd = 2)        # Add variation
  
  # Assign base prices by brand category
  BasePrice <- ifelse(Brand %in% HighPromoBrands, runif(n, 5, 10),
                      ifelse(Brand %in% MediumPromoBrands, runif(n, 4, 8),
                             runif(n, 2, 6)))  # Lower prices for household brands
  
  # Generate discounts
  Discount <- runif(n, 0, 0.5)  # Discount (0% to 50%)
  Price_with_discount <- BasePrice * (1 - Discount)
  Price_without_discount <- BasePrice  # Base price without discount
  
  # Generate customer-level characteristics
  Income <- pmax(rnorm(n, mean = 40000, sd = 15000), 10000)  # Ensure income ≥ €10,000
  Age <- sample(18:80, n, replace = TRUE)  # Age range 18-80
  HouseholdSize <- sample(1:6, n, replace = TRUE, prob = c(0.2, 0.3, 0.2, 0.15, 0.1, 0.05))  # Family size distribution
  Education <- sample(c("No Degree", "High School", "Bachelor's", "Master's", "PhD"), 
                      n, replace = TRUE, prob = c(0.1, 0.4, 0.3, 0.15, 0.05))
  
  # Convert categorical variables into factors
  Education <- factor(Education, levels = c("No Degree", "High School", "Bachelor's", "Master's", "PhD"))
  
  # **Loyalty Program Membership Model**
  loyalty_prob <- plogis(-3 + 0.00003 * Income + 1.5 * (Chain == "Albert Heijn") + 0.05 * Week)
  LoyaltyProgram <- rbinom(n, 1, loyalty_prob)  # Binomial draw for membership
  
  # **Assign Targeted Coupon RANDOMLY**
  TargetedCoupon <- rbinom(n, 1, 0.3)  # 30% probability of receiving a coupon
  
  # **Define the Data Generating Process for Revenue**
  beta_0 <- 0.5  # Base intercept for individual revenue
  beta_price_discount <- -0.3  # Effect of discounted price
  beta_price_no_discount <- -0.2  # Effect of normal price
  beta_temp <- 0.1  # Effect of temperature
  beta_chain <- rnorm(length(ChainNames), 0, 0.2)  # Chain-specific effects
  beta_brand <- rnorm(length(BrandNames), 0, 0.3)  # Brand-specific effects
  beta_week <- sin(2 * pi * Week / 52) * 0.5  # Seasonal revenue variations
  beta_loyalty <- 0.8  # Loyalty members buy slightly more
  beta_income <- 0.00001  # Minor effect of income
  beta_coupon <- 1.5  # Coupon effect
  beta_age <- 0.002  # Older customers spend slightly more
  beta_household <- 0.3  # Larger households buy more
  beta_education <- c("No Degree" = -0.2, "High School" = 0, "Bachelor's" = 0.1, "Master's" = 0.2, "PhD" = 0.3)  # Education effect
  
  # Generate revenue per customer
  Revenue <- pmax(0, 
                  beta_price_discount * Price_with_discount +
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
                    rnorm(n, mean = 0, sd = 0.5))  # Add small variation
  
  # Create and return the dataset
  data <- tibble(
    Chain = factor(Chain), 
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
    Revenue
  )
  
  return(data)
}


#' Download and Load RFM Data from GitHub
#'
#' This function downloads the rta.rda file from GitHub and loads it into the global environment.
#' 
#' @return Loads the rta dataset into the global environment.
#' @export
download_rta_data <- function() {
  url <- "https://raw.githubusercontent.com/GilianPonte/MarketingAnalyticsRSM/main/data/rta.rda"
  destfile <- tempfile(fileext = ".rda")
  
  # Download the file
  download.file(url, destfile, mode = "wb")
  
  # Load the dataset into the global environment
  load(destfile, envir = .GlobalEnv)
}

#' Download and Load ps1_ols Data from GitHub
#'
#' This function downloads the ps1_ols.rda file from GitHub and loads it into the global environment.
#'
#' @return Loads the ps1_ols dataset into the global environment.
#' @export
download_ps1_ols_data <- function() {
  url <- "https://raw.githubusercontent.com/GilianPonte/MarketingAnalyticsRSM/main/data/customers.rda"
  destfile <- tempfile(fileext = ".rda")
  
  # Download the file
  download.file(url, destfile, mode = "wb")
  
  # Load the dataset into the global environment
  load(destfile, envir = .GlobalEnv)
}

#' Download and Load ps1_logistic Data from GitHub
#'
#' This function downloads the ps1_logistic.rda file from GitHub and loads it into the global environment.
#'
#' @return Loads the ps1_logistic dataset into the global environment.
#' @export
download_ps1_logistic_data <- function() {
  url <- "https://raw.githubusercontent.com/GilianPonte/MarketingAnalyticsRSM/main/data/cancellations.rda"
  destfile <- tempfile(fileext = ".rda")
  
  # Download the file
  download.file(url, destfile, mode = "wb")
  
  # Load the dataset into the global environment
  load(destfile, envir = .GlobalEnv)
}

#' Download and Load conjoint data from GitHub
#'
#' This function downloads the conjoint file from GitHub and loads it into the global environment.
#'
#' @return Loads the conjoint dataset into the global environment.
#' @export
download_ps1_conjoint_data <- function() {
  url <- "https://raw.githubusercontent.com/GilianPonte/MarketingAnalyticsRSM/main/data/conjoint.rda"
  destfile <- tempfile(fileext = ".rda")
  
  # Download the file
  download.file(url, destfile, mode = "wb")
  
  # Load the dataset into the global environment
  load(destfile, envir = .GlobalEnv)
}
