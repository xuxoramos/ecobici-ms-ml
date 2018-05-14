# Ejecutando este ejemplo con Microsoft Machine Learning Server 9.3.0
Este ejemplo pretende crear un regresor para predecir tiempos de viaje con los datos de ecobici, utilizando Microsoft Machine Learning Server 9.3.0 en una VM de Azure. Distribuiremos los datos de ecobici mediante un shared Azure File en mi propio storage account.

### ¿Por qué Azure File y no Azure Blob?
La intención de este ejemplo es comparar codo a codo _vanilla R_ y el backend de R del Microsoft Machine Learning Server. Para ello, debemos tener este setup lo más posible al típico ambiente local de _vanilla R_ que usaríamos si los datos de ecobici no fueran tan grandes, y eso implica que no tendremos ayuda del poder de un filesystem distribuído como [Azure Blob Storage](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-python), porque nos obligaría a trabajar con Spark + R Server (que es el actual Machine Learning Server), en detrimento del propósito final del experimento.

## Prerrequisitos
- Una cuenta de Azure. Si no la tienes, puedes abrir un trial [aquí](https://azure.microsoft.com/en-us/offers/ms-azr-0044p/)
- Fork de este repositorio
- Conocimiento intermedio de R y sus desventajas para manejar grandes cantidades de datos (precisamente la razón de ser de este ejemplo)
- Conocimiento básico de cloud computing y algún cloud provider grande (Azure, AWS, GCP)

## Configurando Microsoft Machine Learning Server en una VM Linux en Azure

The following procedure explains how to use the Azure portal to view the full range of VM images that provide Machine Learning Server.

1. Sign in to the Azure portal.
2. Click Create a resource.
3. Search for Machine Learning Server. The following list shows partial search results. VM images include current and previous versions of Machine Learning Server on several common Linux operating systems as well as Windows Server 2016.
![](https://docs.microsoft.com/en-us/machine-learning-server/install/media/machine-learning-server-install-azure-vm/azure-vm-list.png)
VM images include the custom R packages and Python libraries from Machine Learning Server that offer machine learning algorithms, R and Python helpers for deploying analytics, and portable, scalable, and distributable data analysis functions.
4. From the list of virtual machines, choose the VM image providing the operating system and version of Machine Learning Server you want to install.
5. Accept the terms and get started by clicking Create.
6. Follow the onscreen prompts to provision the VM.

### Input recomendados para el Setup Wizard
- Nombre: `msmlserver`
- Usuario: `ecobici`
- Región: `South Central US` (porque 'latencia')
- Tipo de VM: `DS3_v2` (poco menos de $5.00 pesos la hora)
- Si ya tienes recursos creados en tu cuenta de Azure, el Wizard te permitirá asignar Network Security Groups, Resource Groups y Storage Accounts que ya tengas creadas. De lo contrario, deja los defaults.
- Para este ejemplo, deja el tipo de autenticación con `**Password**`

## Verificando la instalación
7. Conéctate a la VM usando la IP pública (pronto le pondremos un nombre para darle la vuelta a la IP dinámica que te da Azure y no pagar por una fija)
8. Ejecuta el comando `$ Revo64`. Si tienes una salida como ésta:
```
Loading Microsoft Machine Learning Server packages, version 9.3.0.
Type 'readme()' for release notes, privacy() for privacy policy, or
'RevoLicense()' for licensing information.
```
¡la VM está lista!
  
## Instalando RStudio Server Community en tu nueva VM
Los siguientes pasos deben ejecutarse con privilegios de `root`.

9. Instala gdebi: `$ sudo apt-get install gdebi-core`
10. Baja el RStudio Server: `$ wget https://download2.rstudio.org/rstudio-server-1.1.447-amd64.deb`
11. Instala el RStudio Server con gdebi: `$sudo gdebi rstudio-server-1.1.447-amd64.deb`
12. Con privilegios de root, edita el archivo de variables de ambiente de R con el siguiente comando `sudo nano /opt/microsoft/mlserver/9.3.0/runtime/R/etc/Renviron`
13. Entra la línea `R_LIBS_SITE=/opt/microsoft/mlserver/9.3.0/libraries/RServer/` al final del archivo. Debe quedar como la imagen muestra

![](https://i.imgur.com/cJugeWm.png)

14. Reinicia la VM desde la consola
15. Abre una ventana de browser y ve a `http://<server-ip>:8787`

No jaló, o se queda pendejo ¿verdad? :D

## Abriendo puertos en el Network Security Group
RStudio Server uses port 8787. The default configuration for the Azure VM does not open this port. To do that, you must go to the Azure portal and elect the proper Network Security Group. Select the All Settings option and choose Inbound security rules. Add a new rule for RStudio. Name the rule, choose Any for the Protocol, and add port 8787 to the destination port range. Click OK to save your changes. You should now be able to access RStudio using a browser.

![](https://i.imgur.com/mD8sjeV.png)

## Probando el RStudio Server
￼16. Vuelve a abrir una ventana de browser y ve de nuevo a `http://<server-ip>:8787`, donde el <server-ip> es la IP asignada por Azure.
17. Usa tu mismo usr y pass que la Linux VM de Azure que acabas de crear. Puedes crear más usuarios de la misma manera que los crearías para Linux.
18. Checa que en el output de inicio en RStudio Server diga algo como:
```
Loading Microsoft Machine Learning Server packages, version 9.3.0.
Type 'readme()' for release notes, privacy() for privacy policy, or
'RevoLicense()' for licensing information.
```
Si tienes esto, ya tienes un RStudio Server Community cuyo R binary es el Microsoft Machine Learning Server. ¡Congrats!

## Accediendo por DNS en lugar de IP

!￼[](https://i.imgur.com/Di0rvHX.png)

Azure, como cualquier cloud provider que se respete, te permite IPs dinámicas e IPs fijas. Este ejemplo usa IP dinámica porque queremos mantener el costo tan bajo como sea posible, y por tanto, cada vez que arranques tu VM va tener una nueva IP. Esto hace que el seguir estos ejemplos sea inconveniente en varias sesiones, y para ello tendremos que bautizar este setup con algún nombre.

19. Ir a [https://portal.azure.com](https://portal.azure.com).
20. Ir a "Resources".
21. Buscar la IP de tu VM. Si seguiste el ejemplo al pie de la letra, debe tener el nombre de `msmlserver`.
22. En _Configuration_, en la parte de abajo, hay un campo donde te permite poner el DNS name. Bautízala con el nombre de _rstudioserver_.

Esto te permitirá acceder al RStudio Server con la siguiente URL: [https://rstudioserver.southcentralus.cloudapp.azure.com:8787](https://rstudioserver.southcentralus.cloudapp.azure.com:8787).

## Permitiendo el acceso al dataset desde Microsoft Machine Learning Server
El repo y el dataset están separados. El dataset puede encontrarse [aquí](https://msmldiag167.file.core.windows.net/ecobici-file-share/ecobici_2010_2017-final.csv), pero no recomendamos bajarlo, porque no es posible ni siquiera cargarlo en una instalación de _vanilla R_.

Para poder acceder al dataset desde la VM con el MSML en Linux, debemos crear un **mount** desde mi Azure file share para que se vea como un directorio del OS.

23. Hacer `ssh` a tu VM que tiene el MS Machine Learning Server. Si has seguido esta guía, debe ser `ssh ecobici@rstudioserver.southcentralus.cloudapp.azure.com`
24. Instalar `cifs-utils`
```
sudo apt-get update
sudo apt-get install cifs-utils
```
25. Crea un mount point en tu VM usando `sudo mkdir /mnt/ecobici-data`
26. Probar el mount point con el siguiente comando
```
sudo mount -t cifs //msmldiag167.file.core.windows.net/ecobici-file-share /mnt/ecobici-data -o vers=3.0,username=msmldiag167,password=Nh4JtXDnVDU1bx/SJbQG+syEYGSLHhen8Qo/+0QGSrjolhl93maUgN97RKXJcHvfNoJyxvs9ApPnodhW/2gC2w==,dir_mode=0755,file_mode=0755,sec=ntlmssp
```
Lo que va a hacer este comando es crear un _mount volume_ de **mi propio storage account** a **tu VM en Azure**. Esto lo hacemos para evitar que tengas que descargar los 16GB y más bien te conectes directito al file share que yo cree.

Si acaso esto no sirviera, entonces será necesario descargar el dataset, y crear el file share en **tu propia storage account**. Refiérete a [esta documentación para ello](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-create-file-share#Create%20file%20share%20through%20the%20Portal).

27. Entra al RStudio Server que instalamos en tu VM con el MS Machine Learning Server: [https://rstudioserver.southcentralus.cloudapp.azure.com:8787](https://rstudioserver.southcentralus.cloudapp.azure.com:8787)
28. Hacer checkout de este repo desde RStudio Server en tu VM.
29. Ejecutar el siguiente comando para importar el CSV de ecobici: `ecobici_data <- rxImport('/mnt/ecobici-data/ecobici_2010_2017-final.csv')`. Nota que estamos usando las funciones de Microsoft R Server y no el `readr::read_csv`, ni el `base::read.csv`.
