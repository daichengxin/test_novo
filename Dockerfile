# ---- Stage 1: build ----
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:$PATH"

# Install system deps
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    ninja-build \
    python3.11 \
    python3.11-venv \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

WORKDIR /workspace

# Pin Python
RUN uv python pin 3.11

# Copy requirements
COPY requirements.uv .

# Create venv and install deps
RUN uv venv .venv --python /usr/bin/python3.11 \
 && . .venv/bin/activate \
 && uv pip install torch==2.2.2 --index-url https://download.pytorch.org/whl/cu121 \
 && uv pip install -r requirements.uv \
 && uv pip install flash-attn==2.7.4.post1 --no-build-isolation

# ---- Stage 2: runtime ----
FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV PATH="/workspace/.venv/bin:$PATH"

WORKDIR /workspace

# Copy venv from builder
COPY --from=builder /workspace/.venv /workspace/.venv
COPY --from=builder /workspace/requirements.uv /workspace/requirements.uv