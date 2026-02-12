#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function loadConfig() {
    const configPath = path.join(__dirname, 'config.json');
    const configData = fs.readFileSync(configPath, 'utf8');
    return JSON.parse(configData);
}

const config = loadConfig();
const PROJECT_CONFIGS = config.projects;
const INTERMEDIATE_TEMPLATES = config.intermediate_templates;

/**
 * Generate cache warming commands for a project
 * @param {Object} cacheWarm - The cache_warm configuration object
 * @returns {string} Dockerfile RUN commands for cache warming
 */
function generateCacheWarmCommands(cacheWarm) {
    if (!cacheWarm) return '';

    const commands = [];

    // NPM cache warming
    if (cacheWarm.npm && cacheWarm.npm.length > 0) {
        commands.push(`# Pre-warm npm cache with project-specific packages`);
        commands.push(`RUN npm cache add ${cacheWarm.npm.join(' ')} || true`);
    }

    // Cargo cache warming (fetch crates without building)
    if (cacheWarm.cargo && cacheWarm.cargo.length > 0) {
        // Create a temporary Cargo.toml to fetch dependencies
        const deps = cacheWarm.cargo.map(crate => {
            const [name, version] = crate.split('@');
            return `${name} = "${version || '*'}"`;
        }).join('\\n');

        commands.push(`# Pre-warm cargo cache with project-specific crates`);
        commands.push(`RUN mkdir -p /tmp/cargo-warm && \\`);
        commands.push(`    printf '[package]\\nname = "warm"\\nversion = "0.0.0"\\nedition = "2021"\\n\\n[dependencies]\\n${deps}\\n' > /tmp/cargo-warm/Cargo.toml && \\`);
        commands.push(`    mkdir -p /tmp/cargo-warm/src && echo 'fn main() {}' > /tmp/cargo-warm/src/main.rs && \\`);
        commands.push(`    cd /tmp/cargo-warm && cargo fetch && \\`);
        commands.push(`    rm -rf /tmp/cargo-warm && \\`);
        commands.push(`    chmod -R a+w $CARGO_HOME`);
    }

    // pip cache warming
    if (cacheWarm.pip && cacheWarm.pip.length > 0) {
        commands.push(`# Pre-warm pip cache with project-specific packages`);
        commands.push(`RUN pip download --break-system-packages --dest /tmp/pip-warm ${cacheWarm.pip.join(' ')} && rm -rf /tmp/pip-warm`);
    }

    return commands.length > 0 ? '\n' + commands.join('\n') + '\n' : '';
}

function generateIntermediateDockerfile(base, outputDir) {
    if (!(base in INTERMEDIATE_TEMPLATES)) {
        throw new Error(`Unknown base: ${base}`);
    }
    
    const filepath = path.join(outputDir, `${base}.Dockerfile`);
    fs.writeFileSync(filepath, INTERMEDIATE_TEMPLATES[base]);
    
    console.log(`Generated intermediate: ${filepath}`);
}

function generateInfraDockerfile(project, config, outputDir) {
    const base = config.base;
    const packages = config.packages;
    const customInstall = config.custom_install;
    
    const dockerfileLines = [`FROM ${base}:latest\n`];
    
    if (customInstall && customInstall.env) {
        dockerfileLines.push('\n');
        const envVars = Object.entries(customInstall.env)
            .map(([key, value]) => `    ${key}=${value}`)
            .join(' \\\n');
        dockerfileLines.push(`ENV ${envVars}\n`);
    }
    
    if (customInstall && customInstall.apt_packages && customInstall.apt_packages.length > 0) {
        const aptPackages = customInstall.apt_packages.join(' ');
        dockerfileLines.push(`\nUSER root\n`);
        dockerfileLines.push(`RUN apt-get update && \\\n`);
        dockerfileLines.push(`    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \\\n`);
        dockerfileLines.push(`      ${aptPackages} && \\\n`);
        dockerfileLines.push(`    rm -rf /var/lib/apt/lists/*\n`);
        dockerfileLines.push(`\nUSER project\n`);
    }
    
    if (customInstall && customInstall.root_commands && customInstall.root_commands.length > 0) {
        dockerfileLines.push(`\nUSER root\n`);
        dockerfileLines.push(`RUN `);
        const commands = customInstall.root_commands.join(' && \\\n    ');
        dockerfileLines.push(`${commands}\n`);
        dockerfileLines.push(`\nUSER project\n`);
    }
    
    if (customInstall && customInstall.commands && customInstall.commands.length > 0) {
        dockerfileLines.push(`\n`);
        const commands = customInstall.commands.join(' && \\\n    ');
        dockerfileLines.push(`RUN ${commands}\n`);
    }
    
    if (packages.npm && packages.npm.length > 0) {
        const npmPackages = packages.npm.join(' ');
        dockerfileLines.push(`\nUSER root\n`);
        dockerfileLines.push(`RUN npm install -g ${npmPackages}\n`);
        dockerfileLines.push(`USER project\n`);
    }
    
    if (packages.cargo && packages.cargo.length > 0) {
        for (const pkg of packages.cargo) {
            const cargoCmd = pkg.includes('@')
                ? `cargo install ${pkg.split('@')[0]} --version ${pkg.split('@')[1]}`
                : `cargo install ${pkg}`;
            dockerfileLines.push(`\nRUN ${cargoCmd}\n`);
        }
    }

    // Cache warming (pre-fetch packages without installing)
    if (config.cache_warm) {
        dockerfileLines.push(generateCacheWarmCommands(config.cache_warm));
    }

    dockerfileLines.push(`\nLABEL description="${project} infrastructure layer"\n`);
    
    const filepath = path.join(outputDir, `${project}.Dockerfile`);
    fs.writeFileSync(filepath, dockerfileLines.join(''));
    
    console.log(`Generated infra: ${filepath}`);
}

