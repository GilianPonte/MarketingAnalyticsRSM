download_rfm_data <- function() {
    url <- "https://raw.githubusercontent.com/GilianPonte/MarketingAnalyticsRSM/main/data/rfm.rda"
    destfile <- tempfile(fileext = ".rda")
    download.file(url, destfile, mode = "wb")
    load(destfile, envir = .GlobalEnv)
}
