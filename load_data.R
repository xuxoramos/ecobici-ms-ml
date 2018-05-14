# Comment!
# File paths
ecobiciinputFile <- file.path('/mnt/ecobici-data', "ecobici_2010_2017-final.csv")
ecobicioutputFile <- file.path('./data/', "ecobici_2010_2017-final.xdf")

# Import the data into the xdf file
# It'll take around 40 min.
ecobici_datasource <- rxImport(inData = ecobiciinputFile,
                               outFile = ecobicioutputFile, 
                               overwrite = TRUE, 
                               varsToDrop = c('fecha_arribo_completa','fecha_retiro_completa','hora_arribo_copy', 'hora_retiro_copy'),
                               transforms = list(fecha_retiro=as.Date(fecha_retiro, format='%Y-%m-%d'),
                                                 fecha_arribo=as.Date(fecha_arribo, format='%Y-%m-%d')))







