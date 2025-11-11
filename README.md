# Projeto de Machine Learning - Previsão de Consumo de Energia Industrial

Este repositório contém o desenvolvimento do Trabalho Final (AP2) da disciplina de **Projeto de Machine Learning** do curso de **CDIA**.

## 🎯 Objetivo do Projeto

O objetivo principal é aplicar conceitos de estatística e aprendizado de máquina para analisar dados reais do **setor de Energia**. O foco é desenvolver um modelo preditivo capaz de estimar o **consumo de energia (em MWh)** pelo setor industrial, utilizando dados históricos da Empresa de Pesquisa Energética (EPE).

## ❓ Questão de Pesquisa

Nossa análise busca responder à seguinte questão central:

> **É possível prever o *consumo* de energia elétrica industrial (em MWh) para os próximos meses, com base em dados históricos?**

## 📊 Dataset

* [cite_start]**Fonte:** Empresa de Pesquisa Energética (EPE) - Plano de Dados Abertos[cite: 2, 3].
* [cite_start]**Conjunto de Dados:** Consumo Mensal de Energia Elétrica [cite: 4] [cite_start](Tabela: `CONSUMO E NUMCONS SAM UF` [cite: 5]).
* [cite_start]**Descrição:** Utilizamos uma série temporal de dados mensais de `Consumo` (em MWh) [cite: 7] [cite_start]e `Consumidores` (número de unidades) [cite: 7][cite_start], com histórico desde Jan/2004[cite: 6].
* [cite_start]**Filtros Principais:** A análise foca nos dados onde a `Classe` é "Industrial".
* **Localização:** Os dados brutos e tratados estão disponíveis na pasta `/1_Dados`.

## 🛠️ Metodologia e Fases do Projeto

O projeto será dividido nas seguintes etapas e entregáveis principais:

1.  **Análise Exploratória e Pré-processamento (EDA):**
    * [cite_start]Limpeza e tratamento dos dados (como os formatos de data `Data` e `DataExcel` ).
    * Análise estatística descritiva e visualização de dados (sazonalidade, tendências, correlações) do consumo industrial.

2.  **Modelagem de Machine Learning:**
    * [cite_start]Desenvolvimento de modelos para prever o `Consumo`.
    * **Técnicas consideradas:** Modelos de Séries Temporais (ARIMA, SARIMA, Prophet) ou Modelos de Regressão (utilizando dados passados como features).
    * **Avaliação:** Os modelos serão avaliados com métricas de performance como RMSE (Raiz do Erro Quadrático Médio) e MAE (Erro Médio Absoluto).

3.  **Aplicação Interativa (Dashboard):**
    * Criação de um dashboard em **R/Shiny**.
    * A aplicação permitirá ao usuário visualizar os dados históricos, os resultados do modelo e as previsões de consumo futuro.

4.  **Artigo Científico:**
    * Redação do relatório final em formato de artigo científico (padrão IEEE), detalhando o problema, a metodologia, os resultados e as conclusões.

## 📁 Estrutura do Repositório

## 🚀 Como Executar a Aplicação Shiny

Para executar a aplicação interativa localmente:

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/GuiDDuran/Projeto-ML-2025.02.git
    cd https://github.com/GuiDDuran/Projeto-ML-2025.02.git/3_Shiny_App
    ```

2.  **Abra o RStudio** e defina o diretório de trabalho para a pasta `3_Shiny_App`.

3.  **Instale as dependências necessárias** (exemplo):
    ```R
    # Instale os pacotes se ainda não os tiver
    install.packages(c("shiny", "dplyr", "ggplot2", "forecast"))
    ```

4.  **Execute a aplicação:**
    ```R
    # Execute o aplicativo
    shiny::runApp()
    ```

## 👨‍💻 Integrantes

* João Gabriel de Castro Rodriguez
* Isabela Vieira
* Guilherme Duran Duran
* Gabriel Franklin Monteiro
