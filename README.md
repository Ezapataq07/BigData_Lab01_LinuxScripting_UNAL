---
title: Untitled

---

<header style="display: flex; align-items: center; justify-content: center; height: 200px; background-color: transparent;">
  <div style="display: flex; align-items: center;">
    <div style="margin-right: 20px;">
      <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzgURBB21syaW6tNpW1-wjaKppJIYXzb_EFg&s" alt="Logo o Imagen" style="height: 150px;">
    </div>
    <div style="text-align: left; line-height: 1.4;">
      <div style="font-size: 30px; font-weight: bold;">
          Evaluación 1: Introducción a Linux       
        </div>
      <div style="font-size: 20px; font-style: italic;font-weight: bold">
          Emanuel Zapata Querubín
        </div>
      <div style="font-size: 16px;">
          Departamento de Ciencias de la Computación
        </div>
        <div style="font-size: 15px;">
          Facultad de Minas
        </div>
      <div style="font-size: 14px; color: #555;">
          2025-06-21
        </div>
    </div>
  </div>
</header>

# Lógica del problema planteado

La NASA desea hacer una simulación para establecer la forma de seguimiento del estado de los dispositivos pertenecientes a las diferentes misiones activas. Para ello se diseña un sistema centralizado al cual llega la información del estado de los diferentes dispositivos, desde los diferentes puntos del espacio exterior, a una frecuencia configurable.

# Lógica y utilización de la simulación

Para ejecutar el programa, es necesario descargar los archivos `.config` y `Apolo-11.sh` en la ruta de su preferencia. Posteriormente, ejecutar el programa principal `Apolo-11.sh` usando el siguiente comando:

```bash 
bash /ruta_preferencia/Apolo-11.sh
```

Al ejecutarse, el programa tomará las variables alojadas en `.config`, cuyo contenido es el siguiente:

```bash 
missions=(ORBONE CLNM TMRS GALXONE UNKN)
statuses=(excellent good warning faulty killed unknown)
devices=(rocket telescope spaceship satellite space_prob engine)
min_files=1
max_files=100
exec_rate=20
folder_devices='devices'
folder_backups='backups'
delimeter='\t'
date_format='+%d%m%y%H%M%S'
max_simulations=720
```

En caso de que requiera cambiar los parámetros de ejecución de la simulación, refiérase a la siguiente tabla para entender su significado, la lógica de la simulación y la forma en que cada parámetro la afecta se detalla más adelante.

|    Constante    | Descripción                                                                                         | Valor por defecto                                           |
|:---------------:| --------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
|    missions     | **Array** que contiene las misiones a ser simuladas.                                                | ORBONE, CLNM, TMRS, GALXONE, UNKN                           |
|    statuses     | **Array** que contiene los posibles estados de los dispositivos                                     | excellent, good, warning, faulty, killed, unknown           |
|     devices     | **Array** que contiene los posibles dispositivos                                                    | rocket, telescope, spaceship, satellite, space_prob, engine |
|    min_files    | Número mínimo de dispositivos que serán simulados                                                   | 1                                                           |
|    max_files    | Número máximo de dispositivos que serán simulados                                                   | 100                                                         |
|    exec_rate    | Frecuencia de llegada de datos a sistema central, en segundos                                       | 20                                                          |
| folder_devices  | Nombre de la carpeta en la que se almacenan los datos de los dispositivos                           | devices                                                     |
| folder_backups  | Nombre de la carpeta en la que se almacenan los datos de los dispositivos al finalizar los reportes | backups                                                     |
|    delimeter    | Delimitador de los datos en los archivos de entrada                                                 | \t                                                          |
|   date_format   | Formato de fecha de los datos en los archivos de entrada                                            | %d%m%y%H%M%S                                                |
| max_simulations | Número máximo de simulaciones a llevar a cabo                                                       | 720                                                         |                                                    |

El programa entonces simulará la llegada de entre `min_files` y `max_files` archivos (número escogido aleatoriamente), con una frecuencia de `exec_rate` segundos. Cada archivo corresponde a un dispositivo en `devices` en alguna de las misiones en `missions` que está reportando su estado actual de acuerdo con `statuses`. Los archivos que llegan se almacenan inicialmente en la carpeta `folder_devices/datetime`, donde `datetime` es la marca de fecha y hora correspondiente a la llegada de los archivos al sistema, en formato `date_format`. Posteriormente, se generan los reportes que se describen a continuación, y toda la información es trasferida a la carpeta `folder_backups/datetime`. El nombre con el que se guarda cada archivo individual es `APL[ORBONE|CLNM|TMRS|GALXONE|UNKN]-0000[1-100].log`

Para evitar que el programa quede ejecutándose infinitamente (al capitán se le olvide cerrarlo o alguna falla externa), se define la variable `max_simulations`, que define el número máximo de simulaciones (o de recepciones de datos) que se van a ejecutar. Para los valores por defecto, 720 simulaciones quiere decir que el programa se ejecutará aproximadamente un total de 4 horas.

## Reportes generados

Los reportes generados tienen la siguiente estructura de nombramiento: `APLSTATS-[REPORTE]-[datetime].log`. Son guardados en la misma carpeta de los archivos de misión.


| Reporte        | Descripción                                                                                                                             |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| CONSOLIDATED   | Consolidado de todos los datos que llegaron en la ejecución                                                                             |
| EVENTANALYSIS  | Contiene el número de eventos reportados en cada misión, por tipo de dispositivo y estado                                               |
| DISCONNECTIONS | Contiene por cada misión, el tipo de dispositivo con más eventos de desconexión, y el número de eventos de desconexión correspondientes |
| FAILURES       | Contiene por cada misión, el número de eventos de dispositivos en estado inoperable (killed)                                            |
| PERCENTS       | Contiene el porcentaje de eventos que se recibieron por cada misión y tipo de dispositivo, respecto al total de eventos de la ejecución |
