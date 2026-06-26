/*
Agrupamento de tabela "de/para" que liga cada UF (estado) à sua região do Brasil.
Motivo: A análise por estado mostrou que estados com poucos pedidos geravam
nota média instável. Agrupar em 5 regiões dá uma amostra mais robusta e melhora a
visualização final.
*/

CREATE TABLE regioes (
    uf CHAR(2) PRIMARY KEY,
    regiao TEXT NOT NULL
);

INSERT INTO regioes (uf, regiao)
VALUES
    ('AC', 'Norte'),
    ('AP', 'Norte'),
    ('AM', 'Norte'),
    ('PA', 'Norte'),
    ('RO', 'Norte'),
    ('RR', 'Norte'),
    ('TO', 'Norte'),
    ('AL', 'Nordeste'),
    ('BA', 'Nordeste'),
    ('CE', 'Nordeste'),
    ('MA', 'Nordeste'),
    ('PB', 'Nordeste'),
    ('PE', 'Nordeste'),
    ('PI', 'Nordeste'),
    ('RN', 'Nordeste'),
    ('SE', 'Nordeste'),
    ('DF', 'Centro-Oeste'),
    ('GO', 'Centro-Oeste'),
    ('MT', 'Centro-Oeste'),
    ('MS', 'Centro-Oeste'),
    ('ES', 'Sudeste'),
    ('MG', 'Sudeste'),
    ('RJ', 'Sudeste'),
    ('SP', 'Sudeste'),
    ('PR', 'Sul'),
    ('RS', 'Sul'),
    ('SC', 'Sul');
