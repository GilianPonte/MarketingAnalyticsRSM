#' Conjoint Analysis Dataset
#'
#' A dataset used for conjoint analysis in marketing.
#'
#' @format A data frame with multiple rows and the following columns:
#' \describe{
#'   \item{person_id}{Unique identifier for each respondent}
#'   \item{choice_id}{Choice set identifier}
#'   \item{urban}{Binary indicator: 1 if urban, -1 otherwise}
#'   \item{futuristic}{Binary indicator: 1 if futuristic, -1 otherwise}
#'   \item{stylish}{Binary indicator: 1 if stylish, -1 otherwise}
#'   \item{retro}{Binary indicator: 1 if retro, -1 otherwise}
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

#' RFM Analysis Dataset
#'
#' A dataset used for RFM (Recency, Frequency, and Monetary) analysis in marketing.
#'
#' @format A data frame with multiple rows and the following columns:
#' \describe{
#'   \item{customer_id}{Unique identifier for each customer}
#'   \item{recency}{Number of days since the last purchase}
#'   \item{frequency}{Number of purchases made by the customer}
#'   \item{monetary}{Total amount spent by the customer}
#'   \item{segment}{Categorical variable indicating customer segment (e.g., "High Value", "Churn Risk")}
#' }
#' @source \url{https://github.com/GilianPonte/MarketingAnalyticsRSM}
#' @examples
#' data(m9_rfm)
#' head(m9_rfm)
"m9_rfm"
