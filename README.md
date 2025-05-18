# R-SNORT WebApp: Sistema Centralizado de Monitorización y Gestión de Intrusiones

**R-SNORT WebApp** es una solución integral y modular de detección y gestión de intrusiones (NIDS), diseñada para desplegarse fácilmente en pequeñas redes locales (SOHO/SMB) utilizando **Snort 3**, **Grafana**, y tecnologías modernas como **Spring Boot** y **Angular**. La aplicación permite la supervisión centralizada de múltiples agentes distribuidos, facilitando el análisis forense, la descarga de alertas y la gestión de reglas desde una interfaz gráfica web.

---

## 🌐 Estructura del Proyecto

```
r-snort-central-module-installer/
├── rsnort-backend/           # Backend en Spring Boot
├── rsnort-frontend/          # Frontend en Angular
└── scripts/                  # Scripts de instalación y despliegue automatizado
```

---

## ⚙️ Tecnologías Utilizadas

- 🔐 **Snort 3.1.84.0**: Motor NIDS en cada agente.
- 🧠 **Spring Boot 3**: Backend REST para el módulo central.
- 🖥️ **Angular 19**: Frontend standalone para la UI web.
- 📊 **Grafana 12**: Visualización avanzada de alertas y métricas del sistema.
- 🐬 **MariaDB**: Almacenamiento de alertas y reglas.
- 📦 **Instaladores `.deb`**: Instalación automática, sin intervención del usuario.

---

## 🧩 Componentes del Sistema

### 1. Agente R-Snort
Cada Raspberry Pi o servidor Ubuntu actúa como agente autónomo que:
- Detecta tráfico malicioso con Snort 3.
- Genera alertas en JSON rotadas y archivadas automáticamente.
- Expone una API REST (`agent_api.py`) con endpoints `/alerts`, `/rules`, `/status`, etc.
- Recolecta métricas del sistema (`metrics_timer.py`).
- Se instala en segundos mediante un paquete `.deb`.

### 2. Módulo Central
- Actúa como agente y servidor principal.
- Agrega alertas de múltiples agentes.
- Permite la gestión remota desde el frontend web.
- Ofrece dashboards de Grafana preconfigurados.
- Administra usuarios con roles y acceso seguro.

---

## 🚀 Instalación Automática

> Requisitos previos: Ubuntu Server 22.04+, acceso sudo, conexión a Internet.

```bash
git clone https://github.com/tuusuario/rsnort-webapp.git
cd rsnort-central-module-installer/scripts
chmod +x run_all.sh
sudo ./run_all.sh
```

Esto compila e instala automáticamente:
- El frontend Angular y backend Spring Boot
- La base de datos MariaDB
- Snort 3 con configuración personalizada
- Dashboards de Grafana preconfigurados
- Servicio del sistema para rsnort_webapp

---

## 🛡️ Funcionalidades Destacadas

- 📡 **Detección en tiempo real** de ataques ICMP, SNMP, DNS, exfiltración de datos, etc.
- 📂 **Archivado forense** de logs con rotación automática vía `logrotate`.
- 🔍 **Interfaz gráfica profesional** con panel oscuro y visualización de alertas.
- 🔐 **Login seguro con roles** y gestión de reglas desde el frontend.
- 🌐 **Gestión de múltiples agentes** desde una única webApp.
- 📥 **Descarga selectiva de alertas** y logs archivados por agente.

---

## 📸 Capturas de Pantalla

> Puedes añadir aquí capturas reales de tu interfaz web, dashboard de Grafana o consola de logs rotados.

---

## 🔧 Scripts Incluidos

| Script                | Función principal                                               |
|----------------------|------------------------------------------------------------------|
| `00_common.sh`       | Variables comunes y funciones auxiliares                        |
| `01_dependencies.sh` | Instalación de dependencias en el sistema                       |
| `02_compile_frontend.sh` | Compila Angular en modo producción                         |
| `03_compile_backend.sh`  | Empaqueta el backend como `.jar` con Maven                 |
| `04_prepare_db.sh`   | Crea la base de datos y estructura inicial                      |
| `05_add_admin_user.sh` | Inserta un usuario administrador predefinido                 |
| `06_setup_agents.sh` | Añade agentes con comprobación automática (`ping` + `/docs`)    |
| `07_install_service.sh` | Instala el servicio systemd para ejecución automática        |
| `run_all.sh`         | Ejecuta todo el proceso de instalación de principio a fin       |

---

## 🧪 Pruebas y Validación

La plataforma ha sido probada con casos reales de intrusión simulada, incluyendo:
- Pings masivos
- Escaneos de puertos con Nmap
- Tráfico DNS malicioso
- Fugas de emails, tarjetas de crédito y NUSS

Toda la metodología está documentada en el capítulo de pruebas del TFG, incluyendo benchmarks con `pmgraph`.

---

## 📚 Documentación Técnica

- `snort-agent` y `rsnort_webapp` están separados por funciones.
- Todos los endpoints REST están documentados en `/docs` de cada agente.
- Incluye compatibilidad con sistemas sin NUMA (desactivación automática).

---

## 🤝 Colaboraciones

Este proyecto es parte de un Trabajo de Fin de Grado (TFG) en Ingeniería Informática y está diseñado para ser expandido, profesionalizado y adaptado a entornos productivos reales.

---

## 📜 Licencia

Licencia MIT. Libre uso, modificación y distribución con atribución.

---

## 📫 Contacto

Desarrollado por Deian Orlando Petrovics.  
