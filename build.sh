#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

function build_base() {
    echo "Building base-system..."
    docker build -t base-system:latest -f base/base-system.Dockerfile .
}

function build_intermediate() {
    local lang=$1
    echo "Building ${lang} intermediate layer..."
    docker build -t ${lang}:latest -f intermediate/${lang}.Dockerfile .
}

function build_infra() {
    local project=$1
    echo "Building ${project} infra layer..."
    docker build -t ${project}:latest -f infra/${project}.Dockerfile .
}

case "$1" in
    base)
        build_base
        ;;
    intermediate)
        if [ -z "$2" ]; then
            for dockerfile in intermediate/*.Dockerfile; do
                lang=$(basename "$dockerfile" .Dockerfile)
                if [ -s "$dockerfile" ]; then
                    build_intermediate "$lang"
                fi
            done
        else
            build_intermediate "$2"
        fi
        ;;
    infra)
        if [ -z "$2" ]; then
            for dockerfile in infra/*.Dockerfile; do
                if [ -f "$dockerfile" ]; then
                    project=$(basename "$dockerfile" .Dockerfile)
                    build_infra "$project"
                fi
            done
        else
            build_infra "$2"
        fi
        ;;
    all)
        build_base
        for dockerfile in intermediate/*.Dockerfile; do
            lang=$(basename "$dockerfile" .Dockerfile)
            if [ -s "$dockerfile" ]; then
                build_intermediate "$lang"
            fi
        done
        for dockerfile in infra/*.Dockerfile; do
            if [ -f "$dockerfile" ]; then
                project=$(basename "$dockerfile" .Dockerfile)
                build_infra "$project"
            fi
        done
        ;;
    *)
        echo "Usage: $0 {base|intermediate [lang]|infra [project]|all}"
        echo ""
        echo "Examples:"
        echo "  $0 base                    # Build base image"
        echo "  $0 intermediate nodejs     # Build specific intermediate"
        echo "  $0 intermediate            # Build all intermediate"
        echo "  $0 infra coinbase          # Build specific project"
        echo "  $0 infra                   # Build all projects"
        echo "  $0 all                     # Build everything"
        exit 1
        ;;
esac

