CREATE TABLE elu
(
    id                     UUID PRIMARY KEY NOT NULL,
    civilite               CHARACTER VARYING(3)       NOT NULL,
    prenom                 CHARACTER VARYING(255)     NOT NULL,
    nom                    CHARACTER VARYING(255)     NOT NULL,
    groupe_politique       CHARACTER VARYING(255)     NOT NULL,
    groupe_politique_court CHARACTER VARYING(255)     NOT NULL,
    image_url              CHARACTER VARYING(255)     NOT NULL,
    actif                  BOOLEAN          NOT NULL,
    creation_date          TIMESTAMP        NOT NULL
);



CREATE TABLE nature_juridique
(
    id      UUID PRIMARY KEY NOT NULL,
    libelle CHARACTER VARYING(255)     NOT NULL
);



CREATE TABLE secteur
(
    id      UUID PRIMARY KEY NOT NULL,
    libelle CHARACTER VARYING(255)     NOT NULL
);



CREATE TABLE deliberation
(
    id                     UUID PRIMARY KEY NOT NULL,
    libelle                CHARACTER VARYING(255)     NOT NULL,
    deliberation_date      DATE             NOT NULL,
    creation_date          TIMESTAMP        NOT NULL,
    last_modification_date TIMESTAMP        NOT NULL
);



CREATE TABLE type_structure
(
    id      UUID PRIMARY KEY NOT NULL,
    libelle CHARACTER VARYING(255)     NOT NULL
);



-- [doc] Spring Jdbc Session specific table
-- https://docs.spring.io/spring-session/docs/current/reference/html5/#api-jdbcoperationssessionrepository-storage
CREATE TABLE spring_session
(
    primary_id            CHAR(36) PRIMARY KEY,
    session_id            CHAR(36) NOT NULL UNIQUE,
    creation_time         BIGINT   NOT NULL,
    last_access_time      BIGINT   NOT NULL,
    max_inactive_interval INTEGER  NOT NULL,
    expiry_time           BIGINT   NOT NULL,
    principal_name        CHARACTER VARYING(255)
);

CREATE INDEX ON spring_session (expiry_time);
CREATE INDEX ON spring_session (principal_name);

CREATE TABLE spring_session_attributes
(
    session_primary_id CHAR(36)     NOT NULL,
    attribute_name     CHARACTER VARYING(200) NOT NULL,
    attribute_bytes    BYTEA        NOT NULL,
    PRIMARY KEY (session_primary_id, attribute_name),
    FOREIGN KEY (session_primary_id) REFERENCES spring_session (primary_id) ON DELETE CASCADE
);

CREATE TABLE app_user
(
    id           UUID PRIMARY KEY,
    mail         CHARACTER VARYING(255) UNIQUE NOT NULL,
    password     CHARACTER VARYING(60)         NOT NULL,
-- [doc] username is at least useful for development
    username     CHARACTER VARYING(255) UNIQUE,
    language     CHARACTER VARYING(2)          NOT NULL,
    admin        BOOLEAN             NOT NULL,
    signup_date  TIMESTAMPTZ         NOT NULL,
    dirty_mail   CHARACTER VARYING(255)
);

CREATE INDEX ON app_user (username);
CREATE INDEX ON app_user (mail);


CREATE TABLE deployment_log
(
    id             UUID PRIMARY KEY,
    build_version  CHARACTER VARYING(255) NOT NULL,
    system_zone_id CHARACTER VARYING(255) NOT NULL,
    startup_date   TIMESTAMPTZ  NOT NULL,
    shutdown_date  TIMESTAMPTZ
);

CREATE TABLE organisme
(
    id                     UUID PRIMARY KEY NOT NULL,
    nom                    CHARACTER VARYING(255)     NOT NULL,
    secteur_id             UUID,
    nature_juridique_id    UUID,
    type_structure_id      UUID,
    nombre_representants   INTEGER,
    nombre_suppleants      INTEGER,
    partage_representants  BOOLEAN          NOT NULL,
    creation_date          TIMESTAMP        NOT NULL,
    last_modification_date TIMESTAMP        NOT NULL,
    FOREIGN KEY (secteur_id) REFERENCES secteur (id),
    FOREIGN KEY (nature_juridique_id) REFERENCES nature_juridique (id),
    FOREIGN KEY (type_structure_id) REFERENCES type_structure (id)
);



