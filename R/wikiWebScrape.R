# purpose: scrape main article text from wikipedia via Google search and R XML parser library
# query = text to query (passed to Google)

wikiWebScrape <- function(query){
  require(XML)
  url <- paste0("http://www.google.com/search?q=",paste0(query," wikipedia"))
  doc <- htmlParse(url)
  return(lapply(doc['//span[@class="st"]'],xmlValue))
}
