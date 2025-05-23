% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/functions.R
\name{rfm_from_transactions}
\alias{rfm_from_transactions}
\title{Generate RFM Metrics from Transactions Data}
\usage{
rfm_from_transactions(transactions)
}
\arguments{
\item{transactions}{A dataframe with columns ID, week, and revenue.}
}
\value{
A tibble with columns:
  \item{x}{Number of transactions per customer}
  \item{t.x}{Last transaction week for each customer}
  \item{m.x}{Average revenue per transaction}
  \item{n.cal}{Fixed calendar period (52 weeks)}
}
\description{
This function calculates Recency, Frequency, and Monetary (RFM) metrics 
from a transaction dataset.
}
