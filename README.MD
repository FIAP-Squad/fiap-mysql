### Migração do MongoDB em EKS para MySQL no RDS para a API

<div style="text-align: justify">Esta seção documenta a migração da tecnologia de armazenamento de dados da API. A mudança substitui o paradigma NoSQL, utilizando MongoDB hospedado em um cluster EKS, por um modelo relacional com MySQL no Amazon RDS.</div>

#### Motivação
<div style="text-align: justify">Embora o EKS seja uma tecnologia poderosa para desenvolvimento de aplicações em nuvem, ele apresenta desvantagens para a gestão de dados, tais como:</div>

* Complexidade na gestão: Requer conhecimento especializado em Kubernetes para orquestração, segurança e replicação de instâncias, demandando mais tempo e expertise da equipe.
* Custos potencialmente elevados: A falta de dimensionamento preciso, especialmente em momentos de pico de demanda, pode gerar custos significativos para a aplicação.
* Alta demanda por configurações manuais: Garantir a tolerância a falhas exige configurações manuais complexas, aumentando a carga de trabalho da equipe.

<div style="text-align: justify">A migração para um banco de dados hospedado no RDS oferece diversas vantagens. O serviço abstrai a gestão de infraestrutura, backups, replicação, monitoramento e ajuste de performance. Além disso, permite a implementação de instâncias otimizadas para diferentes cargas de trabalho, simplificando o gerenciamento e otimizando o desempenho.</div>

#### Escolha do MySQL

<div style="text-align: justify">O MySQL destaca-se como uma das tecnologias de banco de dados mais populares e maduras do mercado, contando com ampla comunidade colaborativa e suporte técnico. Sua performance em workloads intensivos de leitura o torna uma escolha natural para aplicações web com alta demanda.
A sintaxe simples e intuitiva do MySQL contribui para uma curva de aprendizado rápida, reduzindo a necessidade de treinamentos especializados para a equipe.</div>

#### Design e Projeto do Banco

<div style="text-align: justify">O banco de dados fiap-api foi projetado para armazenar e gerenciar informações relacionadas a um sistema de pedidos. Sua estrutura, definida pelo script SQL apresentado, demonstra atenção à organização, performance e segurança dos dados.</div>

<div style="text-align: justify">O banco de dados é composto por sete entidades principais: account, product, order, orderdet, payment, paymentdet, e suas respectivas tabelas de log: account_log, product_log, e order_log.</div>

<p align="center">
  <img src="./public/fiap-api-db-er.png" alt="Diagrama ER do Banco de dados">
</p>

* account: armazena informações sobre os clientes, como nome, CGC, email e senha (criptografada).
* product: contém detalhes sobre os produtos, incluindo nome e preço unitário.
* order: registra os pedidos realizados, incluindo status, data de criação, cliente associado, valor total, data de fechamento e status de pagamento.
* orderdet: detalhes dos itens de cada pedido, relacionando produtos e quantidades.
* payment: informações sobre os pagamentos, como data, desconto total, valor bruto, valor líquido e pedido associado.
* paymentdet: detalha cada pagamento, incluindo sinal, tipo, método de pagamento e valor.
* _log: são tabelas de uso do banco armazenado versões de dados, alimentada através de triggers.