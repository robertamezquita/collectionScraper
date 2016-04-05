## A more complex method for grabbing pesky URLs
print("Beginning to iterate through the failed cases..")

## Check and start RSelenium
print("Checking for RSelenium server and starting it up..")
RSelenium::checkForServer()
RSelenium::startServer()

## Open remote driver
print("Opening a remote driver..")
remDr <- remoteDriver$new()
remDr$open()

## Iteration over fail
for (i in seq_along(fail)) {
    ## Assign fail site
    print(paste0("Working on fail #", i, ": ", fail[i]))
    site <- fail[i]
    
    ## Navigate to the Site
    remDr$navigate(fail[i])
    
    ## Kill the popup (only for first iteration)
    if (i == 1) {
        print("..Waiting for the dreaded popup..")
        Sys.sleep(time = 5)
        
        print("..Killing the popup..")
        webElem <- remDr$findElement(using = "css selector", value = ".align-center")
        remDr$mouseMoveToLocation(x = -400, y = 0, webElement = webElem)
        remDr$buttondown()
        remDr$buttonup()
        Sys.sleep(time = 1)
    }

    ## Opening multiple options dialog box
    print("..Now open multiple options dialog box..")
    webElem <- remDr$findElement(using = "css selector", value = ".lib_text")
    remDr$mouseMoveToLocation(x = 0, y = 0, webElement = webElem)
    remDr$buttondown()
    remDr$buttonup()
    Sys.sleep(time = 1)
    
    ## Click on find additional links
    print("..Clicking to find additional links..")
    webElem <- tryCatch(remDr$findElement(using = "css selector", value = "#find_more_linkouts_button"),
                        error = function(cond) {
                            message("..Cannot find linkouts")
                            return(NA)
                        })

    ## Check for failure
    if (typeof(webElem) != "S4") {
        if (is.na(webElem)) {
            print("..Moving on to next fail case..")
            next
        }
    }
    
    ## Otherwise, continue finding links
    print("..Found additional links button..")
    remDr$mouseMoveToLocation(x = 0, y = 0, webElement = webElem)
    remDr$buttondown()
    remDr$buttonup()
    
    ## Waiting..
    print("..Waiting to populate additional links..")
    Sys.sleep(time = 15)
}

## Finished, retry simple download method
print("Finished fail cases..now trying to download them simply again..")


## Grab PDFs -------------------------------------------------------------------
print("Now working on downloading each fail paper..")

fail2 <- c()
for (i in seq_along(fail)) {
    ## Assign paper URL; grok title to generate PDF destination name
    paper <- fail[i]
    name <- stringr::str_split(paper, "/") %>% unlist %>% .[length(.)]
    print(paste0("Working on fail paper #", i, ": ", name))

    ## Read the HTML of the paper's URL on QxMD
    print("..Reading the page's HTML..")
    page <- xml2::read_html(paper)

    ## Grab the element with PDF in it
    print("..Grabbing web elements with PDF location..")
    links <- rvest::html_nodes(page, ".txt_999")

    ## Check if there is a link with "pdf" in it
    ## If not, save failed QxMD URL for later download
    check <- grep("pdf", as.character(links))
    if (length(check) == 0) {
        ## warning(paste0("No PDF link found for paper #", i, ": ", name))
        print(paste0("..No PDF link found for paper #", i, ": ", name))
        fail2 <- c(fail2, paper)
        next
    } else {
        print("..PDF link found..")
        pdflink <- links[check[1]] ## use only first match if multiple matches
    }
    ##  Alternative css selectors
    ##  pdflink <- rvest::html_nodes(page, ".linkout:nth-child(3) .txt_999")
    ##  pdflink <- rvest::html_nodes(page, ".linkout~ .linkout+ .linkout .b+ .txt_999")
    
    ## Grok the PDF's URL
    print("..Grokking the URL..")
    pdfurl <- stringr::str_split(as.character(pdflink), " ") %>% unlist %>%
        .[grep("http", .)] %>%
        stringr::str_split(., "<") %>% unlist %>%
        .[grep("http", .)]

    ## Download the file; add to fail2 list if no good
    print("..Downloading..")
    if (!file.exists(paste0(dest, "/", name, ".pdf"))) {
        tryCatch(curl::curl_download(url = pdfurl, destfile = paste0(dest, "/", name, ".pdf"), quiet = FALSE),
                 error = function(cond) {
                     message("..Failed to download file")
                     fail2 <- c(fail2, paper)
                 })        
    } else {
        print("..This paper is already downloaded!")
    }
}
print("Finished going through the (fail) collection Captain!")

## Write fail cases
if (length(fail2) > 0) {
    print("However, some PDFs were still not found..saving these URLs destination to fails.txt..")
    write.table(fail2, file = paste0(dest, "/fails.txt"),
                row.names = FALSE, col.names = FALSE, quote = FALSE)
}

## Adieu
print("Adieu and happy reading!")


