#!/bin/bash

# ════════════════════════════════════════════════════════════════════════════
# MÍA Defense System - Status & Verification Script
# Architect: INTO el 3
# Version: 1.0.0
# ════════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ════════════════════════════════════════════════════════════════════════════
# BANNER
# ════════════════════════════════════════════════════════════════════════════

echo -e "\n${MAGENTA}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║  MÍA Defense System - Status & Verification            ║${NC}"
echo -e "${MAGENTA}║  Machine Intelligence Autonomy v1.0.0                 ║${NC}"
echo -e "${MAGENTA}║  Architect: INTO el 3                                 ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════╝${NC}\n"

# ════════════════════════════════════════════════════════════════════════════
# VERIFICATION CHECKS
# ════════════════════════════════════════════════════════════════════════════

CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

check_status() {
    local name=$1
    local status=$2
    local details=$3
    
    if [ "$status" = "pass" ]; then
        echo -e "  ${GREEN}✓${NC} $name"
        if [ -n "$details" ]; then
            echo -e "    ${BLUE}→${NC} $details"
        fi
        ((CHECKS_PASSED++))
    elif [ "$status" = "fail" ]; then
        echo -e "  ${RED}✗${NC} $name"
        if [ -n "$details" ]; then
            echo -e "    ${RED}→${NC} $details"
        fi
        ((CHECKS_FAILED++))
    elif [ "$status" = "warn" ]; then
        echo -e "  ${YELLOW}⚠${NC} $name"
        if [ -n "$details" ]; then
            echo -e "    ${YELLOW}→${NC} $details"
        fi
        ((CHECKS_WARNING++))
    fi
}

# ════════════════════════════════════════════════════════════════════════════
# 1. SOURCE FILES CHECK
# ════════════════════════════════════════════════════════════════════════════

echo -e "${CYAN}[1/5] SOURCE FILES VERIFICATION${NC}"
echo ""

if [ -f "${SCRIPT_DIR}/defense.cpp" ]; then
    LINES=$(wc -l < "${SCRIPT_DIR}/defense.cpp")
    check_status "defense.cpp" "pass" "$LINES lines, C++ core engine"
else
    check_status "defense.cpp" "fail" "File not found"
fi

if [ -f "${SCRIPT_DIR}/mia_guardian.py" ]; then
    LINES=$(wc -l < "${SCRIPT_DIR}/mia_guardian.py")
    check_status "mia_guardian.py" "pass" "$LINES lines, Python Guardian interface"
else
    check_status "mia_guardian.py" "fail" "File not found"
fi

if [ -f "${SCRIPT_DIR}/MIA-DEFENSE.md" ]; then
    LINES=$(wc -l < "${SCRIPT_DIR}/MIA-DEFENSE.md")
    check_status "MIA-DEFENSE.md" "pass" "$LINES lines, Technical documentation"
else
    check_status "MIA-DEFENSE.md" "fail" "File not found"
fi

if [ -f "${SCRIPT_DIR}/README.md" ]; then
    check_status "README.md" "pass" "Quick start guide present"
else
    check_status "README.md" "fail" "File not found"
fi

echo ""

# ════════════════════════════════════════════════════════════════════════════
# 2. ENVIRONMENT CHECK
# ════════════════════════════════════════════════════════════════════════════

echo -e "${CYAN}[2/5] ENVIRONMENT VERIFICATION${NC}"
echo ""

# C++ Compiler
if command -v g++ &> /dev/null; then
    VERSION=$(g++ --version | head -1 | awk '{print $NF}')
    check_status "C++ Compiler (g++)" "pass" "Version $VERSION"
else
    check_status "C++ Compiler (g++)" "fail" "Not installed"
fi

# CMake
if command -v cmake &> /dev/null; then
    VERSION=$(cmake --version | head -1 | awk '{print $NF}')
    check_status "CMake" "pass" "Version $VERSION (optional)"
else
    check_status "CMake" "warn" "Not installed (optional)"
fi

# Python
if command -v python3 &> /dev/null; then
    VERSION=$(python3 --version | awk '{print $2}')
    check_status "Python 3" "pass" "Version $VERSION"
