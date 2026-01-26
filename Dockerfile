FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV UV_SYSTEM_PYTHON=1

# ---- system ----
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    ninja-build \
    python3.11 \
    python3.11-venv \
    && rm -rf /var/lib/apt/lists/*

# ---- uv ----
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

# ---- workspace ----
WORKDIR /workspace

# ---- python ----
RUN uv python pin 3.11

# ---- deps ----
COPY requirements.uv .

RUN uv venv \
 && . .venv/bin/activate \
 && uv pip install torch==2.2.2 \
    --index-url https://download.pytorch.org/whl/cu121 \
 && uv pip install -r requirements.uv \
 && uv pip install flash-attn==2.7.4.post1 --no-build-isolation



