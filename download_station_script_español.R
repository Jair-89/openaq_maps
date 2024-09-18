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

upload_path_drive_google <- "https://drive.google.com/drive/u/1/folders/1X7QJ3XHCwB_5kmqNAQ-3gOGR5kwCK7Ir"

x <- drive_find(n_max = 15,type="csv")

names <- x$name

drive_download(
  file= "PM10_cdmx_2020_2022.csv",
  path = "data_base/files/data_sinaica/PM10_cdmx_2020_2022.csv",
  overwrite = TRUE)

pm10_analysis <- read_csv(
  paste0(
    getwd(),"/data_base/files/data_sinaica/PM10_cdmx_2020_2022.csv"
  )
)

EDA_cdmx_2020_2021 <- pm10_analysis |>
  select(
    date,nombre_estacion,valorAct
    ) |> 
  rename(
    pm10 = valorAct
    ) |> 
  aqStats(
    type="nombre_estacion",
    pollutant = "pm10",
    data.thresh = 75
    )


timeserie_cdmx_2020_2021 <- pm10_analysis |>
  select(
    date,nombre_estacion,valorAct
  ) |> 
  rename(
    pm10 = valorAct
  ) |>
  openair::timePlot(pollutant = "pm10",avg.time = "day",type = "nombre_estacion")
