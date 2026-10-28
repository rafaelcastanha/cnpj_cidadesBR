# CNPJ Cidades BR

O programa *CNPJ_CidadesBR*, em linguagem R, irá fundir todas as 10 (dez) bases de dados 'Estabelecimentos' organizadas pelo Ministério da Fazenda e atualizadas mensalmente, disponíveis em:
https://dados.gov.br/dados/conjuntos-dados/cadastro-nacional-da-pessoa-juridica---cnpj  

O programa tem serventia para gestão da atividade empresarial das cidades brasileiras com empresas inscritas no Cadastro Nacional da Pessoa Jurídica (CNPJ). 

## Como usar

1) Baixe as 10 bases de dados 'Estabelecimentos' (arquivos .zip, ou os arquivos .ESTABELE já descompactados; o programa aceita os dois)
2) Baixe o arquivo 'Cnaes.zip' ou utilize o arquivo 'CNAE.CNAECSV' deste repositório
3) Instale os pacotes necessários, se preciso: `install.packages("data.table")` e, para saída em Excel, `install.packages("openxlsx")`
4) Execute o programa `CNPJ_Cidades.R` (no RStudio ou no console do R)
5) O programa faz três perguntas, antes de ler os arquivos:
   - Formato do arquivo de saída: CSV (C) ou Excel (X)
   - Se deseja somente empresas ativas (S/N)
   - Código do município, ou 'Brasil'. Consulte o código de cada município no arquivo 'Municipios.zip' da mesma base ou utilize 'Municipios.txt' deste repositório
6) O programa abre uma caixa de diálogo - Carregue as 10 bases 'Estabelecimentos'
7) Em seguida, abre uma nova caixa - Carregue 'Cnaes.zip' ou 'CNAE.CNAECSV'
8) Aguarde alguns minutos, devido ao tamanho dos arquivos. Cada arquivo é filtrado assim que é lido, o que reduz o uso de memória
9) O programa salva o arquivo (CSV ou XLSX) no diretório de trabalho do R (`getwd()`) e informa o caminho

## Formato de saída

- **Excel (.xlsx)**: códigos e CNPJ ficam como texto (preserva os zeros à esquerda) e as datas ficam como datas (dd/mm/aaaa). Formato recomendado para municípios.
- **CSV**: separado por ponto e vírgula (;), UTF-8 com BOM. Ao abrir no Excel ou importar pelo Power Query, defina as colunas de código e CNPJ como **texto**; caso contrário, o Excel remove os zeros à esquerda.
- O Excel comporta no máximo 1.048.575 linhas. Acima disso, ou para 'Brasil', o programa grava CSV e avisa.
- Para 'Brasil' os dados são gravados em CSV arquivo por arquivo, sem montar tudo na memória. Nesse caso as tabelas e o gráfico abaixo não são gerados.
- O nome do arquivo segue o padrão `dados_cnpj_cidade_codigo_XXXX.csv|xlsx` (com `_ativas` ao final, quando o filtro de ativas é usado).

## Colunas

Todos os cabeçalhos da base são baseados nos metadados disponibilizados pelo Ministério da Fazenda e estão disponíveis em 'cnpj-metadados.pdf'. A base de dados é enriquecida com alguns cruzamentos de dados:

 - CNPJ_COMPLETO: 14 dígitos de cada CNPJ encontrado.
 - Matriz_Filial: identificação matriz ou filial de cada CNPJ.
 - SITUACAO_CADASTRAL: Classificação em Ativa, Baixada, Inapta, Nula ou Suspensa. 
 - Data_SitCadastral_Padrao: Data da situação cadastral no formato dd/mm/aaaa.
 - Descritor_Motivo_SitCadastral: Decodifica o motivo da situação cadastral.
 - Data_inicio_Padrao: converte a data de início de atividade para o formato dd/mm/aaaa.
 - Ano_Inicio: ano de início da atividade.
 - Descritor_CNAE: Decodifica o código CNAE primário.
 - Atividade_Economica: Classifica a atividade econômica da empresa segundo o código CNAE.
 - Endereco_Completo: Concatena as informações do endereço da empresa (partes vazias são omitidas).
 - Data_SitEspecial_Padrao: converte a data da situação especial para o formato dd/mm/aaaa.

## Visualização de dados

Para municípios (não disponível para 'Brasil'), execute:
- 'tabela_atv_economica' - tabela de distribuição frequência da atividade economica das empresas
- 'tabela_cnae' - tabela de distribuição de frequência dos CNAE das empresas
- 'tabela_sitcadastral' - tabela de distribuição de frequência da situação cadastral das empresas
- 'tabela_sitgeral' - tabela de frequência (dupla) entre situação cadastral e descritores do CNAE
- 'inicio_atividade()'  - grafico de evolução temporal do início de atividade de das empresas

O conjunto de dados 'Cadastro Nacional da Pessoa Jurídica - CNPJ' está sob licença Creative Commons Attribution.
  
*Desenvolvido por Rafael Gutierres Castanha*

*Contato - r.castanha@gmail.com*

*github.com/rafaelcastanha/cnpj_cidadesBR*
