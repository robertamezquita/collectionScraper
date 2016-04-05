## Parse all the titles from the fully loaded web page

## Helper function to parse titles from attributes
getTitle <- function(x) {
    sub <- stringr::str_split(as.character(x), "\"") %>% unlist
    title.url <- sub[grep("href", sub) + 1]
    return(title.url)
}

## Select web elements title headers
print("Selecting relevant web elements..")
webElem <- remDr$findElements(using = "css selector", value = ".atl")

## Extract the outer HTML from each web element
print("Extracting the outer HTML from each web element..")
titles <- lapply(webElem, function(x) {
    unlist(x$getElementAttribute("outerHTML"))
}) %>% unlist

## Parse down to get the URL for each web page pertaining to each paper
print("Parsing URLs for each paper..")
titles.url <- lapply(titles, getTitle) %>%
    unlist %>% unique %>%
    paste0(base, .) 

## Close the RSelenium instance
## print("Closing the RSelenium browser..")
## remDr$closeall()
