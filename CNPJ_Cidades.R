{

############# Desenvolvido por Rafael Gutierres Castanha
############# Contato - r.castanha@gmail.com
############# github.com/rafaelcastanha/cnpj_cidadesBR


#Este programa se baseia nos dados do dataset 'Cadastro Nacional da Pessoa Jurídica - CNPJ'
# organizado pelo Ministério da Fazenda e disponível em:
# https://dados.gov.br/dados/conjuntos-dados/cadastro-nacional-da-pessoa-juridica---cnpj

#Este programa é capaz de fundir todas as 10 bases de dados 'Estabelecimentos'
#atualizadas mensalmente e disponíveis publicamente em:
#https://dadosabertos.rfb.gov.br/CNPJ/dados_abertos_cnpj/?C=N;O=D

#Passo a passo:

  # 1 - Baixe as 10 bases 'Estabelecimentos' (.zip, ou os arquivos .ESTABELE já extraídos)
  # 2 - Baixe o arquivo 'Cnaes.zip'
  # 3 - Execute o programa
  # 4 - O programa pergunta o formato de saída (CSV ou Excel), se deseja somente empresas ativas
  #     e o código do município. Consulte o arquivo 'Municipios.zip'. Para todo o Brasil, digite: Brasil
  # 5 - O programa abre uma caixa de diálogo - Carregue as 10 bases 'Estabelecimentos'
  # 6 - Em seguida, abre uma nova caixa. Carregue 'Cnaes.zip'
  # 7 - Aguarde alguns minutos, devido o tamanho dos arquivos
  # 8 - O programa salva o arquivo (CSV ou XLSX) no diretório de trabalho: getwd()
  # 9 - A base de dados é enriquecida com alguns cruzamentos de dados.

# Observações:
  # - XLSX mantém códigos e CNPJ como texto (preserva os zeros à esquerda) e as datas como datas.
  # - CSV é gravado com ';' e UTF-8 com BOM. Ao abrir no Excel (ou importar pelo Power Query),
  #   defina as colunas de código e CNPJ como TEXTO, ou o Excel remove os zeros à esquerda.
  # - Excel comporta no máximo 1.048.575 linhas. Acima disso (ou para 'Brasil') o programa grava CSV.
  # - Para 'Brasil' os dados são gravados arquivo a arquivo, sem montar tudo na memória.

#Para visualização de dados (não disponível para 'Brasil') execute:

# 'tabela_atv_economica' - tabela de frequência da atividade economica das empresas
# 'tabela_cnae' - tabela de frequência dos CNAE das empresas
# 'tabela_sitcadastral' - tabela de frequência da situação cadastral das empresas
# 'tabela_sitgeral' - tabela cruzada entre situação cadastral e descritores do CNAE
# 'inicio_atividade()'  - grafico de evolução temporal do início de atividade de das empresas

############# Desenvolvido por Rafael Gutierres Castanha
############# Contato - r.castanha@gmail.com
############# github.com/rafaelcastanha/cnpj_cidadesBR


############################################################################################

if (!interactive()) {
  stop("Este programa faz perguntas ao usuário. Execute-o no RStudio ou no console do R.")
}

### Perguntas iniciais (feitas antes de ler os arquivos, que é a etapa demorada)

perguntar <- function(mensagem, validar, erro) {
  repeat {
    resposta <- trimws(readline(mensagem))
    if (validar(resposta)) return(resposta)
    message(erro)
  }
}

formato <- perguntar("Formato do arquivo de saída - CSV (C) ou Excel (X)?: ",
                     function(r) toupper(r) %in% c("C", "X", "CSV", "XLSX"),
                     "Digite C (CSV) ou X (Excel).")
formato <- if (substr(toupper(formato), 1, 1) == "X") "xlsx" else "csv"

ativas <- perguntar("Deseja extrair somente informações de empresas ativas? (S/N): ",
                    function(r) toupper(r) %in% c("S", "N"),
                    "Digite S ou N.")
ativas <- toupper(ativas) == "S"

cidade <- perguntar("Digite o código do município (de 'Municipios.zip') ou 'Brasil': ",
                    function(r) grepl("^[0-9]{1,4}$", r) || tolower(r) == "brasil",
                    "Digite o código do município (até 4 dígitos) ou 'Brasil'.")
brasil <- tolower(cidade) == "brasil"

if (brasil && formato == "xlsx") {
  message("Todo o Brasil não cabe em uma planilha Excel. O arquivo será gravado em CSV.")
  formato <- "csv"
}

pacotes <- c("data.table", if (formato == "xlsx") "openxlsx")
faltando <- pacotes[!vapply(pacotes, requireNamespace, logical(1), quietly = TRUE)]
if (length(faltando) > 0) {
  stop("Instale o(s) pacote(s) necessário(s): install.packages(c(",
       paste0("'", faltando, "'", collapse = ", "), "))")
}
# Silencia apenas o banner e o aviso de versão do data.table (os demais avisos continuam visíveis)
suppressWarnings(suppressPackageStartupMessages(library(data.table)))

############################################################################################

### Estrutura dos dados

nomes_originais <- c("CNPJ_BASICO", "CNPJ_ORDEM", "CNPJ_DV", "IDENTIFICADOR_MATRIZ_FILIAL",
                     "NOME_FANTASIA", "COD_SITUACAO_CADASTRAL", "DATA_SITUACAO_CADASTRAL",
                     "MOTIVO_SITUACAO_CADASTRAL", "NOME_DA_CIDADE_NO_EXTERIOR", "PAIS",
                     "DATA_DE_INICIO_ATIVIDADE", "CNAE_FISCAL_PRINCIPAL", "CNAE_FISCAL_SECUNDARIA",
                     "TIPO_DE_LOGRADOURO", "LOGRADOURO", "NUMERO", "COMPLEMENTO", "BAIRRO",
                     "CEP", "UF", "MUNICIPIO", "DDD_1", "TELEFONE_1", "DDD_2",
                     "TELEFONE_2", "DDD_DO_FAX", "FAX", "CORREIO_ELETRONICO",
                     "SITUACAO_ESPECIAL", "DATA_DA_SITUACAO_ESPECIAL")

colunas_data <- c("Data_SitCadastral_Padrao", "Data_inicio_Padrao", "Data_SitEspecial_Padrao")

### Tabelas de conversão

matriz_filial <- c("1" = "Matriz", "2" = "Filial")

situacao_cadastral <- c("01" = "NULA", "02" = "ATIVA", "03" = "SUSPENSA",
                        "04" = "INAPTA", "08" = "BAIXADA")

motivos <- c(
  "00" = "SEM MOTIVO",
  "01" = "EXTINCAO POR ENCERRAMENTO LIQUIDACAO VOLUNTARIA",
  "02" = "INCORPORACAO",
  "03" = "FUSAO",
  "04" = "CISAO TOTAL",
  "05" = "ENCERRAMENTO DA FALENCIA",
  "06" = "ENCERRAMENTO DA LIQUIDACAO",
  "07" = "ELEVACAO A MATRIZ",
  "08" = "TRANSPASSE",
  "09" = "NAO INICIO DE ATIVIDADE",
  "10" = "EXTINCAO PELO ENCERRAMENTO DA LIQUIDACAO JUDICIAL",
  "11" = "ANULACAO POR MULTIPLICIDADE",
  "12" = "ANULACAO ONLINE DE OFICIO",
  "13" = "OMISSA CONTUMAZ",
  "14" = "OMISSA NAO LOCALIZADA",
  "15" = "INEXISTENCIA DE FATO",
  "16" = "ANULACAO POR VICIOS",
  "17" = "BAIXA INICIADA EM ANALISE",
  "18" = "INTERRUPCAO TEMPORARIA DAS ATIVIDADES",
  "21" = "PEDIDO DE BAIXA INDEFERIDA",
  "24" = "POR EMISSAO CERTIDAO NEGATIVA",
  "28" = "TRANSFERENCIA FILIAL CONDICAO MATRIZ",
  "31" = "EXTINCAO-UNIFICACAO DA FILIAL",
  "33" = "TRANSFERENCIA DO ORGAO LOCAL A CONDICAO DE FILIAL DO ORGAO REGIONAL",
  "34" = "ANULACAO DE INSCRICAO INDEVIDA",
  "35" = "EMPRESA ESTRANGEIRA AGUARDANDO DOCUMENTACAO",
  "36" = "PRATICA IRREGULAR DE OPERACAO DE COMERCIO EXTERIOR",
  "37" = "BAIXA DE PRODUTOR RURAL",
  "38" = "BAIXA DEFERIDA PELA RFB AGUARDANDO ANALISE DO CONVENENTE",
  "39" = "BAIXA DEFERIDA PELA RFB E INDEFERIDA PELO CONVENENTE",
  "40" = "BAIXA INDEFERIDA PELA RFB E AGUARDANDO ANALISE DO CONVENENTE",
  "41" = "BAIXA INDEFERIDA PELA RFB E DEFERIDA PELO CONVENENTE",
  "42" = "BAIXA DEFERIDA PELA RFB E SEFIN, AGUARDANDO ANALISE SEFAZ",
  "43" = "BAIXA DEFERIDA PELA RFB, AGUARDANDO ANALISE DA SEFAZ E INDEFERIDA PELA SEFIN",
  "44" = "BAIXA DEFERIDA PELA RFB E SEFAZ, AGUARDANDO ANALISE SEFIN",
  "45" = "BAIXA DEFERIDA PELA RFB, AGUARDANDO ANALISE DA SEFIN E INDEFERIDA PELA SEFAZ",
  "46" = "BAIXA DEFERIDA PELA RFB E SEFAZ E INDEFERIDA PELA SEFIN",
  "47" = "BAIXA DEFERIDA PELA RFB E SEFIN E INDEFERIDA PELA SEFAZ",
  "48" = "BAIXA INDEFERIDA PELA RFB, AGUARDANDO ANALISE SEFAZ E DEFERIDA PELA SEFIN",
  "49" = "BAIXA INDEFERIDA PELA RFB, AGUARDANDO ANALISE DA SEFAZ E INDEFERIDA PELA SEFIN",
  "50" = "BAIXA INDEFERIDA PELA RFB, DEFERIDA PELA SEFAZ E AGUARDANDO ANALISE DA SEFIN",
  "51" = "BAIXA INDEFERIDA PELA RFB E SEFAZ, AGUARDANDO ANALISE DA SEFIN",
  "52" = "BAIXA INDEFERIDA PELA RFB, DEFERIDA PELA SEFAZ E INDEFERIDA PELA SEFIN",
  "53" = "BAIXA INDEFERIDA PELA RFB E SEFAZ E DEFERIDA PELA SEFIN",
  "54" = "EXTINCAO - TRATAMENTO DIFERENCIADO DADO AS ME E EPP (LEI COMPLEMENTAR NUMERO 123/2006)",
  "55" = "DEFERIDO PELO CONVENENTE, AGUARDANDO ANALISE DA RFB",
  "60" = "ARTIGO 30, VI, DA IN 748/2007",
  "61" = "INDICIO INTERPOS. FRAUDULENTA",
  "62" = "FALTA DE PLURALIDADE DE SOCIOS",
  "63" = "OMISSAO DE DECLARACOES",
  "64" = "LOCALIZACAO DESCONHECIDA",
  "66" = "INAPTIDAO",
  "67" = "REGISTRO CANCELADO",
  "70" = "ANULACAO POR NAO CONFIRMADO ATO DE REGISTRO DO MEI NA JUNTA COMERCIAL",
  "71" = "INAPTIDAO (LEI 11.941/2009 ART.54)",
  "72" = "DETERMINACAO JUDICIAL",
  "73" = "OMISSAO CONTUMAZ",
  "74" = "INCONSISTENCIA CADASTRAL",
  "75" = "OBITO DO MEI - TITULAR FALECIDO",
  "80" = "BAIXA REGISTRADA NA JUNTA, INDEFERIDA NA RFB",
  "82" = "SUSPENSO PERANTE A COMISSAO DE VALORES MOBILIARIOS - CVM"
)

# Atividade econômica pelos 2 primeiros dígitos do CNAE (divisão)

divisoes <- list(
  "AGRICULTURA, PECUÁRIA, PRODUÇÃO FLORESTAL, PESCA E AQÜICULTURA" = 1:3,
  "INDÚSTRIAS EXTRATIVAS" = 5:9,
  "INDÚSTRIAS DE TRANSFORMAÇÃO" = 10:33,
  "ELETRICIDADE E GÁS" = 35,
  "ÁGUA, ESGOTO, ATIVIDADES DE GESTÃO DE RESÍDUOS E DESCONTAMINAÇÃO" = 36:39,
  "CONSTRUÇÃO" = 41:43,
  "COMÉRCIO - REPARAÇÃO DE VEÍCULOS AUTOMOTORES E MOTOCICLETAS" = 45:47,
  "TRANSPORTE, ARMAZENAGEM E CORREIO" = 49:53,
  "ALOJAMENTO E ALIMENTAÇÃO" = 55:56,
  "INFORMAÇÃO E COMUNICAÇÃO" = 58:63,
  "ATIVIDADES FINANCEIRAS, DE SEGUROS E SERVIÇOS RELACIONADOS" = 64:66,
  "ATIVIDADES IMOBILIÁRIAS" = 68,
  "ATIVIDADES PROFISSIONAIS, CIENTÍFICAS E TÉCNICAS" = 69:75,
  "ATIVIDADES ADMINISTRATIVAS E SERVIÇOS COMPLEMENTARES" = 77:82,
  "ADMINISTRAÇÃO PÚBLICA, DEFESA E SEGURIDADE SOCIAL" = 84,
  "EDUCAÇÃO" = 85,
  "SAÚDE HUMANA E SERVIÇOS SOCIAIS" = 86:88,
  "ARTES, CULTURA, ESPORTE E RECREAÇÃO" = 90:93,
  "OUTRAS ATIVIDADES DE SERVIÇOS" = 94:96,
  "SERVIÇOS DOMÉSTICOS" = 97,
  "ORGANISMOS INTERNACIONAIS E OUTRAS INSTITUIÇÕES EXTRATERRITORIAIS" = 99
)

atividades <- setNames(rep(names(divisoes), lengths(divisoes)),
                       sprintf("%02d", unlist(divisoes)))

############################################################################################

### Funções auxiliares

# Completa com zeros à esquerda (mantém NA)
zeros <- function(x, n) {
  ifelse(is.na(x), NA_character_, paste0(strrep("0", pmax(n - nchar(x), 0L)), x))
}

# Pedaço do endereço seguido de ", ". Partes vazias são omitidas
sufixo <- function(x, prefixo = "") {
  ifelse(is.na(x) | x == "", "", paste0(prefixo, x, ", "))
}

# Seleciona arquivos. Windows: caixa de diálogo; outros sistemas: caminhos digitados
selecionar_arquivos <- function(mensagem, multi = FALSE) {
  message(mensagem)
  if (.Platform$OS.type == "windows") {
    arquivos <- choose.files(multi = multi)
  } else {
    resposta <- readline("Digite o(s) caminho(s) completo(s), separados por ';': ")
    arquivos <- trimws(strsplit(resposta, ";")[[1]])
  }
  if (length(arquivos) == 0 || all(is.na(arquivos) | arquivos == "")) {
    stop("Nenhum arquivo foi selecionado. Reinicie o programa.")
  }
  if (!all(file.exists(arquivos))) {
    stop("Arquivo não encontrado: ", paste(arquivos[!file.exists(arquivos)], collapse = ", "))
  }
  arquivos
}

# Se o arquivo for .zip, extrai para uma pasta temporária
extrair_se_zip <- function(arquivo) {
  if (grepl("\\.zip$", arquivo, ignore.case = TRUE)) {
    pasta <- tempfile("cnpj_")
    dir.create(pasta)
    list(caminhos = unzip(arquivo, exdir = pasta), pasta = pasta)
  } else {
    list(caminhos = arquivo, pasta = NULL)
  }
}

# Leitura dos arquivos da Receita: ';', aspas, sem cabeçalho, Latin-1, tudo como texto
ler_csv_receita <- function(caminho) {
  fread(caminho, sep = ";", header = FALSE, colClasses = "character",
        encoding = "Latin-1", na.strings = NULL, showProgress = FALSE)
}

# Converte texto para UTF-8 e campos vazios para NA
limpar_texto <- function(d) {
  for (j in names(d)) {
    valores <- enc2utf8(d[[j]])
    valores[valores == ""] <- NA_character_
    set(d, j = j, value = valores)
  }
  d
}

# Monta o data.table final (41 colunas) a partir dos dados de Estabelecimentos
montar_saida <- function(d, cnae) {

  basico <- zeros(d$CNPJ_BASICO, 8)
  ordem <- zeros(d$CNPJ_ORDEM, 4)
  dv <- zeros(d$CNPJ_DV, 2)
  cod_sit <- zeros(d$COD_SITUACAO_CADASTRAL, 2)
  cod_motivo <- zeros(d$MOTIVO_SITUACAO_CADASTRAL, 2)
  cnae_principal <- zeros(d$CNAE_FISCAL_PRINCIPAL, 7)

  data_sit <- as.Date(d$DATA_SITUACAO_CADASTRAL, format = "%Y%m%d")
  data_inicio <- as.Date(d$DATA_DE_INICIO_ATIVIDADE, format = "%Y%m%d")
  data_sit_esp <- as.Date(d$DATA_DA_SITUACAO_ESPECIAL, format = "%Y%m%d")

  logradouro_completo <- trimws(paste(ifelse(is.na(d$TIPO_DE_LOGRADOURO), "", d$TIPO_DE_LOGRADOURO),
                                      ifelse(is.na(d$LOGRADOURO), "", d$LOGRADOURO)))
  endereco <- sub(", $", "", paste0(sufixo(logradouro_completo), sufixo(d$NUMERO),
                                    sufixo(d$COMPLEMENTO), sufixo(d$BAIRRO),
                                    sufixo(d$CEP, "CEP: ")))
  endereco[endereco == ""] <- NA_character_

  data.table(
    CNPJ_BASICO = basico,
    CNPJ_ORDEM = ordem,
    CNPJ_DV = dv,
    CNPJ_COMPLETO = paste0(basico, ordem, dv),
    IDENTIFICADOR_MATRIZ_FILIAL = d$IDENTIFICADOR_MATRIZ_FILIAL,
    Matriz_Filial = unname(matriz_filial[d$IDENTIFICADOR_MATRIZ_FILIAL]),
    NOME_FANTASIA = d$NOME_FANTASIA,
    COD_SITUACAO_CADASTRAL = cod_sit,
    SITUACAO_CADASTRAL = unname(situacao_cadastral[cod_sit]),
    DATA_SITUACAO_CADASTRAL = d$DATA_SITUACAO_CADASTRAL,
    Data_SitCadastral_Padrao = data_sit,
    MOTIVO_SITUACAO_CADASTRAL = cod_motivo,
    Descritor_Motivo_SitCadastral = unname(motivos[cod_motivo]),
    NOME_DA_CIDADE_NO_EXTERIOR = d$NOME_DA_CIDADE_NO_EXTERIOR,
    PAIS = d$PAIS,
    DATA_DE_INICIO_ATIVIDADE = d$DATA_DE_INICIO_ATIVIDADE,
    Data_inicio_Padrao = data_inicio,
    Ano_Inicio = as.integer(format(data_inicio, "%Y")),
    CNAE_FISCAL_PRINCIPAL = cnae_principal,
    Descritor_CNAE = cnae$Descritor_CNAE[match(cnae_principal, cnae$CNAE_FISCAL_PRINCIPAL)],
    Atividade_Economica = unname(atividades[substr(cnae_principal, 1, 2)]),
    CNAE_Secundaria = d$CNAE_FISCAL_SECUNDARIA,
    TIPO_DE_LOGRADOURO = d$TIPO_DE_LOGRADOURO,
    LOGRADOURO = d$LOGRADOURO,
    NUMERO = d$NUMERO,
    COMPLEMENTO = d$COMPLEMENTO,
    BAIRRO = d$BAIRRO,
    CEP = d$CEP,
    UF = d$UF,
    Endereco_Completo = endereco,
    Cod_Municipio = d$MUNICIPIO,
    DDD_1 = d$DDD_1,
    TELEFONE_1 = d$TELEFONE_1,
    DDD_2 = d$DDD_2,
    TELEFONE_2 = d$TELEFONE_2,
    DDD_DO_FAX = d$DDD_DO_FAX,
    FAX = d$FAX,
    CORREIO_ELETRONICO = d$CORREIO_ELETRONICO,
    SITUACAO_ESPECIAL = d$SITUACAO_ESPECIAL,
    DATA_DA_SITUACAO_ESPECIAL = d$DATA_DA_SITUACAO_ESPECIAL,
    Data_SitEspecial_Padrao = data_sit_esp
  )
}

# No CSV as datas são gravadas como dd/mm/aaaa
datas_para_texto <- function(dt) {
  dt <- copy(dt)
  for (j in colunas_data) set(dt, j = j, value = format(dt[[j]], "%d/%m/%Y"))
  dt
}

# Grava CSV (';', UTF-8 com BOM). Com primeira = FALSE acrescenta ao arquivo existente
gravar_csv <- function(dt, arquivo, primeira = TRUE) {
  if (primeira) {
    con <- file(arquivo, "wb")
    writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), con)
    close(con)
  }
  fwrite(datas_para_texto(dt), arquivo, sep = ";", na = "", append = TRUE, col.names = primeira)
}

