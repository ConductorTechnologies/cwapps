#!/bin/bash

# Default installation location
DEFAULT_LOCATION="$HOME/Library/Preferences/Autodesk/maya"

# Exit codes
SUCCESS=0
INVALID_USAGE=1
INVALID_LOCATION=2
INSTALLATION_FAILED=3
INVALID_TARGET=4

PRODUCT="cwmaya"
VENDOR="coreweave"
PYPI_URL="https://pypi.org/pypi"
PACKAGE_JSON_URL="${PYPI_URL}/pypi/${PRODUCT}/json"

START_YEAR=2022
END_YEAR=2026

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Required parameters:"
    echo "  -t, --target STRING         Specify target Maya version to install for"
    echo ""
    echo "Optional parameters:"
    echo "  -v, --version VERSION       Specify version to install (cannot be used with --dev)"
    echo "  -d, --dev                   Install from development requirements file (cannot be used with --version)"
    echo "  -l, --location DIR          Installation location (default: $DEFAULT_LOCATION)"
    exit $INVALID_USAGE
}

list_targets() {
    for year in $(seq $START_YEAR $END_YEAR); do
        local mayapy_path="/Applications/Autodesk/maya${year}/Maya.app/Contents/bin/mayapy"
        if [ -x "$mayapy_path" ]; then
            echo "$year"
        fi
    done
}

find_python_for_maya() {
    local target="$1"

    # First try the specified target mayapy
    local mayapy_path="/Applications/Autodesk/maya${target}/Maya.app/Contents/bin/mayapy"
    if [ -x "$mayapy_path" ]; then
        if "$mayapy_path" -m pip list &>/dev/null; then
            echo "$mayapy_path"
            return 0
        fi
    fi

    # Try other mayapy installations
    for mayapy in /Applications/Autodesk/maya*/Maya.app/Contents/bin/mayapy; do
        if [ -x "$mayapy" ]; then
            if "$mayapy" -m pip list &>/dev/null; then
                echo "$mayapy"
                return 0
            fi
        fi
    done

    # Try system python3
    if command -v python3 >/dev/null; then
        if python3 -m pip list &>/dev/null; then
            echo "python3"
            return 0
        fi
    fi

    # No suitable python found
    return 1
}

# Function to install package for a specific Maya Python
install_for_mayapy() {
    local mayapy="$1"
    local target_dir="$2"
    local version="$3"
    local package_spec="$4"
    local requirements_file="$5"

    if [ -n "$requirements_file" ]; then
        echo "Installing from requirements file: $requirements_file with: $mayapy"
        "$mayapy" -m pip install \
            --upgrade \
            --force-reinstall \
            --no-cache-dir \
            --ignore-installed \
            --no-warn-script-location \
            --target "$target_dir" \
            -r "$requirements_file"
    else
        if [ -n "$version" ]; then
            echo "Installing $PRODUCT $version with: $mayapy"
        else
            echo "Installing $PRODUCT latest version with: $mayapy"
        fi

        "$mayapy" -m pip install \
            --upgrade \
            --force-reinstall \
            --no-cache-dir \
            --ignore-installed \
            --no-warn-script-location \
            --target "$target_dir" \
            "${package_spec}"
    fi

    return $?
}

# Function to perform installation
do_install() {
    local version="$1"
    local install_location="$2"
    local target="$3"
    local dev_mode="$4"
    local package=$PRODUCT
    local package_spec="${package}"
    local requirements_file=""

    # Check if target is provided
    if [ -z "$target" ]; then
        echo "Error: Target Maya version must be specified"
        exit $INVALID_USAGE
    fi

    # Determine requirements file if dev mode is enabled
    if [ "$dev_mode" = true ]; then
        # Get directory of current script
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        requirements_file="${script_dir}/../requirements.txt"
    fi

    # Validate installation location
    if [ -n "$install_location" ]; then
        if [ ! -d "$install_location" ]; then
            echo "Error: Installation location does not exist: $install_location"
            exit $INVALID_LOCATION
        fi
    else
        install_location="$DEFAULT_LOCATION"
    fi

    # Find Maya Python for target
    local mayapy
    mayapy=$(find_python_for_maya "$target")
    if [ $? -ne 0 ]; then
        echo "Error: No Maya $target installation found"
        exit $INVALID_TARGET
    fi

    local target_dir="${install_location}/${target}/${VENDOR}"
    local module_dir="${install_location}/${target}/modules"
    local module_file="${module_dir}/${PRODUCT}.mod"

    mkdir -p "$target_dir"
    mkdir -p "$module_dir"

    # Perform installation
    if ! install_for_mayapy "$mayapy" "$target_dir" "$version" "$package_spec" "$requirements_file"; then
        echo "Installation failed for Maya $target"
        exit $INSTALLATION_FAILED
    fi

    # Create module file
    echo "+ ${PRODUCT} ${version:-1.0} ${target_dir}/${PRODUCT}" >"$module_file"
    echo "CWMAYA_CIODIR=${target_dir}" >>"$module_file"
    # echo "PYTHONPATH=${target_dir}" >> "$module_file"

    echo "----------------------------------------"
    echo "Installed ${PRODUCT} ${version:-latest} to ${target_dir}/${PRODUCT}"
    echo "Wrote module file: $module_file"
    echo "- - - - - - - - - - - - - - - - - - - -"
    cat "$module_file"
    echo "----------------------------------------"
    exit $SUCCESS
}

# Parse command line arguments
VERSION=""
LOCATION=""
TARGET=""
DEV_MODE=false
while [[ "$#" -gt 0 ]]; do
    case "$1" in
    "-v" | "--version")
        shift
        if [ "$DEV_MODE" = true ]; then
            echo "Error: --version cannot be used with --dev"
            usage
        fi
        VERSION="$1"
        ;;
    "-l" | "--location")
        shift
        LOCATION="$1"
        ;;
    "-t" | "--target")
        shift
        TARGET="$1"
        ;;
    "-d" | "--dev")
        if [ -n "$VERSION" ]; then
            echo "Error: --dev cannot be used with --version"
            usage
        fi
        DEV_MODE=true
        ;;
    *)
        echo "Unknown option: $1"
        usage
        ;;
    esac
    shift
done

# Check if target is provided
if [ -z "$TARGET" ]; then
    echo "Error: --target is required"
    usage
fi

# Execute installation
do_install "$VERSION" "$LOCATION" "$TARGET" "$DEV_MODE"

# If we somehow get here, exit successfully
exit $SUCCESS
