## Part 1. Navigating the collections site to load all title elements

## Site Navigation for loading -------------------------------------------------
print("Checking for RSelenium server and starting it up..")
RSelenium::checkForServer()
RSelenium::startServer()

Sys.sleep(time = 2)

print("Opening a remote driver..")
remDr <- remoteDriver$new()

print("Opening and navigating to site..")
remDr$open(silent = TRUE)
remDr$navigate(site)

print("Waiting for the dreaded popup..")
Sys.sleep(time = 5)

print("Finding the <h3> element of the popup..")
webElem <- remDr$findElement(using = "css selector", value = ".align-center")

print("Moving mouse left of the popup..")
remDr$mouseMoveToLocation(x = -400, y = 0, webElement = webElem)

print("Clicking to kill popup..")
remDr$buttondown()
remDr$buttonup()

print("Waiting for popup to die..")
Sys.sleep(time = 1)

print("Going down to bottom of page..")
remDr$sendKeysToActiveElement(list(key = "end"))

print("Sleeping for 3 secs to let page load..")
Sys.sleep(time = 3)

print("Going down to bottom of page again..")
remDr$sendKeysToActiveElement(list(key = "end"))

print("Sleep a bit more..")
Sys.sleep(time = 3)

print("Going down to bottom of page one last time..")
remDr$sendKeysToActiveElement(list(key = "end"))

print("Successfully navigated Captain!")

