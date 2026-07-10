#!/bin/bash
# Environment setup for ChatGPT connectors

# Set the SJL MCP Filesystem token
export SJL_WRITE_TOKEN="9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e60737770bf5687"

# Set ChatGPT API configuration
export CHATGPT_API_URL="https://api.openai.com/v1"
export CHATGPT_MCP_SERVER="https://72.61.74.250:8813"

# Optional: Set logging level
export LOG_LEVEL="INFO"

echo "Environment configured for ChatGPT connectors"
echo "SJL_WRITE_TOKEN: ${SJL_WRITE_TOKEN:0:20}..."
echo "CHATGPT_MCP_SERVER: ${CHATGPT_MCP_SERVER}"
