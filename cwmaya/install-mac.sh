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
    echo "Single-option commands (cannot be combined):"
    echo "  -gv, --get-versions         Get a list of available versions in reverse chronological order."
    echo "  -gt, --get-targets          Get a list of available Maya target versions. Output is a a list of year"
    echo "  -gl, --get-default-location Get the default installation location"
    echo "  -gs, --get-summary          Get the contents of summary.md"
    echo "  -gi, --get-instructions     Get the contents of instructions.md"
    echo "  -gn, --get-name             Get the name of the application"
    echo "  -gd, --get-detail           Get the contents of detail.md"
    echo "  -gp, --get-picture-url      Get the URL of the logo"
    echo ""
    echo "Installation command and its optional parameters:"
    echo "  -i, --install               Run installation"
    echo "  -v, --version VERSION       Specify version to install (cannot be used with --dev)"
    echo "  -d, --dev                   Install from development requirements file (cannot be used with --version)"
    echo "  -l, --location DIR          Installation location (default: $DEFAULT_LOCATION)"
    echo "  -t, --target STRING         Specify target to install for (optional and can be used multiple times)"
    exit $INVALID_USAGE
}

# Function to list versions
list_versions() {
    # Get latest mayapy path. The latest is less likely to have certificate issues.
    mayapy_path=$(find_maya_pythons | tail -n 1)

    if [ -z "$mayapy_path" ]; then
        echo "No Maya Python installation found"
        exit $INSTALLATION_FAILED
    fi

    # Get directory of current script
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # Run packageVersions.py with mayapy and output json string
    while IFS= read -r line; do
        echo "$line"
    done < <("$mayapy_path" "$script_dir/packageVersions.py")

    exit $SUCCESS
}


list_targets() {
    # Find Maya Python installations first
    maya_pythons=()
    while IFS= read -r line; do
        maya_pythons+=("$line")
    done < <(find_maya_pythons)

    # Extract and print Maya versions
    for mayapy in "${maya_pythons[@]}"; do
        # Extract the year from the path using regex
        if [[ $mayapy =~ maya([0-9]{4}) ]]; then
            echo "${BASH_REMATCH[1]}"
        fi
    done
}

# Function to find and test Maya Python installations
find_maya_pythons() {
    local start_year=$START_YEAR
    local end_year=$END_YEAR
    local found_any=false

    for year in $(seq $start_year $end_year); do
        local mayapy_path="/Applications/Autodesk/maya${year}/Maya.app/Contents/bin/mayapy"

        if [ -x "$mayapy_path" ]; then
            echo "$mayapy_path"
            found_any=true
        fi
    done
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
    local had_error=false
    local requirements_file=""

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

    # Find Maya Python installations
    maya_pythons=()
    while IFS= read -r line; do
        maya_pythons+=("$line")
    done < <(find_maya_pythons)

    # Install for each Maya Python version (or specific target)
    for mayapy in "${maya_pythons[@]}"; do
        # Extract Maya version from mayapy path
        if [[ $mayapy =~ maya([0-9]{4}) ]]; then
            local maya_version="${BASH_REMATCH[1]}"
            local target_dir="${install_location}/${maya_version}/${VENDOR}"
            local module_dir="${install_location}/${maya_version}/modules"
            local module_file="${module_dir}/${PRODUCT}.mod"
            
            mkdir -p "$target_dir"
            mkdir -p "$module_dir"

            # Skip if target is specified and doesn't match
            if [ -n "$target" ] && ! [[ $mayapy =~ maya${target} ]]; then
                continue
            fi

            # Perform installation
            if ! install_for_mayapy "$mayapy" "$target_dir" "$version" "$package_spec" "$requirements_file"; then
                echo "Installation failed for $mayapy"
                if [ -n "$target" ]; then
                    exit $INSTALLATION_FAILED
                fi
                had_error=true
                continue
            fi

            # Create module file
            echo "+ ${PRODUCT} ${version:-1.0} ${target_dir}/${PRODUCT}" > "$module_file"
            echo "CWMAYA_CIODIR=${target_dir}" >> "$module_file"
            # echo "PYTHONPATH=${target_dir}" >> "$module_file"
            
            echo "----------------------------------------"
            echo "Installed ${PRODUCT} ${version:-latest} to ${target_dir}/${PRODUCT}"
            echo "Wrote module file: $module_file"
            echo "- - - - - - - - - - - - - - - - - - - -"
            cat "$module_file"
            echo "----------------------------------------"
            # Exit after successful installation if target was specified
            if [ -n "$target" ]; then
                exit $SUCCESS
            fi
        fi
    done

    # If target was specified but no matching Maya version was found
    if [ -n "$target" ]; then
        echo "Error: No Maya $target installation found"
        exit $INVALID_TARGET
    fi

    if [ "$had_error" = true ]; then
        echo "One or more installations failed"
        exit $INSTALLATION_FAILED
    else
        echo "All installations completed successfully!"
        exit $SUCCESS
    fi
}

