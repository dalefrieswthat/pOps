# 🚀 pOps

**A portable AI/ML dev toolkit with built-in observability, GPU support, and shell resilience.**  
*Python Ops, Prompt Ops, Performance Ops — whatever you need it to be.*

---

## 📦 What's Inside?

- ✅ PyTorch, Transformers, Scikit-learn, Pandas, Matplotlib
- ✅ OpenTelemetry SDK + Loguru for tracing and logging
- ✅ Shell crash protection and enhanced prompts
- ✅ JupyterLab interface (default port: 8888)
- ✅ Prometheus-ready metrics endpoint (port 8000)
- ✅ GPU-aware (auto-detects NVIDIA runtime) or falls back to CPU

---

## 🐳 Build and Run

### 🛠 Build the image

```bash
docker build -t yourusername/pops .

```

## Prerequisites

- Python 3.11+
- Rust (required for pydantic)
  ```bash
  # Install Rust using rustup
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  ```

# Add shell resilience and health prompt
COPY .dev/bashrc_append.sh /tmp/bashrc_append.sh
RUN cat /tmp/bashrc_append.sh >> /etc/bash.bashrc

## Why pOps?

pOps combines several essential ML development tools into a single, secure environment:
- 🔒 **Shell Guard Protection**: Safe development environment with crash protection
- 📊 **Integrated Metrics**: Real-time monitoring of ML model performance
- 🧪 **Interactive Development**: JupyterLab interface for experimentation
- 🐳 **Docker-Based**: Consistent environment across team members
- 🔄 **API-First**: RESTful endpoints for model inference and metrics
- 📈 **Real-Time Visualization**: Interactive dashboards for monitoring

## Similar Tools Comparison

### MLflow
- ✅ ML experiment tracking
- ✅ Metrics visualization
- ❌ No shell protection
- ❌ More complex setup

### Weights & Biases
- ✅ Real-time metrics
- ✅ Experiment tracking
- ❌ Cloud-only
- ❌ Paid service

### Prometheus + Grafana
- ✅ Robust metrics
- ✅ Custom dashboards
- ❌ No ML focus
- ❌ Complex configuration

### JupyterHub
- ✅ Development environment
- ✅ Multi-user support
- ❌ No built-in metrics
- ❌ No shell protection

## Project Structure

## Getting Started with pOps

### Quick Start
```bash
# Build and run container
docker build -t pops:dev --target development .
docker run -it -p 8000:8000 -p 8001:8001 -p 8888:8888 pops:dev /bin/bash --login

# Inside container, start all services
pops-start-all
```

### Testing Your Setup

1. **Check Services**
```bash
# Test metrics endpoint
curl http://localhost:8000/metrics

# Test inference endpoint
curl "http://localhost:8001/predict/This%20is%20amazing!"
```

2. **Using JupyterLab**
- Open http://localhost:8888 in your browser
- Navigate to notebooks/metrics_dashboard.ipynb
- Run all cells to start the dashboard
- Use the interactive text input to test sentiment analysis

3. **Available Commands**
```bash
# Start all services
pops-start-all

# Start just metrics server
pops-run

# Stop all services
pops-stop-all

# Run tests
pops-test

# Lint code
pops-lint
```

### Monitoring and Metrics

1. **Access Points**
- Metrics Dashboard: http://localhost:8888 (JupyterLab)
- Raw Metrics: http://localhost:8000/metrics
- API Documentation: http://localhost:8001/docs

2. **Available Metrics**
- Inference latency
- Request counts
- Model performance
- System health

### Troubleshooting

1. **Port Conflicts**
```bash
# Stop all running containers
docker stop $(docker ps -q)

# Then start pOps again
docker run -it -p 8000:8000 -p 8001:8001 -p 8888:8888 pops:dev /bin/bash --login
```

2. **Common Issues**
- If JupyterLab doesn't load: Restart the kernel
- If metrics don't show: Ensure services are running
- If shell commands not found: Make sure you're inside the container

### Development Workflow

1. **Local Development**
```bash
# Start container with volume mount
docker run -it \
  -p 8000:8000 -p 8001:8001 -p 8888:8888 \
  -v $(pwd):/app \
  pops:dev /bin/bash --login
```

2. **Testing Changes**
- Edit code in your preferred editor
- Changes reflect immediately in the container
- Use JupyterLab for interactive testing
- Monitor metrics in real-time

3. **Best Practices**
- Always use `pops-start-all` to ensure all services are running
- Check metrics dashboard for performance impacts
- Use the shell guard commands for safety
- Test API endpoints after changes

### Environment Variables

```bash
# Required
POPS_ENV=development  # or production
JUPYTER_TOKEN=""      # for JupyterLab security
JUPYTER_PASSWORD=""   # for JupyterLab security

# Optional
METRICS_PORT=8000     # default
JUPYTER_PORT=8888     # default
```

### Production Deployment

```bash
# Build production image
docker build -t pops:prod --target production .

# Run in production mode
docker run -d \
  -p 8000:8000 -p 8001:8001 \
  -e POPS_ENV=production \
  pops:prod
```
