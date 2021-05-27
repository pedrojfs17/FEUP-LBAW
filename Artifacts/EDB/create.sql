DROP TABLE IF EXISTS account CASCADE;
DROP TABLE IF EXISTS password_resets CASCADE;
DROP TABLE IF EXISTS admin CASCADE;
DROP TABLE IF EXISTS country CASCADE;
DROP TABLE IF EXISTS client CASCADE;
DROP TABLE IF EXISTS project CASCADE;
DROP TABLE IF EXISTS invite CASCADE;
DROP TABLE IF EXISTS team_member CASCADE;
DROP TABLE IF EXISTS task CASCADE;
DROP TABLE IF EXISTS waiting_on CASCADE;
DROP TABLE IF EXISTS assignment CASCADE;
DROP TABLE IF EXISTS tag CASCADE;
DROP TABLE IF EXISTS contains_tag CASCADE;
DROP TABLE IF EXISTS check_list_item CASCADE;
DROP TABLE IF EXISTS comment CASCADE;
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

CREATE TABLE account
(
    id       SERIAL PRIMARY KEY,
    username VARCHAR UNIQUE NOT NULL,
    password VARCHAR        NOT NULL,
    email    VARCHAR UNIQUE NOT NULL,
    is_admin BOOLEAN        NOT NULL DEFAULT FALSE
);

CREATE TABLE password_resets
(
    email      VARCHAR NOT NULL,
    token      VARCHAR NOT NULL,
    created_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL
);

CREATE TABLE country
(
    id   SERIAL PRIMARY KEY,
    iso  char(2)     NOT NULL,
    name varchar(80) NOT NULL
);

CREATE TABLE client
(
    id               INTEGER PRIMARY KEY NOT NULL REFERENCES account (id) ON DELETE CASCADE,
    fullname         VARCHAR,
    company          VARCHAR,
    avatar           VARCHAR DEFAULT 'avatars/default.png',
    client_gender    gender DEFAULT 'Unspecified',
    country          INTEGER REFERENCES country (id) ON DELETE CASCADE,
    allow_noti       BOOLEAN             NOT NULL DEFAULT TRUE,
    invite_noti      BOOLEAN             NOT NULL DEFAULT TRUE,
    member_noti      BOOLEAN             NOT NULL DEFAULT TRUE,
    assign_noti      BOOLEAN             NOT NULL DEFAULT TRUE,
    waiting_noti     BOOLEAN             NOT NULL DEFAULT TRUE,
    comment_noti     BOOLEAN             NOT NULL DEFAULT TRUE,
    report_noti      BOOLEAN             NOT NULL DEFAULT TRUE,
    hide_completed   BOOLEAN             NOT NULL DEFAULT FALSE,
    simplified_tasks BOOLEAN             NOT NULL DEFAULT FALSE,
    color            VARCHAR             NOT NULL,
    search           TSVECTOR
);

CREATE TABLE project
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR NOT NULL,
    description VARCHAR NOT NULL,
    due_date    TIMESTAMP CHECK (due_date > CURRENT_DATE),
    search      TSVECTOR
);

CREATE TABLE invite
(
    client_id  INTEGER NOT NULL REFERENCES client (id) ON DELETE CASCADE,
    project_id INTEGER NOT NULL REFERENCES project (id) ON DELETE CASCADE,
    decision   BOOLEAN,
    PRIMARY KEY (client_id, project_id)
);

CREATE TABLE team_member
(
    client_id   INTEGER NOT NULL REFERENCES client (id) ON DELETE CASCADE,
    project_id  INTEGER NOT NULL REFERENCES project (id) ON DELETE CASCADE,
    member_role role NOT NULL DEFAULT 'Reader',
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
    parent      INTEGER REFERENCES task(id) ON DELETE CASCADE,
    search      TSVECTOR
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
    comment_date TIMESTAMP NOT NULL DEFAULT NOW(),
    comment_text VARCHAR,
    parent       INTEGER REFERENCES comment (id) ON DELETE CASCADE
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
    report_text VARCHAR      NOT NULL,
    state       report_state NOT NULL DEFAULT 'Pending',
    reporter    INTEGER      REFERENCES client (id) ON DELETE SET NULL,
    reported    INTEGER      NOT NULL REFERENCES client (id) ON DELETE CASCADE
);

