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

for(i in names){
  drive_download(
    file= i,
    path = paste0("data_base/files/data_sinaica/",i),
    overwrite = TRUE)
}


drive_download(file="cdmx_2020_2022.csv",
               path = paste0("data_base/files/data_sinaica/cdmx_2020_2022.csv"),
               overwrite = TRUE)


clean_cdmx_2020_2022 <- read_csv(
  paste0(getwd(),"/data_base/files/data_sinaica/cdmx_2020_2022.csv")
) |> 
  mutate(
    valorAct = as.numeric(valorAct),
    date = paste(fecha,hora),
    date = ymd_h(date)
  ) |> 
  select(
    -c(
      fecha,hora,nivelValidacion,smca,status_pol,
      status_meteo,num_value,station_yes_par_pol,
      station_yes_par_meteo
      )
    ) |> 
  relocate(9,8,2,3,1,4,5,6,7)

pm10_cdmx_2020_2022 <- clean_cdmx_2020_2022 |> 
  filter(parametro == "PM10") |> 
  select(-estacionesId) |> 
  write_csv(path = paste0(
    getwd(),"/data_base/files/data_sinaica/pm10_cdmx_2020_2022.csv")
    )

parameters_cdmx_download <- function(parameter){
x <- clean_cdmx_2020_2022 |> 
  filter(parametro == parameter) |> 
  select(-estacionesId) |> 
  write_csv(path = paste0(
    getwd(),"/data_base/files/data_sinaica/",parameter,"_cdmx_2020_2022.csv")
  )
}

parametros <- c("PM10","PM2.5","O3","NO2","SO2","CO")

for ( i in parametros){
  parameters_cdmx_download(i)
}

upload_path_drive_google <- as_id("https://drive.google.com/drive/u/1/folders/1X7QJ3XHCwB_5kmqNAQ-3gOGR5kwCK7Ir")

for (i in parametros){
  
  drive_upload(
    media = paste0(getwd(),"/data_base/files/data_sinaica/",i,"_cdmx_2020_2022.csv"),
    path = upload_path_drive_google
  )
}
drive_upload()