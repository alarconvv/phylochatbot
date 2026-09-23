library(shiny)
library(bslib)
library(shinychat)
library(ellmer)
library(ragnar)

# Connect to the DuckDB vector store once globally
store <- ragnar_store_connect("phyloSource.duckdb")

ui <- page_sidebar(
  title = "PhyloChatBot",
  theme = bs_theme(bootswatch = "flatly"),
  sidebar = sidebar(
    title = "Controls",
    p("Phylogenetic Comparative Biology Assistant")
  ),
  layout_columns(
    fill = TRUE,
    card(
      card_header("PhyloChat"),
      chat_ui("chat", fill = TRUE)
    )
  )
)

server <- function(input, output, session) {
  # Instantiate Gemini model per server session to maintain isolated chat history
  chat <- chat_google_gemini(
    model = "gemini-2.5-flash",
    system_prompt = paste(
      "You are phyloBot, an expert AI specialized in phylogenetic comparative biology.",
      "Your role is to guide users on theoretical evolutionary models",
      "(Phylogenetic signal, Phylogenetic Generalized Least Squares [PGLS],",
      "Ancestral state reconstruction, Diversification rates, Character-dependent diversification)",
      "and generate bug-free R code using packages such as `phytools`, `ape`, `geiger`, `nlme`, and `phylolm`.",
      "CRITICAL: Always consult the textbook retrieval tool before formulating answers on theoretical models or complex functions.",
      "Provide precise mathematical definitions and step-by-step R code blocks."
    )
  )
  
  # Register the vector retrieval tool to the session chat
  ragnar_register_tool_retrieve(chat, store)
  
  # Process user prompt and stream async responses to shinychat
  observeEvent(input$chat_user_input, {
    stream <- chat$stream_async(input$chat_user_input)
    chat_append("chat", stream)
  })
}

shinyApp(ui, server)