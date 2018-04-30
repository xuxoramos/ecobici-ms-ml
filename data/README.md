# Información sobre el dataset
El dataset de este ejemplo ha sido obtenido de [datos abiertos de Ecobici](https://www.ecobici.cdmx.gob.mx/es/informacion-del-servicio/open-data), un servicio de renta de bicicletas que ofrece el gobierno de la Ciudad de México. Tiene las siguientes características:

- 2010 a 2017
- Los eventos registrados son las disposiciones y retornos de bicicletas en cualquiera de las estaciones de servicio
- CSV de 16GB descomprimidos (y por tanto dificilmente cabrán en un R local)

# ¿Y dónde está?
Es un archivo de 16GB, así que es impráctico tenerlo en este repo. Por tanto, se ha cargado a un [Blob](https://azure.microsoft.com/en-us/services/storage/blobs/) en un [storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-quickstart-create-account?tabs=portal) en Azure. El archivo se puede descargar [aquí](https://msmldiag167.blob.core.windows.net/ecobici-data/ecobici_2010_2017.csv), pero no recomendamos no hacerlo porque implicaría que el análisis y modelado se realizará en un ambiente local, y a menos que tengas una Alienware [súper mamalona](http://www.dell.com/en-us/shop/dell-laptops/alienware-17-r5/spd/alienware-17-r5), dudamos que tu _vanilla R_ aguante cargarlo.


