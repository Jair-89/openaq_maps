# 0. 
library("pacman")

p_load(
  tidyverse,
  openair,
  openairmaps,
  fs,
  scales,
  googledrive
)


url_google <- "https://drive.google.com/drive/u/1/folders/1NRQGO7WprkfaV2WVjv7bcGbMoJ7Y__8q"

x <- drive_find(n_max = 15,type="csv")

names <- x$name
