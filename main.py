import questionary

from controllers.Programs import run_bloatware_removal, run_program_installation

# Key = the taskname
# Value = the task to be executed (import on the top of the page)
tasks = {
    "Remover Bloatware": run_bloatware_removal,
    "Instalar Programas": run_program_installation,
}

def main():
    '''
    Prints a  CLI using the questionary library, allowing the user to select
    which scripts to run. Uses the tasks specified on the "tasks" dictionary.
    '''
    try:
        print("🔧 Selecione as tarefas que deseja executar:\n")
        selected = questionary.checkbox(
            "Escolha as etapas que deseja rodar:", choices=tasks.keys()
        ).ask()

        if not selected:
            print("Nenhuma tarefa selecionada. Saindo...")
            return
        for name in selected:
            print(f"\n🔸 Executando: {name}")
            try:
                tasks[name]()  # Call the function
            except Exception as e:
                print(f"Erro ao executar '{name}': {e}")
                input("Pressione Enter para continuar...")
    except Exception as e:
        print("Algo deu errado: ", e)


if __name__ == "__main__":
    while True:
        main()
        print("Thank you for using this program!\n")

        user_choice = input("Deseja rodar o programa novamente? (y/n)\n> ").lower()
        if user_choice != "y":
            print("Have a nice day, goodbye!")
            print("\n\n=== Made by: @RomanoBoldrin ===\n\n")
            break
