import subprocess
import os

def run_bloatware_removal() -> dict:
    """
    Executes the BloatwareRemoval.ps1 script from the 'PS' folder, 
    capturing output and enforcing strict error checking.
    """
    # 1. Dynamically resolve the script path (Assuming this python file is in the root directory)
    base_dir = os.path.dirname(os.path.abspath(__file__))
    script_path = os.path.join(base_dir, "..", "PS", "BloatwareRemoval.ps1")

    # 2. Verify the script exists to provide a clear error before execution
    if not os.path.isfile(script_path):
        raise FileNotFoundError(f"Error: The PowerShell script was not found at '{script_path}'")

    # 3. Construct the command list safely
    command = [
        "powershell.exe",
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", script_path
    ]

    # 4. Execute the subprocess
    result = subprocess.run(command, capture_output=True, text=True)

    # 5. Log the output clearly to the console
    if result.stdout:
        print("--- Bloatware Removal STDOUT ---")
        print(result.stdout.strip())
        print("--------------------------------")
        
    if result.stderr:
        print("--- Bloatware Removal STDERR ---")
        print(result.stderr.strip())
        print("--------------------------------")

    # 6. Enforce strict error handling
    if result.returncode != 0:
        raise RuntimeError(
            f"Execution failed! BloatwareRemoval.ps1 returned exit code {result.returncode}.\n"
            f"Error details: {result.stderr.strip()}"
        )

    # 7. Return the structured dictionary
    return {
        "exit_code": result.returncode,
        "stdout": result.stdout,
        "stderr": result.stderr
    }


def run_program_installation() -> dict:
    """
    Executes the ProgramInstallation.ps1 script from the 'PS' folder, 
    capturing output and enforcing strict error checking.
    """
    # 1. Dynamically resolve the script path
    base_dir = os.path.dirname(os.path.abspath(__file__))
    script_path = os.path.join(base_dir, "..", "PS", "ProgramInstallation.ps1")

    # 2. Verify the script exists
    if not os.path.isfile(script_path):
        raise FileNotFoundError(f"Error: The PowerShell script was not found at '{script_path}'")

    # 3. Construct the command list safely
    command = [
        "powershell.exe",
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", script_path
    ]

    # 4. Execute the subprocess
    result = subprocess.run(command, capture_output=True, text=True)

    # 5. Log the output clearly to the console
    if result.stdout:
        print("--- Program Installation STDOUT ---")
        print(result.stdout.strip())
        print("-----------------------------------")
        
    if result.stderr:
        print("--- Program Installation STDERR ---")
        print(result.stderr.strip())
        print("-----------------------------------")

    # 6. Enforce strict error handling
    if result.returncode != 0:
        raise RuntimeError(
            f"Execution failed! ProgramInstallation.ps1 returned exit code {result.returncode}.\n"
            f"Error details: {result.stderr.strip()}"
        )

    # 7. Return the structured dictionary
    return {
        "exit_code": result.returncode,
        "stdout": result.stdout,
        "stderr": result.stderr
    }
