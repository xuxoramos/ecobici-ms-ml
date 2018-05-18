# Comment!
# File paths
ecobiciinputFile <- file.path('/mnt/ecobici-data', "ecobici-small.csv")
ecobicioutputFile <- file.path('/mnt/ecobici-data', "ecobici-small.xdf")

# Import the data into the xdf file
# It'll take around 40 min.
rxImport(inData = ecobiciinputFile,
                               outFile = ecobicioutputFile, 
                               overwrite = TRUE, 
                               varsToDrop = c('fecha_arribo_completa','fecha_retiro_completa','hora_arribo_copy', 'hora_retiro_copy', 'segundo_retiro','segundo_arribo'),
                               transforms = list(fecha_retiro=as.Date(fecha_retiro, format='%Y-%m-%d'),
                                                 fecha_arribo=as.Date(fecha_arribo, format='%Y-%m-%d'),
                                                 bici=factor(bici),
                                                 mes_retiro=factor(mes_retiro),
                                                 delegacion_retiro=factor(delegacion_retiro),
                                                 colonia_retiro=factor(colonia_retiro),
                                                 mes_arribo=factor(mes_arribo),
                                                 delegacion_arribo=factor(delegacion_arribo),
                                                 colonia_arribo=factor(colonia_arribo),
                                                 genero_usuario=as.factor(genero_usuario),
                                                 dia_semana_retiro=as.factor(dia_semana_retiro),
                                                 dia_semana_arribo=as.factor(dia_semana_arribo),
                                                 edad_usuario=as.numeric(edad_usuario),
                                                 duracion_viaje_horas=as.numeric(duracion_viaje_horas),
                                                 duracion_viaje_minutos=as.numeric(duracion_viaje_minutos)
                                                 )
         )

# Read in XDF file we have just written
#ecobici_datasource <- rxReadXdf(file = ecobicioutputFile, numRows = 3740000)

# Summary of the dataset
rxSummary(~., data = ecobici_datasource, blocksPerRead = 2)

rxSplit(inData = ecobicioutputFile, outFilesBase = './data/ecobici-small',
        outFileSuffixes = c('-train', '-test'),
        splitByFactor = "splitVar",
        overwrite = TRUE,
        transforms = list(
          splitVar = factor(sample(c("Train", "Test"),
                                   size = .rxNumRows,
                                   replace = TRUE,
                                   prob = c(.80, .20)),
                            levels = c("Train", "Test"))),
        rngSeed = 17,
        consoleOutput = TRUE)

# read train
ecobici_train <- rxReadXdf('./data/ecobici-small.splitVar.Train.xdf')

# Reg forest
ecobici_forest <- rxDForest(formula = duracion_viaje_horas ~ bici + genero_usuario + edad_usuario + mes_retiro + dia_semana_retiro + delegacion_retiro + colonia_retiro + mes_arribo + dia_semana_arribo + delegacion_arribo + colonia_arribo, data = ecobici_train, 
          maxDepth = 5, nTree = 200, mTry = 2)