gravar_xlsx <- function(dt, arquivo) {
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "Completo")
  openxlsx::writeData(wb, "Completo", dt, withFilter = TRUE)
  openxlsx::addStyle(wb, "Completo", openxlsx::createStyle(numFmt = "dd/mm/yyyy"),
                     rows = 2:(nrow(dt) + 1), cols = match(colunas_data, names(dt)),
                     gridExpand = TRUE)
  openxlsx::freezePane(wb, "Completo", firstRow = TRUE)
  openxlsx::saveWorkbook(wb, arquivo, overwrite = TRUE)
}

############################################################################################

# Seleção dos arquivos

arquivos <- selecionar_arquivos("Selecione as bases de 'Estabelecimentos' que irão compor o arquivo final", multi = TRUE)

# Leitura do arquivo que contém os descritores dos CNAES. Arquivo Cnaes.zip

arquivo_cnae <- selecionar_arquivos("Selecione o arquivo com os códigos CNAE - Classificação Nacional de Atividades Econômicas")

message("Lendo arquivos...Aguarde")

extraido <- extrair_se_zip(arquivo_cnae)
cnae <- ler_csv_receita(extraido$caminhos[1])
if (!is.null(extraido$pasta)) unlink(extraido$pasta, recursive = TRUE)

cnae <- limpar_texto(cnae[, 1:2])
setnames(cnae, c("CNAE_FISCAL_PRINCIPAL", "Descritor_CNAE"))
cnae[, CNAE_FISCAL_PRINCIPAL := zeros(CNAE_FISCAL_PRINCIPAL, 7)]

