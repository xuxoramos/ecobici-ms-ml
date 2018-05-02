# Comment!
# File paths
inputFile <- file.path('/mnt/ecobici-data', "ecobici_2010_2017.csv")
outputFile <- file.path('./data', "ecobici_2010_2017.xdf")

# Read first 5 lines of CSV
ecobici_data_5lines <- read.csv(inputFile, nrow=5, stringsAsFactors = F)

# Details of input file
ecobici_datasource_details <- RxTextData(inputFile, stringsAsFactors = F, rowsToSniff = 5000)

# Import the data into the xdf file
ecobici_datasource <- rxImport(inData = ecobici_datasource_details, 
                               outFile = outputFile, 
                               overwrite = TRUE, 
                               numRows = 5,
                               varsToDrop = c('fecha_arribo_completa','fecha_retiro_completa','hora_arribo_copy', 'hora_retiro_copy'),
                               transforms = list(fecha_retiro=as.Date(fecha_retiro, format='%Y-%m-%d'),
                                                 fecha_arribo=as.Date(fecha_arribo, format='%Y-%m-%d')))





