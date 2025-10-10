#!/usr/bin/env python3

import json
import sys
from pathlib import Path
from typing import Dict


def load_config():
    config_path = Path(__file__).parent / "config.json"
    with open(config_path, 'r') as f:
        return json.load(f)


config = load_config()
PROJECT_CONFIGS = config["projects"]
INTERMEDIATE_TEMPLATES = config["intermediate_templates"]


def generate_intermediate_dockerfile(base: str, output_dir: Path):
    if base not in INTERMEDIATE_TEMPLATES:
        raise ValueError(f"Unknown base: {base}")
    
    filepath = output_dir / f"{base}.Dockerfile"
    with open(filepath, 'w') as f:
        f.write(INTERMEDIATE_TEMPLATES[base])
    
    print(f"Generated intermediate: {filepath}")


def generate_infra_dockerfile(project: str, config: Dict, output_dir: Path):
    base = config["base"]
    packages = config["packages"]
    
    dockerfile_lines = [f"FROM {base}:latest\n"]
    
    if "npm" in packages and packages["npm"]:
        npm_packages = " ".join(packages["npm"])
        dockerfile_lines.append(f"\nRUN npm install -g {npm_packages}\n")
    
    if "cargo" in packages and packages["cargo"]:
        cargo_packages = packages["cargo"]
        for pkg in cargo_packages:
            dockerfile_lines.append(f"\nRUN cargo install {pkg}\n")
    
    dockerfile_lines.append(f'\nLABEL description="{project} infrastructure layer"\n')
    
    filepath = output_dir / f"{project}.Dockerfile"
    with open(filepath, 'w') as f:
        f.writelines(dockerfile_lines)
    
    print(f"Generated infra: {filepath}")


def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_docker.py <project_name> [project_name2 ...]")
        print("\nAvailable projects:")
        for project in sorted(PROJECT_CONFIGS.keys()):
            print(f"  - {project}")
        sys.exit(1)
    
    root_dir = Path(__file__).parent
    intermediate_dir = root_dir / "intermediate"
    infra_dir = root_dir / "infra"
    
    intermediate_dir.mkdir(exist_ok=True)
    infra_dir.mkdir(exist_ok=True)
    
    projects = sys.argv[1:]
    
    for project in projects:
        project = project.lower()
        
        if project not in PROJECT_CONFIGS:
            print(f"Error: Unknown project '{project}'")
            print("\nAvailable projects:")
            for p in sorted(PROJECT_CONFIGS.keys()):
                print(f"  - {p}")
            continue
        
        config = PROJECT_CONFIGS[project]
        base = config["base"]
        
        intermediate_file = intermediate_dir / f"{base}.Dockerfile"
        if not intermediate_file.exists() or intermediate_file.stat().st_size == 0:
            generate_intermediate_dockerfile(base, intermediate_dir)
        
        generate_infra_dockerfile(project, config, infra_dir)


if __name__ == "__main__":
    main()