function generateCombinedDockerfile(projectNames, outputDir) {
    const sortedProjectNames = [...projectNames].sort();
    
    if (JSON.stringify(projectNames) !== JSON.stringify(sortedProjectNames)) {
        console.log(`Sorting projects alphabetically: ${sortedProjectNames.join('_')}`);
    }
    
    const configs = [];
    let base = null;
    
    for (const name of sortedProjectNames) {
        if (!(name in PROJECT_CONFIGS)) {
            console.log(`Error: Unknown project '${name}'`);
            return false;
        }
        
        const config = PROJECT_CONFIGS[name];
        const projectBase = config.base;
        
        if (base === null) {
            base = projectBase;
        } else if (base !== projectBase) {
            console.log(`Error: Cannot combine projects with different base images`);
            console.log(`  ${sortedProjectNames[0]} uses '${base}'`);
            console.log(`  ${name} uses '${projectBase}'`);
            return false;
        }
        
        configs.push([name, config]);
    }
    
    const combinedName = sortedProjectNames.join('_');
    const dockerfileLines = [`FROM ${base}:latest\n`];
    
    const allNpmPackages = [];
    const allCargoPackages = [];
    const allEnvVars = {};
    const allAptPackages = [];
    const allRootCommands = [];
    const allCommands = [];
    const allCacheWarm = { npm: [], cargo: [], pip: [] };

    for (const [name, config] of configs) {
        const packages = config.packages;
        if (packages.npm && packages.npm.length > 0) {
            allNpmPackages.push(...packages.npm);
        }
        if (packages.cargo && packages.cargo.length > 0) {
            allCargoPackages.push(...packages.cargo);
        }

        if (config.custom_install) {
            if (config.custom_install.env) {
                Object.assign(allEnvVars, config.custom_install.env);
            }
            if (config.custom_install.apt_packages) {
                allAptPackages.push(...config.custom_install.apt_packages);
            }
            if (config.custom_install.root_commands) {
                allRootCommands.push(...config.custom_install.root_commands);
            }
            if (config.custom_install.commands) {
                allCommands.push(...config.custom_install.commands);
            }
        }

        // Collect cache_warm configs
        if (config.cache_warm) {
            if (config.cache_warm.npm) allCacheWarm.npm.push(...config.cache_warm.npm);
            if (config.cache_warm.cargo) allCacheWarm.cargo.push(...config.cache_warm.cargo);
            if (config.cache_warm.pip) allCacheWarm.pip.push(...config.cache_warm.pip);
        }
    }
    
    const uniqueNpmPackages = [...new Set(allNpmPackages)];
    const uniqueCargoPackages = [...new Set(allCargoPackages)];
    const uniqueAptPackages = [...new Set(allAptPackages)];
    
    if (Object.keys(allEnvVars).length > 0) {
        dockerfileLines.push('\n');
        const envVars = Object.entries(allEnvVars)
            .map(([key, value]) => `    ${key}=${value}`)
            .join(' \\\n');
        dockerfileLines.push(`ENV ${envVars}\n`);
    }
    
    if (uniqueAptPackages.length > 0) {
        const aptPackages = uniqueAptPackages.join(' ');
        dockerfileLines.push(`\nUSER root\n`);
        dockerfileLines.push(`RUN apt-get update && \\\n`);
        dockerfileLines.push(`    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \\\n`);
        dockerfileLines.push(`      ${aptPackages} && \\\n`);
        dockerfileLines.push(`    rm -rf /var/lib/apt/lists/*\n`);
        dockerfileLines.push(`\nUSER project\n`);
    }
    
    if (allRootCommands.length > 0) {
        dockerfileLines.push(`\nUSER root\n`);
        dockerfileLines.push(`RUN `);
        const commands = allRootCommands.join(' && \\\n    ');
        dockerfileLines.push(`${commands}\n`);
        dockerfileLines.push(`\nUSER project\n`);
    }
    
    if (allCommands.length > 0) {
        dockerfileLines.push(`\n`);
        const commands = allCommands.join(' && \\\n    ');
        dockerfileLines.push(`RUN ${commands}\n`);
    }
    
    if (uniqueNpmPackages.length > 0) {
        const npmPackages = uniqueNpmPackages.join(' ');
        dockerfileLines.push(`\nUSER root\n`);
        dockerfileLines.push(`RUN npm install -g ${npmPackages}\n`);
        dockerfileLines.push(`USER project\n`);
    }
    
    if (uniqueCargoPackages.length > 0) {
        for (const pkg of uniqueCargoPackages) {
            const cargoCmd = pkg.includes('@')
                ? `cargo install ${pkg.split('@')[0]} --version ${pkg.split('@')[1]}`
                : `cargo install ${pkg}`;
            dockerfileLines.push(`\nRUN ${cargoCmd}\n`);
        }
    }

    // Combined cache warming (deduplicated)
    const mergedCacheWarm = {
        npm: [...new Set(allCacheWarm.npm)],
        cargo: [...new Set(allCacheWarm.cargo)],
        pip: [...new Set(allCacheWarm.pip)]
    };
    const hasCacheWarm = mergedCacheWarm.npm.length > 0 || mergedCacheWarm.cargo.length > 0 || mergedCacheWarm.pip.length > 0;
    if (hasCacheWarm) {
        dockerfileLines.push(generateCacheWarmCommands(mergedCacheWarm));
    }

    const projectsDesc = sortedProjectNames.join(', ');
    dockerfileLines.push(`\nLABEL description="Combined: ${projectsDesc}"\n`);
    
    const filepath = path.join(outputDir, `${combinedName}.Dockerfile`);
    fs.writeFileSync(filepath, dockerfileLines.join(''));
    
    console.log(`Generated combined infra: ${filepath}`);
    return true;
}

