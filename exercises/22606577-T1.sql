/*
1.º Teste de SQL

Número de aluno: 22606577
Nome de aluno: Gonçalo Martins
Turma: Sem turma
Horário de realização do teste: 9:30
*/

/* =========================================================
   1. Identificação e metadados
   ========================================================= */

-- 1.1 Identificar todas as tabelas da base de dados/schema
SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;


-- 1.2 Duas tabelas fundamentais escolhidas:
-- production.products
-- production.categories
--
-- Listar campos, tipos, tamanhos e nulidade

SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'production'
  AND TABLE_NAME IN ('products', 'categories')
ORDER BY TABLE_NAME, ORDINAL_POSITION;


-- 1.3 Dependências
-- production.products depende de production.categories.
-- A coluna products.category_id é uma chave estrangeira que
-- referencia categories.category_id.

SELECT
    fk.name AS foreign_key,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) AS schema_origem,
    OBJECT_NAME(fk.parent_object_id) AS tabela_origem,
    COL_NAME(
        fkc.parent_object_id,
        fkc.parent_column_id
    ) AS coluna_origem,
    OBJECT_SCHEMA_NAME(fk.referenced_object_id) AS schema_destino,
    OBJECT_NAME(fk.referenced_object_id) AS tabela_destino,
    COL_NAME(
        fkc.referenced_object_id,
        fkc.referenced_column_id
    ) AS coluna_destino
FROM sys.foreign_keys AS fk
JOIN sys.foreign_key_columns AS fkc
    ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'products'
  AND OBJECT_NAME(fk.referenced_object_id) = 'categories';



/* =========================================================
   2. Consultas e operações básicas
   ========================================================= */

-- sales.customers.phone permite valores NULL.
-- São apresentados apenas clientes que têm telefone atribuído.
-- A ordenação usa last_name ASC e first_name DESC.

SELECT
    customer_id,
    first_name,
    last_name,
    phone
FROM sales.customers
WHERE phone IS NOT NULL
ORDER BY last_name ASC, first_name DESC;



/* =========================================================
   3. Operações de linha
   ========================================================= */

-- first_name é texto.
-- phone também é texto e pode ser NULL.
-- São usados os 3 primeiros caracteres de first_name
-- e o conteúdo completo de phone.
-- O resultado final é convertido para minúsculas.
-- Os campos originais são mantidos.

SELECT
    customer_id,
    first_name,
    phone,
    LOWER(LEFT(first_name, 3) + phone) AS valor_composto
FROM sales.customers
WHERE first_name IS NOT NULL
  AND phone IS NOT NULL
ORDER BY phone;



/* =========================================================
   4. Consultas formatadas
   ========================================================= */

-- category_id é o identificador numérico.
-- category_name é o classificador de texto.
-- O ID é apresentado com 3 posições e zeros à esquerda.

SELECT
    category_id,
    category_name,
    RIGHT(
        '000' + CAST(category_id AS varchar(3)),
        3
    ) + '-' + category_name AS identificador_unico
FROM production.categories
ORDER BY identificador_unico;



/* =========================================================
   5. Inserções e validação
   ========================================================= */

-- 5.1 Identificar tipos e obrigatoriedade das colunas
-- da tabela escolhida: sales.staffs

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'sales'
  AND TABLE_NAME = 'staffs'
ORDER BY ORDINAL_POSITION;


-- 5.2 Verificar primeiro que o identificador não existe

SELECT *
FROM sales.staffs
WHERE staff_id = 9999;


-- 5.3 Inserir o novo registo.
-- phone e manager_id são campos opcionais e não são preenchidos.

SET IDENTITY_INSERT sales.staffs ON;

INSERT INTO sales.staffs
(
    staff_id,
    first_name,
    last_name,
    email,
    active,
    store_id
)
VALUES
(
    9999,
    'Goncalo',
    'Martins',
    'teste22606577@ulht.pt',
    1,
    1
);

SET IDENTITY_INSERT sales.staffs OFF;


-- 5.4 Confirmar o registo inserido

SELECT *
FROM sales.staffs
WHERE staff_id = 9999;



/* =========================================================
   6. Uniformização de texto
   ========================================================= */

-- Converter city para minúsculas.
-- Atualizar apenas IDs dentro de um intervalo,
-- incluindo os limites.

UPDATE sales.customers
SET city = LOWER(city)
WHERE customer_id BETWEEN 1 AND 20;



/* =========================================================
   7. Tratamento de valores em falta
   ========================================================= */

-- phone permite valores NULL.
-- Apenas clientes cujo state pertence à lista indicada
-- e cujo customer_id está dentro do intervalo são alterados.

UPDATE sales.customers
SET phone = NULL
WHERE state IN ('CA', 'NY')
  AND customer_id BETWEEN 1 AND 1000;



/* =========================================================
   8. Construção de valores de texto
   ========================================================= */

-- Atualizar street utilizando:
-- prefixo 'cli-' +
-- quatro últimos caracteres de last_name em minúsculas.
--
-- Apenas registos dentro do intervalo escolhido
-- e com last_name suficientemente grande e não vazio.

UPDATE sales.customers
SET street = 'cli-' + LOWER(RIGHT(last_name, 4))
WHERE customer_id BETWEEN 1 AND 50
  AND last_name IS NOT NULL
  AND LEN(last_name) >= 4;



/* =========================================================
   9. Eliminação de registos
   ========================================================= */

-- 9.1 Identificar primeiro exatamente o registo a eliminar

SELECT *
FROM sales.staffs
WHERE staff_id = 9999;


-- 9.2 Eliminar apenas o registo inserido na pergunta 5

DELETE FROM sales.staffs
WHERE staff_id = 9999;


-- 9.3 Demonstrar que o registo já não existe

SELECT *
FROM sales.staffs
WHERE staff_id = 9999;


-- Confirmação adicional:
-- o resultado esperado é 0.

SELECT COUNT(*) AS registos_restantes
FROM sales.staffs
WHERE staff_id = 9999;