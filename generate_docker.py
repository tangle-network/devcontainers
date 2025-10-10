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


def generate_combined_dockerfile(project_names: list, output_dir: Path):
    configs = []
    base = None
    
    for name in project_names:
        if name not in PROJECT_CONFIGS:
            print(f"Error: Unknown project '{name}'")
            return False
        
        config = PROJECT_CONFIGS[name]
        project_base = config["base"]
        
        if base is None:
            base = project_base
        elif base != project_base:
            print(f"Error: Cannot combine projects with different base images")
            print(f"  {project_names[0]} uses '{base}'")
            print(f"  {name} uses '{project_base}'")
            return False
        
        configs.append((name, config))
    
    combined_name = "_".join(project_names)
    dockerfile_lines = [f"FROM {base}:latest\n"]
    
    all_npm_packages = []
    all_cargo_packages = []
    
    for name, config in configs:
        packages = config["packages"]
        if "npm" in packages and packages["npm"]:
            all_npm_packages.extend(packages["npm"])
        if "cargo" in packages and packages["cargo"]:
            all_cargo_packages.extend(packages["cargo"])
    
    all_npm_packages = list(dict.fromkeys(all_npm_packages))
    all_cargo_packages = list(dict.fromkeys(all_cargo_packages))
    
    if all_npm_packages:
        npm_packages = " ".join(all_npm_packages)
        dockerfile_lines.append(f"\nRUN npm install -g {npm_packages}\n")
    
    if all_cargo_packages:
        for pkg in all_cargo_packages:
            dockerfile_lines.append(f"\nRUN cargo install {pkg}\n")
    
    projects_desc = ", ".join(project_names)
    dockerfile_lines.append(f'\nLABEL description="Combined: {projects_desc}"\n')
    
    filepath = output_dir / f"{combined_name}.Dockerfile"
    with open(filepath, 'w') as f:
        f.writelines(dockerfile_lines)
    
    print(f"Generated combined infra: {filepath}")
    return True


def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_docker.py <project_name> [project_name2 ...]")
        print("       python generate_docker.py <project1_project2_...>")
        print("\nAvailable projects:")
        for project in sorted(PROJECT_CONFIGS.keys()):
            print(f"  - {project}")
        print("\nExamples:")
        print("  python generate_docker.py coinbase")
        print("  python generate_docker.py coinbase_mongodb_postgresql")
        print("  python generate_docker.py ethereum solana")
        sys.exit(1)
    
    root_dir = Path(__file__).parent
    intermediate_dir = root_dir / "intermediate"
    infra_dir = root_dir / "infra"
    
    intermediate_dir.mkdir(exist_ok=True)
    infra_dir.mkdir(exist_ok=True)
    
    projects = sys.argv[1:]
    
    for project_spec in projects:
        project_spec = project_spec.lower()
        
        if "_" in project_spec:
            project_names = [p.strip() for p in project_spec.split("_")]
            
            if not project_names:
                print(f"Error: Invalid project specification '{project_spec}'")
                continue
            
            if len(project_names) == 1:
                project = project_names[0]
                if project not in PROJECT_CONFIGS:
                    print(f"Error: Unknown project '{project}'")
                    continue
                
                config = PROJECT_CONFIGS[project]
                base = config["base"]
                
                intermediate_file = intermediate_dir / f"{base}.Dockerfile"
                if not intermediate_file.exists() or intermediate_file.stat().st_size == 0:
                    generate_intermediate_dockerfile(base, intermediate_dir)
                
                generate_infra_dockerfile(project, config, infra_dir)
            else:
                first_project = project_names[0]
                if first_project in PROJECT_CONFIGS:
                    base = PROJECT_CONFIGS[first_project]["base"]
                    intermediate_file = intermediate_dir / f"{base}.Dockerfile"
                    if not intermediate_file.exists() or intermediate_file.stat().st_size == 0:
                        generate_intermediate_dockerfile(base, intermediate_dir)
                
                generate_combined_dockerfile(project_names, infra_dir)
        else:
            project = project_spec
            
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