function main() {
    if (process.argv.length < 3) {
        console.log('Usage: node generate_docker.js <project_name> [project_name2 ...]');
        console.log('       node generate_docker.js <project1_project2_...>');
        console.log('\nAvailable projects:');
        for (const project of Object.keys(PROJECT_CONFIGS).sort()) {
            console.log(`  - ${project}`);
        }
        console.log('\nExamples:');
        console.log('  node generate_docker.js coinbase');
        console.log('  node generate_docker.js coinbase_mongodb_postgresql');
        console.log('  node generate_docker.js ethereum solana');
        console.log('\nNote: Combined projects are automatically sorted alphabetically.');
        console.log('  ethereum_polygon_zksync and zksync_polygon_ethereum generate the same file.');
        process.exit(1);
    }
    
    const rootDir = __dirname;
    const intermediateDir = path.join(rootDir, 'intermediate');
    const infraDir = path.join(rootDir, 'infra');
    
    if (!fs.existsSync(intermediateDir)) {
        fs.mkdirSync(intermediateDir, { recursive: true });
    }
    if (!fs.existsSync(infraDir)) {
        fs.mkdirSync(infraDir, { recursive: true });
    }
    
    const projects = process.argv.slice(2);
    
    for (const projectSpec of projects) {
        const normalizedSpec = projectSpec.toLowerCase();
        
        if (normalizedSpec.includes('_')) {
            const projectNames = normalizedSpec.split('_').map(p => p.trim());
            
            if (projectNames.length === 0) {
                console.log(`Error: Invalid project specification '${projectSpec}'`);
                continue;
            }
            
            if (projectNames.length === 1) {
                const project = projectNames[0];
                if (!(project in PROJECT_CONFIGS)) {
                    console.log(`Error: Unknown project '${project}'`);
                    continue;
                }
                
                const config = PROJECT_CONFIGS[project];
                const base = config.base;
                
                if (base !== 'base-system') {
                    const intermediateFile = path.join(intermediateDir, `${base}.Dockerfile`);
                    if (!fs.existsSync(intermediateFile) || fs.statSync(intermediateFile).size === 0) {
                        generateIntermediateDockerfile(base, intermediateDir);
                    }
                }
                
                generateInfraDockerfile(project, config, infraDir);
            } else {
                const firstProject = projectNames[0];
                if (firstProject in PROJECT_CONFIGS) {
                    const base = PROJECT_CONFIGS[firstProject].base;
                    if (base !== 'base-system') {
                        const intermediateFile = path.join(intermediateDir, `${base}.Dockerfile`);
                        if (!fs.existsSync(intermediateFile) || fs.statSync(intermediateFile).size === 0) {
                            generateIntermediateDockerfile(base, intermediateDir);
                        }
                    }
                }
                
                generateCombinedDockerfile(projectNames, infraDir);
            }
        } else {
            const project = normalizedSpec;
            
            if (!(project in PROJECT_CONFIGS)) {
                console.log(`Error: Unknown project '${project}'`);
                console.log('\nAvailable projects:');
                for (const p of Object.keys(PROJECT_CONFIGS).sort()) {
                    console.log(`  - ${p}`);
                }
                continue;
            }
            
            const config = PROJECT_CONFIGS[project];
            const base = config.base;
            
            if (base !== 'base-system') {
                const intermediateFile = path.join(intermediateDir, `${base}.Dockerfile`);
                if (!fs.existsSync(intermediateFile) || fs.statSync(intermediateFile).size === 0) {
                    generateIntermediateDockerfile(base, intermediateDir);
                }
            }
            
            generateInfraDockerfile(project, config, infraDir);
        }
    }
}

if (require.main === module) {
    main();
}

