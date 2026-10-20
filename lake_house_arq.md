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
