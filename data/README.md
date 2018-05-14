# Información sobre el dataset
El dataset de este ejemplo ha sido obtenido de [datos abiertos de Ecobici](https://www.ecobici.cdmx.gob.mx/es/informacion-del-servicio/open-data), un servicio de renta de bicicletas que ofrece el gobierno de la Ciudad de México. Tiene las siguientes características:

- 2010 a 2017
- Los eventos registrados son las disposiciones y retornos de bicicletas en cualquiera de las estaciones de servicio
- CSV de 16GB descomprimidos (y por tanto dificilmente cabrán en un R local)

# ¿Y dónde está?
Es un archivo de 16GB, así que es impráctico tenerlo en este repo. Por tanto, se ha cargado a un [File Service](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-create-file-share) en un [storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-quickstart-create-account?tabs=portal) en Azure. El archivo se puede descargar [aquí](https://msmldiag167.file.core.windows.net/ecobici-file-share/ecobici_2010_2017-final.csv), pero no recomendamos hacerlo porque implicaría que el análisis y modelado se realizará en un ambiente local, y a menos que tengas una Alienware [súper mamalona](http://www.dell.com/en-us/shop/dell-laptops/alienware-17-r5/spd/alienware-17-r5), dudamos que tu _vanilla R_ aguante cargarlo.

# ¿Qué transformaciones ha sufrido el archivo?
Los datos originalmente fueron descargados desde el website mencionado arriba, request por request, con un script de scrapping en python al cual lamentablemente ya no tenemos acceso. Se bajaron CSV individuales y se pegaron en un ambiente local. Posteriormente se encerraron en comillas tanto nombres de columnas como valores de cada renglón. Esto porque la función `rxImport` de ML Server tiene una bronca con los formatos de fechas, así que todo lo convertimos a strings.

