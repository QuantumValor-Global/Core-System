#!/bin/bash

# ════════════════════════════════════════════════════════════════════════════
# MÍA Defense System - Build & Compilation Script
# Architect: INTO el 3
# Version: 1.0.0
# ════════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
OUTPUT_DIR="${SCRIPT_DIR}/bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ════════════════════════════════════════════════════════════════════════════
# FUNCTIONS
# ════════════════════════════════════════════════════════════════════════════

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# ════════════════════════════════════════════════════════════════════════════
# CHECK PREREQUISITES
# ════════════════════════════════════════════════════════════════════════════

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check C++ compiler
    if command -v g++ &> /dev/null; then
        CPP_VERSION=$(g++ --version | head -1)
        print_success "C++ Compiler: $CPP_VERSION"
    else
        print_error "C++ compiler (g++) not found"
        print_info "Install with: apt-get install build-essential g++ cmake"
        exit 1
    fi
    
    # Check CMake
    if command -v cmake &> /dev/null; then
        CMAKE_VERSION=$(cmake --version | head -1)
        print_success "CMake: $CMAKE_VERSION"
    else
        print_warning "CMake not found (optional)"
    fi
    
    # Check Python
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version)
        print_success "Python: $PYTHON_VERSION"
    else
        print_error "Python 3 not found"
        exit 1
    fi
}

# ════════════════════════════════════════════════════════════════════════════
# BUILD C++ CORE
# ════════════════════════════════════════════════════════════════════════════

build_cpp() {
    print_header "Building C++ Core Engine"
    
    # Create directories
    mkdir -p "${BUILD_DIR}" "${OUTPUT_DIR}"
    
    print_info "Compiling defense.cpp..."
    
    # Compile with C++17 standard
    g++ -std=c++17 \
        -Wall -Wextra -Werror \
        -O2 \
        -pthread \
        "${SCRIPT_DIR}/defense.cpp" \
        -o "${OUTPUT_DIR}/mia_defense" \
        2>&1 | tee "${BUILD_DIR}/compile.log"
    
    if [ $? -eq 0 ]; then
        print_success "C++ Core compiled successfully"
        print_info "Output: ${OUTPUT_DIR}/mia_defense"
    else
        print_error "C++ compilation failed"
        exit 1
    fi
}

# ════════════════════════════════════════════════════════════════════════════
# DEMO SCENARIOS
# ════════════════════════════════════════════════════════════════════════════

run_demo() {
    print_header "Running MÍA Defense Demo"
    
    print_info "Running C++ core demonstration..."
    echo ""
    
    # Run C++ executable
    "${OUTPUT_DIR}/mia_defense"
    
    print_info "\n"
    print_info "Running Python demonstration..."
    echo ""
    
    # Run Python example
    python3 "${SCRIPT_DIR}/mia_guardian.py"
    
    print_success "Demo completed"
}

# ════════════════════════════════════════════════════════════════════════════
# VERIFY BUILD
# ════════════════════════════════════════════════════════════════════════════

verify_build() {
    print_header "Verifying Build"
    
    # Check if executable exists
    if [ -f "${OUTPUT_DIR}/mia_defense" ]; then
        print_success "Executable found: ${OUTPUT_DIR}/mia_defense"
        
        # Get file info
        SIZE=$(du -h "${OUTPUT_DIR}/mia_defense" | cut -f1)
        print_info "Size: $SIZE"
        
        # Check if executable
        if [ -x "${OUTPUT_DIR}/mia_defense" ]; then
            print_success "Executable permissions correct"
        else
            print_warning "Fixing executable permissions..."
            chmod +x "${OUTPUT_DIR}/mia_defense"
        fi
    else
        print_error "Executable not found"
        exit 1
    fi
    
    # Check source files
    print_info "Verifying source files..."
    
    if [ -f "${SCRIPT_DIR}/defense.cpp" ]; then
        print_success "defense.cpp found ($(wc -l < ${SCRIPT_DIR}/defense.cpp) lines)"
    else
        print_error "defense.cpp not found"
        exit 1
    fi
    
    if [ -f "${SCRIPT_DIR}/mia_guardian.py" ]; then
        print_success "mia_guardian.py found ($(wc -l < ${SCRIPT_DIR}/mia_guardian.py) lines)"
    else
        print_error "mia_guardian.py not found"
        exit 1
    fi
    
    if [ -f "${SCRIPT_DIR}/MIA-DEFENSE.md" ]; then
        print_success "MIA-DEFENSE.md found"
    else
        print_error "MIA-DEFENSE.md not found"
        exit 1
    fi
}

