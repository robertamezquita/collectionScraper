## QxMD Collection Scraping Made Easy

This repository is an `Rscript` (split up into constituent functions) that takes care of scraping PDFs from Read by QxMD public collections. This repo was started because I find it a huge waste of time to go and download one by one each individual PDF. Also, this served as a nice test case for trying to use web scraping technologies such as `(R)Selenium` and other HTML parsing tools (`rvest`, `curl`, `stringr`) to accomplish something that may (or may not) be a time saver in the end.


### Prerequisites

Make sure to have installed the following `R` libraries:

- `optparse`
- `RSelenium`
- `rvest`
- `curl`
- `stringr`

To run the script, first download the repository and modify the permissions to be executable for all files. Then, simply type:

`./collectionScraper.R -s [SITE] -d [DEST}`

You can also show the help by using the `-h` option (thanks `optparse`).

[DEST] is the destination folder where you want your PDFs (which will be created if it does not exist). 

[SITE] should be the Read by QxMD public collection URL that is emailed to you. To get this email, make sure to set your collections (under the star icon) in your Read by QxMD app to be `Public` collections. That way they are (desktop) web accessible. The URL will be emailed to you shortly after setting your collection to be `Public`. The emails come from `webmaster@qxmd.com` in case you want to create an email rule or keep these from going to the spam folder.

[Of note, I am not sure how to access your collection site without this email, as it doesn't seem to be accessible when logged into your QxMD account, so make sure to have email notifications turned on in the app..]


### How it works

The way the script works is as follows:

1. `collectionScraper.R` interprets the arguments, loads the necessary libraries, then sources each subsequent component.
2. `navsite.R` is first executed; this will open a browser instance (using `RSelenium`) and automagically navigate to the bottom to load paper titles. To do this, it uses the `end` key three times to go to the bottom of the page, and prompt the JQuery to load more titles. If there are more than around 80 papers, this may not load all the titles, but it should still be a fairly comprehensive reading list.
3. `extractElements.R` is up next, and extracts the URLs for each paper shown in the QxMD collection.
4. `grabPDFs.R` then comes in to start a first pass of downloading PDFs for all papers where a PDF is available, using a simple HTML parser (`rvest`) and `curl` for downloading. If a PDF is not immediately available, then the URL is saved for a second pass. If no failures occur, then we are finished.
5. `failPDFs.R` will be executed in the likely case of a PDF not being available; first, this script once again uses `RSelenium` to open a new browser window, and clicks on the "More Options > Find Additional Links" prompt to search for additional links. This is performed for each paper where no PDF was found on the first pass. Once this is done for all initial failures, then a second pass is performed using the same `grabPDFs.R` procedure (as the QxMD server seems to keep the generated additional links). If there are still failures, these are saved to a `fails.txt` and can consequently be manually downloaded.

Hopefully, this helps reduce the time it takes to download collections of PDFs by an order of magnitude, and decrease hair pulling in the process.


### Testing

If you want to test this out, run the following on this test QxMD collection (after going through the prerequisites):

`./collectionScraper.R -s http://qxmd.com/r/shared-collection/6721 -d ~/Documents/test/`

You can also try it with keyword collections, as shown [here](https://www.readbyqxmd.com/keyword/8427), or even with [journals](https://www.readbyqxmd.com/journal/33017).

Additionally, this has only been tested successfully on a Linux system. I've tried to get this to work on Mac OS X, but with no luck. Make sure to read the RSelenium docs for further information on configuring your setup.


### A final note on language choice

While this would be better suited in other languages, `R` is my most familiar language and I felt like starting with something quick and dirty..please feel free to convert this to whatever language you personally like. As time permits I'll try to convert this into something a little more sensible, but for now, it does the job.