else
    check_status "Python 3" "fail" "Not installed"
fi

# asyncio (Python)
if python3 -c "import asyncio" 2>/dev/null; then
    check_status "Python asyncio" "pass" "Available"
else
    check_status "Python asyncio" "fail" "Not available"
fi

echo ""

# ════════════════════════════════════════════════════════════════════════════
# 3. BUILD ARTIFACTS CHECK
# ════════════════════════════════════════════════════════════════════════════

echo -e "${CYAN}[3/5] BUILD ARTIFACTS VERIFICATION${NC}"
echo ""

BUILD_DIR="${SCRIPT_DIR}/build"
OUTPUT_DIR="${SCRIPT_DIR}/bin"

if [ -d "${BUILD_DIR}" ]; then
    FILE_COUNT=$(find "${BUILD_DIR}" -type f | wc -l)
    check_status "Build directory" "pass" "$FILE_COUNT files in $BUILD_DIR"
else
    check_status "Build directory" "warn" "Not found (will be created on build)"
fi

if [ -d "${OUTPUT_DIR}" ]; then
    if [ -f "${OUTPUT_DIR}/mia_defense" ]; then
        SIZE=$(du -h "${OUTPUT_DIR}/mia_defense" | cut -f1)
        check_status "Compiled executable" "pass" "$SIZE at ${OUTPUT_DIR}/mia_defense"
    else
        check_status "Compiled executable" "warn" "Not built yet"
    fi
else
    check_status "Output directory" "warn" "Not found (will be created on build)"
fi

echo ""

# ════════════════════════════════════════════════════════════════════════════
# 4. INTEGRATION FILES CHECK
# ════════════════════════════════════════════════════════════════════════════

echo -e "${CYAN}[4/5] INTEGRATION DOCUMENTATION${NC}"
echo ""

DOCS_DIR="${SCRIPT_DIR}/../../docs"

if [ -f "${DOCS_DIR}/MIA-INTO3-INTEGRATION.md" ]; then
    LINES=$(wc -l < "${DOCS_DIR}/MIA-INTO3-INTEGRATION.md")
    check_status "MIA-INTO3-INTEGRATION.md" "pass" "$LINES lines"
else
    check_status "MIA-INTO3-INTEGRATION.md" "fail" "Not found"
fi

if [ -f "${DOCS_DIR}/DECLARATION.md" ]; then
    check_status "DECLARATION.md" "pass" "Present"
else
    check_status "DECLARATION.md" "warn" "Not found (optional)"
fi

echo ""

# ════════════════════════════════════════════════════════════════════════════
# 5. ARCHITECTURE VALIDATION
# ════════════════════════════════════════════════════════════════════════════

echo -e "${CYAN}[5/5] ARCHITECTURE VALIDATION${NC}"
echo ""

# Check for MÍA_Defense_System class in C++
if grep -q "class MIA_Defense_System" "${SCRIPT_DIR}/defense.cpp"; then
    check_status "C++ Main Class" "pass" "MIA_Defense_System found"
else
    check_status "C++ Main Class" "fail" "MIA_Defense_System not found"
fi

# Check for MÍA_Guardian class in Python
if grep -q "class MIA_Guardian" "${SCRIPT_DIR}/mia_guardian.py"; then
    check_status "Python Guardian Class" "pass" "MIA_Guardian found"
else
    check_status "Python Guardian Class" "fail" "MIA_Guardian not found"
fi

# Check for Orbital Mirror functionality
if grep -q "trigger_absolute_zero\|ORBITAL_MIRROR" "${SCRIPT_DIR}/defense.cpp"; then
    check_status "Orbital Mirror Mode" "pass" "Implementation found"
else
    check_status "Orbital Mirror Mode" "fail" "Not found"
fi

# Check for GNLL integration
if grep -q "gnll\|GNLL" "${SCRIPT_DIR}/mia_guardian.py"; then
    check_status "GNLL Integration" "pass" "Linking method found"
else
    check_status "GNLL Integration" "warn" "Not explicitly referenced"
fi

echo ""