CREATE TABLE mail_log
(
    id                UUID PRIMARY KEY,
    application       CHARACTER VARYING(255) NOT NULL,
    deployment_log_id UUID         NOT NULL,
    recipient_type    CHARACTER VARYING(255) NOT NULL,
    user_id           UUID         NOT NULL,
    reference         CHARACTER VARYING(255) NOT NULL,
-- [doc] kept here, mainly because the user can change his mail
    recipient_mail    CHARACTER VARYING(255) NOT NULL,
    data              TEXT         NOT NULL,
    subject           TEXT         NOT NULL,
    content           TEXT         NOT NULL,
    date              TIMESTAMPTZ  NOT NULL,
    FOREIGN KEY (deployment_log_id) REFERENCES deployment_log (id)
);

CREATE INDEX ON mail_log (user_id);

CREATE TABLE magic_link_token
(
    token         CHARACTER VARYING(255) PRIMARY KEY,
    user_id       UUID        NOT NULL,
    -- TODO[magic-link] de la nécessité de créer un index ici
    creation_date TIMESTAMPTZ NOT NULL,
    validity      BOOLEAN     NOT NULL,
    FOREIGN KEY (user_id) REFERENCES app_user (id)
);

CREATE TABLE user_session_log
(
    id                UUID PRIMARY KEY,
    spring_session_id CHARACTER VARYING(255) NOT NULL,
    user_id           UUID         NOT NULL,
    deployment_log_id UUID         NOT NULL,
    date              TIMESTAMPTZ  NOT NULL,
    ip                CHARACTER VARYING(255) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES app_user (id)
);

CREATE TABLE instance
(
    id                     UUID PRIMARY KEY NOT NULL,
    nom                    CHARACTER VARYING(255)     NOT NULL,
    organisme_id           UUID             NOT NULL,
    nombre_representants   INTEGER,
    nombre_suppleants      INTEGER,
    creation_date          TIMESTAMP        NOT NULL,
    last_modification_date TIMESTAMP        NOT NULL,
    FOREIGN KEY (organisme_id) REFERENCES organisme (id)
);

CREATE INDEX ON instance (organisme_id);


CREATE TABLE command_log
(
    id                    UUID PRIMARY KEY,
    user_id               UUID,
    deployment_log_id     UUID         NOT NULL,
    command_class         CHARACTER VARYING(255) NOT NULL,
    json_command          TEXT         NOT NULL,
    ip                    CHARACTER VARYING(255) NOT NULL,
    user_session_id       UUID,
    resulting_ids         TEXT,
    json_result           TEXT,
    exception_stack_trace TEXT,
    start_date            TIMESTAMP    NOT NULL,
    end_date              TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES app_user (id),
    FOREIGN KEY (deployment_log_id) REFERENCES deployment_log (id),
    FOREIGN KEY (user_session_id) REFERENCES user_session_log (id)
);

CREATE TABLE representant
(
    id                        UUID PRIMARY KEY NOT NULL,
    elu_id                    UUID             NOT NULL,
    organisme_id              UUID             NOT NULL,
    instance_id               UUID,
    position                  INT              NOT NULL,
    representant_or_suppleant CHARACTER VARYING(255)     NOT NULL,
    creation_date             TIMESTAMP        NOT NULL,
    last_modification_date    TIMESTAMP        NOT NULL,
    FOREIGN KEY (elu_id) REFERENCES elu (id),
    FOREIGN KEY (organisme_id) REFERENCES organisme (id),
    FOREIGN KEY (instance_id) REFERENCES instance (id)
);

CREATE INDEX ON representant (organisme_id);
CREATE INDEX ON representant (instance_id);

CREATE TABLE lien_deliberation
(
    id                     UUID PRIMARY KEY NOT NULL,
    deliberation_id        UUID             NOT NULL,
    organisme_id           UUID             NOT NULL,
    instance_id            UUID,
    creation_date          TIMESTAMP        NOT NULL,
    last_modification_date TIMESTAMP        NOT NULL,
    FOREIGN KEY (deliberation_id) REFERENCES deliberation (id),
    FOREIGN KEY (organisme_id) REFERENCES organisme (id),
    FOREIGN KEY (instance_id) REFERENCES instance (id)
);

CREATE INDEX ON lien_deliberation (organisme_id);


