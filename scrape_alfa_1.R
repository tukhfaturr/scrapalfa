message('Loading Packages')
library(rvest)
library(tidyverse)
library(mongolite)
library(jsonlite)

message('Scraping Data')

# URL dasar
base_url <- "https://alfagift.id/c/kebutuhan-dapur-5b85712ca3834cdebbbc4363?page="

# Fungsi untuk scrape data dari satu halaman
scrape_page <- function(page_number) {
  url <- paste0(base_url, page_number)
  webpage <- read_html(url)
  
  products <- webpage %>%
    html_nodes(".product-list") %>%
    html_nodes(".product-item") %>%
    html_node("a")
  
  data <- tibble(
    name = products %>% html_attr("data-name"),
    price = products %>% html_attr("data-price"),
    url = products %>% html_attr("href")
  )
  
  return(data)
}

# Scraping data dari semua halaman (hingga halaman 11)
all_data <- bind_rows(lapply(1:11, scrape_page))

# Lihat hasil scraping
print(all_data)

message('Input Data to MongoDB Atlas')
# Menyambung ke MongoDB Atlas
mongo_url <- "mongodb+srv://tukhfaturr:laluna20@cluster0.axrxdmw.mongodb.net/"
mongo_collection <- mongo(collection = "kebutuhan_dapur", url = mongo_url)

# Menyimpan data ke MongoDB
mongo_collection$insert(all_data)

