# CNPJ Cidades BR

O programa *CNPJ_Cidades*, em linguagem R, irá fundir todas as 10 (dez) bases de dados 'Estabelecimentos.zip' organizado pelo Ministério da Fazenda e atualizados mensalmento, disponível em:
https://dados.gov.br/dados/conjuntos-dados/cadastro-nacional-da-pessoa-juridica---cnpj  

O programa tem serventia para gestão da atividade empresarial das cidades brasileiras com empresas inscritas no Cadastro Nacional da Pessoa Jurídica (CNPJ). 

1) Baixe todas as 10 bases de dados 'Estabelecimentos.zip'
2) Baixe a o arquivo 'Cnaes.zip'
3) Execute o programa
4) O programa irá abrir uma caixa de dialogo - Carregue as 10 bases 'Estabelecimentos.zip'
5) Após o carregamente, o programa irá abrir uma nova caixa. Carregue 'Cnaes.zip'
6) Aguarde alguns minutos, devido o tamanho de todos os aquivos
7) Após executar, o programa irá solicitar o código do municipio que deseja. Consulte o código de cada município no arquivo 'Municipios.zip' da mesma base 
8) Digite o código e aguarde. Caso deseje os cnpj de todo o Brasil, digite: 'Brasil'. Caso o código da cidade esteja incorreto, o programa retornará um erro
9) O programa irá salvar um arquivo csv contendo os dados de todos os CNPJ do município ou de todo Brasil em seu diretório padrão
10) A base de dados é enriquecida com alguns cruzamento de dados:
 - CNPJ_Completo: 14 dígitos de cada cnpj encontrado, Matriz_filial: identificação matriz ou filial de cada cnpj.
 - SITUACAO_CADASTRA: Classificação em Ativa, Baixada, Inapta, Nula ou Suspensa. 
 - Data_SitCadastral_Padrao: Data da situação cadastral no formato dd/mm/aaaa.
 - Descritor_Motivo_SitCadastral: Decodifica o motivo da situaçã cadastral.
 - Data_inicio_padrao: converte a data para o formato dd/mm/aaaa.
 - Descritor_CNAE: Decodifica o código CNAE primário.
 - Atividade_Economica: Classifica a atividade economica da emrpesa segundo o código CNAE.
 - Endereco_Completo: Concatena todas informações do endereço da empresa.

Para visualização de dados execute:
- 'tabela_atv_economica' - tabela de distribuição frequência da atividade economica das empresas
- 'tabela_cnae' - tabela de distribuição de frequência dos CNAE das empresas
- 'tabela_sitcadastral' - tabela de distribuição de frequência da situação cadastral das empresas
- 'tabela_sitgeral' - tabela de frequência (dupla) entre situação cadastral e descritores do CNAE
- 'inicio_atividade()'  - grafico de evolução temporal do início de atividade de das empresas
  
*Desenvolvido por Rafael Gutierres Castanha*
*Contato - r.castanha@gmail.com*
*github.com/rafaelcastanha/cnpj_cidadesBR*