# Function to display the contents of a markdown file
get_markdown() {
    local file_path="$1"
    if [ -f "$file_path" ]; then
        cat "$file_path"
    else
        echo "Error: $(basename "$file_path") file not found."
        exit $INVALID_USAGE
    fi
    exit $SUCCESS
}

# Function to display the name
get_name() {
    echo "Conductor for Maya"
    exit $SUCCESS
}

# Function to display the logo URL
get_picture() {
    echo "https://downloads.conductortech.com/images/maya.png"
    exit $SUCCESS
}

# Parse command line arguments
INSTALL=false
VERSION=""
LOCATION=""
TARGET=""
DEV_MODE=false
OPTION_COUNT=0

while [[ "$#" -gt 0 ]]; do
    case $1 in
    -gv | --get-versions)
        ((OPTION_COUNT++))
        if [ $OPTION_COUNT -gt 1 ]; then
            echo "Error: --get-versions cannot be combined with other options"
            usage
        fi
        list_versions
        ;;
    -gt | --get-targets)
        ((OPTION_COUNT++))
        if [ $OPTION_COUNT -gt 1 ]; then
            echo "Error: --get-targets cannot be combined with other options"
            usage
        fi
        list_targets
        exit $SUCCESS
        ;;
   -gl |  --get-default-location)
        ((OPTION_COUNT++))
        if [ $OPTION_COUNT -gt 1 ]; then
            echo "Error: --get-default-location cannot be combined with other options"
            usage
        fi
        echo "$DEFAULT_LOCATION"
        exit $SUCCESS
        ;;
    -i | --install)
        ((OPTION_COUNT++))
        INSTALL=true
        ;;
    -v | --version)
        shift
        if [ "$DEV_MODE" = true ]; then
            echo "Error: --version cannot be used with --dev"
            usage
        fi
        VERSION="$1"
        if [ "$INSTALL" != true ]; then
            echo "Error: --version can only be used with --install"
            usage
        fi
        ;;
    -l | --location)
        shift
        LOCATION="$1"
        if [ "$INSTALL" != true ]; then
            echo "Error: --location can only be used with --install"
            usage
        fi
        ;;
    -t | --target)
        shift
        TARGET="$1"
        if [ "$INSTALL" != true ]; then
            echo "Error: --target can only be used with --install"
            usage
        fi
        ;;
    -d | --dev)
        ((OPTION_COUNT++))
        if [ -n "$VERSION" ]; then
            echo "Error: --dev cannot be used with --version"
            usage
        fi
        DEV_MODE=true
        if [ "$INSTALL" != true ]; then
            echo "Error: --dev can only be used with --install"
            usage
        fi
        ;;
    -gs|--get-summary)
        ((OPTION_COUNT++))
        if [ $OPTION_COUNT -gt 1 ]; then
            echo "Error: -gs/--get-summary cannot be combined with other options"
            usage
        fi
        get_markdown "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/summary.md"
        ;;
    -gi|--get-instructions)
        ((OPTION_COUNT++))
        if [ $OPTION_COUNT -gt 1 ]; then
            echo "Error: -gi/--get-instructions cannot be combined with other options"
            usage
        fi
        get_markdown "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/instructions.md"
        ;;
    -gn|--get-name)
        ((OPTION_COUNT++))
        if [ $OPTION_COUNT -gt 1 ]; then
            echo "Error: -gn/--get-name cannot be combined with other options"
            usage
        fi
        get_name
        ;;
    -gd|--get-detail)
        ((OPTION_COUNT++))
        if [ $OPTION_COUNT -gt 1 ]; then
            echo "Error: -gd/--get-detail cannot be combined with other options"
            usage
        fi
        get_markdown "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/detail.md"
        ;;
    -gp|--get-picture-url)
        ((OPTION_COUNT++))
        if [ $OPTION_COUNT -gt 1 ]; then
            echo "Error: -gp/--get-picture-url cannot be combined with other options"
            usage
        fi
        get_picture
        ;;
    *)
        echo "Unknown option: $1"
        usage
        ;;
    esac
    shift
done

# Validate command line options
if [ $OPTION_COUNT -eq 0 ]; then
    echo "Error: No action specified"
    usage
fi

# Execute installation if --install was specified
if [ "$INSTALL" = true ]; then
    do_install "$VERSION" "$LOCATION" "$TARGET" "$DEV_MODE"
fi

# If we somehow get here, exit successfully
exit $SUCCESS