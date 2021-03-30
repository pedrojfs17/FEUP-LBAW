DROP TABLE IF EXISTS avatar CASCADE;
DROP TABLE IF EXISTS account CASCADE;
DROP TABLE IF EXISTS admin CASCADE;
DROP TABLE IF EXISTS country CASCADE;
DROP TABLE IF EXISTS client CASCADE;
DROP TABLE IF EXISTS project CASCADE;
DROP TABLE IF EXISTS invite CASCADE;
DROP TABLE IF EXISTS team_member CASCADE;
DROP TABLE IF EXISTS task CASCADE;
DROP TABLE IF EXISTS subtask CASCADE;
DROP TABLE IF EXISTS waiting_on CASCADE;
DROP TABLE IF EXISTS assignment CASCADE;
DROP TABLE IF EXISTS tag CASCADE;
DROP TABLE IF EXISTS contains_tag CASCADE;
DROP TABLE IF EXISTS check_list_item CASCADE;
DROP TABLE IF EXISTS comment CASCADE;
DROP TABLE IF EXISTS comment_reply CASCADE;
DROP TABLE IF EXISTS social_media_account CASCADE;
DROP TABLE IF EXISTS associated_project_account CASCADE;
DROP TABLE IF EXISTS associated_client_account CASCADE;
DROP TABLE IF EXISTS report CASCADE;
DROP TABLE IF EXISTS notification CASCADE;
DROP TABLE IF EXISTS comment_notification CASCADE;
DROP TABLE IF EXISTS assignment_notification CASCADE;
DROP TABLE IF EXISTS project_notification CASCADE;
DROP TABLE IF EXISTS report_notification CASCADE;
DROP TABLE IF EXISTS user_support CASCADE;

DROP TYPE IF EXISTS status;
DROP TYPE IF EXISTS gender;
DROP TYPE IF EXISTS role;
DROP TYPE IF EXISTS website;
DROP TYPE IF EXISTS report_state;

-- Types

CREATE TYPE status as ENUM (
    'Waiting',
    'Not Started',
    'In Progress',
    'Completed'
    );

CREATE TYPE gender as ENUM (
    'Female',
    'Male',
    'Unspecified'
    );

CREATE TYPE role as ENUM (
    'Owner',
    'Editor',
    'Reader'
    );

CREATE TYPE website as ENUM (
    'Facebook',
    'Instagram',
    'Twitter'
    );

CREATE TYPE report_state as ENUM (
    'Pending',
    'Ignored',
    'Banned'
    );

-- Tables

CREATE TABLE avatar
(
    id    SERIAL PRIMARY KEY,
    image bytea NOT NULL
);

CREATE TABLE account
(
    id       SERIAL PRIMARY KEY,
    username VARCHAR UNIQUE,
    password VARCHAR        NOT NULL,
    email    VARCHAR UNIQUE NOT NULL
);

CREATE TABLE admin
(
    id INTEGER PRIMARY KEY NOT NULL REFERENCES account (id) ON DELETE CASCADE
);

CREATE TABLE country
(
    id   SERIAL PRIMARY KEY,
    iso  char(2)     NOT NULL,
    name varchar(80) NOT NULL
);

CREATE TABLE client
(
    id                INTEGER PRIMARY KEY NOT NULL REFERENCES account (id) ON DELETE CASCADE,
    fullname          VARCHAR,
    company           VARCHAR,
    client_avatar     INTEGER             NOT NULL REFERENCES avatar (id) ON DELETE CASCADE,
    client_gender     gender DEFAULT 'Unspecified',
    country           INTEGER REFERENCES country (id) ON DELETE CASCADE,
    allowNoti         BOOLEAN             NOT NULL,
    inviteNoti        BOOLEAN             NOT NULL,
    memberNoti        BOOLEAN             NOT NULL,
    assignNoti        BOOLEAN             NOT NULL,
    waitingNoti       BOOLEAN             NOT NULL,
    commentNoti       BOOLEAN             NOT NULL,
    reportNoti        BOOLEAN             NOT NULL,
    hideCompleted     BOOLEAN             NOT NULL,
    simplifiedTasks   BOOLEAN             NOT NULL,
    color             VARCHAR             NOT NULL
);

CREATE TABLE project
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR NOT NULL,
    description VARCHAR NOT NULL,
    due_date    DATE CHECK (due_date > CURRENT_DATE),
    search      TSVECTOR
);

CREATE TABLE invite 
(
    project_id  INTEGER NOT NULL REFERENCES project (id) ON DELETE CASCADE,
    client_id   INTEGER NOT NULL REFERENCES client (id) ON DELETE CASCADE,
    accepted    BOOLEAN,
    PRIMARY KEY (project_id, client_id)
);

CREATE TABLE team_member
(
    client_id   INTEGER NOT NULL REFERENCES client (id) ON DELETE CASCADE,
    project_id  INTEGER NOT NULL REFERENCES project (id) ON DELETE CASCADE,
    member_role role,
    PRIMARY KEY (client_id, project_id)
);

