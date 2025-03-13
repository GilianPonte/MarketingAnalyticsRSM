download_rfm_data <- function() {
    url <- "https://raw.githubusercontent.com/GilianPonte/MarketingAnalyticsRSM/main/data/rfm.rda"
    destfile <- tempfile(fileext = ".rda")
    download.file(url, destfile, mode = "wb")
    load(destfile, envir = .GlobalEnv)
}
#' @export
rfm_from_transactions <- function(transactions) {
  transactions %>%
    dplyr::mutate(transaction = revenue > 0) %>%
    dplyr::group_by(ID) %>%
    dplyr::summarise(x = sum(transaction),
              t.x = max(week * transaction),
              m.x = sum(revenue * transaction) / x,
              n.cal = 52) %>%
    dplyr::mutate(m.x = dplyr::coalesce(m.x, 0))
}
