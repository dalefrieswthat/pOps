# Base image with minimal dependencies
FROM python:3.11-slim AS base
WORKDIR /app

# Setup shell environment
COPY .dev/bashrc_append.sh /etc/profile.d/pops.sh
RUN chmod +x /etc/profile.d/pops.sh && \
    echo "source /etc/profile.d/pops.sh" >> /etc/bash.bashrc

# Copy application files
COPY app ./app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy notebooks
COPY app/notebooks ./notebooks

# Development image with Jupyter
FROM base AS development
COPY requirements-dev.txt .
RUN pip install --no-cache-dir -r requirements-dev.txt

# ML image with heavy dependencies
FROM base AS ml
COPY requirements-ml.txt .
RUN pip install --no-cache-dir -r requirements-ml.txt

# Production image (minimal)
FROM base AS production
CMD ["uvicorn", "app.metrics_server:app", "--host", "0.0.0.0", "--port", "8000"]
