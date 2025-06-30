# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

LightRAG is a knowledge graph-based RAG (Retrieval-Augmented Generation) system with a modular plugin architecture:

### Core Components
- **Core Engine** (`/lightrag/`): Main LightRAG class, operations, and utilities
- **Storage Layer** (`/lightrag/kg/`): Pluggable storage backends for graphs, vectors, KV pairs
- **LLM Integration** (`/lightrag/llm/`): Support for multiple LLM providers via unified interfaces
- **API Server** (`/lightrag/api/`): FastAPI-based REST API with authentication
- **Web UI** (`/lightrag_webui/`): React/TypeScript frontend with graph visualization

### Key Architectural Patterns
- **Storage abstraction**: Multiple implementations (Neo4j, PostgreSQL, MongoDB, Redis, etc.)
- **Async/await**: Concurrent processing with controlled parallelism
- **Plugin system**: Extensible LLM and storage backend support
- **Event-driven**: Document processing pipeline with status tracking

## Development Commands

### Core Installation & Setup
```bash
# Install core package from source (recommended for development)
pip install -e .

# Install with API server dependencies
pip install -e ".[api]"

# Install with visualization tools
pip install -e ".[tools]"

# Development setup from env.example
cp env.example .env
# Edit .env with your LLM/embedding service credentials
```

### Server Operations
```bash
# Start API server (development)
lightrag-server

# Start with gunicorn (production)
lightrag-gunicorn

# Graph visualization tool
lightrag-viewer
```

### Frontend Development
```bash
cd lightrag_webui
bun install
bun dev          # Development server
bun build        # Production build
bun lint         # Code linting
```

### Docker Deployment
```bash
# Full stack with docker-compose
docker-compose up

# Individual container
docker build -t lightrag .
docker run -p 9621:9621 lightrag
```

### Testing
```bash
# Run tests
python -m pytest tests/

# Test specific storage implementation
python -m pytest tests/test_graph_storage.py

# API compatibility testing
python -m pytest tests/test_lightrag_ollama_chat.py
```

## Configuration Management

### Environment Variables (.env)
- **Server**: `HOST`, `PORT`, `WEBUI_TITLE`
- **Authentication**: `AUTH_ACCOUNTS`, `TOKEN_SECRET`
- **LLM**: `LLM_BINDING`, `LLM_MODEL`, `LLM_BINDING_API_KEY`
- **Embedding**: `EMBEDDING_BINDING`, `EMBEDDING_MODEL`, `EMBEDDING_DIM`
- **Storage**: `LIGHTRAG_*_STORAGE` variables for backend selection

### Storage Configuration
Multiple storage backends can be mixed:
```bash
# Example: PostgreSQL for everything except Neo4j for graphs
LIGHTRAG_KV_STORAGE=PGKVStorage
LIGHTRAG_VECTOR_STORAGE=PGVectorStorage
LIGHTRAG_DOC_STATUS_STORAGE=PGDocStatusStorage
LIGHTRAG_GRAPH_STORAGE=Neo4JStorage
```

### Query Modes
- **local**: Context-dependent entity retrieval
- **global**: Knowledge graph relationship-based retrieval  
- **hybrid**: Combined local + global approach
- **naive**: Basic vector similarity search
- **mix**: Integrated KG + vector retrieval

## Development Patterns

### LightRAG Initialization (Required)
```python
# CRITICAL: Both calls required after creating LightRAG instance
rag = LightRAG(working_dir=WORKING_DIR, ...)
await rag.initialize_storages()  # Initialize storage backends
await initialize_pipeline_status()  # Initialize processing pipeline
```

### Adding Storage Backends
1. Inherit from `BaseGraphStorage`, `BaseVectorStorage`, or `BaseKVStorage`
2. Implement required abstract methods
3. Register in storage selection logic
4. Add environment variable support

### LLM Integration
1. Create new file in `/lightrag/llm/`
2. Implement standard async LLM interface
3. Add provider-specific configuration handling
4. Include error handling and retries

### API Extensions
- Add routes in `/lightrag/api/routers/`
- Follow FastAPI patterns with dependency injection
- Include authentication decorators where needed
- Add corresponding frontend components

## Key Files & Responsibilities

### Core Files
- `lightrag/lightrag.py`: Main orchestration class with configuration
- `lightrag/operate.py`: Document processing, entity extraction, querying
- `lightrag/base.py`: Abstract base classes for storage implementations
- `lightrag/types.py`: Pydantic models for entities, relationships, queries

### Storage Implementations
- `lightrag/kg/neo4j_impl.py`: Neo4j graph database
- `lightrag/kg/postgres_impl.py`: PostgreSQL with pgvector
- `lightrag/kg/mongo_impl.py`: MongoDB document storage
- `lightrag/kg/redis_impl.py`: Redis key-value storage

### API & Frontend
- `lightrag/api/lightrag_server.py`: FastAPI application entry point
- `lightrag_webui/src/App.tsx`: React application root
- `lightrag_webui/src/features/`: Feature-based component organization

## Important Notes

### Initialization Requirements
- Always call `await rag.initialize_storages()` and `await initialize_pipeline_status()` after creating LightRAG instance
- Missing initialization causes `AttributeError: __aenter__` or `KeyError: 'history_messages'`

### Model Switching
- When changing embedding models, clear data directory (preserve `kv_store_llm_response_cache.json` if keeping LLM cache)
- Different embedding dimensions require storage reinitialization

### Performance Considerations
- Use `max_parallel_insert` < 10 for document processing (LLM is bottleneck)
- Configure `MAX_ASYNC` and `EMBEDDING_FUNC_MAX_ASYNC` based on provider limits
- Monitor token usage with built-in `TokenTracker`

### Security
- Never commit API keys or credentials
- Use environment variables for all sensitive configuration
- Enable authentication for production deployments
- Configure CORS origins appropriately