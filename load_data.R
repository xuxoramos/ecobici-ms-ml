# Prerrequisitos:
# 1. Login al server msmlserver
# 2. 'sudo mkdir /mnt/ecobici-data' para crear un mount point local
# 3. 'sudo mount -t cifs //msmldiag167.file.core.windows.net/ecobici-file-share /mnt/ecobici-data -o vers=3.0,username=msmldiag167,password=Nh4JtXDnVDU1bx/SJbQG+syEYGSLHhen8Qo/+0QGSrjolhl93maUgN97RKXJcHvfNoJyxvs9ApPnodhW/2gC2w==,dir_mode=0777,file_mode=0777,sec=ntlmssp' para montar en local el Azure File Share.
library(devtools)
library(dplyr)

# Estas son las rutas de archivo de entrada y de salida. Vamos a transformar un CSV de 3.7M de registros a formato XDF, un formato binario que optimiza el almacenamiento por bloques
ecobicismallinputFile <- file.path('/mnt/ecobici-data', "ecobici-small.csv")
ecobicismalloutputFile <- file.path('./data', "ecobici-small.xdf")
ecobicibiginputFile <- file.path('/mnt/ecobici-data', "ecobici_2010_2017-final.csv")
ecobicibigoutputFile <- file.path('./data', "ecobici_2010_2017-final.xdf")

# Importar los datos. Estamos especificando que existen algunas variables que no importaremos, al igual que unas transformaciones para variables de fecha, categóricas y numéricas.
# - máximo 7500000 registros
ecobicibigdatasource <- rxImport(inData = ecobicibiginputFile,
                               outFile = ecobicibigoutputFile, 
                               overwrite = TRUE,
                               numRows = 7500000,
                               varsToDrop = c('fecha_arribo_completa','fecha_retiro_completa','hora_arribo_copy', 'hora_retiro_copy', 'segundo_retiro','segundo_arribo'),
                               transforms = list(fecha_retiro=as.Date(fecha_retiro, format='%Y-%m-%d'),
                                                 fecha_arribo=as.Date(fecha_arribo, format='%Y-%m-%d'),
                                                 bici=as.numeric(bici),
                                                 mes_retiro=as.numeric(mes_retiro),
                                                 delegacion_retiro=factor(delegacion_retiro),
                                                 colonia_retiro=as.numeric(colonia_retiro),
                                                 mes_arribo=as.numeric(mes_arribo),
                                                 delegacion_arribo=factor(delegacion_arribo),
                                                 colonia_arribo=as.numeric(colonia_arribo),
                                                 genero_usuario=as.factor(genero_usuario),
                                                 dia_semana_retiro=as.factor(dia_semana_retiro),
                                                 dia_semana_arribo=as.factor(dia_semana_arribo),
                                                 edad_usuario=as.numeric(edad_usuario),
                                                 duracion_viaje_horas=as.numeric(duracion_viaje_horas),
                                                 duracion_viaje_minutos=as.numeric(duracion_viaje_minutos)
                                                 )
         )

# Leer gran archivote
ecobicibigdatasource <- RxXdfData(file = ecobicibigoutputFile)

# bici + genero_usuario + edad_usuario + mes_retiro + dia_semana_retiro + delegacion_retiro + colonia_retiro + mes_arribo + dia_semana_arribo + delegacion_arribo + colonia_arribo, data = ecobici_train, 
ecobicibigdatasource <- ecobicibigdatasource %>% mutate (
  bici = factor(bici),
  genero_usuario = factor(genero_usuario)
)

# Resúmen del dataset creado
ecobici_summary <- rxSummary(~., data = ecobici_bigdata)

# Promedio de todo el dataset
ecobici_summary$sDataFrame %>% filter(Name == 'duracion_viaje_horas')

# Histogram
rxHistogram(formula=~F(duracion_viaje_horas), data=ecobicibigdatasource)

# Partición del dataset en set de entrenamiento y pruebas. Esta función creará los 2 archivos, así que se especifican prefijos y sufijos.
# El argumento 'transforms' admite una lista donde existe un elemento llamado splitVar, que es el que marca la partición del dataset.
# En este caso, se está creando una variable categórica splitVar, con valores Train y Test, con observaciones .rxNumRows, que es como el n() de vanilla R, y con probabilidad 80-20.
# Esta columna es la que nos va a permitir la partición del dataset en train y test sets.
rxSplit(inData = ecobicibigoutputFile, outFilesBase = './data/ecobici_2010_2017',
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

# Lectura tanto de archivo de train como de test. Recordar que son XDFs ya en el filesystem local del server, y ya no en el shared mount point que creamos arriba.
ecobici_train <- rxReadXdf('./data/ecobici_2010_2017.splitVar.Train.xdf')
ecobici_test <- rxReadXdf('./data/ecobici_2010_2017.splitVar.Test.xdf')

# Entrenar un regression forest con la duración del viaje en horas como target, y bici, género, edad, y detalles de fecha y lugar de retiro y arribo como predictores, con un máximo de ramas de 5, 200 árboles en cada pasada del dataset, y calculando el 'variable importance' que es el ranking de información aportada por cada una.
# 31min de entrenamiento para la mitad de registros de ecobici
ecobici_forest <- rxDForest(formula = duracion_viaje_horas ~ bici + genero_usuario + edad_usuario + mes_retiro + dia_semana_retiro + delegacion_retiro + colonia_retiro + mes_arribo + dia_semana_arribo + delegacion_arribo + colonia_arribo, data = ecobici_train, 
          maxDepth = 5, nTree = 200, mTry = 2, importance = T)

# Ejecutar la predicción con el set de pruebas.
pred <- rxPredict(ecobici_forest, ecobici_test)



