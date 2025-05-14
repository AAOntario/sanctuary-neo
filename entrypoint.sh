FROM ubuntu:22.04

# Install system utilities
RUN apt-get update && apt-get install -y \
    openssh-server sudo curl wget gnupg2 jq netcat lsof dos2unix python3 python3-pip

# SSH Configuration
RUN mkdir /var/run/sshd && \
    sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo 'root:changeme' | chpasswd

# Expose all needed ports
EXPOSE 2222 11434 3000 8080 8888

# Install Python packages and uvx (for OpenWebUI runtime install)
RUN pip install --no-cache-dir jupyterlab uv uvx

# Install code-server (optional; enable if you want VS Code in browser)
# RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh -o /tmp/ollama_install.sh && \
    bash /tmp/ollama_install.sh

# Environment variables for canonical paths
ENV OLLAMA_MODELS=/workspace/ollama/models
ENV WEBUI_DATA=/workspace/webui_data
ENV JUPYTER_RUNTIME_DIR=/workspace/jupyter

# Copy and prepare entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]