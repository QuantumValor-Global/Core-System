# Archivo: start_miax.py
try:
    from core.miax_absorber import MIAX_Absorber
    from protocols.global_optimization import energy_mesh_sync

    # Activar el nexo
    engine = MIAX_Absorber()
    energy_mesh_sync()
    print(f"MIA-X: Sincronización con {engine.qve_standard} Q-Tokens confirmada.")
    print("Estado: Agujero Negro Abierto y Analizando Mercado Tradicional.")
except ImportError:
    print("[ERROR] Primero debes ejecutar 'python MIAX_AutoDeploy.py' para generar los archivos.")