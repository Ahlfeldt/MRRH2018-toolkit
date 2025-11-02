# ================================================================
# MRRH2018 FULL PIPELINE CONTROLLER SCRIPT
# Part of the MRRH2018 Toolkit
#
# Authors: Gabriel Ahlfeldt & Tobias Seidel
# Purpose: Executes all major components of the MRRH2018 Toolkit
#          in the correct order, including grid creation,
#          data processing, and travel time matrix generation.
#
# Dependencies: Python standard library (subprocess, sys, os)
# ================================================================


import subprocess
import sys
import os

# Always use the folder containing this script as root
ROOT_DIR = os.path.dirname(os.path.abspath(__file__))

# Define scripts in order
scripts = [
    os.path.join(ROOT_DIR, "GRID-toolkit", "GRID-gen.py"),
    os.path.join(ROOT_DIR, "GRID-toolkit", "GRID-data.py"),
    os.path.join(ROOT_DIR, "TTMATRIX-toolkit", "TTMATRIX-noHSR.py"),
    os.path.join(ROOT_DIR, "TTMATRIX-toolkit", "TTMATRIX-HSR.py"),
]

print("=== Starting full pipeline execution ===\n")

for script in scripts:
    script_dir = os.path.dirname(script)
    print(f"[RUN] Executing: {script}")

    result = subprocess.run(
        [sys.executable, script],
        cwd=script_dir,
        capture_output=True,
        text=True
    )

    print(result.stdout)
    if result.stderr:
        print("[WARNING / ERROR OUTPUT]:\n", result.stderr)

    if result.returncode != 0:
        print(f"[FAIL] Script failed: {script}")
        sys.exit(result.returncode)

    print(f"[DONE] {os.path.basename(script)} completed successfully.\n{'-'*60}\n")

print("=== All scripts executed successfully ===")
