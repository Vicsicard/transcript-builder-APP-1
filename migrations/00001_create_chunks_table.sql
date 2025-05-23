-- Enable the pgvector extension to work with embeddings
CREATE EXTENSION IF NOT EXISTS vector;

-- Create chunks table for storing transcript chunks and their embeddings
CREATE TABLE IF NOT EXISTS chunks (
    id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    chunk_id TEXT NOT NULL,
    question_id TEXT NOT NULL,
    question_text TEXT NOT NULL,
    response_text TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    similarity_score FLOAT NOT NULL,
    vector_embedding vector(384),  -- Using sentence-transformers all-MiniLM-L6-v2 (384 dimensions)
    project_id TEXT,               -- Optional project association
    user_id TEXT,                 -- Optional user association
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    
    -- Add constraints for data integrity
    CONSTRAINT chunks_chunk_id_unique UNIQUE (chunk_id),
    CONSTRAINT chunks_similarity_valid CHECK (similarity_score >= 0 AND similarity_score <= 1)
);

-- Create index on project_id for faster lookups
CREATE INDEX IF NOT EXISTS chunks_project_id_idx ON chunks(project_id);

-- Create index on user_id for faster lookups
CREATE INDEX IF NOT EXISTS chunks_user_id_idx ON chunks(user_id);

-- Create index on vector_embedding for similarity searches
CREATE INDEX IF NOT EXISTS chunks_vector_embedding_idx ON chunks USING ivfflat (vector_embedding vector_cosine_ops)
WITH (lists = 100);  -- Adjust lists based on expected table size

-- Add helpful comments
COMMENT ON TABLE chunks IS 'Stores transcript chunks with their metadata and vector embeddings';
COMMENT ON COLUMN chunks.vector_embedding IS 'Sentence-transformers all-MiniLM-L6-v2 embedding vector (384 dimensions)';
COMMENT ON COLUMN chunks.project_id IS 'Optional reference to associated project';
COMMENT ON COLUMN chunks.user_id IS 'Optional reference to associated user';
