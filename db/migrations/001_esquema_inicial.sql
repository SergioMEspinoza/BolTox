BEGIN;

CREATE TABLE familia (
    id_familia INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre     TEXT NOT NULL UNIQUE,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE familia  IS
    'Familia botánica a la que pertenece cada especie vegetal.';



CREATE TABLE departamento (
    id_departamento INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL UNIQUE,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE departamento IS
    'Departamento donde se realizó la colecta del material vegetal utilizado';



CREATE TABLE parte_planta (
    id_parte_planta INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL UNIQUE,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE parte_planta IS
    'La parte de la especie vegetal que fue usada para aislar el o los compuestos químicos';



CREATE TABLE metodo (
    id_metodo INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre  TEXT NOT NULL UNIQUE,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE metodo IS
    'Método o métodos espectroscópicos, de espectrometría de masas, rayos X y comparación empleados para caracterizar o 
    identificar el compuesto químico reportado de la especie vegetal';



CREATE TABLE tipo_de_reporte (
    id_tipo_de_reporte INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL UNIQUE,
    descripcion TEXT NOT NULL,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE tipo_de_reporte IS
    'La tabla tipo de reporte permite identificar si el compuesto fue aislado y estructuralmente elucidado,
    o si solamente fue identificado mediante librerías espectrales';



CREATE TABLE revista (
    id_revista INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL UNIQUE,
    issn_electronico TEXT UNIQUE,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE revista IS
    'Información sobre la revista científca en la que fue publicada la revista';



CREATE TABLE autor (
    id_autor INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre TEXT NOT NULL,
    primer_apellido TEXT NOT NULL,
    segundo_apellido TEXT,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE autor IS
    'Autores del artículo donde se reporta el aislamiento o identificación de un compuesto químico';



CREATE TABLE compuesto (
    id_compuesto INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_trivial TEXT,
    nombre_iupac TEXT,
    smiles_original TEXT,
    smiles_canonico TEXT NOT NULL,
    inchikey VARCHAR(27) NOT NULL  UNIQUE CHECK (LENGTH(inchikey) = 27),
    formula_molecular TEXT NOT NULL, 
    masa_molecular NUMERIC(10,4) NOT NULL CHECK (masa_molecular > 0),
    estado_curacion TEXT NOT NULL CHECK (estado_curacion IN ('pendiente', 'validado', 'dudoso')) DEFAULT 'pendiente',
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE compuesto IS
    'Datos químicos de cada compuesto reportado (identificado o aislado) de la flora boliviana';



CREATE TABLE especie (
    id_especie INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_familia INT NOT NULL REFERENCES familia (id_familia) ON DELETE RESTRICT,
    nombre_cientifico TEXT NOT NULL UNIQUE,
    autoridad_botanica TEXT,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_especie_familia ON especie (id_familia);
COMMENT ON TABLE especie IS
    'Datos especie vegetal de la flora boliviana estudiada';



CREATE TABLE referencia (
    id_referencia INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_revista INT NOT NULL REFERENCES revista (id_revista) ON DELETE RESTRICT, 
    titulo TEXT NOT NULL,
    anio SMALLINT NOT NULL CHECK (anio BETWEEN 1800 AND 2100),
    volumen TEXT,
    numero TEXT,
    paginas TEXT,
    doi TEXT UNIQUE,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_referencia_revista     ON referencia (id_revista);
COMMENT ON TABLE referencia IS
    'Datos del artículo donde se reporta la identificación o aislamiento de un compuesto químico';



CREATE TABLE nombre_comun (
    id_nombre_comun INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_especie INT NOT NULL REFERENCES especie (id_especie) ON DELETE RESTRICT,
    nombre_comun TEXT NOT NULL,
    idioma TEXT NOT NULL,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (id_especie, nombre_comun, idioma)
);
COMMENT ON TABLE nombre_comun IS
    'Nombre común de la especie vegetal estudiada, si lo tiene';



CREATE TABLE colecta (
    id_colecta INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_especie INT NOT NULL REFERENCES especie (id_especie) ON DELETE RESTRICT,
    id_departamento INT NOT NULL REFERENCES departamento (id_departamento) ON DELETE RESTRICT,
    localidad TEXT,
    latitud NUMERIC(9,6) CHECK (latitud BETWEEN -23 AND -9),
    longitud NUMERIC(9,6) CHECK (longitud BETWEEN -70 AND -57),
    altitud_msnm INTEGER CHECK (altitud_msnm BETWEEN 70 AND 6600),
    anio_colecta SMALLINT CHECK (anio_colecta BETWEEN 1800 AND 2100),
    mes_colecta SMALLINT CHECK (mes_colecta BETWEEN 1 AND 12),
    herbario TEXT,
    voucher  TEXT,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (mes_colecta IS NULL OR anio_colecta IS NOT NULL)
);
CREATE INDEX idx_colecta_especie        ON colecta (id_especie);
CREATE INDEX idx_colecta_departamento   ON colecta (id_departamento);
COMMENT ON TABLE colecta IS
    'Datos colecta del material empleado para aislar o identificar compuestos químicos';



CREATE TABLE referencia_autor (
    id_referencia INT NOT NULL REFERENCES referencia(id_referencia) ON DELETE CASCADE,
    id_autor INT NOT NULL REFERENCES autor (id_autor) ON DELETE RESTRICT,
    orden_posicion_autoria SMALLINT NOT NULL CHECK (orden_posicion_autoria > 0),
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (id_referencia, id_autor), 
    UNIQUE (id_referencia, orden_posicion_autoria)
);
CREATE INDEX idx_referencia_autor_autor ON referencia_autor (id_autor);
COMMENT ON TABLE referencia_autor IS
    'Tabla intermedia para la relación muchos a muchos entre la referencia y el autor';



CREATE TABLE reporte (
    id_reporte  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_compuesto INT NOT NULL REFERENCES compuesto (id_compuesto) ON DELETE RESTRICT,
    id_colecta INT NOT NULL REFERENCES colecta (id_colecta) ON DELETE RESTRICT,
    id_referencia INT NOT NULL REFERENCES referencia (id_referencia) ON DELETE RESTRICT,
    id_parte_planta INT NOT NULL REFERENCES parte_planta (id_parte_planta) ON DELETE RESTRICT,
    id_tipo_de_reporte INT NOT NULL REFERENCES tipo_de_reporte (id_tipo_de_reporte) ON DELETE RESTRICT,
    nombre_reportado TEXT NOT NULL,
    formula_reportada TEXT,
    compuesto_nuevo BOOLEAN NOT NULL DEFAULT false,
    notas TEXT,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (id_compuesto, id_colecta, id_referencia)
);
CREATE INDEX idx_reporte_colecta        ON reporte (id_colecta);
CREATE INDEX idx_reporte_referencia     ON reporte (id_referencia);
CREATE INDEX idx_reporte_parte          ON reporte (id_parte_planta);
CREATE INDEX idx_reporte_tipo           ON reporte (id_tipo_de_reporte);
COMMENT ON TABLE reporte IS
    'El reporte hace referencia específicamente a un compuesto químico aislado o identificado
    a partir de una especie vegetal boliviana, el cual ha sido reportado en un artículo científico';



CREATE TABLE reporte_metodo (
    id_reporte INT NOT NULL REFERENCES reporte (id_reporte) ON DELETE CASCADE,
    id_metodo INT NOT NULL REFERENCES metodo (id_metodo) ON DELETE RESTRICT,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (id_reporte, id_metodo)
);
CREATE INDEX idx_reporte_metodo_metodo  ON reporte_metodo (id_metodo);
COMMENT ON TABLE reporte_metodo IS
    'Tabla intermedia que permite la relación muchos a muchos entre el reporte y el método';

COMMIT;


















