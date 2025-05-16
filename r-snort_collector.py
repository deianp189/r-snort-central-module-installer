# ==========================================
# r-snort_collector.py
# ==========================================

import os
import time
import json
import psutil
import pymysql
from datetime import datetime
from pymysql import OperationalError

# =============================
# Configuración
# =============================
DB_HOST = 'localhost'
DB_PORT = 3306
DB_USER = 'snortuser'
DB_PASSWORD = os.environ.get('RSNORT_DB_PASSWORD')
DB_NAME = 'rsnort_webapp'

SNORT_ALERT_LOG = '/opt/snort/logs/live/alert_json.txt'

# =============================
# Funciones auxiliares
# =============================

def conectar_db():
    return pymysql.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )

def leer_alertas(alertas_vistas):
    nuevas_alertas = []
    try:
        with open(SNORT_ALERT_LOG, 'r') as f:
            lineas = f.readlines()
        for linea in lineas:
            if not linea.strip():
                continue
            alerta = json.loads(linea.strip())
            clave = (alerta.get('timestamp'), alerta.get('src_addr'), alerta.get('dst_addr'), alerta.get('msg'))
            if clave not in alertas_vistas:
                nuevas_alertas.append((clave, alerta))
    except Exception as e:
        print(f"[!] Error leyendo alertas: {e}")
    return nuevas_alertas

def capturar_metricas():
    try:
        cpu = psutil.cpu_percent()
        mem = psutil.virtual_memory().percent
        disk = psutil.disk_usage('/').percent
        temp = None
        if hasattr(psutil, 'sensors_temperatures'):
            temps = psutil.sensors_temperatures()
            if temps:
                for name, entries in temps.items():
                    temp = entries[0].current
                    break
        if temp is None:
            temp = 0.0
        return {
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'cpu_usage': cpu,
            'memory_usage': mem,
            'temperature': temp,
            'disk_usage': disk
        }
    except Exception as e:
        print(f"[!] Error capturando métricas: {e}")
        return None

def insertar_alertas(conn, alertas):
    try:
        with conn.cursor() as cursor:
            for alerta in alertas:
                ts_raw = alerta.get('timestamp')
                try:
                    ts_dt = datetime.strptime(ts_raw, '%m/%d-%H:%M:%S.%f')
                    ts_final = ts_dt.replace(year=datetime.now().year)
                    ts_str = ts_final.strftime('%Y-%m-%d %H:%M:%S')
                except Exception:
                    ts_str = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

                cursor.execute("""
                    INSERT INTO alerts (timestamp, proto, dir, src_addr, src_port, dst_addr, dst_port, msg, sid, gid, priority)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    ts_str,
                    alerta.get('proto'),
                    alerta.get('dir'),
                    alerta.get('src_addr'),
                    alerta.get('src_port'),
                    alerta.get('dst_addr'),
                    alerta.get('dst_port'),
                    alerta.get('msg'),
                    alerta.get('sid'),
                    alerta.get('gid'),
                    alerta.get('priority')
                ))
        conn.commit()
    except Exception as e:
        print(f"[!] Error insertando alertas: {e}")

def insertar_metrica(conn, metrica):
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                INSERT INTO system_metrics (timestamp, cpu_usage, memory_usage, temperature, disk_usage)
                VALUES (%s, %s, %s, %s, %s)
            """, (
                metrica['timestamp'],
                metrica['cpu_usage'],
                metrica['memory_usage'],
                metrica['temperature'],
                metrica['disk_usage']
            ))
        conn.commit()
    except Exception as e:
        print(f"[!] Error insertando métricas: {e}")

# =============================
# Bucle principal
# =============================

def main_loop():
    alertas_vistas = set()
    buffer_alertas = []
    contador_segundos = 0

    while True:
        nuevas_alertas = leer_alertas(alertas_vistas)
        for clave, alerta in nuevas_alertas:
            buffer_alertas.append(alerta)
            alertas_vistas.add(clave)

        if contador_segundos % 5 == 0:
            metrica = capturar_metricas()
            if metrica:
                try:
                    conn = conectar_db()
                    insertar_metrica(conn, metrica)
                finally:
                    conn.close()

        if contador_segundos >= 60:
            if buffer_alertas:
                try:
                    conn = conectar_db()
                    insertar_alertas(conn, buffer_alertas)
                finally:
                    conn.close()
                buffer_alertas.clear()
            contador_segundos = 0

        contador_segundos += 1
        time.sleep(1)

# =============================
# Inicio
# =============================

if __name__ == '__main__':
    if not DB_PASSWORD:
        print("❌ No se encontró la variable de entorno RSNORT_DB_PASSWORD.")
        exit(1)

    print("🚀 r-snort_collector iniciado.")
    main_loop()
