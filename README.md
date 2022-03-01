# harpya

[![No Maintenance Intended](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)
[![Fork](https://img.shields.io/github/forks/takusuman/harpya?style=social)](https://github.com/takusuman/harpya/fork)
[![Domínio Público](https://upload.wikimedia.org/wikipedia/commons/8/84/Public_Domain_Mark_button.svg)](./LICENCE.txt)  

Web scrapper para o sistema digital da ANCINE, feito em Korn Shell 93.  
Foi criado para solucionar um problema, que era buscar registros de uma
determinada produtora na consulta pública da ANCINE pelo S.A.D (Sistema ANCINE
Digital).  
  
**Note for non-brazilians**: This program probably won't be useful
if you're outside Brazil and/or don't work with the audiovisual
environment.

## Como usar?

Para fazer uma busca com o Harpya, você deve informar ao programa três
informações: nome da produtora, unidade federativa (em formato de sigla) e
número de páginas que você quer fazer scrapping.  

Então, vamos supor, hipoteticamente falando, que eu queira pesquisar por todos
as obras registradas enquanto projetos na ANCINE da produtora Pindorama no
estado do Rio de Janeiro nas 300 primeiras páginas da consulta digital:  

```console
ksh harpya.ksh -N 'Pindorama Filmes' -E RJ -s 300
```

O número máximo de páginas servidas pela consulta digital da ANCINE até o dia de
hoje (1 de março de 2022) é 601, após isso você recebe apenas, como esperado,
erros 404.  

Caso o programa encontre algo nessas páginas, ele vai enviar os resultados para
o arquivo `eureka.txt`, na raiz do projeto (um diretório com o nome da produtora
e a data de acesso (`'Nome da Produtora_YYYY-mm-dd-HH.MM.SS'`)); em formato de
matriz --- o que pode ajudar posteriormente, por mais que o Harpya não tenha a
capacidade de processar os separadores das tabelas em HTML e tenham espaçamentos
desnecessários entre as palavras (isso é mais uma "limitação" do Lynx em si na
prática).  

```
text/ConsultaProjetosAudiovisuais.do.XXX.txt: Nome da Produção/Projeto NOME DA PRODUTORA YYYYYY UF
## Sinopse
XXX = Número da página encontrada
YYYYYY = Número SALIC
```

## Dependências

- Korn Shell 93 da AT&T (`ksh93`);
- Ferramentas padrões do UNIX;
- GNU `grep` e `realpath`;
- cURL;
- Lynx.

## *Bugs*

- É lento, mas *muito*, **muito**, ***muito*** lento comparado a um scrapper com
  *concurrency* escrito em Go, por exemplo --- por mais que ainda assim seja
muito mais rápido do que pesquisar manualmente;
- O log é bem incompleto, muita coisa que deveria estar lá (ex.: *verbosing* do
  Lynx na hora de parsear HTML em texto puro) não está;
- O código não está tão bem documentado como eu gostaria que estivesse (e para
  meus padrões como desenvolvedor), é um mero *hack* em Shell;
- E, pelo motivo acima, eu acabei também não criando uma função `print_help()`,
  como faço de costume;
- Suporta apenas scrapping no site da ANCINE, afinal não fiz pensando num
  scrapper universal no momento, como eu disse anteriormente.

Eu não pretendo continuar mantendo esse script, logo, caso você queira fazer
alguma mudança ou consertar alguma falha, forque-o o quanto quiser.  

Uma boa referência para programação em Korn Shell 93 é o livro da O'Reilly
"Learning the Korn Shell 2nd edition", que pode ser encontrado num site
ucraniano ou comprado direto da O'Reilly.  
Divirta-se!

## Licença

Domínio Público.
