SELECT
  e.uuid,
  c.uuid AS empresa_uuid,
  CASE
    WHEN c.razao_social ~ ' \d{11}$' THEN LEFT(c.razao_social, -12)
    ELSE c.razao_social
  END AS razao_social,
  c.codigo_natureza_juridica,
  c.codigo_qualificacao_responsavel,
  c.capital_social,
  c.codigo_porte,
  c.ente_responsavel_uf,
  c.ente_responsavel_codigo_municipio,
  e.cnpj,
  e.matriz,
  e.nome_fantasia,
  e.codigo_situacao_cadastral,
  e.data_situacao_cadastral,
  e.codigo_motivo_situacao_cadastral,
  e.cidade_exterior,
  e.codigo_pais,
  e.data_inicio_atividade,
  e.cnae_principal,
  e.cnae_secundaria,
  CASE
    WHEN s.opcao_mei OR c.codigo_natureza_juridica IN (2135, 2305, 2313, 4014, 4081) THEN NULL
    ELSE e.tipo_logradouro
  END AS tipo_logradouro,
  CASE
    WHEN s.opcao_mei OR c.codigo_natureza_juridica IN (2135, 2305, 2313, 4014, 4081) THEN NULL
    ELSE e.logradouro
  END AS logradouro,
  CASE
    WHEN s.opcao_mei OR c.codigo_natureza_juridica IN (2135, 2305, 2313, 4014, 4081) THEN NULL
    ELSE e.numero
  END AS numero,
  CASE
    WHEN s.opcao_mei OR c.codigo_natureza_juridica IN (2135, 2305, 2313, 4014, 4081) THEN NULL
    ELSE e.complemento
  END AS complemento,
  CASE
    WHEN s.opcao_mei OR c.codigo_natureza_juridica IN (2135, 2305, 2313, 4014, 4081) THEN NULL
    ELSE e.bairro
  END AS bairro,
  CASE
    WHEN s.opcao_mei OR c.codigo_natureza_juridica IN (2135, 2305, 2313, 4014, 4081) THEN NULL
    ELSE e.cep
  END AS cep,
  e.uf,
  e.codigo_municipio,
  CASE
    WHEN s.opcao_mei OR c.codigo_natureza_juridica IN (2135, 2305, 2313, 4014, 4081) THEN NULL
    ELSE e.ddd_1
  END AS ddd_1,
  CASE
    WHEN s.opcao_mei OR c.codigo_natureza_juridica IN (2135, 2305, 2313, 4014, 4081) THEN NULL
    ELSE e.telefone_1
  END AS telefone_1,
  CASE
    WHEN s.opcao_mei OR c.codigo_natureza_juridica IN (2135, 2305, 2313, 4014, 4081) THEN NULL
    ELSE e.ddd_2
  END AS ddd_2,
  CASE
    WHEN s.opcao_mei OR c.codigo_natureza_juridica IN (2135, 2305, 2313, 4014, 4081) THEN NULL
    ELSE e.telefone_2
  END AS telefone_2,
  CASE
    WHEN s.opcao_mei OR c.codigo_natureza_juridica IN (2135, 2305, 2313, 4014, 4081) THEN NULL
    ELSE e.ddd_fax
  END AS ddd_fax,
  CASE
    WHEN s.opcao_mei OR c.codigo_natureza_juridica IN (2135, 2305, 2313, 4014, 4081) THEN NULL
    ELSE e.fax
  END AS fax,
  CASE
    WHEN s.opcao_mei OR c.codigo_natureza_juridica IN (2135, 2305, 2313, 4014, 4081) THEN NULL
    ELSE e.email
  END AS email,
  e.situacao_especial,
  e.data_situacao_especial,
  s.opcao_simples,
  s.data_opcao_simples,
  s.data_exclusao_simples,
  s.opcao_mei,
  s.data_opcao_mei,
  s.data_exclusao_mei
FROM estabelecimento AS e
  LEFT JOIN empresa AS c
    ON e.empresa_uuid = c.uuid
  LEFT JOIN simples AS s
    ON s.empresa_uuid = c.uuid
