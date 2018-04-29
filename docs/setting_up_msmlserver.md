# Ejecutando este ejemplo con Microsoft Machine Learning Server 9.3.0
Este ejemplo pretende crear un regresor para predecir tiempos de viaje con los datos de ecobici, utilizando Microsoft Machine Learning Server 9.3.0 en una VM de Azure.

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

  - Nombre: `msmlserver`
  - Región: `South Central US` (porque 'latencia')
  - Tipo de VM: `D3S_v2` (poco menos de $2.00 pesos la hora)
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
12. Abre una ventana de browser y ve a `http://<server-ip>:8787`

No jaló, o se queda pendejo ¿verdad? :D

## Abriendo puertos en el Network Security Group
RStudio Server uses port 8787. The default configuration for the Azure VM does not open this port. To do that, you must go to the Azure portal and elect the proper Network Security Group. Select the All Settings option and choose Inbound security rules. Add a new rule for RStudio. Name the rule, choose Any for the Protocol, and add port 8787 to the destination port range. Click OK to save your changes. You should now be able to access RStudio using a browser.”

## Probando el RStudio Server
￼13. Vuelve a abrir una ventana de browser y ve de nuevo a `http://<server-ip>:8787`
14. Usa tu mismo usr y pass que la Linux VM de Azure que acabas de crear. Puedes crear más usuarios de la misma manera que los crearías para Linux.
15. Checa que en el output de inicio diga algo como:
```
Microsoft R Open 3.4.3
The enhanced R distribution from Microsoft
Microsoft packages Copyright (C) 2017 Microsoft Corporation
```
Si tienes esto, ya tienes un RStudio Server Community cuyo R binary es el Microsoft Machine Learning Server. ¡Congrats!

## Accediendo por DNS en lugar de IP
Azure, como cualquier cloud provider que se respete, te permite IPs dinámicas e IPs fijas. Este ejemplo usa IP dinámica porque queremos mantener el costo tan bajo como sea posible, y por tanto, cada vez que arranques tu VM va tener una nueva IP. Esto hace que el seguir estos ejemplos sea inconveniente en varias sesiones, y para ello tendremos que bautizar este setup con algún nombre.
16. Ir a [https://portal.azure.com](https://portal.azure.com)
17. Ir a "Resources"
18. Buscar la IP de tu VM. Si seguiste el ejemplo al pie de la letra, debe tener el nombre de `msmlserver`
19. En "Configuration", en la parte de abajo, hay un campo donde te permite poner el DNS name. Bautízala con el nombre de “rstudioserver”.

Esto te permitirá acceder al RStudio Server con la siguiente URL: [https://rstudioserver.southcentralus.cloudapp.azure.com:8787](https://rstudioserver.southcentralus.cloudapp.azure.com:8787)

## Clonando el repo y bajando el proyecto
TBD

