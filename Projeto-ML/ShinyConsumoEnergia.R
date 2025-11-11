# ============================================================
# SHINY - Previsão de Classe de Consumo Industrial (rpart)
# ============================================================
library(shiny)
library(dplyr)
library(stringi)
library(rpart)

# ====== CARREGAR OBJETOS TREINADOS ======
modelo_arvore <- readRDS("modelo_arvore.rds")
colnames_dummies <- readRDS("colnames_dummies.rds")
normalizacao_consumidores <- readRDS("normalizacao_consumidores.rds")

# Garantir que colnames_dummies é vetor
if (is.data.frame(colnames_dummies)) {
  colnames_dummies <- colnames(colnames_dummies)
} else if (!is.character(colnames_dummies)) {
  colnames_dummies <- unlist(colnames_dummies)
}

# ====== FUNÇÃO PARA INFERIR ESTAÇÃO ======
obter_estacao <- function(mes) {
  mes <- tolower(mes)
  if (mes %in% c("dezembro", "janeiro", "fevereiro")) return("Verao")
  if (mes %in% c("marco", "abril", "maio")) return("Outono")
  if (mes %in% c("junho", "julho", "agosto")) return("Inverno")
  if (mes %in% c("setembro", "outubro", "novembro")) return("Primavera")
  return(NA)
}

# ====== UI ======
ui <- fluidPage(
  titlePanel("🔌 Previsão de Classe de Consumo Industrial"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Insira as informações abaixo:"),
      numericInput("consumidores", "Número de Consumidores:", value = 50000, min = 0),
      selectInput("uf", "UF:", 
                  choices = c("AC","AL","AM","AP","BA","CE","DF","ES","GO","MA",
                              "MG","MS","MT","PA","PB","PE","PI","PR","RJ","RN",
                              "RO","RR","RS","SC","SE","SP","TO")),
      selectInput("tipo", "Tipo de Consumidor:", choices = c("Cativo","Livre")),
      selectInput("mes", "Mês:", 
                  choices = c("Janeiro","Fevereiro","Março","Abril","Maio","Junho",
                              "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro")),
      actionButton("prever", "🔍 Prever Classe", class = "btn btn-primary")
    ),
    
    mainPanel(
      h3("Resultado da Previsão:"),
      uiOutput("resultado_ui"),
      plotOutput("grafico_prob", height = "280px")
    )
  )
)

# ====== SERVER ======
server <- function(input, output, session) {
  
  valores <- reactiveValues(pred = NULL, prob = NULL)
  
  observeEvent(input$prever, {
    # 1️⃣ Pré-processamento
    mes_clean <- stri_trans_general(input$mes, "Latin-ASCII")
    mes_clean <- paste0(toupper(substr(mes_clean, 1, 1)), 
                        tolower(substr(mes_clean, 2, nchar(mes_clean))))
    estacao <- obter_estacao(mes_clean)
    
    df_input <- data.frame(
      consumidores = input$consumidores,
      uf = input$uf,
      tipoconsumidor = input$tipo,
      estacao = estacao,
      mes = mes_clean,
      stringsAsFactors = FALSE
    )
    
    # 2️⃣ Normalizar e preparar
    df_input$consumidores <- (df_input$consumidores - normalizacao_consumidores$mean) / 
      normalizacao_consumidores$sd
    
    df_dummies <- as.data.frame(matrix(0, nrow = 1, ncol = length(colnames_dummies)))
    colnames(df_dummies) <- colnames_dummies
    
    colunas_ativas <- c(
      paste0("uf_", df_input$uf),
      paste0("tipoconsumidor_", df_input$tipoconsumidor),
      paste0("estacao_", df_input$estacao),
      paste0("mes_", df_input$mes)
    )
    
    df_dummies[1, intersect(colunas_ativas, names(df_dummies))] <- 1
    df_dummies$consumidores <- as.numeric(df_input$consumidores)
    
    # 3️⃣ Previsão
    valores$pred <- predict(modelo_arvore, newdata = df_dummies, type = "class")
    
    # 4️⃣ Probabilidades
    if (length(unique(modelo_arvore$frame$yval)) > 1) {
      prob <- as.data.frame(predict(modelo_arvore, newdata = df_dummies, type = "prob"))
      valores$prob <- prob * 100  # converter para percentual
    } else {
      valores$prob <- NULL
    }
  })
  
  # ====== Exibir classe prevista ======
  output$resultado_ui <- renderUI({
    req(valores$pred)
    classe <- as.character(valores$pred)
    div(
      style = "background-color:#f8f9fa; border-radius:10px; padding:20px; 
               text-align:center; font-size:20px; font-weight:bold; color:#2c3e50;",
      paste("Classe prevista:", classe)
    )
  })
  
  # ====== Gráfico de probabilidades (%)
  output$grafico_prob <- renderPlot({
    req(valores$prob)
    probs <- as.numeric(valores$prob[1, ])
    names_classes <- colnames(valores$prob)
    
    barplot(
      probs,
      names.arg = names_classes,
      main = "Probabilidades de Cada Classe (%)",
      ylab = "Probabilidade (%)",
      ylim = c(0, 100),
      col = "#3498db",
      border = "white"
    )
    grid(nx = NA, ny = NULL, col = "gray80", lty = "dotted")
  })
}

# ====== EXECUTAR APP ======
shinyApp(ui = ui, server = server)
