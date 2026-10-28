# 1. Ingesta y almacenamiento — Landing / Bronze

```mermaid
flowchart LR
    subgraph SRC["Fuentes de datos"]
        DB["Bases de datos"]
        FILES["Archivos / CSV / JSON"]
        API["APIs y otros sistemas"]
    end

    subgraph ING["Capa de ingesta"]
        CDC["Debezium<br/>Captura CDC"]
        KAFKA["Apache Kafka<br/>Eventos"]
        NIFI["Apache NiFi<br/>Ingesta batch"]
    end

    subgraph LAKE["Almacenamiento Lakehouse"]
        LAND["Landing / Raw"]
        MINIO[("MinIO<br/>Object Storage")]
        BRONZE[("Bronze<br/>Apache Iceberg")]
        HMS["Hive Metastore<br/>Catálogo Iceberg"]
    end

    DB --> CDC
    CDC --> KAFKA
    FILES --> NIFI
    API --> NIFI
    KAFKA --> LAND
    NIFI --> LAND
    LAND --> MINIO
    MINIO --> BRONZE
    BRONZE -. "Metadatos" .-> HMS

    classDef source fill:#e8f1ff,stroke:#3973ac,color:#172b4d
    classDef ingest fill:#fff0d9,stroke:#c58b2b,color:#51380b
    classDef storage fill:#e3f5e8,stroke:#3a8c57,color:#153d24
    class DB,FILES,API source
    class CDC,KAFKA,NIFI ingest
    class LAND,MINIO,BRONZE,HMS storage
```

Objetivo: centralizar datos de fuentes operacionales y archivos en el almacenamiento de objetos,
conservando los datos originales y registrando las tablas Iceberg en el catálogo.

# 2. Procesamiento y transformación — Medallion

```mermaid

flowchart TB
    subgraph STORAGE["Almacenamiento"]
        B[("Bronze<br/>Datos crudos")]
        S[("Silver<br/>Datos limpios")]
        G[("Gold<br/>Datos analíticos")]
        MINIO[("MinIO<br/>Almacenamiento físico")]
        HMS["Hive Metastore<br/>Catálogo de tablas"]
    end

    subgraph PROC["Procesamiento"]
        SPARK["Apache Spark<br/>Procesamiento distribuido"]
        DBT["dbt-core<br/>Modelado SQL"]
        GE["Great Expectations<br/>Validación de calidad"]
    end

    B --> SPARK
    SPARK --> S
    S --> DBT
    DBT --> G

    S -.-> GE
    G -.-> GE
    GE -. "Resultados de validación" .-> QUALITY["Reportes / alertas"]

    B -.-> MINIO
    S -.-> MINIO
    G -.-> MINIO

    B -.-> HMS
    S -.-> HMS
    G -.-> HMS

    classDef bronze fill:#f8e4d2,stroke:#bd7839,color:#542d0c
    classDef silver fill:#e9edf2,stroke:#7a8999,color:#263746
    classDef gold fill:#fff1bd,stroke:#c39b23,color:#5c4700
    classDef process fill:#e5e6ff,stroke:#6664b5,color:#28275e
    class B bronze
    class S silver
    class G gold
    class SPARK,DBT,GE process
```

Objetivo: transformar los datos progresivamente, desde los registros originales hasta modelos analíticos confiables. Spark realiza el procesamiento distribuido; dbt gestiona el modelado SQL, y Great Expectations valida la calidad.

# 3. Consumo y analítica

