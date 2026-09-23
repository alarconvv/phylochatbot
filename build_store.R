library(ragnar)

# Configuration
db_path <- "phyloSource.duckdb"
folder <- "./phyloSource"

# Ensure source folder exists
if (!dir.exists(folder)) {
  dir.create(folder)
}

# 1. Initialize vector store with local Ollama embeddings
store <- ragnar_store_create(
  location = db_path,
  embed = \(x) embed_ollama(x, model = "nomic-embed-text"),
  overwrite = TRUE
)

# 2. Convert and chunk files (PDF, EPUB, Markdown)
files <- list.files(folder, pattern = "\\.(pdf|epub|md)$", full.names = TRUE)

for (f in files) {
  md <- read_as_markdown(f)
  chunks <- markdown_chunk(md)
  ragnar_store_insert(store, chunks)
}

# 3. Build index for fast retrieval
ragnar_store_build_index(store)
cat("Vector database successfully built at:", db_path, "\n")
