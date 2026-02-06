#!/bin/bash
# AUTO-EXECUTE on terminal startup
# Add this to .bashrc to auto-run the build pipeline

if [ -f /tmp/.build_pipeline_started ]; then
    return
fi

# Mark that build has started
touch /tmp/.build_pipeline_started

# Change to workspace
cd /workspaces/Core-System 2>/dev/null || cd /

# Run the build pipeline
if [ -f scripts/full-build-pipeline.sh ]; then
    echo "🚀 Iniciando pipeline de compilación automático..."
    bash scripts/full-build-pipeline.sh
fi