```mermaid
flowchart LR
    subgraph DATA["Lakehouse"]
        BRONZE[("Bronze")]
        SILVER[("Silver")]
        GOLD[("Gold<br/>Tablas de negocio")]
        HMS["Hive Metastore"]
        MINIO[("MinIO")]
    end

    subgraph QUERY["Acceso a datos"]
        TRINO["Trino<br/>SQL distribuido y federación"]
    end

    subgraph CONSUMERS["Consumo"]
        BI["Apache Superset<br/>Dashboards y BI"]
        ANALYST["Analistas / Científicos de datos"]
        APPS["Aplicaciones y servicios"]
    end

    GOLD --> TRINO
    HMS -. "Metadatos" .-> TRINO
    MINIO -. "Archivos Iceberg" .-> TRINO
    BRONZE ~~~ SILVER

    TRINO --> BI
    TRINO --> ANALYST
    TRINO --> APPS

    classDef gold fill:#fff1bd,stroke:#c39b23,color:#5c4700
    classDef query fill:#e5e6ff,stroke:#6664b5,color:#28275e
    classDef consumer fill:#e3f5e8,stroke:#3a8c57,color:#153d24
    class GOLD gold
    class TRINO query
    class BI,ANALYST,APPS consumer
```

Objetivo: ofrecer un punto de acceso SQL a los datos analíticos mediante Trino, con Superset como herramienta de visualización y con posibilidad de acceso desde otras aplicaciones.

# 4. Servicios transversales e infraestructura

```mermaid
flowchart TB
    subgraph SECURITY["Seguridad y gobierno"]
        AD["Active Directory<br/>Identidad corporativa"]
        RANGER["Apache Ranger<br/>Políticas y auditoría"]
        VAULT["HashiCorp Vault<br/>Gestión de secretos"]
        TLS["TLS en tránsito<br/>Cifrado en reposo"]
        META["OpenMetadata<br/>Catálogo de negocio y linaje"]
    end

    subgraph PLATFORM["Plataforma lakehouse"]
        ING["Ingesta<br/>Debezium / Kafka / NiFi"]
        LAKE["Almacenamiento<br/>MinIO / Iceberg / HMS"]
        PROC["Procesamiento<br/>Spark / dbt / Airflow"]
        QUERY["Consulta<br/>Trino / Superset"]
    end

    subgraph OPS["Operación y entrega"]
        OBS["Prometheus + Grafana<br/>Métricas y monitoreo"]
        GIT["GitLab<br/>Repositorios y CI/CD"]
        K8S["Kubernetes<br/>Plataforma de ejecución"]
        ANS["Ansible<br/>Configuración y automatización"]
    end

    AD -. "Identidad" .-> RANGER
    RANGER -. "Políticas de acceso" .-> LAKE
    RANGER -. "Políticas de acceso" .-> QUERY
    VAULT -. "Credenciales y secretos" .-> PLATFORM
    TLS -. "Protección" .-> LAKE
    META -. "Metadatos y linaje" .-> LAKE
    META -. "Metadatos y linaje" .-> PROC

    OBS -. "Métricas" .-> PLATFORM
    GIT --> K8S
    ANS --> K8S
    K8S -. "Ejecución" .-> PLATFORM

    classDef security fill:#fce7e7,stroke:#bd5555,color:#572020
    classDef platform fill:#e5e6ff,stroke:#6664b5,color:#28275e
    classDef ops fill:#e3f5e8,stroke:#3a8c57,color:#153d24
    class AD,RANGER,VAULT,TLS,META security
    class ING,LAKE,PROC,QUERY platform
    class OBS,GIT,K8S,ANS ops
```

Objetivo: representar los servicios compartidos que dan soporte a toda la plataforma, sin repetirlos en los diagramas de flujo de datos.

# 5. Diagrama general — Arquitectura integral del Lakehouse

```mermaid

flowchart LR
    A["1. INGESTA<br/>Debezium · Kafka<br/>Apache NiFi"]
    B[("2. BRONZE<br/>Datos crudos<br/>MinIO + Iceberg")]
    C[("3. SILVER<br/>Datos depurados<br/>Spark + Iceberg")]
    D[("4. GOLD<br/>Datos analíticos<br/>dbt-core + Iceberg")]
    E["5. CONSUMO<br/>Trino · Superset"]

    A --> B --> C --> D --> E

    CAT["Catálogo técnico<br/>Hive Metastore"]
    ORQ["Orquestación<br/>Airflow"]
    GOV["Gobierno y seguridad<br/>OpenMetadata · Ranger<br/>Active Directory · Vault"]
    OPS["Operación e infraestructura<br/>GitLab · Kubernetes · Ansible<br/>Prometheus · Grafana"]

    CAT -.-> B
    CAT -.-> C
    CAT -.-> D
    CAT -.-> E

    ORQ -.-> A
    ORQ -.-> C
    ORQ -.-> D

    GOV -.-> B
    GOV -.-> C
    GOV -.-> D
    GOV -.-> E

    OPS -.-> A
    OPS -.-> B
    OPS -.-> C
    OPS -.-> D
    OPS -.-> E

    classDef ingest fill:#dbeafe,stroke:#2563eb,color:#1e3a8a
    classDef bronze fill:#fce7d5,stroke:#c27632,color:#713f12
    classDef silver fill:#e5e7eb,stroke:#6b7280,color:#1f2937
    classDef gold fill:#fef3c7,stroke:#d97706,color:#78350f
    classDef consume fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef transversal fill:#f3e8ff,stroke:#9333ea,color:#581c87

    class A ingest
    class B bronze
    class C silver
    class D gold
    class E consume
    class CAT,ORQ,GOV,OPS transversal
```

Lectura del diagrama:
- Flujo principal: ingesta → Bronze → Silver → Gold → consumo.
- Catálogo: Hive Metastore registra las tablas Iceberg utilizadas en las capas del lakehouse y consultadas por Trino.
- Orquestación: Airflow coordina los pipelines.
- Gobierno y seguridad: OpenMetadata, Ranger, Active Directory y Vault proporcionan capacidades transversales.
- Operación: GitLab, Kubernetes, Ansible y Prometheus/Grafana soportan despliegue y monitoreo.
MinIO es el almacenamiento físico compartido de Bronze, Silver y Gold; Iceberg es el formato de tablas. El cifrado en reposo y TLS deben configurarse como controles de infraestructura y comunicación, respectivamente.


# 6. Integración de Machine Learning con Medallion e infraestructura GPU

```mermaid
flowchart TB
    subgraph LAKE["Lakehouse existente"]
        SILVER[("Silver<br/>Datos depurados")]
        GOLD[("Gold<br/>Datos analíticos")]
        STORE[("MinIO + Iceberg<br/>Datasets y predicciones")]
        HMS["Hive Metastore<br/>Catálogo técnico"]
    end

    subgraph ML["Entorno de Machine Learning"]
        PREP["Preparación de variables<br/>Python / Spark"]
        DATA["Datasets de entrenamiento<br/>y validación"]
        CPU["Servidor CPU<br/>Entrenamiento convencional"]
        GPU["Servidor GPU opcional<br/>Deep Learning / modelos intensivos"]
        MLFLOW["MLflow<br/>Experimentos y modelos"]
        INF["Inferencia<br/>Batch o API"]
    end

    SILVER --> PREP
    GOLD --> PREP
    PREP --> DATA
    DATA --> CPU
    DATA -. "Si el modelo lo requiere" .-> GPU
    CPU --> MLFLOW
    GPU --> MLFLOW
    MLFLOW --> INF
    INF --> STORE
    STORE -. "Registro de tablas" .-> HMS

    classDef lake fill:#e3f5e8,stroke:#3a8c57,color:#153d24
    classDef ml fill:#e5e6ff,stroke:#6664b5,color:#28275e
    classDef gpu fill:#fff0d9,stroke:#c58b2b,color:#51380b
    class SILVER,GOLD,STORE,HMS lake
    class PREP,DATA,CPU,MLFLOW,INF ml
    class GPU gpu
```

**Objetivo:** identificar el punto de conexión entre el Lakehouse y el entorno de ML, así como los recursos de cómputo necesarios.

- **Origen de datos:** Silver proporciona datos depurados; Gold aporta variables e indicadores de negocio. No es necesario entrenar directamente sobre Bronze, salvo para casos específicos.
- **Almacenamiento:** los datasets preparados y las predicciones se pueden persistir en MinIO mediante tablas Iceberg cuando corresponda.
- **Servidor CPU:** suficiente para comenzar con regresión, clasificación y muchos modelos tabulares tradicionales.
- **Servidor GPU:** recurso opcional para entrenamiento o inferencia que aproveche aceleración por GPU. Puede ser un nodo dedicado del clúster Kubernetes o un servidor separado.
- **MLflow:** registra experimentos y versiones de modelos; no reemplaza al almacenamiento Lakehouse.
- **Catálogo:** Hive Metastore mantiene los metadatos de las tablas Iceberg, no el registro de modelos.

La GPU no es un requisito para toda la plataforma ni para todos los modelos. Su necesidad debe determinarse mediante el caso de uso, el volumen de datos, el tiempo de entrenamiento y los requisitos de inferencia.

# 7. Flujo de Machine Learning y MLOps

```mermaid
flowchart LR
    DATA[("Silver / Gold<br/>MinIO + Iceberg")]
    ORQ["Airflow<br/>Orquestación"]
    PREP["Python / Spark<br/>Preparación de datos"]
    TRAIN["Entrenamiento<br/>scikit-learn / XGBoost<br/>GPU opcional"]
    MLFLOW["MLflow<br/>Experimentos y registro"]
    VALID{"Validación<br/>del modelo"}
    DEPLOY["GitLab CI/CD<br/>Despliegue controlado"]
    SERV["Inferencia<br/>API o proceso batch"]
    OUT[("Predicciones<br/>MinIO + Iceberg")]
    MON["Monitoreo<br/>Calidad, deriva y métricas"]

    DATA --> ORQ
    ORQ --> PREP
    PREP --> TRAIN
    TRAIN --> MLFLOW
    MLFLOW --> VALID
    VALID -->|Aprobado| DEPLOY
    VALID -->|Rechazado| TRAIN
    DEPLOY --> SERV
    SERV --> OUT
    OUT --> MON
    MON -. "Señales para evaluar<br/>reentrenamiento" .-> ORQ

    classDef data fill:#e3f5e8,stroke:#3a8c57,color:#153d24
    classDef process fill:#e5e6ff,stroke:#6664b5,color:#28275e
    classDef decision fill:#fff0d9,stroke:#c58b2b,color:#51380b
    class DATA,OUT data
    class ORQ,PREP,TRAIN,MLFLOW,DEPLOY,SERV,MON process
    class VALID decision
```

**Objetivo:** representar el ciclo de vida de un modelo, desde los datos hasta su ejecución en producción.

1. Airflow coordina la preparación de datos y el entrenamiento.
2. Python, scikit-learn o XGBoost entrenan el modelo; Spark puede utilizarse cuando el volumen de datos lo justifique.
3. MLflow registra experimentos, métricas y versiones de los modelos.
4. El modelo se valida con criterios técnicos y de negocio antes de aprobar su despliegue.
5. GitLab CI/CD controla el proceso de entrega; la inferencia se ejecuta como proceso batch o servicio API.
6. Las predicciones se almacenan en el Lakehouse y se monitorean para detectar degradación.

El reentrenamiento no debe reemplazar automáticamente un modelo productivo sin validación. La promoción debe estar sujeta a criterios de aceptación y controles definidos.

# 8. Diagrama general — Arquitectura objetivo Lakehouse + Machine Learning

```mermaid
flowchart LR
    SRC["Fuentes<br/>Bases de datos, archivos y APIs"]
    ING["1. INGESTA<br/>Debezium · Kafka · NiFi"]
    BR[("2. BRONZE<br/>MinIO + Iceberg")]
    SI[("3. SILVER<br/>Spark + Iceberg")]
    GO[("4. GOLD<br/>dbt-core + Iceberg")]
    CON["5. CONSUMO<br/>Trino · Superset"]

    subgraph ML["6–7. MACHINE LEARNING"]
        PREP["Preparación de datasets<br/>Python / Spark"]
        TRAIN["Entrenamiento<br/>scikit-learn / XGBoost<br/>GPU opcional"]
        REG["MLflow<br/>Experimentos y modelos"]
        INF["Inferencia<br/>Batch / API"]
        PRED[("Predicciones<br/>MinIO + Iceberg")]
        PREP --> TRAIN --> REG --> INF --> PRED
    end

    SRC --> ING --> BR --> SI --> GO --> CON
    SI --> PREP
    GO --> PREP
    PRED --> CON

    CAT["Catálogo técnico<br/>Hive Metastore"]
    ORQ["Orquestación<br/>Airflow"]
    GOV["Gobierno y seguridad<br/>OpenMetadata · Ranger<br/>Active Directory · Vault"]
    OPS["Operación e infraestructura<br/>GitLab · Kubernetes · Ansible<br/>Prometheus · Grafana"]

    CAT -.-> BR
    CAT -.-> SI
    CAT -.-> GO
    CAT -.-> PRED
    CAT -.-> CON

    ORQ -.-> ING
    ORQ -.-> SI
    ORQ -.-> GO
    ORQ -.-> PREP
    ORQ -.-> TRAIN
    ORQ -.-> INF

    GOV -.-> BR
    GOV -.-> SI
    GOV -.-> GO
    GOV -.-> PRED
    GOV -.-> CON

    OPS -.-> ING
    OPS -.-> BR
    OPS -.-> SI
    OPS -.-> GO
    OPS -.-> CON
    OPS -.-> ML

    classDef ingest fill:#dbeafe,stroke:#2563eb,color:#1e3a8a
    classDef bronze fill:#fce7d5,stroke:#c27632,color:#713f12
    classDef silver fill:#e5e7eb,stroke:#6b7280,color:#1f2937
    classDef gold fill:#fef3c7,stroke:#d97706,color:#78350f
    classDef consume fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef mlclass fill:#e5e6ff,stroke:#6664b5,color:#28275e
    classDef transversal fill:#f3e8ff,stroke:#9333ea,color:#581c87

    class SRC,ING ingest
    class BR bronze
    class SI silver
    class GO gold
    class CON consume
    class PREP,TRAIN,REG,INF,PRED mlclass
    class CAT,ORQ,GOV,OPS transversal
```

**Objetivo:** mostrar cómo se incorpora ML a la arquitectura objetivo sin crear un Lakehouse independiente.

- **Flujo principal:** ingesta → Bronze → Silver → Gold → consumo analítico.
- **Conexión con ML:** los datos depurados de Silver y los modelos analíticos de Gold alimentan la preparación de datasets para entrenamiento.
- **Resultados:** las predicciones se almacenan en MinIO/Iceberg y quedan disponibles para consultas con Trino y visualización en Superset.
- **Orquestación:** Airflow coordina los procesos de datos y ML.
- **MLOps:** MLflow administra experimentos y modelos; GitLab CI/CD y Kubernetes soportan el despliegue.
- **Infraestructura GPU:** se incorpora como capacidad de cómputo opcional para las cargas que lo requieran, sin convertirla en dependencia de toda la plataforma.
- **Servicios transversales:** catálogo, seguridad, gobierno y observabilidad mantienen su función compartida.

La arquitectura representa una capacidad futura: los componentes de ML pueden incorporarse gradualmente cuando exista un caso de uso priorizado, datos suficientes y requisitos definidos de entrenamiento e inferencia.

# 9. Consumo de modelos ML mediante APIs

```mermaid
flowchart LR
    subgraph CLIENTS["Consumidores"]
        APP["Otros servicios"]
        SYS["Sistemas de negocio"]
    end

    subgraph ML["Plataforma de Machine Learning"]
        API["FastAPI<br/>API REST"]
        MODEL["Modelo ML<br/>Cargado en memoria"]
        REG["MLflow Model Registry<br/>Versiones y metadatos"]
        STORE[("MinIO<br/>Artefactos del modelo")]
    end

    APP -->|"HTTP / JSON"| API
    SYS -->|"HTTP / JSON"| API

    REG -.->|"Versión aprobada"| API
    STORE -->|"Descarga del artefacto"| API
    API --> MODEL
    MODEL --> API

    API -->|"Predicción JSON"| APP
    API -->|"Predicción JSON"| SYS

    classDef client fill:#dbeafe,stroke:#2563eb,color:#1e3a8a
    classDef service fill:#e5e6ff,stroke:#6664b5,color:#28275e
    classDef storage fill:#e3f5e8,stroke:#3a8c57,color:#153d24

    class APP,SYS client
    class API,MODEL,REG service
    class STORE storage

```

