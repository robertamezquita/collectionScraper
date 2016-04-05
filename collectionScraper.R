#!/bin/env Rscript

## Utility for mass automated download of QxMD Paper Collections
## utilizing RSelenium, rvest, and good ol' fashioned parsing

## Parse arguments -------------------------------------------------------------

library(optparse)

## Help text
option_list <- list(
  make_option(c("-d", "--dest"), action = "store", type = "character", default = "~/Documents/scraped/",
              help = "Directory where scraped PDFs will be placed. [default: '~/Documents/scraped/']"),
  make_option(c("-s", "--site"), action = "store", type = "character", default = NULL,
              help = "Site where public Read by QxMD collection is held"))

parser <- OptionParser(usage = "%prog [options]", option_list = option_list)
arguments <- parse_args(parser, positional_arguments = 0)
opt <- arguments$options

## Save args
dest <- opt$dest
site <- opt$site
base <- "https://www.readbyqxmd.com"

## Error check
if (is.null(site)) {
    stop("Error: specify collections site. Check your email.")
}

## Check if destination directory exists
if (!file.exists(dest)) {
    system(paste0("mkdir -p ", dest))
}

## Run the pipeline ------------------------------------------------------------
## Load Libraries
library(RSelenium)
library(rvest)
library(stringr)
library(curl)

## Run first pass
source("navSite.R") ## Navigate collection; load all papers in collection
source("extractElements.R") ## Parse each paper's URL
source("grabPDFs.R") ## perform first pass downloading; sets flag = 1 if fails exist

## Run second pass in case of failed downloads
if (flag == 1) {
    source("failPDFs.R") ## finds additional links; then tries again to download PDF
}

## Close all windows - user can do this..
## remDr$close()
## remDr$closeWindow()
## remDr$closeServer()


## Define Site - for testing
## site <- "https://www.readbyqxmd.com/collection/6717"
## base <- "https://www.readbyqxmd.com"
## dest <- "~/Documents/dl2"
