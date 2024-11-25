{
  
############# Desenvolvido por Rafael Gutierres Castanha
############# Contato - r.castanha@gmail.com
############# github.com/rafaelcastanha/CNPJ_Cidades
  
  
#Este programa se baseia nos dados do dataset 'Cadastro Nacional da Pessoa Jurídica - CNPJ'
# organizado pelo Ministério da Fazenda e disponível em:
# https://dados.gov.br/dados/conjuntos-dados/cadastro-nacional-da-pessoa-juridica---cnpj  

#Este programa irá fundir todas as 10 (dez) bases de dados 'Estabelecimentos.zip'
#atualizadas mensalmente e disponíveis publicamente em:
#https://dadosabertos.rfb.gov.br/CNPJ/dados_abertos_cnpj/?C=N;O=D
  
#Passo a passo:

  # 1 - Baixe todas as 10 bases de dados 'Estabelecimentos.zip'
  # 2 - Baixe a o arquivo 'Cnaes.zip'
  # 3 - Execute o programa
  # 4 - O programa irá abrir uma caixa de dialogo - Carregue as 10 bases 'Estabelecimentos.zip'
  # 5 - Após o carregamente, o programa irá abrir uma nova caixa. Carregue 'Cnaes.zip'
  # 6 - Aguarde alguns minutos, devido o tamanho de todos os aquivos
  # 7 - Após executar, o programa irá solicitar o código do municipio que deseja. Consulte o arquivo 'Municipios.zip'
  # 8 - Digite o código e aguarde. Caso deseje os cnpj de todo o Brasil, digite: Brasil. Caso o código da cidade esteja incorreto, o programa retornará um erro
  # 9 - O programa irá salvar um arquivo csv contendo os dados de todos os CNPJ do município ou de todo Brasil em seu diretório padrão
  # 10 - A base de dados é enriquecida com alguns cruzamento de dados.
  
############# Desenvolvido por Rafael Gutierres Castanha
############# Contato - r.castanha@gmail.com
############# github.com/rafaelcastanha/CNPJ_Cidades
  

############################################################################################  
        
  
#Instale a biblioteca se necessário
#install.packages('dplyr')
  
library(dplyr)

# Faça o dowload e carregue todos arquivos 'Estabelecimentos.zip' 
# de https://dadosabertos.rfb.gov.br/CNPJ/dados_abertos_cnpj/?C=N;O=D  

suppressWarnings({
  
    
corpus<-choose.files(multi = T) #seleciona os arquivos da base de dados 

# Leitura do arquivo que contém os descritores dos CNAES. Arquivo Cnaes.zip

cnae<-read.csv(file.choose(), sep=";", header = F,colClasses = "character")

# Ajuste dos descritores CNAE

colnames(cnae)[1]<-"CNAE_FISCAL_PRINCIPAL"
colnames(cnae)[2]<-"Descritor_CNAE"

cnae_2<-cnae
colnames(cnae_2)[1]<-"CNAE_FISCAL_SECUNDARIA"
colnames(cnae_2)[2]<-"Descritor_CNAE_2"

#Fusão de todos arquivos 'Estabelecimentos.zip'

if (length(corpus)==1){

df<-read.csv(corpus, header = F, sep=";", colClasses = "character")    
  
} else {

 
df<-data.frame()

for (i in corpus){

extract<-read.csv(i, header = F, sep=";", colClasses = "character")

df<-rbind(df, extract)

}
}
#Ajustes de cabeçalhos

colnames(df)<-c("CNPJ_BASICO", "CNPJ_ORDEM", "CNPJ_DV", "IDENTIFICADOR_MATRIZ_FILIAL", 
                "NOME_FANTASIA", "COD_SITUACAO_CADASTRAL", "DATA_SITUACAO_CADASTRAL", 
                "MOTIVO_SITUACAO_CADASTRAL", "NOME_DA_CIDADE_NO_EXTERIOR", "PAIS", 
                "DATA_DE_INICIO_ATIVIDADE", "CNAE_FISCAL_PRINCIPAL", "CNAE_FISCAL_SECUNDARIA", 
                "TIPO_DE_LOGRADOURO", "LOGRADOURO", "NUMERO", "COMPLEMENTO", "BAIRRO", 
                "CEP", "UF", "MUNICIPIO", "DDD_1", "TELEFONE_1", "DDD_2", 
                "TELEFONE_2", "DDD_DO_FAX", "FAX", "CORREIO_ELETRONICO", 
                "SITUACAO_ESPECIAL", "DATA_DA_SITUACAO_ESPECIAL")

#Seleciona a cidade de interesse segundo o código da cidade
#Consulte o arquivo 'Municipios.zip'

cidade<-readline("Digite o código da cidade que deseja os dados das empresas: ")

if (cidade == 'Brasil'){
  df_sc<-df

  } else {

df_sc<-unique(df[df$MUNICIPIO==cidade, ])

  }

if (all(is.na(df_sc))==TRUE){
  stop("Não há registros para o código desta cidade. Possivelmente o código da cidade ou 'Brasil' foi digitado incorretamente. Reinicie o programa.")

} else{

if(cidade=="Brasil"){     
   print("Aguarde enquanto os dados de todos CNPJ do Brasil estão sendo fundidos. Está operação é demorada.")}
else{
  print(paste0("Os dados de CNPJ da cidade de código ",cidade," estão sendo combinados. Esta operação é demorada." ))
} }


### Ajuste do CNPJ

remove(df, extract)

### looping para ajuste do CNPJ Básico

basico<-c()
cnpj_b<-c()

for (i in 1:dim(df_sc)[1]){
  
  if(is.na(df_sc[i,1])){
    cnpj_b<-df_sc[i,1]
  }
  
  if (!is.na(df_sc[i,1]) && nchar(df_sc[i,1])==8){
    cnpj_b<-df_sc[i,1]
  } 
  
  if (!is.na(df_sc[i,1]) && nchar(df_sc[i,1])==1){
    cnpj_b<-paste0("0000000",df_sc[i,1])
  }
  
  if (!is.na(df_sc[i,1]) && nchar(df_sc[i,1])==2){
    cnpj_b<-paste0("000000",df_sc[i,1])
  }
  
  if (!is.na(df_sc[i,1]) && nchar(df_sc[i,1])==3){
    cnpj_b<-paste0("00000",df_sc[i,1])
  }
  
  if (!is.na(df_sc[i,1]) && nchar(df_sc[i,1])==4){
    cnpj_b<-paste0("0000",df_sc[i,1])
  }
  
  if (!is.na(df_sc[i,1]) && nchar(df_sc[i,1])==5){
    cnpj_b<-paste0("000",df_sc[i,1])
  }
  
  if (!is.na(df_sc[i,1]) && nchar(df_sc[i,1])==6){
    cnpj_b<-paste0("00",df_sc[i,1])
  }
  
  if (!is.na(df_sc[i,1]) && nchar(df_sc[i,1])==7){
    cnpj_b<-paste0("0",df_sc[i,1])
  }
  
basico<-append(basico, cnpj_b)  
  
}


#### looping para ajuste do Ordem do CNPJ (DV)

ordem<-c()
cnpj_o<-c()

for (i in 1:dim(df_sc)[1]){
  
  if(is.na(df_sc[i,2])){
    cnpj_o<-df_sc[i,2]
  }
  
  if (!is.na(df_sc[i,2]) && nchar(df_sc[i,2])==4){
    cnpj_o<-df_sc[i,2]
  }
  
  if (!is.na(df_sc[i,2]) && nchar(df_sc[i,2])==1){
    cnpj_o<-paste0("000",df_sc[i,2])
  }
  
  if (!is.na(df_sc[i,2]) && nchar(df_sc[i,2])==2){
    cnpj_o<-paste0("00",df_sc[i,2])
  }
  
  if (!is.na(df_sc[i,2]) && nchar(df_sc[i,2])==3){
    cnpj_o<-paste0("0",df_sc[i,2])
  }
  
  ordem<-append(ordem, cnpj_o)  
  
}

#### looping para ajuste do Digito Verificador (DV)

dv<-c()
cnpj_dv<-c()

for (i in 1:dim(df_sc)[1]){
  
  if(is.na(df_sc[i,3])){
    cnpj_dv<-df_sc[i,3]
  }
  
  if (!is.na(df_sc[i,3]) && nchar(df_sc[i,3])==2){
    cnpj_dv<-df_sc[i,3]
  }
  
  if (!is.na(df_sc[i,3]) && nchar(df_sc[i,3])==1){
    cnpj_dv<-paste0("0",df_sc[i,3])
  }
  
  dv<-append(dv, cnpj_dv)  
  
}

### Concatena CNPJ Completo com 14 digitos

cnpj_completo<-c()

for (i in 1:dim(df_sc)[1]){
  
  cnpj_completo[i]<-paste0(basico[i],ordem[i],dv[i])
  
}

### Ajuste do endereco completo

end<-c()

for (i in 1:dim(df_sc)[1]){
  
  end[i]<-paste0(df_sc[i,14]," ",df_sc[i,15],", ",df_sc[i,16], ", ", df_sc[i,17],
                 ", ", df_sc[i,18],", CEP: ", df_sc[i,19])
}

### Ajuste matriz e filial

mtz_filial<-gsub("2", "Filial", df_sc$IDENTIFICADOR_MATRIZ_FILIAL)
mtz_filial_2<-gsub("1", "Matriz", mtz_filial)

### Ajuste situação cadastral

sit_cad<-gsub("01", "NULA", df_sc$COD_SITUACAO_CADASTRAL)
sit_cad_1<-gsub("02", "ATIVA", sit_cad)
sit_cad_2<-gsub("2", "ATIVA", sit_cad_1)
sit_cad_3<-gsub("3", "SUSPENSA", sit_cad_2)
sit_cad_4<-gsub("4", "INAPTA", sit_cad_3)
sit_cad_5<-gsub("08", "BAIXADA", sit_cad_4)
sit_cad_6<-gsub("8", "BAIXADA", sit_cad_5)
sit_cad_7<-gsub("1", "NULA", sit_cad_6)


### Ajuste data de inicio

data_inicio<-format(as.Date(as.character(df_sc$DATA_DE_INICIO_ATIVIDADE), format="%Y%m%d"),"%d/%m/%Y")

### Extrai ano de inicio

ano_inicio<-substr(as.character(df_sc$DATA_DE_INICIO_ATIVIDADE), 1, 4)

### Ajusta data sit. cadastral

data_sit<-format(as.Date(as.character(df_sc$DATA_SITUACAO_CADASTRAL), format="%Y%m%d"),"%d/%m/%Y")

### Ajusta data sit. especial

data_sit_esp<-format(as.Date(as.character(df_sc$DATA_DA_SITUACAO_ESPECIAL), format="%Y%m%d"),"%d/%m/%Y")

### Ajusta sit. Especial

motivo_sit <- ' "00";"SEM MOTIVO"
"01";"EXTINCAO POR ENCERRAMENTO LIQUIDACAO VOLUNTARIA"
"02";"INCORPORACAO"
"03";"FUSAO"
"04";"CISAO TOTAL"
"05";"ENCERRAMENTO DA FALENCIA"
"06";"ENCERRAMENTO DA LIQUIDACAO"
"07";"ELEVACAO A MATRIZ"
"08";"TRANSPASSE"
"09";"NAO INICIO DE ATIVIDADE"
"0";"SEM MOTIVO"
"1";"EXTINCAO POR ENCERRAMENTO LIQUIDACAO VOLUNTARIA"
"2";"INCORPORACAO"
"3";"FUSAO"
"4";"CISAO TOTAL"
"5";"ENCERRAMENTO DA FALENCIA"
"6";"ENCERRAMENTO DA LIQUIDACAO"
"7";"ELEVACAO A MATRIZ"
"8";"TRANSPASSE"
"9";"NAO INICIO DE ATIVIDADE"
"10";"EXTINCAO PELO ENCERRAMENTO DA LIQUIDACAO JUDICIAL"
"11";"ANULACAO POR MULTICIPLIDADE"
"12";"ANULACAO ONLINE DE OFICIO"
"13";"OMISSA CONTUMAZ"
"14";"OMISSA NAO LOCALIZADA"
"15";"INEXISTENCIA DE FATO"
"16";"ANULACAO POR VICIOS"
"17";"BAIXA INICIADA EM ANALISE"
"18";"INTERRUPCAO TEMPORARIA DAS ATIVIDADES"
"21";"PEDIDO DE BAIXA INDEFERIDA"
"24";"POR EMISSAO CERTIDAO NEGATIVA"
"28";"TRANSFERENCIA FILIAL CONDICAO MATRIZ"
"31";"EXTINCAO-UNIFICACAO DA FILIAL"
"33";"TRANSFERENCIA DO ORGAO LOCAL A CONDICAO DE FILIAL DO ORGAO REGIONAL"
"34";"ANULACAO DE INSCRICAO INDEVIDA"
"35";"EMPRESA ESTRANGEIRA AGUARDANDO DOCUMENTACAO"
"36";"PRATICA IRREGULAR DE OPERACAO DE COMERCIO EXTERIOR"
"37";"BAIXA DE PRODUTOR RURAL"
"38";"BAIXA DEFERIDA PELA RFB AGUARDANDO ANALISE DO CONVENENTE"
"39";"BAIXA DEFERIDA PELA RFB E INDEFERIDA PELO CONVENENTE"
"40";"BAIXA INDEFERIDA PELA RFB E AGUARDANDO ANALISE DO CONVENENTE"
"41";"BAIXA INDEFERIDA PELA RFB E DEFERIDA PELO CONVENENTE"
"42";"BAIXA DEFERIDA PELA RFB E SEFIN, AGUARDANDO ANALISE SEFAZ"
"43";"BAIXA DEFERIDA PELA RFB, AGUARDANDO ANALISE DA SEFAZ E INDEFERIDA PELA SEFIN"
"44";"BAIXA DEFERIDA PELA RFB E SEFAZ, AGUARDANDO ANALISE SEFIN"
"45";"BAIXA DEFERIDA PELA RFB, AGUARDANDO ANALISE DA SEFIN E INDEFERIDA PELA SEFAZ"
"46";"BAIXA DEFERIDA PELA RFB E SEFAZ E INDEFERIDA PELA SEFIN"
"47";"BAIXA DEFERIDA PELA RFB E SEFIN E INDEFERIDA PELA SEFAZ"
"48";"BAIXA INDEFERIDA PELA RFB, AGARDANDO ANALISE SEFAZ E DEFERIDA PELA SEFIN"
"49";"BAIXA INDEFERIDA PELA RFB, AGUARDANDO ANALISE DA SEFAZ E INDEFERIDA PELA SEFIN"
"50";"BAIXA INDEFERIDA PELA RFB, DEFERIDA PELA SEFAZ E AGUARDANDO ANALISE DA SEFIN"
"51";"BAIXA INDEFERIDA PELA RFB E SEFAZ, AGUARDANDO ANALISE DA SEFIN"
"52";"BAIXA INDEFERIDA PELA RFB, DEFERIDA PELA SEFAZ E INDEFERIDA PELA SEFIN"
"53";"BAIXA INDEFERIDA PELA RFB E SEFAZ E DEFERIDA PELA SEFIN"
"54";"EXTINCAO - TRATAMENTO DIFERENCIADO DADO AS ME E EPP (LEI COMPLEMENTAR NUMERO 123/2006)"
"55";"DEFERIDO PELO CONVENENTE, AGUARDANDO ANALISE DA RFB"
"60";"ARTIGO 30, VI, DA IN 748/2007"
"61";"INDICIO INTERPOS. FRAUDULENTA"
"62";"FALTA DE PLURALIDADE DE SOCIOS"
"63";"OMISSAO DE DECLARACOES"
"64";"LOCALIZACAO DESCONHECIDA"
"66";"INAPTIDAO"
"67";"REGISTRO CANCELADO"
"70";"ANULACAO POR NAO CONFIRMADO ATO DE REGISTRO DO MEI NA JUNTA COMERCIAL"
"71";"INAPTIDAO (LEI 11.941/2009 ART.54)"
"72";"DETERMINACAO JUDICIAL"
"73";"OMISSAO CONTUMAZ"
"74";"INCONSISTENCIA CADASTRAL"
"75";"OBITO DO MEI - TITULAR FALECIDO"
"80";"BAIXA REGISTRADA NA JUNTA, INDEFERIDA NA RFB"
"82";"SUSPENSO PERANTE A COMISSAO DE VALORES MOBILIARIOS - CVM"'

linhas <- unlist(strsplit(motivo_sit, "\n"))
dados <- do.call(rbind, strsplit(linhas, ";"))
dados <- gsub('"', '', dados)
mapa <- setNames(dados[, 2], dados[, 1])
motivo_sit_cad<- mapa[as.character(df_sc$MOTIVO_SITUACAO_CADASTRAL)]

#### Atividade economica

atv_eco<-'"01";"AGRICULTURA, PECUÁRIA, PRODUÇÃO FLORESTAL, PESCA E AQÜICULTURA"
"02";"AGRICULTURA, PECUÁRIA, PRODUÇÃO FLORESTAL, PESCA E AQÜICULTURA"
"03";"AGRICULTURA, PECUÁRIA, PRODUÇÃO FLORESTAL, PESCA E AQÜICULTURA"
"05";"INDÚSTRIAS EXTRATIVAS"
"06";"INDÚSTRIAS EXTRATIVAS"
"07";"INDÚSTRIAS EXTRATIVAS"
"08";"INDÚSTRIAS EXTRATIVAS"
"09";"INDÚSTRIAS EXTRATIVAS"
"10";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"11";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"12";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"13";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"14";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"15";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"16";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"17";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"18";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"19";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"20";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"21";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"22";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"23";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"24";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"25";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"26";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"27";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"28";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"29";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"30";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"31";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"32";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"33";"INDÚSTRIAS DE TRANSFORMAÇÃO"
"35";"ELETRICIDADE E GÁS"
"36";"ÁGUA, ESGOTO, ATIVIDADES DE GESTÃO DE RESÍDUOS E DESCONTAMINAÇÃO"
"37";"ÁGUA, ESGOTO, ATIVIDADES DE GESTÃO DE RESÍDUOS E DESCONTAMINAÇÃO"
"38";"ÁGUA, ESGOTO, ATIVIDADES DE GESTÃO DE RESÍDUOS E DESCONTAMINAÇÃO"
"39";"ÁGUA, ESGOTO, ATIVIDADES DE GESTÃO DE RESÍDUOS E DESCONTAMINAÇÃO"
"41";"CONSTRUÇÃO"
"42";"CONSTRUÇÃO"
"43";"CONSTRUÇÃO"
"45";"COMÉRCIO - REPARAÇÃO DE VEÍCULOS AUTOMOTORES E MOTOCICLETAS"
"46";"COMÉRCIO- REPARAÇÃO DE VEÍCULOS AUTOMOTORES E MOTOCICLETAS"
"47";"COMÉRCIO- REPARAÇÃO DE VEÍCULOS AUTOMOTORES E MOTOCICLETAS"
"49";"TRANSPORTE, ARMAZENAGEM E CORREIO"
"50";"TRANSPORTE, ARMAZENAGEM E CORREIO"
"51";"TRANSPORTE, ARMAZENAGEM E CORREIO"
"52";"TRANSPORTE, ARMAZENAGEM E CORREIO"
"53";"TRANSPORTE, ARMAZENAGEM E CORREIO"
"55";"ALOJAMENTO E ALIMENTAÇÃO"
"56";"ALOJAMENTO E ALIMENTAÇÃO"
"58";"INFORMAÇÃO E COMUNICAÇÃO"
"59";"INFORMAÇÃO E COMUNICAÇÃO"
"60";"INFORMAÇÃO E COMUNICAÇÃO"
"61";"INFORMAÇÃO E COMUNICAÇÃO"
"62";"INFORMAÇÃO E COMUNICAÇÃO"
"63";"INFORMAÇÃO E COMUNICAÇÃO"
"64";"ATIVIDADES FINANCEIRAS, DE SEGUROS E SERVIÇOS RELACIONADOS"
"65";"ATIVIDADES FINANCEIRAS, DE SEGUROS E SERVIÇOS RELACIONADOS"
"66";"ATIVIDADES FINANCEIRAS, DE SEGUROS E SERVIÇOS RELACIONADOS"
"68";"ATIVIDADES IMOBILIÁRIAS"
"69";"ATIVIDADES PROFISSIONAIS, CIENTÍFICAS E TÉCNICAS"
"70";"ATIVIDADES PROFISSIONAIS, CIENTÍFICAS E TÉCNICAS"
"71";"ATIVIDADES PROFISSIONAIS, CIENTÍFICAS E TÉCNICAS"
"72";"ATIVIDADES PROFISSIONAIS, CIENTÍFICAS E TÉCNICAS"
"73";"ATIVIDADES PROFISSIONAIS, CIENTÍFICAS E TÉCNICAS"
"74";"ATIVIDADES PROFISSIONAIS, CIENTÍFICAS E TÉCNICAS"
"75";"ATIVIDADES PROFISSIONAIS, CIENTÍFICAS E TÉCNICAS"
"77";"ATIVIDADES ADMINISTRATIVAS E SERVIÇOS COMPLEMENTARES"
"78";"ATIVIDADES ADMINISTRATIVAS E SERVIÇOS COMPLEMENTARES"
"79";"ATIVIDADES ADMINISTRATIVAS E SERVIÇOS COMPLEMENTARES"
"80";"ATIVIDADES ADMINISTRATIVAS E SERVIÇOS COMPLEMENTARES"
"81";"ATIVIDADES ADMINISTRATIVAS E SERVIÇOS COMPLEMENTARES"
"82";"ATIVIDADES ADMINISTRATIVAS E SERVIÇOS COMPLEMENTARES"
"84";"ADMINISTRAÇÃO PÚBLICA, DEFESA E SEGURIDADE SOCIAL"
"85";"EDUCAÇÃO"
"86";"SAÚDE HUMANA E SERVIÇOS SOCIAIS"
"87";"SAÚDE HUMANA E SERVIÇOS SOCIAIS"
"88";"SAÚDE HUMANA E SERVIÇOS SOCIAIS"
"90";"ARTES, CULTURA, ESPORTE E RECREAÇÃO"
"91";"ARTES, CULTURA, ESPORTE E RECREAÇÃO"
"92";"ARTES, CULTURA, ESPORTE E RECREAÇÃO"
"93";"ARTES, CULTURA, ESPORTE E RECREAÇÃO"
"94";"OUTRAS ATIVIDADES DE SERVIÇOS"
"95";"OUTRAS ATIVIDADES DE SERVIÇOS"
"96";"OUTRAS ATIVIDADES DE SERVIÇOS"
"97";"SERVIÇOS DOMÉSTICOS"
"99";"ORGANISMOS INTERNACIONAIS E OUTRAS INSTITUIÇÕES EXTRATERRITORIAIS"'

linhas1 <- unlist(strsplit(atv_eco, "\n"))
dados1 <- do.call(rbind, strsplit(linhas1, ";"))
dados1 <- gsub('"', '', dados1)
mapa1 <- setNames(dados1[, 2], dados1[, 1])
atividade_economica<- mapa1[as.character(substr(df_sc$CNAE_FISCAL_PRINCIPAL, 1, 2))]

### Novo dataframe

df_sc_total<-data.frame(df_sc$CNPJ_BASICO,df_sc$CNPJ_ORDEM,df_sc$CNPJ_DV,
                        cnpj_completo ,df_sc$IDENTIFICADOR_MATRIZ_FILIAL,mtz_filial_2,
                        df_sc$NOME_FANTASIA, df_sc$COD_SITUACAO_CADASTRAL,
                        sit_cad_6,df_sc$DATA_SITUACAO_CADASTRAL,data_sit,
                        df_sc$MOTIVO_SITUACAO_CADASTRAL,motivo_sit_cad, df_sc$NOME_DA_CIDADE_NO_EXTERIOR,
                        df_sc$PAIS, df_sc$DATA_DE_INICIO_ATIVIDADE,data_inicio,ano_inicio,
                        df_sc$CNAE_FISCAL_PRINCIPAL, atividade_economica,
                        df_sc$CNAE_FISCAL_SECUNDARIA,df_sc$TIPO_DE_LOGRADOURO,
                        df_sc$LOGRADOURO, df_sc$NUMERO, df_sc$COMPLEMENTO, df_sc$BAIRRO,
                        df_sc$CEP, df_sc$UF,end,df_sc$DDD_1, df_sc$TELEFONE_1,
                        df_sc$DDD_2, df_sc$TELEFONE_2, df_sc$DDD_DO_FAX, df_sc$FAX,
                        df_sc$CORREIO_ELETRONICO, df_sc$SITUACAO_ESPECIAL, df_sc$DATA_DA_SITUACAO_ESPECIAL,
                        data_sit_esp)

colnames(df_sc_total)<-c("CNPJ_BASICO", "CNPJ_ORDEM", "CNPJ_DV",
                         "CNPJ_COMPLETO", "IDENTIFICADOR_MATRIZ_FILIAL", "Matriz_Filial",
                         "NOME_FANTASIA", "COD_SITUACAO_CADASTRAL","SITUACAO_CADASTRAL", 
                         "DATA_SITUACAO_CADASTRAL","Data_SitCadastral_Padrao","MOTIVO_SITUACAO_CADASTRAL", 
                         "Descritor_Motivo_SitCadastral","NOME_DA_CIDADE_NO_EXTERIOR",
                         "PAIS", "DATA_DE_INICIO_ATIVIDADE","Data_inicio_Padrao","Ano_Inicio", 
                         "CNAE_FISCAL_PRINCIPAL", "Atividade_Economica",
                         "CNAE_Secundaria","TIPO_DE_LOGRADOURO",
                         "LOGRADOURO", "NUMERO", "COMPLEMENTO", "BAIRRO",
                         "CEP", "UF", "Endereco_Completo", "DDD_1", "TELEFONE_1",
                         "DDD_2", "TELEFONE_2", "DDD_DO_FAX", "FAX",
                         "CORREIO_ELETRONICO", "SITUACAO_ESPECIAL", "DATA_DA_SITUACAO_ESPECIAL",
                         "Data_SitEspecial_Padrao")

### Merge CNAE principal

remove(df_sc)

cnae_merge<-merge(df_sc_total, cnae, by = "CNAE_FISCAL_PRINCIPAL", all.x = TRUE)

remove(df_sc_total)

#Organização final do daframe

df_final <- cnae_merge %>%
  select("CNPJ_BASICO", "CNPJ_ORDEM", "CNPJ_DV",
         "CNPJ_COMPLETO", "IDENTIFICADOR_MATRIZ_FILIAL","Matriz_Filial",
         "NOME_FANTASIA", "COD_SITUACAO_CADASTRAL","SITUACAO_CADASTRAL", "DATA_SITUACAO_CADASTRAL",
         "Data_SitCadastral_Padrao", "MOTIVO_SITUACAO_CADASTRAL","Descritor_Motivo_SitCadastral" ,"NOME_DA_CIDADE_NO_EXTERIOR",
         "PAIS", "DATA_DE_INICIO_ATIVIDADE","Data_inicio_Padrao","Ano_Inicio",
         "CNAE_FISCAL_PRINCIPAL", "Descritor_CNAE","Atividade_Economica",
         "CNAE_Secundaria","TIPO_DE_LOGRADOURO", "LOGRADOURO", "NUMERO", "COMPLEMENTO", "BAIRRO",
         "CEP", "UF", "Endereco_Completo", "DDD_1", "TELEFONE_1",
         "DDD_2", "TELEFONE_2", "DDD_DO_FAX", "FAX",
         "CORREIO_ELETRONICO", "SITUACAO_ESPECIAL", "DATA_DA_SITUACAO_ESPECIAL", "Data_SitEspecial_Padrao")

df_final[df_final==""]<-NA

remove(cnae_merge)

write.csv(df_final, paste0("dados_cnpj_","cidade_codigo_",cidade,".csv"), sep=";", row.names = F, col.names = T,fileEncoding = "UTF-8")

print("Os dados foram combinados corretamente e foram salvos em seu diretório padrão")

})

}