CREATE TABLE task
(
    id          SERIAL PRIMARY KEY,
    project     INTEGER NOT NULL REFERENCES project (id) ON DELETE CASCADE,
    name        VARCHAR NOT NULL,
    description VARCHAR,
    due_date    TIMESTAMP,
    task_status status DEFAULT 'Not Started',
    search      TSVECTOR
);

CREATE TABLE subtask
(
    id     INTEGER PRIMARY KEY REFERENCES task (id) ON DELETE CASCADE,
    parent INTEGER NOT NULL REFERENCES task (id) ON DELETE CASCADE
);

CREATE TABLE waiting_on
(
    task1 INTEGER NOT NULL REFERENCES task (id) ON DELETE CASCADE,
    task2 INTEGER NOT NULL REFERENCES task (id) ON DELETE CASCADE,
    PRIMARY KEY (task1, task2)
);

CREATE TABLE assignment
(
    task   INTEGER NOT NULL REFERENCES task (id) ON DELETE CASCADE,
    client INTEGER NOT NULL REFERENCES client (id) ON DELETE CASCADE,
    PRIMARY KEY (task, client)
);

CREATE TABLE tag
(
    id      SERIAL PRIMARY KEY,
    project INTEGER NOT NULL REFERENCES project (id) ON DELETE CASCADE,
    name    VARCHAR NOT NULL,
    color   VARCHAR NOT NULL
);

CREATE TABLE contains_tag
(
    tag  INTEGER NOT NULL REFERENCES tag (id) ON DELETE CASCADE,
    task INTEGER NOT NULL REFERENCES task (id) ON DELETE CASCADE,
    PRIMARY KEY (tag, task)
);

CREATE TABLE check_list_item
(
    id        SERIAL PRIMARY KEY,
    item_text VARCHAR NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    task      INTEGER NOT NULL REFERENCES task (id) ON DELETE CASCADE
);

CREATE TABLE comment
(
    id           SERIAL PRIMARY KEY,
    task         INTEGER   NOT NULL REFERENCES task (id) ON DELETE CASCADE,
    author       INTEGER   REFERENCES client (id) ON DELETE SET NULL,
    comment_date TIMESTAMP NOT NULL,
    comment_text VARCHAR
);

CREATE TABLE comment_reply
(
    id     INTEGER PRIMARY KEY REFERENCES comment (id) ON DELETE CASCADE,
    parent INTEGER NOT NULL REFERENCES comment (id) ON DELETE CASCADE
);

CREATE TABLE social_media_account
(
    id           SERIAL PRIMARY KEY,
    social_media website NOT NULL,
    username     VARCHAR NOT NULL,
    access_token VARCHAR NOT NULL
);

CREATE TABLE associated_project_account
(
    account INTEGER NOT NULL REFERENCES social_media_account (id) ON DELETE CASCADE,
    project INTEGER NOT NULL REFERENCES project ON DELETE CASCADE,
    PRIMARY KEY (account, project)
);

CREATE TABLE associated_client_account
(
    account INTEGER NOT NULL REFERENCES social_media_account (id) ON DELETE CASCADE,
    client  INTEGER NOT NULL REFERENCES client ON DELETE CASCADE,
    PRIMARY KEY (account, client)
);

CREATE TABLE report
(
    id          SERIAL PRIMARY KEY,
    report_text VARCHAR NOT NULL,
    state       report_state NOT NULL DEFAULT 'Pending',
    reporter    INTEGER REFERENCES client (id) ON DELETE SET NULL,
    reported    INTEGER NOT NULL REFERENCES client (id) ON DELETE CASCADE
);

CREATE TABLE notification
(
    id                SERIAL PRIMARY KEY,
    client            INTEGER NOT NULL REFERENCES client (id) ON DELETE CASCADE,
    seen              BOOLEAN NOT NULL DEFAULT FALSE,
    notification_text VARCHAR NOT NULL
);

CREATE TABLE comment_notification
(
    id      INTEGER NOT NULL REFERENCES notification (id) ON DELETE CASCADE,
    comment INTEGER NOT NULL REFERENCES comment (id) ON DELETE CASCADE
);

CREATE TABLE assignment_notification
(
    id         INTEGER NOT NULL REFERENCES notification (id) ON DELETE CASCADE,
    assignment INTEGER NOT NULL REFERENCES task (id) ON DELETE CASCADE
);

CREATE TABLE project_notification
(
    id      INTEGER NOT NULL REFERENCES notification (id) ON DELETE CASCADE,
    project INTEGER NOT NULL REFERENCES project (id) ON DELETE CASCADE
);

CREATE TABLE report_notification
(
    id     INTEGER NOT NULL REFERENCES notification (id) ON DELETE CASCADE,
    report INTEGER NOT NULL REFERENCES report (id) ON DELETE CASCADE
);

CREATE TABLE user_support
(
    id        SERIAL PRIMARY KEY,
    email     VARCHAR NOT NULL,
    name      VARCHAR,
    subject   VARCHAR NOT NULL,
    body      VARCHAR NOT NULL,
    responded BOOLEAN NOT NULL DEFAULT FALSE,
    response  VARCHAR
);