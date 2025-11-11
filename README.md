# Projeto de ML - Classificação do Nível de Consumo de Energia Industrial

**Status:** 🚀 Concluído / Em Apresentação 🚀

Este repositório contém o desenvolvimento do Trabalho Final (AP2) da disciplina de **Projeto de Machine Learning** do curso de **CDIA**. O projeto foca na construção de um modelo de classificação para prever o nível de consumo de energia do setor industrial.

## 🚀 Aplicação Interativa (Shiny)

O modelo de classificação foi implementado em uma aplicação web interativa usando R/Shiny. Você pode testar o preditor em tempo real no link abaixo:

**[➡️ Acesse o App de Previsão aqui](https://guiduran.shinyapps.io/Projeto-ML/)**

## 🎯 Objetivo do Projeto

O objetivo foi aplicar conceitos de aprendizado de máquina supervisionado para desenvolver um modelo de **classificação** capaz de prever o **nível de consumo** (Baixo, Médio ou Alto) do setor industrial, com base em dados históricos da Empresa de Pesquisa Energética (EPE).

## ❓ Questão de Pesquisa

Nossa análise busca responder à seguinte questão central:

> **É possível *classificar* o nível de consumo de energia industrial (Baixo, Médio ou Alto) com base em variáveis como localização (UF), número de consumidores, tipo de contrato (Cativo/Livre) e época do ano (mês/estação)?**

## 📊 Dataset e Metodologia

1.  **Fonte:** Empresa de Pesquisa Energética (EPE) - Dados Abertos de Consumo Mensal.
2.  **Filtro:** A análise foi focada apenas nos registros de `classe` == "Industrial".
3.  **Engenharia de Features:**
    * `estacao`: Criada a partir do mês (Verão, Outono, etc.).
    * `mes`: Extraído da data.
4.  **Criação da Variável-Alvo (Target):**
    * O problema foi transformado de regressão para classificação. A variável contínua `consumo` (em MWh) foi **discretizada** em 3 categorias de igual frequência (`method = "frequency"`): **"Baixo", "Médio" e "Alto"**.
    * Esta nova variável (`classeconsumo`) se tornou o alvo do nosso modelo.
5.  **Pré-Processamento para Modelagem:**
    * **Normalização:** A variável `consumidores` foi normalizada (scaled) para ter média 0 e desvio padrão 1.
    * **One-Hot Encoding:** As variáveis categóricas (`uf`, `tipoconsumidor`, `estacao`, `mes`) foram transformadas em colunas dummies.
6.  **Modelo de Machine Learning:**
    * Foi treinado um modelo de **Árvore de Decisão (rpart)** para classificar o `classeconsumo`.
    * O modelo foi avaliado usando uma Matriz de Confusão, focando em métricas como **Acurácia (Accuracy)**.
7.  **Aplicação (Shiny):**
    * O modelo treinado (`.rds`) e os parâmetros de normalização foram salvos e são carregados pela aplicação Shiny.
    * O app recebe as entradas do usuário, aplica os mesmos passos de pré-processamento (normalização e one-hot encoding) e utiliza o modelo para prever a classe e suas probabilidades.

## 👨‍💻 Integrantes

* João Gabriel de Castro Rodriguez
* Isabela Vieira
* Guilherme Duran Duran
* Gabriel Franklin Monteiro
