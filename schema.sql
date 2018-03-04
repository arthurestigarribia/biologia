DROP TABLE IF EXISTS biologia.usuarios;
DROP TABLE IF EXISTS biologia.cadeia;

CREATE table IF NOT EXISTS biologia.usuarios(
	id SERIAL NOT NULL PRIMARY KEY,
    nome VARCHAR(1000) NOT NULL,
    email VARCHAR(1000) NOT NULL,
    senha VARCHAR(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS biologia.cadeia(
	id SERIAL NOT NULL PRIMARY KEY,
    cadeia VARCHAR(10000),
    usuario INTEGER NOT NULL REFERENCES biologia.usuarios(id)
);