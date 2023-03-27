
if(!require(tidyverse))install.packages("tidyverse", dependencies = TRUE)
if(!require(readxl)) install.packages("readxl", dependencies = TRUE)
if(!require(purrr)) install.packages("purrr", dependencies = TRUE)
if(!require(writexl)) install.packages("writexl", dependencies = TRUE)
if(!require(openxlsx)) install.packages("openxlsx", dependencies = TRUE)
if(!require(data.table)) install.packages("data.table", dependencies = TRUE)


path <- "C:/Users/Yuri/My Drive/PhD/00_UM/03_graduate/00_courses/02_2nd_semester/02_infographic_I/01_class_recordings_and_slides/02_march/03-02-23/Project_1/homelessess/00_data"
path

regions <- readr::read_csv("00_data/regions_ny.csv") %>% 
  unique()
regions

file_path <- list.files(path, pattern="\\.xlsx$", full.names = TRUE)
file_path


#For each file in file_path
homeless.tables <- purrr::map(file_path, ~
                         #For each sheet
                         purrr::map(2:3, function(i) {
                           #Read the file with particular sheet nummber
                           openxlsx::read.xlsx(.x, sheet=i, startRow=1)}) %>% 
                         purrr::reduce(dplyr::full_join) %>%
                         #Remove all NA rows
                         #dplyr::filter(Reduce(`|`, across(.fns = ~!is.na(.)))) %>%
                         #Add Year column at 1st position
                         dplyr::mutate(YEAR = tools::file_path_sans_ext(basename(.x)), .before = 1))

homeless.tables

homeless.tables.bind <- data.table::rbindlist(homeless.tables, use.names=TRUE, fill=FALSE, idcol=TRUE) %>% 
  dplyr::rename_all(., .funs = toupper) %>% 
  dplyr::filter(!"TOTAL.HOMELESS" == "s") %>% 
  dplyr::mutate(TOTAL.HOMELESS = as.numeric(TOTAL.HOMELESS),
                YEAR = stringr::str_extract(YEAR, ".0..")) %>% 
  dplyr::left_join(regions) %>% 
  stats::na.omit() %>% 
  dplyr::select(c(3,4,6,5,2))

homeless.tables.bind
