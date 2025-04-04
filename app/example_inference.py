from transformers import pipeline
from opentelemetry import trace
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from loguru import logger
from fastapi import FastAPI
import numpy as np
from prometheus_client import Counter, Histogram, make_asgi_app
import time
from pydantic import BaseModel
import logging

trace.set_tracer_provider(
    TracerProvider(resource=Resource.create({SERVICE_NAME: "pops"}))
)
tracer = trace.get_tracer(__name__)
span_processor = BatchSpanProcessor(OTLPSpanExporter())
trace.get_tracer_provider().add_span_processor(span_processor)

app = FastAPI()

# Add prometheus metrics
metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load pre-trained sentiment analysis model with increased timeout
logger.info("Loading sentiment analysis model... (this may take a few minutes)")
try:
    sentiment_analyzer = pipeline(
        "sentiment-analysis",
        model="distilbert-base-uncased-finetuned-sst-2-english",
        timeout=30
    )
    logger.info("Model loaded successfully!")
except Exception as e:
    logger.error(f"Error loading model: {e}")
    sentiment_analyzer = None

# Define metrics
INFERENCE_COUNT = Counter(
    'inference_requests_total',
    'Total number of inference requests'
)

INFERENCE_LATENCY = Histogram(
    'inference_duration_seconds',
    'Inference latency in seconds'
)

# Define input model
class TextInput(BaseModel):
    text: str

@def run_inference():
    with tracer.start_as_current_span("inference-span"):
        logger.info("Loading model...")
        classifier = pipeline("sentiment-analysis")
        result = classifier("I love open source AI environments.")
        logger.info(f"Inference result: {result}")

@app.get("/")
async def root():
    return {
        "message": "pOps Sentiment Analysis Service",
        "model_status": "loaded" if sentiment_analyzer else "not loaded"
    }

# Change to support both GET and POST
@app.get("/predict/{text}")
@app.post("/predict")
async def predict(text: str = None, body: TextInput = None):
    if not sentiment_analyzer:
        return {"error": "Model not loaded. Please try again later."}

    start_time = time.time()
    
    try:
        # Get text from either path parameter or body
        input_text = text if text else body.text if body else "No text provided"
        
        # Real ML inference
        result = sentiment_analyzer(input_text)
        
        # Record metrics
        INFERENCE_COUNT.inc()
        INFERENCE_LATENCY.observe(time.time() - start_time)
        
        return {
            "text": input_text,
            "sentiment": result[0]["label"],
            "confidence": float(result[0]["score"])
        }
    except Exception as e:
        logger.error(f"Inference error: {e}")
        return {"error": "Failed to process text"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
