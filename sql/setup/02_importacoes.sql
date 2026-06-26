/*
Carga de importação dos 9 csvs do Olist via COPY nativo do PostgreSQL.

Usei o COPY em vez do wizard de importação do DBeaver porque o wizard
desalinhava tabelas com texto livre (order_reviews, orders), gerando registros
corrompidos. O COPY respeita campos entre aspas com vírgula e quebra de linha.

OBS: Para que não ocorra erro de restrições na hora de importar os arquivos,
é necessario ativar a permissão de leitura ao serviço do Postgres na pasta 
dos csvs no gerenciador de aquivos.
*/

-- Exemplo da importação diretamente da minha máquina.

COPY customers FROM 'C:/PROJETOS/ecommerce-profitability-analysis/assets/olist_customers_dataset.csv'
    WITH (FORMAT csv, HEADER true, QUOTE '"', ENCODING 'UTF8');

COPY geolocation FROM 'C:/PROJETOS/ecommerce-profitability-analysis/assets/olist_geolocation_dataset.csv'
    WITH (FORMAT csv, HEADER true, QUOTE '"', ENCODING 'UTF8');

COPY orders FROM 'C:/PROJETOS/ecommerce-profitability-analysis/assets/olist_orders_dataset.csv'
    WITH (FORMAT csv, HEADER true, QUOTE '"', ENCODING 'UTF8');

COPY order_items FROM 'C:/PROJETOS/ecommerce-profitability-analysis/assets/olist_order_items_dataset.csv'
    WITH (FORMAT csv, HEADER true, QUOTE '"', ENCODING 'UTF8');

COPY order_payments FROM 'C:/PROJETOS/ecommerce-profitability-analysis/assets/olist_order_payments_dataset.csv'
    WITH (FORMAT csv, HEADER true, QUOTE '"', ENCODING 'UTF8');

COPY order_reviews FROM 'C:/PROJETOS/ecommerce-profitability-analysis/assets/olist_order_reviews_dataset.csv'
    WITH (FORMAT csv, HEADER true, QUOTE '"', ENCODING 'UTF8');

COPY products FROM 'C:/PROJETOS/ecommerce-profitability-analysis/assets/olist_products_dataset.csv'
    WITH (FORMAT csv, HEADER true, QUOTE '"', ENCODING 'UTF8');

COPY sellers FROM 'C:/PROJETOS/ecommerce-profitability-analysis/assets/olist_sellers_dataset.csv'
    WITH (FORMAT csv, HEADER true, QUOTE '"', ENCODING 'UTF8');

COPY category_translation FROM 'C:/PROJETOS/ecommerce-profitability-analysis/assets/product_category_name_translation.csv'
    WITH (FORMAT csv, HEADER true, QUOTE '"', ENCODING 'UTF8');
