#' Conjoint Analysis Dataset
#'
#' This dataset is used for conjoint analysis in marketing analytics. 
#' It contains information on consumer choices based on various product attributes.
#'
#' @format A data frame with multiple rows and the following columns:
#' \describe{
#'   \item{person_id}{Unique identifier for each respondent}
#'   \item{choice_id}{Choice set identifier}
#'   \item{urban}{Binary indicator: 1 if the design is urban, -1 if not}
#'   \item{futuristic}{Binary indicator: 1 if the design is futuristic, -1 if not}
#'   \item{stylish}{Binary indicator: 1 if the design is stylish, -1 if not}
#'   \item{retro}{Binary indicator: 1 if the design is retro, -1 if not}
#'   \item{exceeds}{Binary indicator: 1 if safety exceeds EU standards, 0 otherwise}
#'   \item{log.price}{Log-transformed price of the product}
#'   \item{age}{Standardized age of the respondent}
#'   \item{female}{Indicator: -0.5 for male, 0.5 for female}
#'   \item{income}{Standardized income of the respondent}
#'   \item{chose.A}{Binary choice outcome: 1 if option A was chosen, 0 otherwise}
#' }
#' @source \url{https://github.com/GilianPonte/MarketingAnalyticsRSM}
#' @examples
#' data(conjoint)
#' head(conjoint)
"conjoint"
