# Comment!
# File paths
ecobiciinputFile <- file.path('/mnt/ecobici-data', "ecobici_2010_2017-final.csv")
ecobicioutputFile <- file.path('./data/', "ecobici_2010_2017-final.xdf")

#testinputfile <- file.path('/mnt/ecobici-data', "test-final.csv")
#testoutputfile <- file.path('./data/', "test-final.xdf")

#testdata <- rxImport(inData = testinputfile,
#                     outFile = testoutputfile, 
#                     overwrite = TRUE, 
#                     varsToDrop = c('fecha_arribo_completa',
#                                    'fecha_retiro_completa',
#                                    'hora_arribo_copy', 
#                                    'hora_retiro_copy'))

# Import the data into the xdf file
ecobici_datasource <- rxImport(inData = ecobiciinputFile,
                               outFile = ecobicioutputFile, 
                               overwrite = TRUE, 
#                               numRows = 5,
                               varsToDrop = c('fecha_arribo_completa','fecha_retiro_completa','hora_arribo_copy', 'hora_retiro_copy'),
                               transforms = list(fecha_retiro=as.Date(fecha_retiro, format='%Y-%m-%d'),
                                                 fecha_arribo=as.Date(fecha_arribo, format='%Y-%m-%d')))







