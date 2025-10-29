#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const TEST_DIR = path.join(__dirname, "test_output");
const INFRA_DIR = path.join(TEST_DIR, "infra");
const INTERMEDIATE_DIR = path.join(TEST_DIR, "intermediate");

function setup() {
    if (fs.existsSync(TEST_DIR)) {
        // Use rm -rf for Node.js < 14.14 compatibility
        execSync(`rm -rf ${TEST_DIR}`, { stdio: "ignore" });
    }
    fs.mkdirSync(TEST_DIR, { recursive: true });
    fs.mkdirSync(INFRA_DIR, { recursive: true });
    fs.mkdirSync(INTERMEDIATE_DIR, { recursive: true });
}

function cleanup() {
    if (fs.existsSync(TEST_DIR)) {
        // Use rm -rf for Node.js < 14.14 compatibility
        execSync(`rm -rf ${TEST_DIR}`, { stdio: "ignore" });
    }
}

function generateDockerfile(projectSpec) {
    const scriptPath = path.join(__dirname, "generate_docker.js");

    const tempScriptPath = path.join(TEST_DIR, "generate_docker_temp.js");
    let scriptContent = fs.readFileSync(scriptPath, "utf8");

    scriptContent = scriptContent.replace(
        "const configPath = path.join(__dirname, 'config.json');",
        `const configPath = '${path.join(__dirname, "config.json")}';`,
    );
    scriptContent = scriptContent.replace(
        /const intermediateDir = path\.join\(rootDir, 'intermediate'\);/,
        `const intermediateDir = '${INTERMEDIATE_DIR}';`,
    );
    scriptContent = scriptContent.replace(
        /const infraDir = path\.join\(rootDir, 'infra'\);/,
        `const infraDir = '${INFRA_DIR}';`,
    );

    fs.writeFileSync(tempScriptPath, scriptContent);

    try {
        execSync(`node ${tempScriptPath} ${projectSpec}`, {
            cwd: __dirname,
            stdio: "pipe",
        });
    } catch (error) {
        console.error(`Error executing: ${error.message}`);
        throw error;
    }
}

function testDeduplication() {
    console.log("Testing deduplication...");

    setup();

    generateDockerfile("ethereum_polygon_zksync");
    const file1 = path.join(INFRA_DIR, "ethereum_polygon_zksync.Dockerfile");
    const content1 = fs.readFileSync(file1, "utf8");

    execSync(`rm -rf ${INFRA_DIR}`, { stdio: "ignore" });
    fs.mkdirSync(INFRA_DIR, { recursive: true });

    generateDockerfile("zksync_polygon_ethereum");
    const file2 = path.join(INFRA_DIR, "ethereum_polygon_zksync.Dockerfile");

    if (!fs.existsSync(file2)) {
        console.error(
            "❌ FAILED: Expected ethereum_polygon_zksync.Dockerfile to be generated",
        );
        cleanup();
        process.exit(1);
    }

    const content2 = fs.readFileSync(file2, "utf8");

    if (content1 !== content2) {
        console.error("❌ FAILED: File contents do not match");
        console.error("Content 1:", content1);
        console.error("Content 2:", content2);
        cleanup();
        process.exit(1);
    }

    console.log("✅ PASSED: Deduplication works correctly");
    console.log(`   Generated file: ethereum_polygon_zksync.Dockerfile`);
    console.log(`   Content:\n${content1}`);

    cleanup();
}

function testDifferentOrders() {
    console.log("\nTesting different order combinations...");

    const testCases = [
        ["coinbase_mongodb", "mongodb_coinbase"],
        ["ethereum_polygon", "polygon_ethereum"],
        ["solana_sui_aptos", "aptos_solana_sui", "sui_aptos_solana"],
    ];

    for (const testCase of testCases) {
        setup();

        const contents = [];
        const expectedFilename =
            testCase[0].split("_").sort().join("_") + ".Dockerfile";

        for (const spec of testCase) {
            execSync(`rm -rf ${INFRA_DIR}`, { stdio: "ignore" });
            fs.mkdirSync(INFRA_DIR, { recursive: true });

            generateDockerfile(spec);

            const files = fs.readdirSync(INFRA_DIR);
            if (files.length !== 1) {
                console.error(
                    `❌ FAILED: Expected 1 file, got ${files.length}`,
                );
                cleanup();
                process.exit(1);
            }

            if (files[0] !== expectedFilename) {
                console.error(
                    `❌ FAILED: Expected ${expectedFilename}, got ${files[0]}`,
                );
                cleanup();
                process.exit(1);
            }

            const content = fs.readFileSync(
                path.join(INFRA_DIR, files[0]),
                "utf8",
            );
            contents.push(content);
        }

        const allSame = contents.every((c) => c === contents[0]);
        if (!allSame) {
            console.error(
                `❌ FAILED: Contents differ for ${testCase.join(", ")}`,
            );
            cleanup();
            process.exit(1);
        }

        console.log(
            `✅ PASSED: ${testCase.join(" = ")} -> ${expectedFilename}`,
        );

        cleanup();
    }
}

function testAlphabeticalSorting() {
    console.log("\nTesting alphabetical sorting in labels...");

    setup();

    generateDockerfile("zksync_ethereum_polygon");
    const file = path.join(INFRA_DIR, "ethereum_polygon_zksync.Dockerfile");
    const content = fs.readFileSync(file, "utf8");

    if (
        !content.includes(
            'LABEL description="Combined: ethereum, polygon, zksync"',
        )
    ) {
        console.error(
            "❌ FAILED: Label should contain alphabetically sorted project names",
        );
        console.error("Content:", content);
        cleanup();
        process.exit(1);
    }

    console.log(
        "✅ PASSED: Labels contain alphabetically sorted project names",
    );

    cleanup();
}

console.log("Running deduplication tests...\n");
testDeduplication();
testDifferentOrders();
testAlphabeticalSorting();
console.log("\n✅ All tests passed!");
