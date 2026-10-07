# Instale os pacotes uma única vez, se ainda não estiverem instalados:
# install.packages(c("httr", "jsonlite"))

library(httr)
library(jsonlite)

# Endereço da página que fornece os dados da tabela
url <- "https://www.scrapethissite.com/pages/ajax-javascript/"

# Anos disponíveis na página
anos <- 2010:2015

# Lista para armazenar os dados de cada ano
lista_filmes <- list()

# Percorre os anos e solicita os dados ao site
for (ano in anos) {

  resposta <- GET(
    url,
    query = list(
      ajax = "true",
      year = ano
    )
  )

  # Interrompe o código se houver erro na requisição
  stop_for_status(resposta)

  # Lê a resposta JSON
  conteudo <- content(resposta, as = "text", encoding = "UTF-8")
  filmes_ano <- fromJSON(conteudo, simplifyVector = FALSE)

  # Converte os registros do ano em uma tabela
  tabela_ano <- do.call(
    rbind,
    lapply(filmes_ano, function(filme) {
      data.frame(
        titulo = trimws(filme$title),
        ano = filme$year,
        indicacoes = filme$nominations,
        premios = filme$awards,
        melhor_filme = if (is.null(filme$best_picture)) {
          "Não"
        } else {
          "Sim"
        },
        stringsAsFactors = FALSE
      )
    })
  )

  lista_filmes[[as.character(ano)]] <- tabela_ano
}

# Junta os dados de todos os anos em uma única tabela
tabela_oscar <- do.call(rbind, lista_filmes)

# Reinicia a numeração das linhas
rownames(tabela_oscar) <- NULL

# Exibe a tabela
View(tabela_oscar)

# Mostra as primeiras linhas no console
head(tabela_oscar)

# Salva a tabela em um arquivo CSV
write.csv(
  tabela_oscar,
  "filmes_oscar_scrapethissite.csv",
  row.names = FALSE,
  fileEncoding = "UTF-8"
)