message('Loading Packages')
library(rvest)
library(tidyverse)
library(mongolite)
library(httr)

message('Scraping Data')

# URL to scrape
url <- "https://www.monotaro.id/c25.html"

# Read the HTML content from the URL
page <- read_html(url)

# Extract titles using XPath
produk <- page %>%
  html_elements(xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "product-item-link", " " ))]') %>%
  html_text()
produk


harga<- page %>% 
  html_elements(xpath='//*[contains(concat( " ", @class, " " ), concat( " ", "price-including-tax", " " ))]//*[contains(concat( " ", @class, " " ), concat( " ", "price", " " ))]') %>% 
  html_text()
harga

tersedia <-page %>% 
  html_elements(xpath='//*[contains(concat( " ", @class, " " ), concat( " ", "sap_btn", " " ))]') %>% 
  html_text()
tersedia


length(produk)
length(harga)
length(tersedia)

# Create a dataframe
data_produk <- data.frame(Produk = produk, Harga = harga, Tersedia = tersedia)

# Display the dataframe
view(data_produk)

pilih <- sample(1:40, 1, replace=FALSE)
data_produk <- data_produk[pilih,]

message('Input Data to MongoDB Atlas')
atlas_conn <- mongo(
  collection = Sys.getenv("ATLAS_COLLECTION"),
  db         = Sys.getenv("ATLAS_DB"),
  url        = Sys.getenv("ATLAS_URL")
)

atlas_conn$insert(data_produk)
rm(atlas_conn)

