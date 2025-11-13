# -------------------------------------------------------------
# 1. Carregar pacotes necessários
# -------------------------------------------------------------
library(readxl)
library(dplyr)
library(lubridate)
library(arules)
library(fastDummies)
library(RWeka)
library(caret)
library(stringi)
library(rJava)
library(rpart)
library(rpart.plot)

# -------------------------------------------------------------
# 2. Ler a planilha e padronizar nomes das colunas
# -------------------------------------------------------------
df <- read_excel("Dados_abertos_Consumo_Mensal.xlsx", sheet = "CONSUMO E NUMCONS SAM UF")

# Remover acentos e deixar colunas em minúsculo
colnames(df) <- colnames(df) %>%
  stri_trans_general("Latin-ASCII") %>%
  tolower()

# Exibir nomes padronizados
print(colnames(df))

# -------------------------------------------------------------
# 3. Selecionar colunas de interesse
# -------------------------------------------------------------
selected_columns <- c("dataexcel", "uf", "classe", "tipoconsumidor", "consumo", "consumidores")
df <- df %>% select(all_of(selected_columns))

# -------------------------------------------------------------
# 4. Filtrar apenas registros da classe Industrial
# -------------------------------------------------------------
df_industrial <- df %>% filter(classe == "Industrial")

# -------------------------------------------------------------
# 5. Converter a coluna de data (número de série Excel → data real)
# -------------------------------------------------------------
df_industrial$dataexcel <- as.Date(df_industrial$dataexcel, origin = "1899-12-30")

# -------------------------------------------------------------
# 6. Função para identificar a estação do ano (Brasil)
# -------------------------------------------------------------
get_season <- function(date) {
  m <- month(date)
  if (m %in% c(12, 1, 2)) {
    return("Verao")
  } else if (m %in% c(3, 4, 5)) {
    return("Outono")
  } else if (m %in% c(6, 7, 8)) {
    return("Inverno")
  } else {
    return("Primavera")
  }
}

# -------------------------------------------------------------
# 7. Adicionar colunas derivadas: Estação e Mês (em português)
# -------------------------------------------------------------
map_month_pt <- function(date) {
  mes <- month(date, label = TRUE, abbr = FALSE, locale = "pt_BR.UTF-8") |> as.character()
  mes <- stringi::stri_trans_general(mes, "Latin-ASCII")
  return(mes)
}

df_industrial <- df_industrial %>%
  mutate(
    estacao = sapply(dataexcel, get_season),
    mes = sapply(dataexcel, map_month_pt)
  )

# -------------------------------------------------------------
# 8. Criar classes de consumo (Baixo, Medio, Alto)
# -------------------------------------------------------------
df_industrial <- df_industrial %>%
  mutate(
    classeconsumo = discretize(
      consumo,
      method = "frequency",
      breaks = 5,
      labels = c("Muito Baixo", "Baixo", "Medio", "Alto", "Muito Alto")
    )
  )

# -------------------------------------------------------------
# 9. Testes de associação e correlação
# -------------------------------------------------------------
df_corr <- df_industrial
df_corr$classeconsumonum <- as.numeric(df_corr$classeconsumo)
cor(df_corr$consumidores, df_corr$classeconsumonum, use = "complete.obs")
chisq.test(table(df_industrial$uf, df_industrial$classeconsumo))
chisq.test(table(df_industrial$tipoconsumidor, df_industrial$classeconsumo))
chisq.test(table(df_industrial$estacao, df_industrial$classeconsumo))
chisq.test(table(df_industrial$mes, df_industrial$classeconsumo))

# -------------------------------------------------------------
# 10. Preparação para modelagem
# -------------------------------------------------------------
df_industrial <- df_industrial %>%
  select(-c(dataexcel, classe, consumo)) %>%
  mutate(across(c(uf, tipoconsumidor, estacao, mes), as.factor))

# -------------------------------------------------------------
# 11. Separar variável alvo e preditoras
# -------------------------------------------------------------
target <- df_industrial$classeconsumo
features <- df_industrial %>% select(-classeconsumo)

# -------------------------------------------------------------
# 12. Aplicar One-Hot Encoding nas variáveis categóricas
# -------------------------------------------------------------
features_encoded <- dummy_cols(
  features,
  remove_first_dummy = FALSE,
  remove_selected_columns = TRUE
)

# -------------------------------------------------------------
# 13. Normalizar a variável 'consumidores'
#     (agora garantindo que seja numérica e não matriz)
# -------------------------------------------------------------
consumidores_scaled <- scale(features_encoded$consumidores)
features_normalized <- features_encoded %>%
  mutate(consumidores = as.numeric(consumidores_scaled))

# -------------------------------------------------------------
# 14. Reunir conjunto final
# -------------------------------------------------------------
df_modelo <- cbind(features_normalized, classeconsumo = target)
print(colnames(df_modelo))

# -------------------------------------------------------------
# 15. Dividir dados em treino/teste
# -------------------------------------------------------------
set.seed(123)
train_index <- createDataPartition(df_modelo$classeconsumo, p = 0.7, list = FALSE)
train_data <- df_modelo[train_index, ]
test_data <- df_modelo[-train_index, ]

# -------------------------------------------------------------
# 16. Treinar modelo de Árvore de Decisão (rpart)
# -------------------------------------------------------------
modelo_arvore <- rpart(
  classeconsumo ~ .,
  data = train_data,
  method = "class",
  control = rpart.control(cp = 0.01)
)

# -------------------------------------------------------------
# 17. Avaliar modelo
# -------------------------------------------------------------
pred_treino <- predict(modelo_arvore, train_data, type = "class")
confusao_treino <- confusionMatrix(pred_treino, train_data$classeconsumo)
print(confusao_treino)

pred_teste <- predict(modelo_arvore, test_data, type = "class")
confusao_teste <- confusionMatrix(pred_teste, test_data$classeconsumo)
print(confusao_teste)

# -------------------------------------------------------------
# 18. Salvar modelo e parâmetros
# -------------------------------------------------------------
saveRDS(modelo_arvore, "modelo_arvore.rds")

colnames_dummies <- colnames(features_normalized)
saveRDS(colnames_dummies, "colnames_dummies.rds")

consumidores_mean <- attr(consumidores_scaled, "scaled:center")
consumidores_sd <- attr(consumidores_scaled, "scaled:scale")
saveRDS(list(mean = consumidores_mean, sd = consumidores_sd), "normalizacao_consumidores.rds")