# ════════════════════════════════════════════════════════════════════════════
# GENERATE REPORT
# ════════════════════════════════════════════════════════════════════════════

generate_report() {
    print_header "Build Report"
    
    echo "MÍA Defense System - Build Summary"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "Build Date: $(date)"
    echo "Build Location: ${BUILD_DIR}"
    echo "Output Location: ${OUTPUT_DIR}"
    echo ""
    echo "Components:"
    echo "  C++ Core (defense.cpp): $(wc -l < ${SCRIPT_DIR}/defense.cpp) lines"
    echo "  Python Guardian (mia_guardian.py): $(wc -l < ${SCRIPT_DIR}/mia_guardian.py) lines"
    echo "  Documentation (MIA-DEFENSE.md): $(wc -l < ${SCRIPT_DIR}/MIA-DEFENSE.md) lines"
    echo ""
    echo "Executable:"
    echo "  Location: ${OUTPUT_DIR}/mia_defense"
    echo "  Size: $(du -h ${OUTPUT_DIR}/mia_defense | cut -f1)"
    echo "  Status: Ready"
    echo ""
    echo "Files Generated:"
    ls -lh "${OUTPUT_DIR}/"
    echo ""
    echo "Compilation Log: ${BUILD_DIR}/compile.log"
    echo ""
    echo "═══════════════════════════════════════════════════════"
}

# ════════════════════════════════════════════════════════════════════════════
# CLEAN BUILD
# ════════════════════════════════════════════════════════════════════════════

clean_build() {
    print_header "Cleaning Build Artifacts"
    
    if [ -d "${BUILD_DIR}" ]; then
        print_info "Removing ${BUILD_DIR}..."
        rm -rf "${BUILD_DIR}"
    fi
    
    if [ -d "${OUTPUT_DIR}" ]; then
        print_info "Removing ${OUTPUT_DIR}..."
        rm -rf "${OUTPUT_DIR}"
    fi
    
    print_success "Clean complete"
}

# ════════════════════════════════════════════════════════════════════════════
# INSTALL DEPENDENCIES
# ════════════════════════════════════════════════════════════════════════════

install_dependencies() {
    print_header "Installing Dependencies"
    
    # Check if running on Ubuntu/Debian
    if command -v apt-get &> /dev/null; then
        print_info "Detected apt package manager"
        print_info "Installing build-essential..."
        
        if [ "$EUID" -eq 0 ]; then
            apt-get update
            apt-get install -y build-essential g++ cmake
            print_success "Dependencies installed"
        else
            print_warning "Root privileges required"
            print_info "Run: sudo bash $0 --deps"
        fi
    else
        print_warning "Unable to detect package manager"
        print_info "Please install: build-essential g++ cmake"
    fi
}

# ════════════════════════════════════════════════════════════════════════════
# MAIN MENU
# ════════════════════════════════════════════════════════════════════════════

show_menu() {
    print_header "MÍA Defense Build Menu"
    
    echo "Options:"
    echo "  --help           Show this help message"
    echo "  --check          Check prerequisites only"
    echo "  --cpp            Build C++ core only"
    echo "  --verify         Verify build artifacts"
    echo "  --demo           Run full demonstration"
    echo "  --report         Generate build report"
    echo "  --clean          Clean all build artifacts"
    echo "  --deps           Install build dependencies"
    echo "  --all            Full build + demo (default)"
    echo ""
}

# ════════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ════════════════════════════════════════════════════════════════════════════

main() {
    if [ $# -eq 0 ]; then
        # Default: full build
        check_prerequisites
        build_cpp
        verify_build
        generate_report
        run_demo
    else
        case "$1" in
            --help)
                show_menu
                ;;
            --check)
                check_prerequisites
                ;;
            --cpp)
                check_prerequisites
                build_cpp
                ;;
            --verify)
                verify_build
                ;;
            --demo)
                run_demo
                ;;
            --report)
                generate_report
                ;;
            --clean)
                clean_build
                ;;
            --deps)
                install_dependencies
                ;;
            --all)
                check_prerequisites
                build_cpp
                verify_build
                generate_report
                run_demo
                ;;
            *)
                print_error "Unknown option: $1"
                show_menu
                exit 1
                ;;
        esac
    fi
}

# Execute main function
main "$@"
