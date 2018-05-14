# ecobici-ms-ml
Este ejemplo pretende crear un regresor para predecir tiempos de viaje con los datos de ecobici, utilizando Microsoft Machine Learning Server 9.3.0 en una VM de Azure. Distribuiremos los datos de ecobici mediante un shared Azure File en mi propio storage account.

## ¿Por qué?
R había sido el campeón del mundo de Ciencia de Datos y Machine Learning hasta 2016, cuando Google hizo open source su proyecto TensorFlow, un framework para redes neuronales "profundas", y FB posteriormente lanzó PyTorch, una capa de abstracción sobre TensorFlow. Esto se debe a que R, por diseño, tiene las siguientes limitantes como plataforma de análisis:
- Trabaja solamente con la memoria física disponible para el proceso
- El proceso de R está programado para no hacer `fork()` (el call del OS), y por tanto no maneja ni hilos, ni se pueden comunicar varios procesos R entre ellos, siendo incompatibles con la [ley de Amdahl](https://www.techopedia.com/definition/17035/amdahls-law).

El Microsoft Machine Learning Server de MS tiene dentro 2 engines, Anaconda para Python, y el Microsoft R Server, antes Revolution Analytics. En este ejercicio nos enfocaremos en R, y mostraremos como, mientras _vanilla R_ no tiene el punch para trabajar con datos de ecobici, el MS ML Server si, dado que es un completo rewrite de funciones de R, pero diseñadas para aprovechar múltiples cores y memoria virtual.

## ¿Por qué no Spark + R Server de MS?
La intención de este ejemplo es comparar codo a codo _vanilla R_ y el backend de R del Microsoft Machine Learning Server. Para ello, debemos tener este setup lo más posible al típico ambiente local de _vanilla R_ que usaríamos si los datos de ecobici no fueran tan grandes, y eso implica que no tendremos ayuda del poder de un filesystem distribuído como [Azure Blob Storage](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-python), porque nos obligaría a trabajar con Spark + R Server (que es el actual Machine Learning Server), en detrimento del propósito final del experimento.

## ¿Por qué los datos de ecobici?
¡Porque son un ch...orro! Es un CSV de 16GB sin comprimir, y por tanto ofrece una buena oportunidad para demostrar las ventajas de MS ML Server sobre el R que traemos todos en nuestras laps. Puedes ver más detalles sobre los datos en [/data/README.md](https://github.com/datankai/ecobici-ms-ml/blob/master/data/README.md).
