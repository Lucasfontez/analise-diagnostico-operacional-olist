/*
Aplica PKs e índices após a carga. PKs apenas nas tabelas com identificador
único, as demais não têm chave natural. Índices nas colunas usadas em JOINs.
*/

-- Chaves primárias (só nas tabelas com identificador único real)
ALTER TABLE customers ADD PRIMARY KEY (customer_id);
ALTER TABLE orders ADD PRIMARY KEY (order_id);
ALTER TABLE products ADD PRIMARY KEY (product_id);
ALTER TABLE sellers ADD PRIMARY KEY (seller_id);
ALTER TABLE category_translation ADD PRIMARY KEY (product_category_name);

-- Índices nas colunas usadas nos JOINs.
-- Padrão de nome: idx_<tabela>_<referência>
CREATE INDEX idx_orders_cliente ON orders(customer_id);
CREATE INDEX idx_itens_pedido ON order_items(order_id);
CREATE INDEX idx_itens_produto ON order_items(product_id);
CREATE INDEX idx_itens_vendedor ON order_items(seller_id);
CREATE INDEX idx_pagamentos_pedido ON order_payments(order_id);
CREATE INDEX idx_avaliacoes_pedido ON order_reviews(order_id);
