message('Loading Packages')
library(rvest)
library(tidyverse)
library(mongolite)

message('Scraping Data')
url <- "https://alfagift.id/"

# Baca halaman web
web_page <- read_html(url)

# Lakukan scraping data produk
products <- web_page %>%
  html_nodes(".product-item") %>% # Sesuaikan dengan kelas HTML dari elemen produk
  map_df(~{
    tibble(
      name = .x %>% html_node(".product-title") %>% html_text(trim = TRUE),
      price = .x %>% html_node(".product-price") %>% html_text(trim = TRUE),
      link = .x %>% html_node("a") %>% html_attr("href")
    )
  })

# Proses data (contoh pemrosesan harga)
products <- products %>%
  mutate(price = as.numeric(gsub("[^0-9]", "", price))) %>%
  mutate(time = Sys.time(), city = "Jakarta") %>%
  select(time, city, name, price, link)

# Lihat hasil scraping
print(products)

# Koneksi ke MongoDB Atlas
message('Input Data to MongoDB Atlas')
atlas_conn <- mongo(
  collection = Sys.getenv("ATLAS_COLLECTION"),
  db         = Sys.getenv("ATLAS_DB"),
  url        = Sys.getenv("ATLAS_URL")
)

# Simpan data ke MongoDB
atlas_conn$insert(products)
rm(atlas_conn)