CREATE TABLE notification
(
    id                SERIAL PRIMARY KEY,
    client            INTEGER   NOT NULL REFERENCES client (id) ON DELETE CASCADE,
    seen              BOOLEAN   NOT NULL DEFAULT FALSE,
    notification_date TIMESTAMP NOT NULL DEFAULT NOW(),
    notification_text VARCHAR   NOT NULL
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


-- Functions

CREATE OR REPLACE FUNCTION client_search_update() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.search =
                (SELECT setweight(to_tsvector(account.username), 'A') || setweight(to_tsvector(account.email), 'A') ||
                        setweight(to_tsvector('english', coalesce(NEW.fullname, '')), 'B') ||
                        setweight(to_tsvector(coalesce(NEW.company, '')), 'C')
                 FROM account
                 WHERE NEW.id = account.id);
    ELSIF TG_OP = 'UPDATE' AND (NEW.fullname <> OLD.fullname OR NEW.company <> OLD.company) THEN
        NEW.search =
                (SELECT setweight(to_tsvector(account.username), 'A') || setweight(to_tsvector(account.email), 'A') ||
                        setweight(to_tsvector('english', coalesce(NEW.fullname, '')), 'B') ||
                        setweight(to_tsvector(coalesce(NEW.company, '')), 'C')
                 FROM account
                 WHERE NEW.id = account.id);
    END IF;
    RETURN NEW;
END;
$BODY$
    LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION project_search_update() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.search = (SELECT setweight(to_tsvector('english', NEW.name), 'A') || setweight(to_tsvector('english', NEW.description), 'B'));
    ELSIF TG_OP = 'UPDATE' AND (NEW.name <> OLD.name OR NEW.description <> OLD.description) THEN
        NEW.search = (SELECT setweight(to_tsvector('english', NEW.name), 'A') || setweight(to_tsvector('english', NEW.description), 'B'));
    END IF;
    RETURN NEW;
END;
$BODY$
    LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION task_search_update() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.search = (SELECT setweight(to_tsvector('english', NEW.name), 'A') ||
                             setweight(to_tsvector('english', coalesce(NEW.description, '')), 'B'));
    ELSIF TG_OP = 'UPDATE' AND (NEW.name <> OLD.name OR NEW.description <> OLD.description) THEN
        NEW.search = (SELECT setweight(to_tsvector('english', NEW.name), 'A') ||
                             setweight(to_tsvector('english', coalesce(NEW.description, '')), 'B'));
    END IF;
    RETURN NEW;
END;
$BODY$
    LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION assign_tag() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF NOT EXISTS(SELECT *
                  FROM tag,
                       task
                  WHERE NEW.task = task.id
                    AND NEW.tag = tag.id
                    AND tag.project = task.project) THEN
        RAISE EXCEPTION 'Tag does not belong to this project';
    END IF;
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION assign_member() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF NOT EXISTS(SELECT *
                  FROM team_member,
                       task
                  WHERE NEW.task = task.id
                    AND NEW.client = team_member.client_id
                    AND team_member.project_id = task.project) THEN
        RAISE EXCEPTION 'Client is not a member of project';
    END IF;
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_project_owner() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF OLD.member_role = 'Owner'
        AND (SELECT count(*) FROM team_member WHERE project_id = OLD.project_id AND member_role = 'Owner') = 1
        AND (SELECT COUNT(*) FROM team_member WHERE project_id = OLD.project_id) > 1
    THEN
        RAISE EXCEPTION 'Project must have at least one owner!';
    END IF;
    RETURN OLD;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION accept_invite() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF OLD.decision IS NULL AND NEW.decision = TRUE
    THEN
        INSERT INTO team_member (client_id, project_id) SELECT NEW.client_id, NEW.project_id;
    END IF;
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_task_date() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF NEW.due_date > (SELECT project.due_date FROM project WHERE NEW.project = project.id)
    THEN
        RAISE EXCEPTION 'Date is greater than the projects date';
    END IF;
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION add_invite_notification() RETURNS TRIGGER AS
$BODY$
BEGIN
    WITH inserted AS (
        INSERT INTO notification (client, notification_text)
            VALUES (NEW.client_id, concat('You have been invited to join ', (SELECT name FROM project where NEW.project_id = id), '!'))
            RETURNING id
    )
    INSERT INTO project_notification SELECT inserted.id, NEW.project_id FROM inserted;
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION add_project_notification() RETURNS TRIGGER AS
$BODY$
BEGIN
    WITH inserted AS (
        INSERT INTO notification (client, notification_text)
            SELECT team_member.client_id,
                   concat((SELECT username FROM account where NEW.client_id = id), ' joined ',
                          (SELECT name FROM project where NEW.project_id = id), '!')
            FROM team_member
            WHERE team_member.project_id = NEW.project_id
              AND team_member.client_id != NEW.client_id
            RETURNING id
    )
    INSERT INTO project_notification SELECT inserted.id, NEW.project_id FROM inserted;
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION add_assignment_notification() RETURNS TRIGGER AS
$BODY$
BEGIN
    WITH inserted AS (
        INSERT INTO notification (client, notification_text)
            SELECT team_member.client_id,
                   concat((SELECT username FROM account where NEW.client = id), ' was assigned to ',
                          (SELECT name FROM task where NEW.task = id), '!')
            FROM team_member
            WHERE team_member.project_id = (SELECT project FROM task WHERE task.id = NEW.task)
            RETURNING id
    )
    INSERT INTO assignment_notification SELECT inserted.id, NEW.task FROM inserted;
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION add_comment_notification() RETURNS TRIGGER AS
$BODY$
BEGIN
    WITH inserted AS (
        INSERT INTO notification (client, notification_text)
            SELECT assignment.client,
                   concat((SELECT username FROM account where NEW.author = id), ' commented on task ',
                          (SELECT name FROM task where NEW.task = id), '!')
            FROM assignment
            WHERE assignment.task = NEW.task
            RETURNING id
    )
    INSERT INTO comment_notification SELECT inserted.id, NEW.id FROM inserted;
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION add_report_notification() RETURNS TRIGGER AS
$BODY$
BEGIN
    WITH inserted AS (
        INSERT INTO notification (client, notification_text)
            VALUES (NEW.reporter, concat('Your report has been reviewed! Decision: ', NEW.state, '!'))
            RETURNING id
    )
    INSERT INTO report_notification SELECT inserted.id, NEW.id FROM inserted;
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION add_members(project_id INT, client_ids integer[]) RETURNS VOID AS
$BODY$
BEGIN
    INSERT INTO team_member SELECT unnest(client_ids), project_id, 'Reader';
END;
$BODY$
    LANGUAGE plpgsql;


-- Triggers

DROP TRIGGER IF EXISTS update_client_search ON client;
DROP TRIGGER IF EXISTS update_project_search ON project;
DROP TRIGGER IF EXISTS update_task_search ON task;
DROP TRIGGER IF EXISTS assign_tag ON contains_tag;
DROP TRIGGER IF EXISTS assign_member ON assignment;
DROP TRIGGER IF EXISTS check_project_owner ON team_member;
DROP TRIGGER IF EXISTS accept_invite ON invite;
DROP TRIGGER IF EXISTS check_task_date ON task;
DROP TRIGGER IF EXISTS add_invite_notification ON invite;
DROP TRIGGER IF EXISTS add_project_notification ON team_member;
DROP TRIGGER IF EXISTS add_assignment_notification ON assignment;
DROP TRIGGER IF EXISTS add_comment_notification ON comment;
DROP TRIGGER IF EXISTS add_report_notification ON report;


-- TRIGGER01
CREATE TRIGGER update_client_search
    BEFORE INSERT OR UPDATE
    ON client
    FOR EACH ROW
EXECUTE PROCEDURE client_search_update();


-- TRIGGER02
CREATE TRIGGER update_project_search
    BEFORE INSERT OR UPDATE
    ON project
    FOR EACH ROW
EXECUTE PROCEDURE project_search_update();


-- TRIGGER03
CREATE TRIGGER update_task_search
    BEFORE INSERT OR UPDATE
    ON task
    FOR EACH ROW
EXECUTE PROCEDURE task_search_update();


-- TRIGGER04
CREATE TRIGGER assign_tag
    BEFORE INSERT
    ON contains_tag
    FOR EACH ROW
EXECUTE PROCEDURE assign_tag();


-- TRIGGER05
CREATE TRIGGER assign_member
    BEFORE INSERT
    ON assignment
    FOR EACH ROW
EXECUTE PROCEDURE assign_member();


-- TRIGGER06
CREATE TRIGGER check_project_owner
    BEFORE DELETE
    ON team_member
    FOR EACH ROW
EXECUTE PROCEDURE check_project_owner();


-- TRIGGER07
CREATE TRIGGER accept_invite
    AFTER UPDATE
    ON invite
    FOR EACH ROW
EXECUTE PROCEDURE accept_invite();


-- TRIGGER08
CREATE TRIGGER check_task_date
    BEFORE INSERT OR UPDATE
    ON task
    FOR EACH ROW
EXECUTE PROCEDURE check_task_date();


-- TRIGGER09
CREATE TRIGGER add_invite_notification
    AFTER INSERT
    ON invite
    FOR EACH ROW
EXECUTE PROCEDURE add_invite_notification();


-- TRIGGER10
CREATE TRIGGER add_project_notification
    AFTER INSERT
    ON team_member
    FOR EACH ROW
EXECUTE PROCEDURE add_project_notification();


-- TRIGGER11
CREATE TRIGGER add_assignment_notification
    AFTER INSERT
    ON assignment
    FOR EACH ROW
EXECUTE PROCEDURE add_assignment_notification();


-- TRIGGER012
CREATE TRIGGER add_comment_notification
    AFTER INSERT
    ON comment
    FOR EACH ROW
EXECUTE PROCEDURE add_comment_notification();


-- TRIGGER13
CREATE TRIGGER add_report_notification
    AFTER UPDATE OF state
    ON report
    FOR EACH ROW
EXECUTE PROCEDURE add_report_notification();


-- Indexes

-- Laravel Indexes

DROP INDEX IF EXISTS password_resets_email_index;
DROP INDEX IF EXISTS password_resets_token_index;

CREATE INDEX password_resets_email_index ON password_resets (email);
create index password_resets_token_index ON password_resets (token);

-- Oversee Indexes

DROP INDEX IF EXISTS client_member_index;
DROP INDEX IF EXISTS project_member_index;
DROP INDEX IF EXISTS task_index;
DROP INDEX IF EXISTS waiting_index;
DROP INDEX IF EXISTS task_assign_index;
DROP INDEX IF EXISTS client_assign_index;
DROP INDEX IF EXISTS tag_index;
DROP INDEX IF EXISTS task_tag_index;
DROP INDEX IF EXISTS tag_task_index;
DROP INDEX IF EXISTS check_list_index;
DROP INDEX IF EXISTS comment_index;
DROP INDEX IF EXISTS notification_index;
DROP INDEX IF EXISTS search_client;
DROP INDEX IF EXISTS search_project;
DROP INDEX IF EXISTS search_task;

-- IDX01
CREATE INDEX client_member_index ON team_member USING hash (client_id);

-- IDX02
CREATE INDEX project_member_index ON team_member USING hash (project_id);

-- IDX03
CREATE INDEX task_index ON task USING hash (project);

-- IDX04
CREATE INDEX waiting_index ON waiting_on USING hash (task1);

-- IDX05
CREATE INDEX task_assign_index ON assignment USING hash (task);

-- IDX06
CREATE INDEX client_assign_index ON assignment USING hash (task);

-- IDX07
CREATE INDEX tag_index ON tag USING hash (project);

-- IDX08
CREATE INDEX task_tag_index ON contains_tag USING hash (task);

-- IDX09
CREATE INDEX tag_task_index ON contains_tag USING hash (tag);

-- IDX10
CREATE INDEX check_list_index ON check_list_item USING hash (task);

-- IDX11
CREATE INDEX comment_index ON comment USING btree (task, comment_date);

-- IDX12
CREATE INDEX notification_index ON notification USING btree (client, notification_date);

-- IDX13
CREATE INDEX search_client ON client USING GIN (search);

-- IDX14
CREATE INDEX search_project ON project USING GIN (search);

-- IDX15
CREATE INDEX search_task ON task USING GIN (search);
