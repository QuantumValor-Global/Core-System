import os
def check_system():
    paths = ["core/g-agi", "blockchain-core/solana-vlt", "vault"]
    for p in paths:
        if os.path.exists(p):
            print(f"✅ {p}: ACTIVE")
check_system()