# Nome do arquivo de saída

nome_base <- paste0("dados_cnpj_", if (brasil) "brasil" else paste0("cidade_codigo_", zeros(cidade, 4)),
                    if (ativas) "_ativas" else "")
arquivo_saida <- file.path(getwd(), paste0(nome_base, ".", formato))

if (!brasil) cidade <- zeros(cidade, 4)

############################################################################################

# Fusão de todos os arquivos 'Estabelecimentos'. Cada arquivo é filtrado assim que é lido,
# para não carregar na memória os dados de outros municípios

if (brasil) {
  message("Os dados de todos os CNPJ do Brasil estão sendo fundidos. Esta operação é demorada.")
  if (file.exists(arquivo_saida)) file.remove(arquivo_saida)
} else {
  message("Os dados de CNPJ da cidade de código ", cidade, " estão sendo combinados. Esta operação é demorada.")
}

partes <- list()
total <- 0L
primeira <- TRUE

for (k in seq_along(arquivos)) {

  extraido <- extrair_se_zip(arquivos[k])

  for (caminho in extraido$caminhos) {

    d <- ler_csv_receita(caminho)

    if (ncol(d) != length(nomes_originais)) {
      stop("O arquivo ", basename(caminho), " tem ", ncol(d), " colunas, mas eram esperadas ",
           length(nomes_originais), ". Verifique se é um arquivo 'Estabelecimentos'.")
    }
    setnames(d, nomes_originais)

    if (!brasil) d <- d[MUNICIPIO == cidade]
    if (ativas) d <- d[COD_SITUACAO_CADASTRAL %in% c("02", "2")]

    message(sprintf("[%d/%d] %s - %s registros selecionados", k, length(arquivos),
                    basename(caminho), format(nrow(d), big.mark = ".", decimal.mark = ",")))

    if (nrow(d) > 0) {

      parte <- montar_saida(limpar_texto(d), cnae)
      total <- total + nrow(parte)

      if (brasil) {
        gravar_csv(parte, arquivo_saida, primeira)
        primeira <- FALSE
      } else {
        partes[[length(partes) + 1]] <- parte
      }
    }

    rm(d)
    invisible(gc())
  }

  if (!is.null(extraido$pasta)) unlink(extraido$pasta, recursive = TRUE)
}

