import subprocess

PAUSE = "🚀 Pressione enter para continuar..."


def configurarPlanoEnergia():
    print("ℹ️ Começando alteração de plano de energia...")
    try:
        print("ℹ️ Activate High Performance plan (optional if already done)")
        subprocess.run(
            [
                "powershell",
                "-Command",
                "powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c",
            ],
            check=True,
        )

        print(
            'ℹ️ Setting "Turn off hard disk after" to 0 (Never) for both AC and DC (plugged and battery)'
        )
        subprocess.run(
            ["powershell", "-Command", "powercfg -change -disk-timeout-ac 0"],
            check=True,
        )
        subprocess.run(
            ["powershell", "-Command", "powercfg -change -disk-timeout-dc 0"],
            check=True,
        )

        print('ℹ️ Setting "Turn off display after" to 0 (Never) for both AC and DC')
        subprocess.run(
            ["powershell", "-Command", "powercfg -change -monitor-timeout-ac 0"],
            check=True,
        )
        subprocess.run(
            ["powershell", "-Command", "powercfg -change -monitor-timeout-dc 0"],
            check=True,
        )

        print("✅ Configurações de energia aplicadas com sucesso.\n")

    except subprocess.CalledProcessError as e:
        print("\n❌ Erro ao configurar plano de energia:", e)
        input(PAUSE)