**Objetivo:** exponer los modelos de Machine Learning mediante APIs REST para que otros servicios y sistemas de negocio puedan solicitar predicciones sin acceder directamente a la infraestructura de entrenamiento ni al Lakehouse.

**Componentes y responsabilidades:**

- **FastAPI:** expone los endpoints REST, recibe solicitudes HTTP con datos en formato JSON y devuelve las predicciones.
- **MLflow Model Registry:** registra las versiones de los modelos, sus metadatos y su estado de aprobación.
- **MinIO:** almacena los artefactos de los modelos entrenados, como archivos serializados de scikit-learn o XGBoost.
- **Modelo ML:** se carga en memoria desde el artefacto almacenado en MinIO para realizar las predicciones.
- **Otros servicios:** consumen la API mediante HTTP/HTTPS, enviando los datos requeridos y recibiendo las predicciones en formato JSON.

**Flujo de funcionamiento:**

1. Un modelo entrenado se registra en MLflow y su artefacto se almacena en MinIO.
2. FastAPI identifica la versión aprobada y carga el modelo desde MinIO, normalmente al iniciar o actualizar el servicio.
3. Otros sistemas envían solicitudes a la API con los datos necesarios para realizar una predicción.
4. FastAPI ejecuta el modelo y devuelve el resultado al sistema solicitante.

**Infraestructura y seguridad:** el servicio puede desplegarse como contenedor en Kubernetes. Deben implementarse autenticación, autorización, TLS y controles de acceso a MinIO y MLflow según las políticas corporativas.

**Consideración arquitectónica:** MinIO almacena los archivos de los modelos, mientras que MLflow administra sus versiones y metadatos. No es necesario almacenar los modelos como tablas Iceberg; ambos componentes pueden utilizar la infraestructura de almacenamiento de la plataforma con funciones diferenciadas.

# Capas y herramientas para Machine Learning y MLOps

| Etapa | Capa | Herramienta |
|---|---|---|
| Machine Learning | Lenguaje de desarrollo y análisis | Python |
| Machine Learning | Entrenamiento de modelos tradicionales | scikit-learn |
| Machine Learning | Modelos tabulares avanzados | XGBoost / LightGBM |
| Machine Learning | Preparación y procesamiento de datasets | Apache Spark + Python |
| Machine Learning | Entorno de desarrollo interactivo | JupyterHub |
| Machine Learning | Registro de experimentos, métricas y versiones de modelos | MLflow Tracking + Model Registry |
| Machine Learning | Almacenamiento de artefactos de modelos | MinIO |
| Machine Learning | Cómputo acelerado para entrenamiento e inferencia intensiva | Servidor GPU / Kubernetes con GPU (opcional) |
| MLOps | Orquestación de pipelines de entrenamiento y evaluación | Apache Airflow |
| MLOps | Validación y evaluación de modelos | Python + scikit-learn |
| MLOps | Versionamiento y despliegue de modelos | GitLab CI/CD + Kubernetes |
| MLOps | Monitoreo de deriva de datos y desempeño de modelos | Evidently |
| Inferencia / Consumo | Exposición de modelos mediante API REST | FastAPI |
| Inferencia / Consumo | Ejecución de predicciones batch | Python / Apache Spark + Airflow |
| Inferencia / Consumo | Almacenamiento de predicciones e históricos | MinIO + Apache Iceberg |
| Inferencia / Consumo | Consulta y análisis de predicciones | Trino + Apache Superset |
| Transversal | Métricas y monitoreo de infraestructura y servicios ML | Prometheus + Grafana |
| Transversal | Seguridad y gestión de credenciales | Active Directory + HashiCorp Vault |
| Transversal | Plataforma de ejecución de servicios ML | Kubernetes |