if (total == 0) {
  stop("Não há registros para o código desta cidade. Possivelmente o código da cidade foi digitado incorretamente. Reinicie o programa.")
}

############################################################################################

# Gravação do arquivo final

if (!brasil) {

  df_final <- rbindlist(partes)
  rm(partes)

  if (formato == "xlsx" && nrow(df_final) > 1048575) {
    message("Há mais linhas do que o Excel comporta. O arquivo será gravado em CSV.")
    formato <- "csv"
    arquivo_saida <- file.path(getwd(), paste0(nome_base, ".csv"))
  }

  if (formato == "xlsx") {
    gravar_xlsx(df_final, arquivo_saida)
  } else {
    gravar_csv(df_final, arquivo_saida)
  }
}

message("Os dados foram combinados corretamente e foram salvos em: ", arquivo_saida)

############################################################################################

#Visualização de dados

if (!brasil) {

  tabela_atv_economica <- table(df_final$Atividade_Economica)

  tabela_cnae <- table(df_final$Descritor_CNAE)

  inicio_atividade <- function() {
    contagem <- table(df_final$Ano_Inicio)
    return(barplot(contagem, ylim = c(0, 1.1 * max(contagem)), las = 2))
  }

  tabela_sitcadastral <- table(df_final$SITUACAO_CADASTRAL)

  tabela_sitgeral <- t(as.data.frame.matrix(table(df_final$SITUACAO_CADASTRAL, df_final$Descritor_CNAE)))

} else {
  message("As tabelas e o gráfico de visualização não são gerados para 'Brasil'. Leia o CSV gravado para analisá-lo.")
}

}
