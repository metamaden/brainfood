# script example for scraping CNN RSS feed using Rcurl and XML
# courtesy of: izahn https://gist.github.com/izahn/5785265

## This R script contains a simple screen scraping example,
## downloading the text of the articles in the CNN website
## rss feed.

library(RCurl)
library(XML)

options(stringsAsFactors = FALSE)

## get rss document
xml.url <- "http://rss.cnn.com/rss/cnn_topstories.rss"
script <- getURL(xml.url, ssl.verifypeer = FALSE)

## convert document to XML tree in R
doc <- xmlParse(script)

## find the names of the item nodes
# unique(xpathSApply(doc,'//item/*',xmlName, full=TRUE))

## Extract some information from each node in the rss feed
titles <- xpathSApply(doc,'//item/title',xmlValue)
pubdates <- xpathSApply(doc,'//item/pubDate',xmlValue)
categories <- xpathSApply(doc,'//item/category',xmlValue)
links <- xpathSApply(doc,'//item/feedburner:origLink',xmlValue)
descriptions <- xpathSApply(doc,'//item/description',xmlValue)

## get the full text of the linked articles
articles <- sapply(links, getURL)

## write a function to extract the text from the articles
processHTML <- function(html) {
  doc <- htmlTreeParse(html, useInternalNodes=TRUE)
  ## the step below can be trickier--in this example we lucked out
  ## because on the CNN website there is no non-article text in
  ## paragraph tags, so we can just get all the "p" elements.
  text <- unlist(xpathApply(doc, "//p", xmlValue))
  ## combine each paragraph, separated by two line breaks
  text.comb <- paste(text, collapse="\n\n")
  return(text.comb)
}

## apply our text extraction function to each html article
fulltext <-  sapply(articles, processHTML)

## make a data.frame with info from the rss feed as well as 
ArticlesAndInfo <- data.frame(titles, pubdates, links, fulltext)
