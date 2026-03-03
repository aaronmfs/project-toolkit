import subprocess
import sys
import requests
import tomllib

from importlib.metadata import version, PackageNotFoundError
from packaging.version import parse

PYPROJECT_URL = "https://raw.githubusercontent.com/aaronmfs/project-toolkit/refs/heads/main/pyproject.toml"

def fetch_remote_version():
    try:
        response = requests.get(PYPROJECT_URL, timeout=10)
        response.raise_for_status()
        data = tomllib.loads(response.text)
        return parse(data["project"]["version"])
    except requests.RequestException:
        print("Could not reach GitHub. Check your connection.")
        return None

def fetch_local_version():
    try:
        return parse(version("project-toolkit"))
    except PackageNotFoundError:
        print("Package not installed properly.")
        return parse("0.0.0")

def prompt_update():
    print(
        "A new version of Project Toolkit is available.\n"
        "Do you want to update now? (y/n): "
    )

    answer = input("").strip().lower()

    if answer == "y":
        print("Installing update...")
        subprocess.run(
            [
                sys.executable,
                "-m",
                "pip",
                "install",
                "--upgrade",
                "git+https://github.com/aaronmfs/project-toolkit.git"
            ],
            check=True
        )
        print("Done. Restart your terminal to use the new version.")
    else:
        print("Update skipped.")

def check_for_update():
    local = fetch_local_version()
    remote = fetch_remote_version()

    if remote is None:
        return
    if remote > local:
        prompt_update()
    else:
        print("You are up to date.")