# ════════════════════════════════════════════════════════════════════════════
# SUMMARY REPORT
# ════════════════════════════════════════════════════════════════════════════

echo -e "${CYAN}SUMMARY REPORT${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
echo ""

echo "Checks Performed: $((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNING))"
echo -e "  ${GREEN}Passed${NC}: $CHECKS_PASSED"
echo -e "  ${RED}Failed${NC}: $CHECKS_FAILED"
echo -e "  ${YELLOW}Warnings${NC}: $CHECKS_WARNING"
echo ""

# ════════════════════════════════════════════════════════════════════════════
# SYSTEM STATUS
# ════════════════════════════════════════════════════════════════════════════

echo -e "${CYAN}SYSTEM STATUS${NC}"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "  ${GREEN}✓ MÍA Defense System: READY${NC}"
    STATUS="ready"
else
    echo -e "  ${RED}✗ MÍA Defense System: INCOMPLETE${NC}"
    STATUS="incomplete"
fi

echo ""

# ════════════════════════════════════════════════════════════════════════════
# QUICK START GUIDE
# ════════════════════════════════════════════════════════════════════════════

echo -e "${CYAN}QUICK START${NC}"
echo ""

if [ "$STATUS" = "ready" ]; then
    echo "Build & run MÍA:"
    echo -e "  ${BLUE}$> cd ${SCRIPT_DIR}${NC}"
    echo -e "  ${BLUE}$> ./build.sh --demo${NC}"
    echo ""
else
    echo "First step: Install dependencies"
    echo -e "  ${BLUE}$> sudo apt-get install build-essential g++${NC}"
    echo ""
    echo "Then build:"
    echo -e "  ${BLUE}$> ./build.sh --all${NC}"
    echo ""
fi

# ════════════════════════════════════════════════════════════════════════════
# COMPONENT DETAILS
# ════════════════════════════════════════════════════════════════════════════

echo -e "${CYAN}COMPONENT DETAILS${NC}"
echo ""

echo "1. C++ Core Engine (defense.cpp)"
echo "   • Threat detection for 8 attack vectors"
echo "   • 4-tier automaticresponse escalation"
echo "   • Orbital Mirror Protocol automation"
echo "   • Real-time system monitoring"
echo ""

echo "2. Python Guardian Interface (mia_guardian.py)"
echo "   • Async/await threat response handling"
echo "   • GNLL Engine integration & coordination"
echo "   • Continuous monitoring loop"
echo "   • Graceful recovery protocols"
echo ""

echo "3. Documentation (MIA-DEFENSE.md)"
echo "   • Complete threat taxonomy"
echo "   • Orbital Mirror Mode specifications"
echo "   • Integration examples & patterns"
echo "   • Performance metrics & benchmarks"
echo ""

# ════════════════════════════════════════════════════════════════════════════
# NEXT STEPS
# ════════════════════════════════════════════════════════════════════════════

echo -e "${CYAN}NEXT STEPS${NC}"
echo ""

if [ -f "${SCRIPT_DIR}/bin/mia_defense" ]; then
    echo "1. Review documentation:"
    echo "   cat MIA-DEFENSE.md"
    echo ""
    echo "2. Run the demonstration:"
    echo "   ./bin/mia_defense"
    echo ""
    echo "3. Run Python Guardian demo:"
    echo "   python3 mia_guardian.py"
    echo ""
    echo "4. Integrate with GNLL:"
    echo "   python3 -c 'from mia_guardian import MIA_Guardian; mia = MIA_Guardian()'"
    echo ""
else
    echo "1. Build the system:"
    echo "   ./build.sh --all"
    echo ""
    echo "2. Verify the build:"
    echo "   bash STATUS.sh"
    echo ""
    echo "3. Review documentation:"
    echo "   cat MIA-DEFENSE.md"
    echo ""
fi

# ════════════════════════════════════════════════════════════════════════════
# FOOTER
# ════════════════════════════════════════════════════════════════════════════

echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}MÍA Defense System Status Check Complete${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
echo ""

# Exit with appropriate code
if [ $CHECKS_FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi
