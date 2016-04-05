## Grab PDFs after ascertaining each individual paper's URL
fail <- c() ## just in case of failures, a place to save them

print("Now working on downloading each paper..")
for (i in seq_along(titles.url)) {
    ## Assign paper URL; grok title to generate PDF destination name
    paper <- titles.url[i]
    name <- stringr::str_split(paper, "/") %>% unlist %>% .[length(.)]
    print(paste0("Working on paper #", i, ": ", name))

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
        fail <- c(fail, paper)
        next
    } else {
        print("..PDF link found..")
        pdflink <- links[check]
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

    ## Download the file
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
print("Finished going through the collection Captain!")

## Write fail cases
if (length(fail) > 0) {
    print("However, some PDFs were not found..saving these URLs destination..")
    ## write.table(fail, file = paste0(dest, "/fails.txt"),
    ##             row.names = FALSE, col.names = FALSE, quote = FALSE)

    ## Running the fail script
    print("Now time to unleash the big guns to download pesky PDFs..")
    flag = 1
} else {
    ## Bid adieu
    print("Got it on the first try! Adieu and Happy reading!")
}
    
