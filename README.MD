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

<div style="text-align: justify">O banco de dados é composto por sete entidades principais: account, product, order, orderdet, payment e paymentdet.</div>

<p align="center">
  <img src="./public/fiap-api-db-er.png" alt="Diagrama ER do Banco de dados">
</p>

**account**: armazena informações sobre os clientes, como nome, CGC, email e senha (criptografada).

_name_:<br>
Tipo: varchar(191)<br>
Descrição: Nome completo do usuário.<br>
Restrições: Não pode ser nulo.<br>
_cpf_:<br>
Tipo: varchar(191)<br>
Descrição: CPF (Cadastro de Pessoa Física) do usuário.
Restrições: Não pode ser nulo.<br>
_email_:<br>
Tipo: varchar(191)<br>
Descrição: Endereço de email do usuário.<br>
Restrições: Não pode ser nulo. Deve ser único na tabela.<br>
_password_:<br>
Tipo: varchar(191)<br>
Descrição: Senha do usuário (armazenada de forma segura, idealmente com hash e salt).<br>
Restrições: Não pode ser nulo.<br>
_accessToken_:<br>
Tipo: varchar(191)<br>
Descrição: Token de acesso usado para autenticar o usuário na API.<br>
Restrições: Pode ser nulo.<br>
_role_:<br>
Tipo: varchar(191)<br>
Descrição: Papel/permissão do usuário na aplicação (ex: "admin", "user", "editor").<br>
Restrições: Pode ser nulo.<br>

**product**: contém detalhes sobre os produtos, incluindo nome e preço unitário.

_category_:<br>
Tipo: varchar(191)<br>
Descrição: Categoria do produto (ex: "Eletrônicos", "Roupas", "Livros").<br>
Restrições: Não pode ser nulo.<br>
_name_:<br>
Tipo: varchar(191)<br>
Descrição: Nome do produto.<br>
Restrições: Não pode ser nulo.<br>
_price_:<br>
Tipo: int(11)<br>
Descrição: Preço do produto, em centavos (ex: 1999 para R$ 19,99).<br>
Restrições: Não pode ser nulo.<br>
_description_:<br>
Tipo: varchar(191)<br>
Descrição: Descrição detalhada do produto.<br>
Restrições: Não pode ser nulo.<br>
_image_:<br>
Tipo: varchar(191)<br>
Descrição: URL ou caminho para a imagem do produto.<br>
Restrições: Não pode ser nulo.<br>

**order**: registra os pedidos realizados, incluindo status, data de criação, cliente associado, valor total, data de fechamento e status de pagamento.

_number_:<br>
Tipo: int(11)<br>
Descrição: Número de identificação do pedido.<br>
Restrições: Pode ser nulo, o que sugere que a numeração do pedido pode ser gerada ou atribuída posteriormente.<br>
_customer_:<br>
Tipo: varchar(191)<br>
Descrição: Identificador do cliente que realizou o pedido. Assumindo a estrutura do banco, provavelmente referencia o id da tabela account.<br>
Restrições: Não pode ser nulo.<br>
_status_:<br>
Tipo: varchar(191)<br>
Descrição: Status atual do pedido (ex: "Pendente", "Processando", "Enviado", "Entregue", "Cancelado").
Restrições: Não pode ser nulo.<br>
_amount_:<br>
Tipo: int(11)<br>
Descrição: Valor total do pedido, em centavos (ex: 2999 para R$ 29,99).<br>
Restrições: Não pode ser nulo.<br>

**orderdet**: detalhes dos itens de cada pedido, relacionando produtos e quantidades.

_totalItems_:<br>
Tipo: int(11)<br>
Descrição: Quantidade total do item específico no pedido.<br>
Restrições: Não pode ser nulo.<br>
_unitPrice_:<br>
Tipo: int(11)<br>
Descrição: Preço unitário do item no momento da compra, em centavos.<br>
Restrições: Não pode ser nulo.<br>
_amount_:<br>
Tipo: int(11)<br>
Descrição: Valor total do item no pedido (quantidade x preço unitário), em centavos.<br>
Restrições: Não pode ser nulo.<br>
_orderId_:<br>
Tipo: varchar(191)<br>
Descrição: Identificador do pedido ao qual o item pertence. É uma chave estrangeira que referencia a coluna id da tabela order.<br>
Restrições: Não pode ser nulo. A restrição orderItem_orderId_fkey garante a integridade referencial com a tabela order, atualizando em cascata caso o id do pedido seja modificado.<br>
_productId_:<br>
Tipo: varchar(191)<br>
Descrição: Identificador do produto que compõe o item do pedido. É uma chave estrangeira que referencia a coluna id da tabela product.<br>
Restrições: Não pode ser nulo. A restrição orderItem_productId_fkey garante a integridade referencial com a tabela product, atualizando em cascata caso o id do produto seja modificado.<br>

**erros**: informações de erros da aplicação.
