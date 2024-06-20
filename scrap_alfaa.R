message('Loading Packages')
library(rvest)
library(tidyverse)
library(mongolite)

message('Scraping Data')
base_url <- "https://alfagift.id/c/kebutuhan-dapur-5b85712ca3834cdebbbc4363?page="

# Fungsi untuk scraping data dari satu halaman
scrape_page <- function(page_number) {
  url <- paste0(base_url, page_number)
  web_page <- read_html(url)
  
  products <- web_page %>%
    html_nodes(".product-item") %>% # Sesuaikan dengan kelas HTML dari elemen produk
    map_df(~{
      tibble(
        name = .x %>% html_node(".product-title") %>% html_text(trim = TRUE),
        price = .x %>% html_node(".product-price") %>% html_text(trim = TRUE),
        link = .x %>% html_node("a") %>% html_attr("href")
      )
    })
  return(products)
}

# Mengumpulkan data dari semua halaman (1 sampai 11)
all_products <- map_df(1:11, scrape_page)

# Proses data (contoh pemrosesan harga)
all_products <- all_products %>%
  mutate(price = as.numeric(gsub("[^0-9]", "", price))) %>%
  mutate(time = Sys.time(), city = "Jakarta") %>%
  select(time, city, name, price, link)

# Lihat hasil scraping
print(all_products)

# Koneksi ke MongoDB Atlas
message('Input Data to MongoDB Atlas')
atlas_conn <- mongo(
  collection = Sys.getenv("ATLAS_COLLECTION"),
  db         = Sys.getenv("ATLAS_DB"),
  url        = Sys.getenv("ATLAS_URL")
)

# Simpan data ke MongoDB
atlas_conn$insert(all_products)
rm(atlas_conn)