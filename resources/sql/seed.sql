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
    closed      BOOLEAN NOT NULL DEFAULT FALSE,
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
        AND NOT (SELECT closed FROM project WHERE id = OLD.project_id)
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
    DELETE FROM invite WHERE invite.client_id = NEW.client_id AND invite.project_id = NEW.project_id;
    RETURN OLD;
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


CREATE OR REPLACE FUNCTION empty_project() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF (SELECT count(*) FROM team_member WHERE project_id = OLD.project_id) = 0
    THEN
        DELETE FROM project WHERE id = OLD.project_id;
END IF;
RETURN OLD;
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
DROP TRIGGER IF EXISTS empty_project ON team_member;


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

-- TRIGGER14
CREATE TRIGGER empty_project
    AFTER DELETE
    ON team_member
    FOR EACH ROW
    EXECUTE PROCEDURE empty_project();


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


-- Populate

-- Country

INSERT INTO country (iso, name) VALUES ('AF', 'Afghanistan');
INSERT INTO country (iso, name) VALUES ('AL', 'Albania');
INSERT INTO country (iso, name) VALUES ('DZ', 'Algeria');
INSERT INTO country (iso, name) VALUES ('AS', 'American Samoa');
INSERT INTO country (iso, name) VALUES ('AD', 'Andorra');
INSERT INTO country (iso, name) VALUES ('AO', 'Angola');
INSERT INTO country (iso, name) VALUES ('AI', 'Anguilla');
INSERT INTO country (iso, name) VALUES ('AQ', 'Antarctica');
INSERT INTO country (iso, name) VALUES ('AG', 'Antigua and Barbuda');
INSERT INTO country (iso, name) VALUES ('AR', 'Argentina');
INSERT INTO country (iso, name) VALUES ('AM', 'Armenia');
INSERT INTO country (iso, name) VALUES ('AW', 'Aruba');
INSERT INTO country (iso, name) VALUES ('AU', 'Australia');
INSERT INTO country (iso, name) VALUES ('AT', 'Austria');
INSERT INTO country (iso, name) VALUES ('AZ', 'Azerbaijan');
INSERT INTO country (iso, name) VALUES ('BS', 'Bahamas');
INSERT INTO country (iso, name) VALUES ('BH', 'Bahrain');
INSERT INTO country (iso, name) VALUES ('BD', 'Bangladesh');
INSERT INTO country (iso, name) VALUES ('BB', 'Barbados');
INSERT INTO country (iso, name) VALUES ('BY', 'Belarus');
INSERT INTO country (iso, name) VALUES ('BE', 'Belgium');
INSERT INTO country (iso, name) VALUES ('BZ', 'Belize');
INSERT INTO country (iso, name) VALUES ('BJ', 'Benin');
INSERT INTO country (iso, name) VALUES ('BM', 'Bermuda');
INSERT INTO country (iso, name) VALUES ('BT', 'Bhutan');
INSERT INTO country (iso, name) VALUES ('BO', 'Bolivia');
INSERT INTO country (iso, name) VALUES ('BA', 'Bosnia and Herzegovina');
INSERT INTO country (iso, name) VALUES ('BW', 'Botswana');
INSERT INTO country (iso, name) VALUES ('BV', 'Bouvet Island');
INSERT INTO country (iso, name) VALUES ('BR', 'Brazil');
INSERT INTO country (iso, name) VALUES ('IO', 'British Indian Ocean Territory');
INSERT INTO country (iso, name) VALUES ('BN', 'Brunei Darussalam');
INSERT INTO country (iso, name) VALUES ('BG', 'Bulgaria');
INSERT INTO country (iso, name) VALUES ('BF', 'Burkina Faso');
INSERT INTO country (iso, name) VALUES ('BI', 'Burundi');
INSERT INTO country (iso, name) VALUES ('KH', 'Cambodia');
INSERT INTO country (iso, name) VALUES ('CM', 'Cameroon');
INSERT INTO country (iso, name) VALUES ('CA', 'Canada');
INSERT INTO country (iso, name) VALUES ('CV', 'Cape Verde');
INSERT INTO country (iso, name) VALUES ('KY', 'Cayman Islands');
INSERT INTO country (iso, name) VALUES ('CF', 'Central African Republic');
INSERT INTO country (iso, name) VALUES ('TD', 'Chad');
INSERT INTO country (iso, name) VALUES ('CL', 'Chile');
INSERT INTO country (iso, name) VALUES ('CN', 'China');
INSERT INTO country (iso, name) VALUES ('CX', 'Christmas Island');
INSERT INTO country (iso, name) VALUES ('CC', 'Cocos (Keeling) Islands');
INSERT INTO country (iso, name) VALUES ('CO', 'Colombia');
INSERT INTO country (iso, name) VALUES ('KM', 'Comoros');
INSERT INTO country (iso, name) VALUES ('CG', 'Congo');
INSERT INTO country (iso, name) VALUES ('CD', 'Congo, the Democratic Republic of the');
INSERT INTO country (iso, name) VALUES ('CK', 'Cook Islands');
INSERT INTO country (iso, name) VALUES ('CR', 'Costa Rica');
INSERT INTO country (iso, name) VALUES ('CI', 'Cote D''Ivoire');
INSERT INTO country (iso, name) VALUES ('HR', 'Croatia');
INSERT INTO country (iso, name) VALUES ('CU', 'Cuba');
INSERT INTO country (iso, name) VALUES ('CY', 'Cyprus');
INSERT INTO country (iso, name) VALUES ('CZ', 'Czech Republic');
INSERT INTO country (iso, name) VALUES ('DK', 'Denmark');
INSERT INTO country (iso, name) VALUES ('DJ', 'Djibouti');
INSERT INTO country (iso, name) VALUES ('DM', 'Dominica');
INSERT INTO country (iso, name) VALUES ('DO', 'Dominican Republic');
INSERT INTO country (iso, name) VALUES ('EC', 'Ecuador');
INSERT INTO country (iso, name) VALUES ('EG', 'Egypt');
INSERT INTO country (iso, name) VALUES ('SV', 'El Salvador');
INSERT INTO country (iso, name) VALUES ('GQ', 'Equatorial Guinea');
INSERT INTO country (iso, name) VALUES ('ER', 'Eritrea');
INSERT INTO country (iso, name) VALUES ('EE', 'Estonia');
INSERT INTO country (iso, name) VALUES ('ET', 'Ethiopia');
INSERT INTO country (iso, name) VALUES ('FK', 'Falkland Islands (Malvinas)');
INSERT INTO country (iso, name) VALUES ('FO', 'Faroe Islands');
INSERT INTO country (iso, name) VALUES ('FJ', 'Fiji');
INSERT INTO country (iso, name) VALUES ('FI', 'Finland');
INSERT INTO country (iso, name) VALUES ('FR', 'France');
INSERT INTO country (iso, name) VALUES ('GF', 'French Guiana');
INSERT INTO country (iso, name) VALUES ('PF', 'French Polynesia');
INSERT INTO country (iso, name) VALUES ('TF', 'French Southern Territories');
INSERT INTO country (iso, name) VALUES ('GA', 'Gabon');
INSERT INTO country (iso, name) VALUES ('GM', 'Gambia');
INSERT INTO country (iso, name) VALUES ('GE', 'Georgia');
INSERT INTO country (iso, name) VALUES ('DE', 'Germany');
INSERT INTO country (iso, name) VALUES ('GH', 'Ghana');
INSERT INTO country (iso, name) VALUES ('GI', 'Gibraltar');
INSERT INTO country (iso, name) VALUES ('GR', 'Greece');
INSERT INTO country (iso, name) VALUES ('GL', 'Greenland');
INSERT INTO country (iso, name) VALUES ('GD', 'Grenada');
INSERT INTO country (iso, name) VALUES ('GP', 'Guadeloupe');
INSERT INTO country (iso, name) VALUES ('GU', 'Guam');
INSERT INTO country (iso, name) VALUES ('GT', 'Guatemala');
INSERT INTO country (iso, name) VALUES ('GN', 'Guinea');
INSERT INTO country (iso, name) VALUES ('GW', 'Guinea-Bissau');
INSERT INTO country (iso, name) VALUES ('GY', 'Guyana');
INSERT INTO country (iso, name) VALUES ('HT', 'Haiti');
INSERT INTO country (iso, name) VALUES ('HM', 'Heard Island and Mcdonald Islands');
INSERT INTO country (iso, name) VALUES ('VA', 'Holy See (Vatican City State)');
INSERT INTO country (iso, name) VALUES ('HN', 'Honduras');
INSERT INTO country (iso, name) VALUES ('HK', 'Hong Kong');
INSERT INTO country (iso, name) VALUES ('HU', 'Hungary');
INSERT INTO country (iso, name) VALUES ('IS', 'Iceland');
INSERT INTO country (iso, name) VALUES ('IN', 'India');
INSERT INTO country (iso, name) VALUES ('ID', 'Indonesia');
INSERT INTO country (iso, name) VALUES ('IR', 'Iran, Islamic Republic of');
INSERT INTO country (iso, name) VALUES ('IQ', 'Iraq');
INSERT INTO country (iso, name) VALUES ('IE', 'Ireland');
INSERT INTO country (iso, name) VALUES ('IL', 'Israel');
INSERT INTO country (iso, name) VALUES ('IT', 'Italy');
INSERT INTO country (iso, name) VALUES ('JM', 'Jamaica');
INSERT INTO country (iso, name) VALUES ('JP', 'Japan');
INSERT INTO country (iso, name) VALUES ('JO', 'Jordan');
INSERT INTO country (iso, name) VALUES ('KZ', 'Kazakhstan');
INSERT INTO country (iso, name) VALUES ('KE', 'Kenya');
INSERT INTO country (iso, name) VALUES ('KI', 'Kiribati');
INSERT INTO country (iso, name) VALUES ('KP', 'Korea, Democratic People''s Republic of');
INSERT INTO country (iso, name) VALUES ('KR', 'Korea, Republic of');
INSERT INTO country (iso, name) VALUES ('KW', 'Kuwait');
INSERT INTO country (iso, name) VALUES ('KG', 'Kyrgyzstan');
INSERT INTO country (iso, name) VALUES ('LA', 'Lao People''s Democratic Republic');
INSERT INTO country (iso, name) VALUES ('LV', 'Latvia');
INSERT INTO country (iso, name) VALUES ('LB', 'Lebanon');
INSERT INTO country (iso, name) VALUES ('LS', 'Lesotho');
INSERT INTO country (iso, name) VALUES ('LR', 'Liberia');
INSERT INTO country (iso, name) VALUES ('LY', 'Libyan Arab Jamahiriya');
INSERT INTO country (iso, name) VALUES ('LI', 'Liechtenstein');
INSERT INTO country (iso, name) VALUES ('LT', 'Lithuania');
INSERT INTO country (iso, name) VALUES ('LU', 'Luxembourg');
INSERT INTO country (iso, name) VALUES ('MO', 'Macao');
INSERT INTO country (iso, name) VALUES ('MK', 'North Macedonia');
INSERT INTO country (iso, name) VALUES ('MG', 'Madagascar');
INSERT INTO country (iso, name) VALUES ('MW', 'Malawi');
INSERT INTO country (iso, name) VALUES ('MY', 'Malaysia');
INSERT INTO country (iso, name) VALUES ('MV', 'Maldives');
INSERT INTO country (iso, name) VALUES ('ML', 'Mali');
INSERT INTO country (iso, name) VALUES ('MT', 'Malta');
INSERT INTO country (iso, name) VALUES ('MH', 'Marshall Islands');
INSERT INTO country (iso, name) VALUES ('MQ', 'Martinique');
INSERT INTO country (iso, name) VALUES ('MR', 'Mauritania');
INSERT INTO country (iso, name) VALUES ('MU', 'Mauritius');
INSERT INTO country (iso, name) VALUES ('YT', 'Mayotte');
INSERT INTO country (iso, name) VALUES ('MX', 'Mexico');
INSERT INTO country (iso, name) VALUES ('FM', 'Micronesia, Federated States of');
INSERT INTO country (iso, name) VALUES ('MD', 'Moldova, Republic of');
INSERT INTO country (iso, name) VALUES ('MC', 'Monaco');
INSERT INTO country (iso, name) VALUES ('MN', 'Mongolia');
INSERT INTO country (iso, name) VALUES ('MS', 'Montserrat');
INSERT INTO country (iso, name) VALUES ('MA', 'Morocco');
INSERT INTO country (iso, name) VALUES ('MZ', 'Mozambique');
INSERT INTO country (iso, name) VALUES ('MM', 'Myanmar');
INSERT INTO country (iso, name) VALUES ('NA', 'Namibia');
INSERT INTO country (iso, name) VALUES ('NR', 'Nauru');
INSERT INTO country (iso, name) VALUES ('NP', 'Nepal');
INSERT INTO country (iso, name) VALUES ('NL', 'Netherlands');
INSERT INTO country (iso, name) VALUES ('AN', 'Netherlands Antilles');
INSERT INTO country (iso, name) VALUES ('NC', 'New Caledonia');
INSERT INTO country (iso, name) VALUES ('NZ', 'New Zealand');
INSERT INTO country (iso, name) VALUES ('NI', 'Nicaragua');
INSERT INTO country (iso, name) VALUES ('NE', 'Niger');
INSERT INTO country (iso, name) VALUES ('NG', 'Nigeria');
INSERT INTO country (iso, name) VALUES ('NU', 'Niue');
INSERT INTO country (iso, name) VALUES ('NF', 'Norfolk Island');
INSERT INTO country (iso, name) VALUES ('MP', 'Northern Mariana Islands');
INSERT INTO country (iso, name) VALUES ('NO', 'Norway');
INSERT INTO country (iso, name) VALUES ('OM', 'Oman');
INSERT INTO country (iso, name) VALUES ('PK', 'Pakistan');
INSERT INTO country (iso, name) VALUES ('PW', 'Palau');
INSERT INTO country (iso, name) VALUES ('PS', 'Palestinian Territory, Occupied');
INSERT INTO country (iso, name) VALUES ('PA', 'Panama');
INSERT INTO country (iso, name) VALUES ('PG', 'Papua New Guinea');
INSERT INTO country (iso, name) VALUES ('PY', 'Paraguay');
INSERT INTO country (iso, name) VALUES ('PE', 'Peru');
INSERT INTO country (iso, name) VALUES ('PH', 'Philippines');
INSERT INTO country (iso, name) VALUES ('PN', 'Pitcairn');
INSERT INTO country (iso, name) VALUES ('PL', 'Poland');
INSERT INTO country (iso, name) VALUES ('PT', 'Portugal');
INSERT INTO country (iso, name) VALUES ('PR', 'Puerto Rico');
INSERT INTO country (iso, name) VALUES ('QA', 'Qatar');
INSERT INTO country (iso, name) VALUES ('RE', 'Reunion');
INSERT INTO country (iso, name) VALUES ('RO', 'Romania');
INSERT INTO country (iso, name) VALUES ('RU', 'Russian Federation');
INSERT INTO country (iso, name) VALUES ('RW', 'Rwanda');
INSERT INTO country (iso, name) VALUES ('SH', 'Saint Helena');
INSERT INTO country (iso, name) VALUES ('KN', 'Saint Kitts and Nevis');
INSERT INTO country (iso, name) VALUES ('LC', 'Saint Lucia');
INSERT INTO country (iso, name) VALUES ('PM', 'Saint Pierre and Miquelon');
INSERT INTO country (iso, name) VALUES ('VC', 'Saint Vincent and the Grenadines');
INSERT INTO country (iso, name) VALUES ('WS', 'Samoa');
INSERT INTO country (iso, name) VALUES ('SM', 'San Marino');
INSERT INTO country (iso, name) VALUES ('ST', 'Sao Tome and Principe');
INSERT INTO country (iso, name) VALUES ('SA', 'Saudi Arabia');
INSERT INTO country (iso, name) VALUES ('SN', 'Senegal');
INSERT INTO country (iso, name) VALUES ('RS', 'Serbia');
INSERT INTO country (iso, name) VALUES ('SC', 'Seychelles');
INSERT INTO country (iso, name) VALUES ('SL', 'Sierra Leone');
INSERT INTO country (iso, name) VALUES ('SG', 'Singapore');
INSERT INTO country (iso, name) VALUES ('SK', 'Slovakia');
INSERT INTO country (iso, name) VALUES ('SI', 'Slovenia');
INSERT INTO country (iso, name) VALUES ('SB', 'Solomon Islands');
INSERT INTO country (iso, name) VALUES ('SO', 'Somalia');
INSERT INTO country (iso, name) VALUES ('ZA', 'South Africa');
INSERT INTO country (iso, name) VALUES ('GS', 'South Georgia and the South Sandwich Islands');
INSERT INTO country (iso, name) VALUES ('ES', 'Spain');
INSERT INTO country (iso, name) VALUES ('LK', 'Sri Lanka');
INSERT INTO country (iso, name) VALUES ('SD', 'Sudan');
INSERT INTO country (iso, name) VALUES ('SR', 'Suriname');
INSERT INTO country (iso, name) VALUES ('SJ', 'Svalbard and Jan Mayen');
INSERT INTO country (iso, name) VALUES ('SZ', 'Swaziland');
INSERT INTO country (iso, name) VALUES ('SE', 'Sweden');
INSERT INTO country (iso, name) VALUES ('CH', 'Switzerland');
INSERT INTO country (iso, name) VALUES ('SY', 'Syrian Arab Republic');
INSERT INTO country (iso, name) VALUES ('TW', 'Taiwan, Province of China');
INSERT INTO country (iso, name) VALUES ('TJ', 'Tajikistan');
INSERT INTO country (iso, name) VALUES ('TZ', 'Tanzania, United Republic of');
INSERT INTO country (iso, name) VALUES ('TH', 'Thailand');
INSERT INTO country (iso, name) VALUES ('TL', 'Timor-Leste');
INSERT INTO country (iso, name) VALUES ('TG', 'Togo');
INSERT INTO country (iso, name) VALUES ('TK', 'Tokelau');
INSERT INTO country (iso, name) VALUES ('TO', 'Tonga');
INSERT INTO country (iso, name) VALUES ('TT', 'Trinidad and Tobago');
INSERT INTO country (iso, name) VALUES ('TN', 'Tunisia');
INSERT INTO country (iso, name) VALUES ('TR', 'Turkey');
INSERT INTO country (iso, name) VALUES ('TM', 'Turkmenistan');
INSERT INTO country (iso, name) VALUES ('TC', 'Turks and Caicos Islands');
INSERT INTO country (iso, name) VALUES ('TV', 'Tuvalu');
INSERT INTO country (iso, name) VALUES ('UG', 'Uganda');
INSERT INTO country (iso, name) VALUES ('UA', 'Ukraine');
INSERT INTO country (iso, name) VALUES ('AE', 'United Arab Emirates');
INSERT INTO country (iso, name) VALUES ('GB', 'United Kingdom');
INSERT INTO country (iso, name) VALUES ('US', 'United States');
INSERT INTO country (iso, name) VALUES ('UM', 'United States Minor Outlying Islands');
INSERT INTO country (iso, name) VALUES ('UY', 'Uruguay');
INSERT INTO country (iso, name) VALUES ('UZ', 'Uzbekistan');
INSERT INTO country (iso, name) VALUES ('VU', 'Vanuatu');
INSERT INTO country (iso, name) VALUES ('VE', 'Venezuela');
INSERT INTO country (iso, name) VALUES ('VN', 'Viet Nam');
INSERT INTO country (iso, name) VALUES ('VG', 'Virgin Islands, British');
INSERT INTO country (iso, name) VALUES ('VI', 'Virgin Islands, U.s.');
INSERT INTO country (iso, name) VALUES ('WF', 'Wallis and Futuna');
INSERT INTO country (iso, name) VALUES ('EH', 'Western Sahara');
INSERT INTO country (iso, name) VALUES ('YE', 'Yemen');
INSERT INTO country (iso, name) VALUES ('ZM', 'Zambia');
INSERT INTO country (iso, name) VALUES ('ZW', 'Zimbabwe');
INSERT INTO country (iso, name) VALUES ('ME', 'Montenegro');
INSERT INTO country (iso, name) VALUES ('XK', 'Kosovo');
INSERT INTO country (iso, name) VALUES ('AX', 'Aland Islands');
INSERT INTO country (iso, name) VALUES ('BQ', 'Bonaire, Sint Eustatius and Saba');
INSERT INTO country (iso, name) VALUES ('CW', 'Curacao');
INSERT INTO country (iso, name) VALUES ('GG', 'Guernsey');
INSERT INTO country (iso, name) VALUES ('IM', 'Isle of Man');
INSERT INTO country (iso, name) VALUES ('JE', 'Jersey');
INSERT INTO country (iso, name) VALUES ('BL', 'Saint Barthelemy');
INSERT INTO country (iso, name) VALUES ('MF', 'Saint Martin');
INSERT INTO country (iso, name) VALUES ('SX', 'Sint Maarten');
INSERT INTO country (iso, name) VALUES ('SS', 'South Sudan');

-- Account

INSERT INTO account (username, password, email, is_admin) VALUES ('admin', '$2y$10$H79wwJSwhsb2aan4MMnv5ODCNrPZjtPge5MKRquDMZ7.dXjHriDhy', 'admin@gmail.com', TRUE);
INSERT INTO account (username, password, email) VALUES ('nenieats', '$2y$10$H79wwJSwhsb2aan4MMnv5ODCNrPZjtPge5MKRquDMZ7.dXjHriDhy', 'nenieats@gmail.com');
INSERT INTO account (username, password, email) VALUES ('pedgojodge', '$2y$10$H79wwJSwhsb2aan4MMnv5ODCNrPZjtPge5MKRquDMZ7.dXjHriDhy', 'pedgojodge@gmail.com');
INSERT INTO account (username, password, email) VALUES ('guninha_uwu', '$2y$10$H79wwJSwhsb2aan4MMnv5ODCNrPZjtPge5MKRquDMZ7.dXjHriDhy', 'kbaby69@gmail.com');
INSERT INTO account (username, password, email) VALUES ('bababooey', '$2y$10$H79wwJSwhsb2aan4MMnv5ODCNrPZjtPge5MKRquDMZ7.dXjHriDhy', 'nhonholoro@gmail.com');
INSERT INTO account (username, password, email) VALUES ('ccominotti0', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'tgaynes0@unicef.org');
INSERT INTO account (username, password, email) VALUES ('csand1', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'kgonneau1@ca.gov');
INSERT INTO account (username, password, email) VALUES ('apusey2', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'fjanjic2@rambler.ru');
INSERT INTO account (username, password, email) VALUES ('llevi3', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'lrobbins3@jigsy.com');
INSERT INTO account (username, password, email) VALUES ('aillesley4', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'dluddy4@about.com');
INSERT INTO account (username, password, email) VALUES ('nallkins5', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'edederick5@ftc.gov');
INSERT INTO account (username, password, email) VALUES ('acaruth6', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'dfathers6@geocities.jp');
INSERT INTO account (username, password, email) VALUES ('gdunklee7', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'cearle7@oracle.com');
INSERT INTO account (username, password, email) VALUES ('mthackeray8', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'hlincke8@oracle.com');
INSERT INTO account (username, password, email) VALUES ('tbrewins9', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'drendell9@sbwire.com');
INSERT INTO account (username, password, email) VALUES ('oviant0', '$2y$10$H79wwJSwhsb2aan4MMnv5ODCNrPZjtPge5MKRquDMZ7.dXjHriDhy', 'hlocal0@timesonline.co.uk');
INSERT INTO account (username, password, email) VALUES ('jcromack1', '$2y$10$H79wwJSwhsb2aan4MMnv5ODCNrPZjtPge5MKRquDMZ7.dXjHriDhy', 'jpoetz1@123-reg.co.uk');
INSERT INTO account (username, password, email) VALUES ('acunliffe2', '$2y$10$H79wwJSwhsb2aan4MMnv5ODCNrPZjtPge5MKRquDMZ7.dXjHriDhy', 'mdemann2@dion.ne.jp');
INSERT INTO account (username, password, email) VALUES ('nlewton3', '$2y$10$H79wwJSwhsb2aan4MMnv5ODCNrPZjtPge5MKRquDMZ7.dXjHriDhy', 'jdillon3@wix.com');
INSERT INTO account (username, password, email) VALUES ('hlawleff4', '$2y$10$H79wwJSwhsb2aan4MMnv5ODCNrPZjtPge5MKRquDMZ7.dXjHriDhy', 'cgertray4@nbcnews.com');
INSERT INTO account (username, password, email) VALUES ('kgindghill5', '$2y$10$H79wwJSwhsb2aan4MMnv5ODCNrPZjtPge5MKRquDMZ7.dXjHriDhy', 'amusterd5@engadget.com');
INSERT INTO account (username, password, email) VALUES ('edesquesnes6', '$2y$10$H79wwJSwhsb2aan4MMnv5ODCNrPZjtPge5MKRquDMZ7.dXjHriDhy', 'bstrathearn6@list-manage.com');
INSERT INTO account (username, password, email) VALUES ('mkleinhaus7', '$2y$10$H79wwJSwhsb2aan4MMnv5ODCNrPZjtPge5MKRquDMZ7.dXjHriDhy', 'kscripture7@fc2.com');
INSERT INTO account (username, password, email) VALUES ('tmorecomb8', '$2y$10$H79wwJSwhsb2aan4MMnv5ODCNrPZjtPge5MKRquDMZ7.dXjHriDhy', 'gben8@huffingtonpost.com');
INSERT INTO account (username, password, email) VALUES ('mbrockelsby9', '$2y$10$H79wwJSwhsb2aan4MMnv5ODCNrPZjtPge5MKRquDMZ7.dXjHriDhy', 'waustin9@baidu.com');


-- Client

INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (2, 'Whitby Dumberell', 'Centimia', 'avatars/AvatarMaker1.png', '#69ca7f', 'Unspecified', 172);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (3, 'Consalve Abys', 'Photobug', 'avatars/AvatarMaker2.png', '#83c20b', 'Male', 172);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (4, 'Effie Yuille', 'Oba', 'avatars/AvatarMaker3.png', '#67dfd5', 'Female', 172);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (5, 'Analise Gooderick', 'Rhybox', 'avatars/AvatarMaker4.png', '#1431c5', 'Unspecified', 172);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (6, 'Orville Gostage', 'Vitz', 'avatars/AvatarMaker5.png', '#56f8fb', 'Unspecified', 172);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (7, 'Burt Yearnsley', 'Izio', 'avatars/AvatarMaker6.png', '#1b3404', 'Unspecified', 172);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (8, 'Wynnie Wey', 'Yodoo', 'avatars/AvatarMaker7.png', '#006205', 'Unspecified', 172);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (9, 'Pearla Gaine of England', 'Skinix', 'avatars/AvatarMaker8.png', '#efdca5', 'Unspecified', 172);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (10, 'Wernher O''Dowling', 'Leenti', 'avatars/AvatarMaker9.png', '#aba97c', 'Unspecified', 172);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (11, 'Mary Pietersma', 'Fivebridge', 'avatars/AvatarMaker10.png', '#dd6d7b', 'Unspecified', 226);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (12, 'Hanan Tryme', 'Shuffledrive', 'avatars/AvatarMaker11.png', '#0e565d', 'Female', 226);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (13, 'Madel Dunkinson', 'Centizu', 'avatars/AvatarMaker12.png', '#adc321', 'Female', 226);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (14, 'Kirby Woolway', 'Realpoint', 'avatars/AvatarMaker13.png', '#dee419', 'Unspecified', 226);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (15, 'Birdie Tertre', 'Quinu', 'avatars/AvatarMaker14.png', '#cc2207', 'Unspecified', 38);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (16, 'Jacquie Meran', 'Divanoodle', 'avatars/AvatarMaker15.png', '#cf64db', 'Unspecified', 38);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (17, 'Agatha Lockhurst', 'Skyndu', 'avatars/AvatarMaker16.png', '#bbcaa3', 'Unspecified', 38);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (18, 'Chad Outhwaite', 'Dabjam', 'avatars/AvatarMaker17.png', '#c098a9', 'Female', 110);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (19, 'Nathalia Pues', 'Browsebug', 'avatars/AvatarMaker18.png', '#7fdc98', 'Male', 110);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (20, 'Marcelline Ruske', 'Yakijo', 'avatars/AvatarMaker19.png', '#e65f3f', 'Female', 240);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (21, 'Cordie Kareman', 'Ooba', 'avatars/AvatarMaker20.png', '#03f5cb', 'Male', 240);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (22, 'Georgeanna Gruczka', 'Dablist', 'avatars/AvatarMaker21.png', '#831dcd', 'Female', 110);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (23, 'Amber Terrans', 'Yodo', 'avatars/AvatarMaker22.png', '#16887b', 'Unspecified', 38);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (24, 'Darcee Bullas', 'Quatz', 'avatars/AvatarMaker23.png', '#44ea40', 'Unspecified', 38);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (25, 'Lilla Ridel', 'Babbleopia', 'avatars/AvatarMaker24.png', '#eb7680', 'Unspecified', 240);


-- Project

INSERT INTO project (name, description, due_date) VALUES ('repurpose efficient portals', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', '2022-12-20');
INSERT INTO project (name, description, due_date) VALUES ('mesh collaborative platforms', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', '2022-02-06');
INSERT INTO project (name, description, due_date) VALUES ('maximize plug-and-play applications', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', '2022-09-26');
INSERT INTO project (name, description, due_date) VALUES ('synergize intuitive interfaces', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', '2022-08-27');
INSERT INTO project (name, description, due_date) VALUES ('facilitate dot-com deliverables', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', '2022-01-09');
INSERT INTO project (name, description, due_date) VALUES ('whiteboard integrated web services', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl.', '2022-06-27');
INSERT INTO project (name, description, due_date) VALUES ('engage integrated infrastructures', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', '2022-06-26');
INSERT INTO project (name, description, due_date) VALUES ('seize web-enabled ROI', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '2022-05-07');
INSERT INTO project (name, description, due_date) VALUES ('innovate compelling applications', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', '2022-10-28');
INSERT INTO project (name, description, due_date) VALUES ('mesh impactful users', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', null);
INSERT INTO project (name, description, due_date) VALUES ('recontextualize 24/365 applications', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', '2022-07-11');
INSERT INTO project (name, description, due_date) VALUES ('unleash revolutionary communities', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', '2022-03-12');
INSERT INTO project (name, description, due_date) VALUES ('repurpose integrated models', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', null);
INSERT INTO project (name, description, due_date) VALUES ('evolve dynamic partnerships', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl.', '2022-03-25');
INSERT INTO project (name, description, due_date) VALUES ('grow 24/365 infrastructures', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', '2022-03-24');
INSERT INTO project (name, description, due_date) VALUES ('disintermediate one-to-one infomediaries', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', '2021-08-30');
INSERT INTO project (name, description, due_date) VALUES ('envisioneer cross-media mindshare', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.', null);
INSERT INTO project (name, description, due_date) VALUES ('implement front-end architectures', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '2022-06-26');
INSERT INTO project (name, description, due_date) VALUES ('grow wireless vortals', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', null);
INSERT INTO project (name, description, due_date) VALUES ('mesh vertical architectures', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', '2022-04-14');
INSERT INTO project (name, description, due_date) VALUES ('whiteboard magnetic technologies', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', null);
INSERT INTO project (name, description, due_date) VALUES ('orchestrate best-of-breed users', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', null);
INSERT INTO project (name, description, due_date) VALUES ('repurpose integrated e-commerce', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', '2021-11-09');
INSERT INTO project (name, description, due_date) VALUES ('enhance cutting-edge channels', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '2022-10-29');
INSERT INTO project (name, description, due_date) VALUES ('empower real-time models', 'Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', '2021-08-14');
INSERT INTO project (name, description, due_date) VALUES ('visualize dynamic experiences', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', null);
INSERT INTO project (name, description, due_date) VALUES ('morph collaborative methodologies', 'Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', '2022-07-24');
INSERT INTO project (name, description, due_date) VALUES ('enhance robust convergence', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', '2021-08-28');
INSERT INTO project (name, description, due_date) VALUES ('empower cross-media channels', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '2021-12-05');
INSERT INTO project (name, description, due_date) VALUES ('orchestrate e-business technologies', 'Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '2022-12-08');
INSERT INTO project (name, description, due_date) VALUES ('scale dynamic metrics', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '2022-06-11');
INSERT INTO project (name, description, due_date) VALUES ('incubate open-source e-markets', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', null);
INSERT INTO project (name, description, due_date) VALUES ('morph efficient mindshare', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', null);
INSERT INTO project (name, description, due_date) VALUES ('grow impactful interfaces', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', '2022-07-30');
INSERT INTO project (name, description, due_date) VALUES ('seize mission-critical niches', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '2022-06-09');
INSERT INTO project (name, description, due_date) VALUES ('expedite intuitive infomediaries', 'Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', '2022-09-14');
INSERT INTO project (name, description, due_date) VALUES ('morph e-business vortals', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '2022-06-11');
INSERT INTO project (name, description, due_date) VALUES ('engineer cross-platform synergies', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', null);
INSERT INTO project (name, description, due_date) VALUES ('repurpose extensible eyeballs', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', '2022-04-02');
INSERT INTO project (name, description, due_date) VALUES ('facilitate end-to-end models', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2022-04-27');
INSERT INTO project (name, description, due_date) VALUES ('enhance next-generation markets', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', null);
INSERT INTO project (name, description, due_date) VALUES ('matrix killer web-readiness', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', '2022-10-27');
INSERT INTO project (name, description, due_date) VALUES ('productize turn-key e-services', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '2021-09-06');
INSERT INTO project (name, description, due_date) VALUES ('seize open-source infrastructures', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', null);
INSERT INTO project (name, description, due_date) VALUES ('integrate rich relationships', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '2022-02-23');
INSERT INTO project (name, description, due_date) VALUES ('deliver rich convergence', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '2022-08-06');
INSERT INTO project (name, description, due_date) VALUES ('seize strategic mindshare', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '2021-07-20');
INSERT INTO project (name, description, due_date) VALUES ('engineer integrated platforms', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', '2022-09-20');
INSERT INTO project (name, description, due_date) VALUES ('enable dot-com applications', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', '2022-06-07');
INSERT INTO project (name, description, due_date) VALUES ('morph out-of-the-box partnerships', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '2022-06-16');


-- Invite

INSERT INTO invite (client_id, project_id) VALUES (8, 13);
INSERT INTO invite (client_id, project_id) VALUES (12, 13);
INSERT INTO invite (client_id, project_id) VALUES (16, 13);
INSERT INTO invite (client_id, project_id) VALUES (3, 46);
INSERT INTO invite (client_id, project_id) VALUES (4, 46);
INSERT INTO invite (client_id, project_id) VALUES (10, 46);
INSERT INTO invite (client_id, project_id) VALUES (22, 46);


-- Team Member

INSERT INTO team_member (client_id, project_id, member_role) VALUES (2, 1, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (2, 3, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (2, 8, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (2, 10, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (2, 13, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (2, 24, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (2, 33, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (2, 35, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (2, 36, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (2, 46, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (3, 1, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (3, 5, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (3, 7, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (3, 11, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (3, 17, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (3, 23, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (3, 32, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (3, 37, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (3, 40, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (3, 47, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (3, 48, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 7, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 8, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 9, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 12, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 14, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 16, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 17, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 22, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 30, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 36, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 38, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 41, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 42, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 43, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 44, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (4, 50, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (5, 4, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (5, 5, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (5, 8, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (5, 9, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (5, 10, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (5, 13, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (5, 17, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (5, 28, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (5, 33, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (5, 36, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (5, 38, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (5, 41, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (5, 45, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (5, 46, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (5, 47, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (6, 5, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (6, 9, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (6, 11, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (6, 14, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (6, 18, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (6, 24, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (6, 25, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (6, 26, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (6, 27, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (6, 28, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (6, 30, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (6, 32, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (6, 38, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (6, 46, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (6, 47, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (7, 3, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (7, 4, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (7, 14, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (7, 34, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (7, 37, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (7, 39, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (7, 46, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (7, 47, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (7, 50, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (8, 4, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (8, 20, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (8, 24, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (8, 28, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (8, 36, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (8, 39, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (8, 41, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (8, 44, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (9, 11, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (9, 18, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (9, 19, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (9, 22, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (9, 24, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (9, 31, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (9, 35, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (9, 40, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (9, 43, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (9, 48, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (10, 3, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (10, 6, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (10, 7, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (10, 11, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (10, 15, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (10, 20, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (10, 31, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (10, 32, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (10, 33, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (10, 37, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (10, 41, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (10, 47, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (11, 5, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (11, 9, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (11, 17, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (11, 18, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (11, 22, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (11, 23, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (11, 25, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (11, 31, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (11, 34, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (11, 35, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (11, 38, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (11, 39, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (12, 1, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (12, 7, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (12, 10, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (12, 12, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (12, 16, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (12, 20, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (12, 22, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (12, 23, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (12, 24, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (12, 28, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (12, 31, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (12, 34, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (12, 40, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (12, 41, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (12, 48, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (13, 1, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (13, 3, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (13, 5, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (13, 6, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (13, 14, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (13, 17, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (13, 27, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (13, 31, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (13, 37, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (13, 38, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (13, 43, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (14, 2, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (14, 20, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (14, 22, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (14, 25, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (14, 26, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (14, 38, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (14, 42, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (14, 50, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (15, 15, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (15, 20, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (15, 24, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (15, 25, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (15, 27, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (15, 36, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (15, 46, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (16, 1, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (16, 4, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (16, 5, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (16, 6, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (16, 12, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (16, 17, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (16, 26, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (16, 33, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (16, 35, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (16, 38, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (16, 42, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (16, 43, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (16, 45, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (17, 2, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (17, 4, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (17, 8, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (17, 12, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (17, 14, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (17, 28, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (17, 37, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (17, 38, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (17, 43, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (17, 44, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (17, 48, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (17, 49, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (18, 8, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (18, 10, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (18, 13, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (18, 16, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (18, 26, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (18, 29, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (18, 35, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (18, 43, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (18, 45, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (19, 1, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (19, 5, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (19, 8, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (19, 10, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (19, 12, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (19, 17, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (19, 22, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (19, 28, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (19, 32, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (19, 38, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (19, 40, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (19, 48, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (20, 1, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (20, 9, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (20, 11, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (20, 17, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (20, 19, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (20, 21, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (20, 25, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (20, 30, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (20, 31, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (20, 32, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (20, 35, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (20, 43, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (20, 44, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (21, 2, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (21, 5, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (21, 11, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (21, 17, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (21, 18, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (21, 19, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (21, 30, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (21, 31, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (21, 34, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (21, 37, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (22, 7, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (22, 12, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (22, 16, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (22, 24, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (22, 25, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (22, 29, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (22, 36, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (22, 39, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (22, 40, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (22, 50, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (23, 6, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (23, 8, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (23, 14, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (23, 17, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (23, 29, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (23, 30, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (23, 39, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (23, 40, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (23, 45, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (23, 47, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (23, 48, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (23, 49, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (24, 2, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (24, 4, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (24, 5, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (24, 6, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (24, 13, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (24, 15, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (24, 24, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (24, 26, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (24, 31, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (24, 42, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (24, 44, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (24, 48, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (25, 1, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (25, 2, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (25, 5, 'Reader');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (25, 6, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (25, 8, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (25, 26, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (25, 27, 'Editor');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (25, 43, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (25, 47, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (25, 48, 'Owner');
INSERT INTO team_member (client_id, project_id, member_role) VALUES (25, 49, 'Owner');


-- Task

INSERT INTO task (project, name, description, due_date, task_status) VALUES (25, 'drive proactive solutions', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat.', '2020-08-23 17:41:34', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (45, 'generate collaborative synergies', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (24, 'harness bleeding-edge e-business', null, '2020-12-26 00:39:36', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (5, 'deploy impactful portals', null, '2020-12-13 08:15:07', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (8, 'aggregate real-time functionalities', 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', '2021-01-05 07:07:11', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (46, 'grow integrated synergies', 'Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (25, 'repurpose out-of-the-box experiences', 'Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (21, 'target 24/365 mindshare', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (23, 'mesh open-source content', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (13, 'architect killer functionalities', 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (40, 'disintermediate B2B interfaces', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (32, 'expedite dot-com supply-chains', null, '2020-05-27 10:57:57', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (29, 'revolutionize enterprise e-business', 'Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (18, 'transition strategic interfaces', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (5, 'grow revolutionary communities', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (27, 'harness compelling methodologies', null, '2020-10-07 17:29:43', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (26, 'evolve interactive partnerships', null, '2020-11-12 18:59:50', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (26, 'incentivize bricks-and-clicks markets', null, '2021-01-06 23:26:48', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (40, 'reinvent rich architectures', 'Sed ante.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (40, 'enhance ubiquitous architectures', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '2021-01-01 13:47:30', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (8, 'implement bleeding-edge portals', 'Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia.', '2021-02-17 09:46:55', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'recontextualize rich content', null, '2020-11-08 08:48:25', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (32, 'transform holistic users', 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (6, 'synergize one-to-one models', null, '2020-08-19 21:20:34', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (17, 'transition wireless niches', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (19, 'whiteboard collaborative e-markets', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo.', '2021-01-11 06:08:26', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (46, 'optimize bleeding-edge functionalities', 'In est risus, auctor sed, tristique in, tempus sit amet, sem.', '2020-09-15 02:02:28', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (37, 'expedite extensible infomediaries', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (24, 'benchmark out-of-the-box schemas', null, '2020-11-20 08:40:16', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (29, 'synergize innovative solutions', 'Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (16, 'incentivize frictionless initiatives', 'Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis.', '2020-11-09 23:52:37', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (34, 'mesh ubiquitous web-readiness', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (17, 'evolve turn-key synergies', 'Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '2020-04-15 22:49:34', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'deliver strategic paradigms', 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis.', '2020-06-20 18:03:07', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (1, 'syndicate holistic deliverables', null, null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (26, 'empower wireless functionalities', 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', '2020-07-05 01:27:11', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (26, 'engage dot-com eyeballs', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (26, 'generate extensible communities', null, '2020-08-20 14:52:03', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (21, 'maximize cross-media solutions', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (36, 'revolutionize frictionless functionalities', 'Phasellus id sapien in sapien iaculis congue.', '2020-12-18 09:12:14', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (24, 'unleash plug-and-play relationships', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', '2020-12-10 07:58:36', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (14, 'utilize end-to-end methodologies', 'Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (5, 'cultivate out-of-the-box eyeballs', 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', '2020-09-28 05:39:15', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (46, 'deploy next-generation eyeballs', 'Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'matrix user-centric interfaces', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (38, 'seize frictionless initiatives', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (47, 'enhance intuitive communities', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (39, 'maximize sticky partnerships', 'Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (36, 'incubate plug-and-play mindshare', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', '2020-04-06 10:41:13', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'grow compelling systems', 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (1, 'engineer bleeding-edge networks', 'In hac habitasse platea dictumst.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (1, 'deploy best-of-breed networks', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (9, 'leverage best-of-breed vortals', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (47, 'orchestrate robust ROI', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.', '2021-02-19 20:11:54', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (49, 'drive clicks-and-mortar platforms', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (49, 'repurpose value-added architectures', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.', '2020-10-20 19:04:47', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (15, 'engage next-generation infomediaries', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (9, 'reintermediate granular networks', 'Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (31, 'leverage one-to-one schemas', 'Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (11, 'enhance B2C supply-chains', 'Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (49, 'aggregate intuitive schemas', 'Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque.', '2020-11-04 16:05:55', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (23, 'disintermediate sexy solutions', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'reinvent mission-critical web-readiness', null, '2021-03-15 03:45:18', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (2, 'scale interactive mindshare', 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.', '2020-09-30 13:42:46', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (22, 'deliver vertical e-services', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (50, 'target dynamic channels', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (22, 'synthesize rich channels', 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam. Nam tristique tortor eu pede.', '2021-01-21 04:52:12', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (50, 'transform bleeding-edge models', 'Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'deploy impactful networks', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (4, 'reintermediate B2B communities', 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.', '2021-02-01 09:10:12', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (43, 'generate sexy e-markets', 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (17, 'incentivize out-of-the-box convergence', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '2020-12-21 10:36:25', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (6, 'scale global networks', 'Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.', '2020-05-06 16:45:49', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (17, 'redefine scalable schemas', 'Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', '2020-04-30 03:03:19', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (42, 'visualize cross-platform eyeballs', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (49, 'transition magnetic web services', 'Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2020-12-31 08:51:31', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (11, 'evolve one-to-one users', 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (38, 'deliver revolutionary technologies', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.', '2021-02-26 21:39:44', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (27, 'orchestrate one-to-one communities', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (35, 'whiteboard clicks-and-mortar e-services', 'Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (8, 'grow leading-edge methodologies', 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (3, 'visualize intuitive infrastructures', 'Duis aliquam convallis nunc.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (37, 'envisioneer synergistic paradigms', 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2020-09-17 05:13:31', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (10, 'expedite wireless ROI', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (19, 'engineer ubiquitous markets', 'Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis.', '2021-02-07 18:47:09', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'utilize efficient synergies', null, '2020-10-18 00:49:17', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (20, 'envisioneer front-end partnerships', 'Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (32, 'harness wireless eyeballs', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (41, 'monetize distributed e-business', null, '2020-12-25 18:43:52', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'monetize viral infomediaries', null, '2021-03-02 10:33:17', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (7, 'maximize bricks-and-clicks metrics', null, '2020-08-14 21:26:46', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (25, 'engineer one-to-one web services', 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (32, 'repurpose best-of-breed infomediaries', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (30, 'morph dot-com applications', 'Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam. Nam tristique tortor eu pede.', '2021-01-08 16:31:16', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (49, 'scale killer users', 'Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (48, 'envisioneer cross-media niches', 'Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (34, 'monetize bricks-and-clicks e-commerce', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem.', '2021-02-15 17:39:21', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (9, 'cultivate seamless interfaces', 'Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis.', '2020-09-03 06:23:01', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'enable interactive markets', null, '2020-07-12 03:08:52', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (25, 'benchmark frictionless architectures', 'Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (6, 'enhance impactful methodologies', null, '2020-04-14 10:05:00', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (30, 'envisioneer leading-edge metrics', 'Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (33, 'engineer collaborative technologies', 'Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', '2020-10-25 01:43:35', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (24, 'expedite collaborative systems', 'Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (43, 'brand 24/7 communities', 'Donec posuere metus vitae ipsum.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (21, 'iterate rich web-readiness', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (50, 'engineer plug-and-play initiatives', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (24, 'cultivate holistic metrics', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (47, 'maximize cross-media metrics', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst.', '2020-09-03 11:30:15', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (43, 'optimize killer e-tailers', 'Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', '2020-10-25 23:00:46', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (39, 'repurpose sticky convergence', 'Praesent id massa id nisl venenatis lacinia.', '2020-10-14 11:07:26', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (14, 'embrace ubiquitous functionalities', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (33, 'scale magnetic e-services', null, '2020-05-29 22:13:03', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'synergize impactful experiences', null, '2020-04-07 09:24:47', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (38, 'disintermediate seamless experiences', 'Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.', '2020-04-08 02:49:34', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (43, 'enhance best-of-breed partnerships', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.', '2021-02-15 21:07:51', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (18, 'monetize revolutionary mindshare', null, '2021-02-15 04:29:49', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (21, 'innovate cutting-edge infomediaries', 'Curabitur convallis.', '2020-05-08 14:52:54', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (48, 'architect virtual eyeballs', 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus.', '2020-06-15 07:25:31', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (27, 'unleash synergistic vortals', null, '2020-06-28 13:34:46', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (33, 'reintermediate wireless technologies', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (5, 'expedite integrated eyeballs', null, '2020-10-01 23:17:52', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (28, 'morph impactful functionalities', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.', '2020-06-04 07:08:23', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (2, 'streamline global functionalities', null, '2021-01-28 07:41:23', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (48, 'transition sticky deliverables', 'In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst.', '2021-01-25 22:33:53', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'architect compelling schemas', 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo.', '2020-11-23 12:07:47', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (7, 'empower customized e-markets', 'Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla.', '2020-09-13 08:40:32', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (29, 'target intuitive interfaces', 'Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.', '2020-09-20 12:56:30', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (18, 'morph sexy niches', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (40, 'expedite customized architectures', 'Proin eu mi.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (49, 'streamline synergistic niches', 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.', '2020-06-29 17:31:11', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (6, 'expedite seamless platforms', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo.', '2021-02-19 06:12:04', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (7, 'aggregate transparent synergies', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (22, 'transition magnetic partnerships', 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (11, 'syndicate open-source architectures', 'Mauris lacinia sapien quis libero.', '2020-06-23 00:05:10', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (11, 'generate global communities', null, '2021-02-23 18:27:16', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (17, 'transition wireless partnerships', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (11, 'disintermediate leading-edge content', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (33, 'matrix vertical relationships', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (49, 'empower world-class methodologies', 'Pellentesque viverra pede ac diam.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (5, 'cultivate user-centric solutions', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (48, 'incentivize virtual solutions', 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2020-05-20 15:00:42', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'deliver extensible interfaces', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien.', '2021-01-01 23:03:36', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (32, 'integrate proactive infomediaries', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', '2020-12-17 12:35:18', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (31, 'generate world-class experiences', 'Ut tellus. Nulla ut erat id mauris vulputate elementum.', '2020-04-17 00:59:44', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (8, 'aggregate end-to-end web services', null, '2020-08-17 06:42:36', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (16, 'reintermediate viral infrastructures', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', '2020-06-13 13:16:25', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (24, 'reintermediate best-of-breed web-readiness', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (43, 'e-enable real-time convergence', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.', '2021-02-16 13:22:14', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (22, 'target leading-edge web-readiness', 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', '2020-07-08 03:21:49', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (10, 'engage real-time niches', 'Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', '2020-05-23 20:04:04', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (7, 'enhance open-source systems', null, '2020-03-26 07:26:19', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (16, 'harness integrated markets', null, '2020-12-26 19:51:59', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (5, 'matrix bricks-and-clicks web services', 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', '2020-04-18 17:57:21', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (48, 'visualize B2C e-commerce', 'Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '2020-08-02 21:21:52', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (13, 'optimize cutting-edge supply-chains', 'Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', '2021-03-03 00:47:24', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (14, 'expedite world-class eyeballs', 'Pellentesque ultrices mattis odio.', '2020-11-02 03:23:31', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (49, 'benchmark back-end technologies', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (1, 'disintermediate frictionless synergies', 'Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (38, 'envisioneer frictionless solutions', null, '2020-12-20 17:47:22', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (50, 'whiteboard viral e-tailers', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', '2020-12-31 02:11:35', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (47, 'strategize back-end architectures', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', '2020-07-20 04:03:11', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (31, 'streamline open-source relationships', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (5, 'implement world-class action-items', 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', '2020-11-12 10:09:48', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (13, 'morph best-of-breed solutions', null, '2020-07-07 04:23:24', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (23, 'innovate web-enabled interfaces', 'Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (30, 'integrate innovative partnerships', 'Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (32, 'synthesize killer methodologies', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', '2020-11-16 05:12:38', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (50, 'recontextualize web-enabled channels', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio.', '2021-02-06 20:01:09', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (50, 'harness 24/7 paradigms', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (21, 'visualize 24/365 eyeballs', 'Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', '2021-02-08 17:39:12', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (38, 'generate distributed applications', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (1, 'strategize scalable niches', null, '2020-07-16 11:33:10', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (27, 'utilize web-enabled channels', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (42, 'transform e-business architectures', null, '2021-01-31 07:11:28', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (2, 'maximize viral partnerships', null, '2020-07-13 22:43:22', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (11, 'cultivate sticky infomediaries', null, '2020-12-05 05:39:09', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (20, 'implement next-generation deliverables', 'Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (25, 'embrace dynamic relationships', 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', '2020-10-12 10:25:51', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (9, 'streamline granular platforms', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (45, 'mesh one-to-one portals', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (4, 'embrace visionary technologies', null, '2020-11-06 13:51:14', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (1, 'harness cross-media communities', 'Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (36, 'deliver open-source mindshare', null, '2020-08-15 21:38:18', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (42, 'streamline visionary architectures', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.', '2020-06-29 03:16:44', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'transform revolutionary platforms', null, '2020-05-07 20:18:24', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (28, 'incubate virtual channels', 'Integer ac leo.', '2020-09-14 16:52:15', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (30, 'transform web-enabled infomediaries', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.', '2021-02-15 03:51:06', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (23, 'redefine best-of-breed deliverables', 'Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (5, 'integrate next-generation e-markets', 'Nulla facilisi.', '2020-10-30 22:32:42', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (45, 'reinvent customized initiatives', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (19, 'deliver ubiquitous e-commerce', 'Donec vitae nisi.', '2020-07-27 11:14:53', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (15, 'syndicate sticky models', 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', '2020-11-15 15:53:48', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (16, 'expedite plug-and-play supply-chains', 'Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (27, 'mesh frictionless methodologies', 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', '2020-11-16 04:46:35', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (27, 'maximize ubiquitous channels', 'Nam nulla.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (43, 'strategize efficient metrics', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', '2020-05-11 10:12:04', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (7, 'maximize back-end eyeballs', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (31, 'brand back-end convergence', 'Proin risus.', '2020-04-13 03:39:24', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (33, 'whiteboard leading-edge niches', null, '2020-11-28 14:52:22', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (41, 'extend cross-platform mindshare', null, '2020-09-30 15:54:48', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (21, 'visualize plug-and-play convergence', 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (19, 'facilitate enterprise e-business', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.', '2020-09-24 01:48:08', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (17, 'generate seamless technologies', null, '2020-09-08 10:30:28', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (27, 'transition integrated bandwidth', 'Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (21, 'facilitate visionary relationships', null, '2020-03-27 08:02:07', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (6, 'reintermediate enterprise partnerships', 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', '2020-04-11 15:56:17', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (47, 'reinvent enterprise ROI', 'Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis.', '2021-02-01 18:47:27', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (46, 'visualize proactive initiatives', null, '2020-09-28 05:53:08', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (14, 'facilitate extensible solutions', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (30, 'synthesize e-business partnerships', null, null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (39, 'redefine frictionless e-markets', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (6, 'engage dot-com e-business', null, '2020-11-26 16:32:39', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (13, 'recontextualize turn-key portals', 'Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', '2020-07-28 10:50:49', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (13, 'whiteboard virtual markets', 'In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', '2020-05-11 14:37:01', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (40, 'optimize seamless e-markets', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (31, 'monetize dynamic paradigms', 'Donec dapibus. Duis at velit eu est congue elementum.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (10, 'productize rich networks', 'Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'cultivate user-centric eyeballs', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (22, 'whiteboard strategic functionalities', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.', '2021-03-08 03:09:39', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (34, 'extend e-business paradigms', 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis.', '2020-04-18 20:22:50', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (35, 'deploy world-class relationships', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (39, 'envisioneer bleeding-edge metrics', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (10, 'aggregate e-business partnerships', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.', '2020-09-18 09:01:56', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (23, 'incubate killer bandwidth', 'Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.', '2020-09-18 03:53:35', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (21, 'scale front-end systems', 'Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.', '2020-04-14 17:06:59', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (20, 'target value-added users', null, '2020-08-06 21:23:06', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (33, 'seize back-end partnerships', 'Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (5, 'envisioneer impactful applications', null, '2020-12-17 19:11:24', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (15, 'transform holistic platforms', 'Morbi porttitor lorem id ligula.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (18, 'seize end-to-end functionalities', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla.', '2020-06-22 21:45:36', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (15, 'disintermediate mission-critical web-readiness', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '2021-03-06 03:44:33', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (34, 'extend 24/7 action-items', null, null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'reintermediate front-end schemas', null, null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'extend next-generation content', 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', '2020-08-28 07:46:50', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (1, 'incentivize e-business web services', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (16, 'deploy impactful architectures', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (27, 'maximize B2B web services', 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (39, 'repurpose integrated partnerships', 'Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (14, 'synthesize B2B architectures', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.', '2020-08-06 14:56:22', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (27, 'incentivize visionary bandwidth', null, '2021-01-13 03:10:28', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (13, 'architect best-of-breed e-commerce', 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', '2021-03-14 14:42:44', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (37, 'cultivate B2B bandwidth', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (28, 'target magnetic infrastructures', 'In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (3, 'utilize magnetic models', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (40, 'whiteboard holistic interfaces', 'Aliquam non mauris. Morbi non lectus.', '2020-06-12 02:53:49', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (1, 'aggregate virtual infomediaries', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (9, 'utilize real-time e-commerce', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (2, 'deliver transparent initiatives', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (35, 'target seamless convergence', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo.', '2020-09-24 03:06:26', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (24, 'enable ubiquitous convergence', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', '2020-10-06 21:07:18', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (21, 'harness strategic channels', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (29, 'deliver plug-and-play web services', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (39, 'expedite scalable methodologies', null, '2020-07-04 05:06:03', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (19, 'recontextualize B2C applications', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', '2020-06-03 13:07:02', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (49, 'maximize 24/7 ROI', 'In est risus, auctor sed, tristique in, tempus sit amet, sem.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (35, 'drive holistic e-business', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (19, 'orchestrate e-business e-services', 'Nunc purus. Phasellus in felis. Donec semper sapien a libero.', '2020-06-10 07:35:39', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (29, 'extend granular channels', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (41, 'engage value-added networks', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '2020-08-28 02:18:49', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (5, 'cultivate cross-media infomediaries', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', '2020-12-14 08:29:53', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (30, 'generate intuitive platforms', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (31, 'architect frictionless paradigms', 'Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '2020-07-20 20:40:43', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'disintermediate extensible niches', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (20, 'expedite magnetic e-services', 'Etiam faucibus cursus urna.', '2020-08-24 08:04:38', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'benchmark collaborative applications', 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.', '2020-10-29 15:59:55', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (25, 'envisioneer plug-and-play architectures', null, '2020-04-22 05:32:04', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (2, 'recontextualize value-added solutions', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (19, 'facilitate killer niches', null, '2020-07-02 22:09:35', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (39, 'reintermediate front-end systems', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.', '2020-07-18 19:41:18', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (20, 'implement transparent infomediaries', 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (48, 'synthesize turn-key vortals', 'Nunc nisl.', '2020-05-24 15:50:02', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'reinvent interactive platforms', 'Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (40, 'benchmark sexy action-items', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (35, 'iterate dynamic platforms', null, '2020-05-17 16:01:15', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (47, 'drive synergistic e-tailers', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'drive web-enabled methodologies', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', '2020-07-27 20:27:15', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (23, 'scale efficient solutions', 'Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.', '2020-11-01 23:09:10', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (7, 'revolutionize out-of-the-box synergies', null, '2020-11-25 08:33:05', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (7, 'revolutionize front-end paradigms', 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', '2021-02-03 00:26:39', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (15, 'benchmark synergistic web-readiness', 'Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (23, 'disintermediate virtual web services', 'Aenean lectus. Pellentesque eget nunc.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (11, 'optimize holistic mindshare', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (15, 'scale back-end eyeballs', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.', '2020-06-29 18:00:22', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (19, 'expedite mission-critical paradigms', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', '2020-06-29 03:47:40', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (30, 'expedite mission-critical relationships', 'Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (24, 'transform virtual e-business', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', '2020-07-21 23:56:13', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (21, 'transform collaborative action-items', 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '2021-01-16 20:51:59', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (16, 'incentivize leading-edge channels', 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.', '2020-04-27 14:31:32', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (39, 'aggregate cross-platform convergence', 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (25, 'synthesize B2C platforms', 'Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', '2021-01-16 02:21:07', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (47, 'drive strategic portals', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (7, 'envisioneer dynamic eyeballs', 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (40, 'reintermediate distributed relationships', null, '2020-05-11 22:38:26', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (33, 'deploy synergistic systems', null, '2020-09-12 00:08:51', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (20, 'synergize cutting-edge applications', 'Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.', '2021-01-24 11:43:22', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (11, 'leverage enterprise infomediaries', 'Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.', '2020-08-16 00:32:40', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (29, 'matrix sticky web services', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (13, 'maximize magnetic portals', null, '2020-06-02 20:12:05', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (20, 'engineer cross-platform deliverables', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', '2020-10-05 05:18:57', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (47, 'morph extensible bandwidth', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus.', '2020-11-02 17:34:00', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (9, 'visualize compelling models', null, null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (19, 'whiteboard distributed channels', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (34, 'matrix out-of-the-box deliverables', 'Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (26, 'syndicate B2C networks', 'Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (47, 'revolutionize end-to-end architectures', 'Aliquam erat volutpat. In congue.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (6, 'harness intuitive vortals', null, '2020-11-27 09:31:24', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (49, 'implement user-centric relationships', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.', '2020-04-21 06:06:08', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (2, 'seize virtual supply-chains', null, null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (30, 'streamline 24/7 e-business', null, '2020-09-02 11:24:45', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (20, 'enable front-end interfaces', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (24, 'iterate back-end relationships', 'Proin risus. Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend.', '2020-09-05 17:43:30', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (30, 'morph back-end synergies', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (20, 'synthesize bleeding-edge content', null, '2020-12-04 10:54:03', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (4, 'reintermediate dynamic methodologies', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (35, 'visualize revolutionary e-markets', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (13, 'visualize next-generation applications', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'deliver revolutionary architectures', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo.', '2020-08-13 15:03:17', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'architect sexy e-commerce', 'Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (4, 'strategize innovative mindshare', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (9, 'scale dot-com metrics', 'Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (35, 'monetize end-to-end content', null, '2020-11-25 22:47:04', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (45, 'incentivize B2C portals', null, '2020-06-25 23:06:48', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (19, 'incubate bricks-and-clicks metrics', 'Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (41, 'envisioneer value-added channels', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (42, 'strategize sticky mindshare', 'Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (17, 'incentivize virtual action-items', null, '2020-04-10 23:23:53', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (33, 'engineer wireless niches', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (5, 'grow one-to-one initiatives', 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (6, 'harness visionary communities', 'Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', '2020-05-13 18:28:06', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (39, 'utilize robust deliverables', 'Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '2020-05-13 12:06:48', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (47, 'expedite scalable relationships', 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '2020-04-03 08:07:57', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'deploy intuitive web-readiness', 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis.', '2021-01-26 12:18:45', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (23, 'target cross-media infrastructures', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (23, 'transform compelling partnerships', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', '2020-12-15 09:18:05', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (45, 'reintermediate distributed platforms', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', '2020-10-03 20:46:45', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (18, 'deliver plug-and-play functionalities', null, '2021-01-20 23:25:53', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (45, 'integrate customized initiatives', 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2020-11-05 16:57:09', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (4, 'deploy plug-and-play e-services', null, '2020-06-14 12:30:09', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'enhance dot-com communities', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (2, 'maximize scalable supply-chains', 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (31, 'e-enable B2C paradigms', 'In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum.', '2020-06-16 06:17:49', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (39, 'drive real-time vortals', 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (29, 'maximize interactive networks', null, '2021-02-20 16:40:17', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (19, 'monetize holistic supply-chains', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (50, 'repurpose visionary vortals', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (18, 'synergize sexy methodologies', 'Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.', '2021-01-02 19:07:37', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (6, 'implement plug-and-play markets', 'In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', '2020-07-28 21:42:14', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (4, 'deliver bleeding-edge e-services', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (47, 'implement sticky paradigms', 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', '2020-11-06 21:34:31', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (34, 'generate strategic portals', null, '2020-11-22 23:02:31', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (4, 'iterate viral synergies', null, '2020-09-15 02:39:30', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (2, 'redefine intuitive supply-chains', 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (2, 'productize B2C e-tailers', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (16, 'enable visionary functionalities', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2021-03-16 15:07:32', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (18, 'reinvent mission-critical web services', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (40, 'deliver proactive synergies', 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (20, 'brand extensible mindshare', 'Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '2020-05-28 08:43:07', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (41, 'cultivate 24/7 web services', 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'enhance intuitive e-business', null, null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'matrix frictionless markets', null, '2020-06-02 06:10:25', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (8, 'aggregate sexy e-tailers', 'Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio.', '2021-01-08 18:56:43', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (47, 'morph cutting-edge e-tailers', 'Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (48, 'cultivate seamless users', null, '2020-11-22 23:04:26', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (19, 'incentivize frictionless supply-chains', null, '2020-04-02 18:46:13', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (1, 'streamline back-end functionalities', 'Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '2020-12-17 03:40:02', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (29, 'target intuitive e-markets', 'Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.', '2020-12-05 11:46:08', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (5, 'aggregate wireless technologies', null, null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (7, 'facilitate sexy supply-chains', 'Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', '2021-03-24 13:12:47', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'scale open-source functionalities', 'Quisque ut erat.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'harness user-centric methodologies', 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius.', '2020-06-09 20:09:28', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (8, 'streamline extensible systems', null, '2020-07-25 07:24:57', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (9, 'matrix user-centric platforms', null, '2020-04-01 23:16:06', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (33, 'leverage sticky synergies', 'Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (40, 'implement integrated networks', null, '2020-04-18 09:01:52', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (16, 'expedite ubiquitous eyeballs', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', '2020-12-10 10:53:39', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (15, 'optimize proactive deliverables', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (8, 'implement scalable deliverables', 'Aenean lectus. Pellentesque eget nunc.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (34, 'synergize 24/365 niches', null, null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (31, 'synergize B2C mindshare', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'architect turn-key eyeballs', 'Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia.', '2020-08-24 16:32:28', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'reintermediate bleeding-edge convergence', 'Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.', '2020-10-27 01:29:54', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (19, 'strategize turn-key niches', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '2020-10-12 15:50:07', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (7, 'integrate front-end networks', null, null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (1, 'facilitate out-of-the-box users', 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst.', '2020-08-06 01:03:36', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (2, 'whiteboard customized interfaces', 'Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', '2021-02-24 03:41:22', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (1, 'e-enable dot-com convergence', 'Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (47, 'implement out-of-the-box functionalities', null, null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'reinvent visionary e-tailers', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.', '2021-01-14 19:09:36', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (32, 'innovate viral relationships', 'Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (19, 'syndicate bleeding-edge initiatives', 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (49, 'aggregate clicks-and-mortar architectures', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (11, 'expedite wireless e-business', 'Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '2020-05-01 23:27:23', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (45, 'enable web-enabled functionalities', 'Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', '2020-04-23 21:23:22', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (9, 'transition world-class applications', 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.', '2020-10-12 17:57:56', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (3, 'leverage turn-key technologies', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', '2020-05-31 10:58:10', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (8, 'incentivize granular web services', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (16, 'architect best-of-breed relationships', 'Vestibulum sed magna at nunc commodo placerat.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (45, 'synthesize leading-edge bandwidth', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (31, 'productize turn-key eyeballs', 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante.', '2020-06-29 04:35:27', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (46, 'synthesize next-generation infrastructures', 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.', '2020-11-01 09:26:21', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (19, 'facilitate B2B partnerships', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.', '2020-06-08 09:24:06', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (18, 'visualize magnetic eyeballs', 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis.', '2020-09-09 01:06:19', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (46, 'maximize scalable technologies', 'Integer a nibh. In quis justo.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'reinvent integrated action-items', 'Aenean sit amet justo. Morbi ut odio.', '2020-04-19 17:08:03', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (28, 'transition dot-com vortals', 'Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', '2020-11-03 20:08:14', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (47, 'drive out-of-the-box technologies', null, '2020-12-28 11:15:03', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (45, 'architect proactive functionalities', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '2020-11-28 21:55:17', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (23, 'mesh bricks-and-clicks deliverables', null, '2020-12-01 21:49:03', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (17, 'disintermediate extensible schemas', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.', '2020-04-11 08:26:07', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'whiteboard front-end convergence', null, '2020-12-17 06:09:56', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (34, 'recontextualize front-end systems', 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus.', '2020-12-09 00:34:54', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (6, 'aggregate real-time communities', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (34, 'transition B2B partnerships', 'Nam tristique tortor eu pede.', '2020-10-07 21:11:31', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (3, 'morph leading-edge relationships', 'Praesent blandit.', '2020-09-16 00:47:57', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (27, 'evolve interactive e-commerce', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (31, 'envisioneer viral infrastructures', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'benchmark revolutionary methodologies', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (29, 'utilize mission-critical e-commerce', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (27, 'morph value-added methodologies', 'Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (46, 'exploit magnetic synergies', 'Ut at dolor quis odio consequat varius.', '2021-01-31 16:21:33', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (4, 'disintermediate holistic e-markets', 'Mauris lacinia sapien quis libero.', '2020-04-07 17:25:39', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (4, 'extend end-to-end architectures', 'Etiam justo. Etiam pretium iaculis justo.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (26, 'seize intuitive e-business', 'Fusce consequat.', '2020-10-14 18:51:05', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (1, 'orchestrate e-business platforms', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti.', '2020-04-24 13:40:21', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (14, 'extend sexy web services', null, '2020-09-22 07:32:34', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'engineer cross-platform experiences', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (14, 'grow customized interfaces', 'Aenean sit amet justo.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (20, 'mesh bleeding-edge web-readiness', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.', '2021-02-06 11:51:58', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (40, 'aggregate killer ROI', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (49, 'transform clicks-and-mortar functionalities', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (21, 'disintermediate efficient synergies', null, '2021-01-30 06:43:07', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (35, 'innovate bleeding-edge markets', 'Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (9, 'evolve next-generation synergies', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue.', '2020-07-19 07:35:43', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'visualize compelling initiatives', 'Praesent blandit. Nam nulla.', '2021-02-03 06:53:37', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (11, 'brand end-to-end users', 'Cras pellentesque volutpat dui.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (43, 'enhance one-to-one platforms', 'Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (7, 'deploy leading-edge partnerships', null, '2020-04-19 09:04:10', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (9, 'optimize web-enabled functionalities', 'In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', '2020-05-08 18:44:10', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (30, 'e-enable back-end supply-chains', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'matrix next-generation initiatives', 'Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', '2020-10-10 14:08:00', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (17, 'benchmark B2B niches', 'Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (20, 'enable value-added systems', 'Maecenas tincidunt lacus at velit.', '2020-10-18 18:14:49', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (1, 'cultivate efficient interfaces', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (29, 'architect sexy interfaces', null, '2020-06-04 02:00:05', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (14, 'utilize cutting-edge e-commerce', 'Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (9, 'exploit 24/365 paradigms', 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (20, 'maximize robust supply-chains', 'Fusce consequat. Nulla nisl.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (13, 'disintermediate sticky platforms', null, null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (41, 'matrix one-to-one e-markets', null, '2020-10-20 06:15:56', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (43, 'deploy synergistic portals', 'In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', '2020-11-20 13:41:19', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (42, 'utilize world-class experiences', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (40, 'streamline granular paradigms', 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '2021-01-12 07:16:58', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (31, 'seize intuitive users', 'Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (49, 'utilize front-end methodologies', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.', '2020-09-23 02:58:39', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (3, 'matrix front-end web-readiness', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (18, 'embrace rich eyeballs', null, '2020-04-08 04:52:42', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (18, 'empower bricks-and-clicks applications', null, '2021-01-24 19:54:41', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (11, 'utilize cutting-edge deliverables', 'Quisque porta volutpat erat.', '2020-12-15 15:14:39', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (16, 'deploy back-end action-items', 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (25, 'brand cutting-edge convergence', 'Nullam molestie nibh in lectus.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (24, 'deploy virtual content', null, '2020-10-16 16:05:55', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (4, 'whiteboard frictionless experiences', null, '2020-08-27 20:51:51', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (23, 'mesh next-generation platforms', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.', '2020-04-23 23:54:38', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (33, 'envisioneer frictionless e-tailers', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', '2020-09-09 20:11:50', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (24, 'aggregate B2C web-readiness', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '2020-08-19 06:18:37', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (24, 'engineer bleeding-edge portals', 'Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', '2020-05-01 14:35:39', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (27, 'orchestrate sticky experiences', null, '2020-04-06 07:11:41', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (20, 'embrace real-time users', 'Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (22, 'disintermediate clicks-and-mortar initiatives', null, '2020-05-17 04:04:59', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (31, 'deliver web-enabled communities', 'Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.', '2020-11-24 06:32:53', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (4, 'scale ubiquitous partnerships', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'matrix extensible bandwidth', 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', '2020-11-08 19:36:39', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (33, 'utilize front-end markets', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.', '2020-12-21 21:38:10', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (40, 'redefine plug-and-play communities', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', '2020-09-26 08:54:26', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (37, 'morph plug-and-play mindshare', 'Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '2020-05-13 19:10:16', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (2, 'optimize ubiquitous networks', 'Donec ut dolor.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (2, 'architect granular users', 'Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (25, 'incubate out-of-the-box supply-chains', null, null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (34, 'reintermediate 24/365 channels', 'Nulla nisl.', '2020-08-22 03:05:40', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (50, 'synergize front-end markets', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (18, 'seize revolutionary systems', 'Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (32, 'synthesize cross-media markets', 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (40, 'architect intuitive infrastructures', null, '2020-06-10 11:24:30', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (11, 'synthesize dynamic e-services', 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (48, 'implement enterprise partnerships', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', '2020-09-15 16:34:53', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (38, 'target 24/365 interfaces', 'Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (49, 'morph intuitive deliverables', 'Morbi a ipsum. Integer a nibh. In quis justo.', null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (24, 'empower best-of-breed schemas', 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', '2020-08-26 23:26:31', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (1, 'architect virtual schemas', 'Nullam porttitor lacus at turpis.', '2021-02-06 11:37:14', 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (35, 'extend holistic solutions', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', null, 'Waiting');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (14, 'repurpose vertical functionalities', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.', '2021-03-15 19:39:34', 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (41, 'whiteboard one-to-one interfaces', 'Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (2, 'implement sexy metrics', null, null, 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (37, 'mesh compelling e-markets', 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.', '2021-01-31 20:40:18', 'In Progress');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (21, 'incubate cross-platform synergies', 'Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', null, 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (26, 'transform real-time mindshare', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2020-08-27 03:59:39', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'innovate leading-edge convergence', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.', '2020-05-26 00:53:03', 'Completed');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (12, 'monetize synergistic convergence', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', null, 'Not Started');
INSERT INTO task (project, name, description, due_date, task_status) VALUES (44, 'repurpose leading-edge web-readiness', 'Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam.', null, 'In Progress');


-- Subtask

UPDATE task SET parent = 479 WHERE id = 1;
UPDATE task SET parent = 399 WHERE id = 2;
UPDATE task SET parent = 81 WHERE id = 5;
UPDATE task SET parent = 209 WHERE id = 6;
UPDATE task SET parent = 253 WHERE id = 13;
UPDATE task SET parent = 196 WHERE id = 16;
UPDATE task SET parent = 421 WHERE id = 27;
UPDATE task SET parent = 243 WHERE id = 28;
UPDATE task SET parent = 344 WHERE id = 30;
UPDATE task SET parent = 204 WHERE id = 33;
UPDATE task SET parent = 490 WHERE id = 35;
UPDATE task SET parent = 202 WHERE id = 39;
UPDATE task SET parent = 104 WHERE id = 41;
UPDATE task SET parent = 361 WHERE id = 45;
UPDATE task SET parent = 388 WHERE id = 47;
UPDATE task SET parent = 235 WHERE id = 50;
UPDATE task SET parent = 284 WHERE id = 57;
UPDATE task SET parent = 400 WHERE id = 59;
UPDATE task SET parent = 335 WHERE id = 62;
UPDATE task SET parent = 120 WHERE id = 79;
UPDATE task SET parent = 415 WHERE id = 82;
UPDATE task SET parent = 243 WHERE id = 83;
UPDATE task SET parent = 151 WHERE id = 84;
UPDATE task SET parent = 303 WHERE id = 85;
UPDATE task SET parent = 265 WHERE id = 87;
UPDATE task SET parent = 483 WHERE id = 88;
UPDATE task SET parent = 279 WHERE id = 91;
UPDATE task SET parent = 479 WHERE id = 100;
UPDATE task SET parent = 437 WHERE id = 116;
UPDATE task SET parent = 368 WHERE id = 122;
UPDATE task SET parent = 406 WHERE id = 123;
UPDATE task SET parent = 436 WHERE id = 135;
UPDATE task SET parent = 486 WHERE id = 142;
UPDATE task SET parent = 397 WHERE id = 146;
UPDATE task SET parent = 467 WHERE id = 148;
UPDATE task SET parent = 224 WHERE id = 151;
UPDATE task SET parent = 256 WHERE id = 158;
UPDATE task SET parent = 173 WHERE id = 159;
UPDATE task SET parent = 454 WHERE id = 163;
UPDATE task SET parent = 261 WHERE id = 164;
UPDATE task SET parent = 278 WHERE id = 166;
UPDATE task SET parent = 490 WHERE id = 173;
UPDATE task SET parent = 353 WHERE id = 176;
UPDATE task SET parent = 271 WHERE id = 178;
UPDATE task SET parent = 373 WHERE id = 180;
UPDATE task SET parent = 452 WHERE id = 185;
UPDATE task SET parent = 244 WHERE id = 187;
UPDATE task SET parent = 230 WHERE id = 193;
UPDATE task SET parent = 213 WHERE id = 207;
UPDATE task SET parent = 292 WHERE id = 208;
UPDATE task SET parent = 240 WHERE id = 210;
UPDATE task SET parent = 290 WHERE id = 212;
UPDATE task SET parent = 498 WHERE id = 219;
UPDATE task SET parent = 233 WHERE id = 221;
UPDATE task SET parent = 275 WHERE id = 222;
UPDATE task SET parent = 295 WHERE id = 228;
UPDATE task SET parent = 458 WHERE id = 231;
UPDATE task SET parent = 480 WHERE id = 233;
UPDATE task SET parent = 376 WHERE id = 237;
UPDATE task SET parent = 495 WHERE id = 243;
UPDATE task SET parent = 259 WHERE id = 253;
UPDATE task SET parent = 364 WHERE id = 272;
UPDATE task SET parent = 316 WHERE id = 275;
UPDATE task SET parent = 280 WHERE id = 279;
UPDATE task SET parent = 384 WHERE id = 280;
UPDATE task SET parent = 464 WHERE id = 282;
UPDATE task SET parent = 460 WHERE id = 289;
UPDATE task SET parent = 480 WHERE id = 304;
UPDATE task SET parent = 350 WHERE id = 306;
UPDATE task SET parent = 313 WHERE id = 310;
UPDATE task SET parent = 473 WHERE id = 318;
UPDATE task SET parent = 491 WHERE id = 322;
UPDATE task SET parent = 359 WHERE id = 325;
UPDATE task SET parent = 482 WHERE id = 337;
UPDATE task SET parent = 375 WHERE id = 357;
UPDATE task SET parent = 435 WHERE id = 361;
UPDATE task SET parent = 383 WHERE id = 365;
UPDATE task SET parent = 400 WHERE id = 380;
UPDATE task SET parent = 483 WHERE id = 390;
UPDATE task SET parent = 472 WHERE id = 463;



-- Waiting On

INSERT INTO waiting_on (task1, task2) VALUES (2, 336);
INSERT INTO waiting_on (task1, task2) VALUES (3, 41);
INSERT INTO waiting_on (task1, task2) VALUES (5, 378);
INSERT INTO waiting_on (task1, task2) VALUES (20, 130);
INSERT INTO waiting_on (task1, task2) VALUES (21, 146);
INSERT INTO waiting_on (task1, task2) VALUES (27, 421);
INSERT INTO waiting_on (task1, task2) VALUES (30, 253);
INSERT INTO waiting_on (task1, task2) VALUES (32, 97);
INSERT INTO waiting_on (task1, task2) VALUES (40, 184);
INSERT INTO waiting_on (task1, task2) VALUES (49, 184);
INSERT INTO waiting_on (task1, task2) VALUES (50, 86);
INSERT INTO waiting_on (task1, task2) VALUES (51, 366);
INSERT INTO waiting_on (task1, task2) VALUES (57, 377);
INSERT INTO waiting_on (task1, task2) VALUES (81, 146);
INSERT INTO waiting_on (task1, task2) VALUES (83, 243);
INSERT INTO waiting_on (task1, task2) VALUES (87, 429);
INSERT INTO waiting_on (task1, task2) VALUES (90, 86);
INSERT INTO waiting_on (task1, task2) VALUES (99, 86);
INSERT INTO waiting_on (task1, task2) VALUES (103, 474);
INSERT INTO waiting_on (task1, task2) VALUES (105, 71);
INSERT INTO waiting_on (task1, task2) VALUES (118, 202);
INSERT INTO waiting_on (task1, task2) VALUES (136, 135);
INSERT INTO waiting_on (task1, task2) VALUES (154, 261);
INSERT INTO waiting_on (task1, task2) VALUES (155, 272);
INSERT INTO waiting_on (task1, task2) VALUES (167, 102);
INSERT INTO waiting_on (task1, task2) VALUES (179, 267);
INSERT INTO waiting_on (task1, task2) VALUES (195, 416);
INSERT INTO waiting_on (task1, task2) VALUES (199, 217);
INSERT INTO waiting_on (task1, task2) VALUES (204, 25);
INSERT INTO waiting_on (task1, task2) VALUES (206, 8);
INSERT INTO waiting_on (task1, task2) VALUES (207, 330);
INSERT INTO waiting_on (task1, task2) VALUES (230, 377);
INSERT INTO waiting_on (task1, task2) VALUES (233, 480);
INSERT INTO waiting_on (task1, task2) VALUES (234, 126);
INSERT INTO waiting_on (task1, task2) VALUES (239, 212);
INSERT INTO waiting_on (task1, task2) VALUES (248, 53);
INSERT INTO waiting_on (task1, task2) VALUES (253, 298);
INSERT INTO waiting_on (task1, task2) VALUES (268, 176);
INSERT INTO waiting_on (task1, task2) VALUES (270, 223);
INSERT INTO waiting_on (task1, task2) VALUES (282, 278);
INSERT INTO waiting_on (task1, task2) VALUES (290, 343);
INSERT INTO waiting_on (task1, task2) VALUES (313, 286);
INSERT INTO waiting_on (task1, task2) VALUES (317, 10);
INSERT INTO waiting_on (task1, task2) VALUES (327, 204);
INSERT INTO waiting_on (task1, task2) VALUES (335, 408);
INSERT INTO waiting_on (task1, task2) VALUES (345, 26);
INSERT INTO waiting_on (task1, task2) VALUES (346, 481);
INSERT INTO waiting_on (task1, task2) VALUES (357, 246);
INSERT INTO waiting_on (task1, task2) VALUES (362, 372);
INSERT INTO waiting_on (task1, task2) VALUES (366, 159);
INSERT INTO waiting_on (task1, task2) VALUES (374, 328);
INSERT INTO waiting_on (task1, task2) VALUES (381, 69);
INSERT INTO waiting_on (task1, task2) VALUES (404, 209);
INSERT INTO waiting_on (task1, task2) VALUES (410, 204);
INSERT INTO waiting_on (task1, task2) VALUES (415, 82);
INSERT INTO waiting_on (task1, task2) VALUES (422, 182);
INSERT INTO waiting_on (task1, task2) VALUES (424, 38);
INSERT INTO waiting_on (task1, task2) VALUES (450, 260);
INSERT INTO waiting_on (task1, task2) VALUES (450, 493);
INSERT INTO waiting_on (task1, task2) VALUES (477, 386);


-- Assignment

INSERT INTO assignment (task, client) VALUES (1, 11);
INSERT INTO assignment (task, client) VALUES (1, 20);
INSERT INTO assignment (task, client) VALUES (1, 22);
INSERT INTO assignment (task, client) VALUES (2, 23);
INSERT INTO assignment (task, client) VALUES (3, 9);
INSERT INTO assignment (task, client) VALUES (3, 24);
INSERT INTO assignment (task, client) VALUES (4, 16);
INSERT INTO assignment (task, client) VALUES (4, 19);
INSERT INTO assignment (task, client) VALUES (6, 6);
INSERT INTO assignment (task, client) VALUES (6, 7);
INSERT INTO assignment (task, client) VALUES (7, 14);
INSERT INTO assignment (task, client) VALUES (9, 3);
INSERT INTO assignment (task, client) VALUES (9, 11);
INSERT INTO assignment (task, client) VALUES (10, 24);
INSERT INTO assignment (task, client) VALUES (11, 19);
INSERT INTO assignment (task, client) VALUES (12, 6);
INSERT INTO assignment (task, client) VALUES (13, 18);
INSERT INTO assignment (task, client) VALUES (13, 22);
INSERT INTO assignment (task, client) VALUES (15, 24);
INSERT INTO assignment (task, client) VALUES (16, 25);
INSERT INTO assignment (task, client) VALUES (18, 14);
INSERT INTO assignment (task, client) VALUES (18, 18);
INSERT INTO assignment (task, client) VALUES (19, 22);
INSERT INTO assignment (task, client) VALUES (20, 12);
INSERT INTO assignment (task, client) VALUES (21, 5);
INSERT INTO assignment (task, client) VALUES (21, 23);
INSERT INTO assignment (task, client) VALUES (23, 6);
INSERT INTO assignment (task, client) VALUES (27, 6);
INSERT INTO assignment (task, client) VALUES (27, 15);
INSERT INTO assignment (task, client) VALUES (28, 3);
INSERT INTO assignment (task, client) VALUES (28, 10);
INSERT INTO assignment (task, client) VALUES (28, 17);
INSERT INTO assignment (task, client) VALUES (30, 22);
INSERT INTO assignment (task, client) VALUES (31, 12);
INSERT INTO assignment (task, client) VALUES (31, 22);
INSERT INTO assignment (task, client) VALUES (35, 3);
INSERT INTO assignment (task, client) VALUES (36, 24);
INSERT INTO assignment (task, client) VALUES (37, 16);
INSERT INTO assignment (task, client) VALUES (38, 16);
INSERT INTO assignment (task, client) VALUES (38, 25);
INSERT INTO assignment (task, client) VALUES (39, 20);
INSERT INTO assignment (task, client) VALUES (40, 2);
INSERT INTO assignment (task, client) VALUES (40, 4);
INSERT INTO assignment (task, client) VALUES (40, 5);
INSERT INTO assignment (task, client) VALUES (40, 8);
INSERT INTO assignment (task, client) VALUES (40, 15);
INSERT INTO assignment (task, client) VALUES (41, 8);
INSERT INTO assignment (task, client) VALUES (41, 24);
INSERT INTO assignment (task, client) VALUES (42, 17);
INSERT INTO assignment (task, client) VALUES (43, 5);
INSERT INTO assignment (task, client) VALUES (43, 25);
INSERT INTO assignment (task, client) VALUES (44, 15);
INSERT INTO assignment (task, client) VALUES (46, 17);
INSERT INTO assignment (task, client) VALUES (48, 11);
INSERT INTO assignment (task, client) VALUES (49, 2);
INSERT INTO assignment (task, client) VALUES (49, 4);
INSERT INTO assignment (task, client) VALUES (49, 15);
INSERT INTO assignment (task, client) VALUES (49, 22);
INSERT INTO assignment (task, client) VALUES (51, 19);
INSERT INTO assignment (task, client) VALUES (52, 20);
INSERT INTO assignment (task, client) VALUES (53, 6);
INSERT INTO assignment (task, client) VALUES (53, 11);
INSERT INTO assignment (task, client) VALUES (54, 10);
INSERT INTO assignment (task, client) VALUES (55, 17);
INSERT INTO assignment (task, client) VALUES (57, 10);
INSERT INTO assignment (task, client) VALUES (57, 24);
INSERT INTO assignment (task, client) VALUES (58, 5);
INSERT INTO assignment (task, client) VALUES (60, 10);
INSERT INTO assignment (task, client) VALUES (61, 23);
INSERT INTO assignment (task, client) VALUES (62, 3);
INSERT INTO assignment (task, client) VALUES (64, 17);
INSERT INTO assignment (task, client) VALUES (64, 24);
INSERT INTO assignment (task, client) VALUES (65, 11);
INSERT INTO assignment (task, client) VALUES (66, 4);
INSERT INTO assignment (task, client) VALUES (67, 11);
INSERT INTO assignment (task, client) VALUES (67, 19);
INSERT INTO assignment (task, client) VALUES (68, 22);
INSERT INTO assignment (task, client) VALUES (70, 5);
INSERT INTO assignment (task, client) VALUES (71, 13);
INSERT INTO assignment (task, client) VALUES (72, 13);
INSERT INTO assignment (task, client) VALUES (72, 16);
INSERT INTO assignment (task, client) VALUES (73, 13);
INSERT INTO assignment (task, client) VALUES (75, 4);
INSERT INTO assignment (task, client) VALUES (75, 14);
INSERT INTO assignment (task, client) VALUES (75, 16);
INSERT INTO assignment (task, client) VALUES (76, 23);
INSERT INTO assignment (task, client) VALUES (78, 11);
INSERT INTO assignment (task, client) VALUES (78, 13);
INSERT INTO assignment (task, client) VALUES (78, 14);
INSERT INTO assignment (task, client) VALUES (78, 16);
INSERT INTO assignment (task, client) VALUES (78, 19);
INSERT INTO assignment (task, client) VALUES (79, 25);
INSERT INTO assignment (task, client) VALUES (80, 16);
INSERT INTO assignment (task, client) VALUES (80, 18);
INSERT INTO assignment (task, client) VALUES (82, 2);
INSERT INTO assignment (task, client) VALUES (82, 10);
INSERT INTO assignment (task, client) VALUES (82, 13);
INSERT INTO assignment (task, client) VALUES (83, 3);
INSERT INTO assignment (task, client) VALUES (83, 13);
INSERT INTO assignment (task, client) VALUES (83, 21);
INSERT INTO assignment (task, client) VALUES (84, 2);
INSERT INTO assignment (task, client) VALUES (84, 5);
INSERT INTO assignment (task, client) VALUES (84, 18);
INSERT INTO assignment (task, client) VALUES (84, 19);
INSERT INTO assignment (task, client) VALUES (86, 16);
INSERT INTO assignment (task, client) VALUES (86, 17);
INSERT INTO assignment (task, client) VALUES (88, 3);
INSERT INTO assignment (task, client) VALUES (88, 19);
INSERT INTO assignment (task, client) VALUES (91, 3);
INSERT INTO assignment (task, client) VALUES (96, 12);
INSERT INTO assignment (task, client) VALUES (96, 17);
INSERT INTO assignment (task, client) VALUES (97, 7);
INSERT INTO assignment (task, client) VALUES (97, 12);
INSERT INTO assignment (task, client) VALUES (97, 21);
INSERT INTO assignment (task, client) VALUES (98, 5);
INSERT INTO assignment (task, client) VALUES (98, 20);
INSERT INTO assignment (task, client) VALUES (99, 16);
INSERT INTO assignment (task, client) VALUES (100, 6);
INSERT INTO assignment (task, client) VALUES (100, 11);
INSERT INTO assignment (task, client) VALUES (100, 22);
INSERT INTO assignment (task, client) VALUES (101, 10);
INSERT INTO assignment (task, client) VALUES (101, 23);
INSERT INTO assignment (task, client) VALUES (101, 25);
INSERT INTO assignment (task, client) VALUES (102, 4);
INSERT INTO assignment (task, client) VALUES (102, 21);
INSERT INTO assignment (task, client) VALUES (103, 16);
INSERT INTO assignment (task, client) VALUES (104, 2);
INSERT INTO assignment (task, client) VALUES (105, 9);
INSERT INTO assignment (task, client) VALUES (105, 20);
INSERT INTO assignment (task, client) VALUES (105, 25);
INSERT INTO assignment (task, client) VALUES (108, 2);
INSERT INTO assignment (task, client) VALUES (108, 15);
INSERT INTO assignment (task, client) VALUES (108, 22);
INSERT INTO assignment (task, client) VALUES (110, 20);
INSERT INTO assignment (task, client) VALUES (111, 7);
INSERT INTO assignment (task, client) VALUES (111, 8);
INSERT INTO assignment (task, client) VALUES (111, 11);
INSERT INTO assignment (task, client) VALUES (112, 23);
INSERT INTO assignment (task, client) VALUES (113, 2);
INSERT INTO assignment (task, client) VALUES (113, 5);
INSERT INTO assignment (task, client) VALUES (116, 13);
INSERT INTO assignment (task, client) VALUES (117, 9);
INSERT INTO assignment (task, client) VALUES (117, 21);
INSERT INTO assignment (task, client) VALUES (118, 20);
INSERT INTO assignment (task, client) VALUES (119, 9);
INSERT INTO assignment (task, client) VALUES (119, 12);
INSERT INTO assignment (task, client) VALUES (119, 17);
INSERT INTO assignment (task, client) VALUES (119, 25);
INSERT INTO assignment (task, client) VALUES (120, 13);
INSERT INTO assignment (task, client) VALUES (121, 5);
INSERT INTO assignment (task, client) VALUES (122, 3);
INSERT INTO assignment (task, client) VALUES (122, 13);
INSERT INTO assignment (task, client) VALUES (123, 8);
INSERT INTO assignment (task, client) VALUES (123, 19);
INSERT INTO assignment (task, client) VALUES (125, 9);
INSERT INTO assignment (task, client) VALUES (125, 19);
INSERT INTO assignment (task, client) VALUES (125, 24);
INSERT INTO assignment (task, client) VALUES (125, 25);
INSERT INTO assignment (task, client) VALUES (126, 19);
INSERT INTO assignment (task, client) VALUES (127, 3);
INSERT INTO assignment (task, client) VALUES (129, 11);
INSERT INTO assignment (task, client) VALUES (129, 21);
INSERT INTO assignment (task, client) VALUES (132, 10);
INSERT INTO assignment (task, client) VALUES (132, 23);
INSERT INTO assignment (task, client) VALUES (133, 10);
INSERT INTO assignment (task, client) VALUES (134, 9);
INSERT INTO assignment (task, client) VALUES (134, 14);
INSERT INTO assignment (task, client) VALUES (135, 6);
INSERT INTO assignment (task, client) VALUES (135, 9);
INSERT INTO assignment (task, client) VALUES (135, 20);
INSERT INTO assignment (task, client) VALUES (136, 6);
INSERT INTO assignment (task, client) VALUES (136, 10);
INSERT INTO assignment (task, client) VALUES (136, 21);
INSERT INTO assignment (task, client) VALUES (137, 13);
INSERT INTO assignment (task, client) VALUES (137, 16);
INSERT INTO assignment (task, client) VALUES (138, 21);
INSERT INTO assignment (task, client) VALUES (140, 23);
INSERT INTO assignment (task, client) VALUES (142, 19);
INSERT INTO assignment (task, client) VALUES (144, 3);
INSERT INTO assignment (task, client) VALUES (146, 5);
INSERT INTO assignment (task, client) VALUES (147, 12);
INSERT INTO assignment (task, client) VALUES (148, 15);
INSERT INTO assignment (task, client) VALUES (149, 9);
INSERT INTO assignment (task, client) VALUES (150, 11);
INSERT INTO assignment (task, client) VALUES (151, 2);
INSERT INTO assignment (task, client) VALUES (151, 5);
INSERT INTO assignment (task, client) VALUES (151, 12);
INSERT INTO assignment (task, client) VALUES (151, 19);
INSERT INTO assignment (task, client) VALUES (152, 10);
INSERT INTO assignment (task, client) VALUES (152, 12);
INSERT INTO assignment (task, client) VALUES (153, 12);
INSERT INTO assignment (task, client) VALUES (153, 18);
INSERT INTO assignment (task, client) VALUES (154, 16);
INSERT INTO assignment (task, client) VALUES (154, 19);
INSERT INTO assignment (task, client) VALUES (154, 25);
INSERT INTO assignment (task, client) VALUES (155, 9);
INSERT INTO assignment (task, client) VALUES (155, 12);
INSERT INTO assignment (task, client) VALUES (155, 23);
INSERT INTO assignment (task, client) VALUES (156, 18);
INSERT INTO assignment (task, client) VALUES (157, 4);
INSERT INTO assignment (task, client) VALUES (157, 7);
INSERT INTO assignment (task, client) VALUES (157, 13);
INSERT INTO assignment (task, client) VALUES (157, 17);
INSERT INTO assignment (task, client) VALUES (160, 6);
INSERT INTO assignment (task, client) VALUES (160, 11);
INSERT INTO assignment (task, client) VALUES (160, 19);
INSERT INTO assignment (task, client) VALUES (161, 14);
INSERT INTO assignment (task, client) VALUES (162, 5);
INSERT INTO assignment (task, client) VALUES (166, 3);
INSERT INTO assignment (task, client) VALUES (166, 11);
INSERT INTO assignment (task, client) VALUES (167, 4);
INSERT INTO assignment (task, client) VALUES (168, 20);
INSERT INTO assignment (task, client) VALUES (169, 14);
INSERT INTO assignment (task, client) VALUES (170, 7);
INSERT INTO assignment (task, client) VALUES (170, 22);
INSERT INTO assignment (task, client) VALUES (171, 20);
INSERT INTO assignment (task, client) VALUES (172, 5);
INSERT INTO assignment (task, client) VALUES (172, 14);
INSERT INTO assignment (task, client) VALUES (172, 16);
INSERT INTO assignment (task, client) VALUES (173, 12);
INSERT INTO assignment (task, client) VALUES (174, 6);
INSERT INTO assignment (task, client) VALUES (174, 25);
INSERT INTO assignment (task, client) VALUES (175, 4);
INSERT INTO assignment (task, client) VALUES (175, 14);
INSERT INTO assignment (task, client) VALUES (177, 10);
INSERT INTO assignment (task, client) VALUES (177, 20);
INSERT INTO assignment (task, client) VALUES (178, 15);
INSERT INTO assignment (task, client) VALUES (179, 15);
INSERT INTO assignment (task, client) VALUES (179, 20);
INSERT INTO assignment (task, client) VALUES (180, 4);
INSERT INTO assignment (task, client) VALUES (181, 5);
INSERT INTO assignment (task, client) VALUES (181, 16);
INSERT INTO assignment (task, client) VALUES (182, 24);
INSERT INTO assignment (task, client) VALUES (183, 16);
INSERT INTO assignment (task, client) VALUES (184, 2);
INSERT INTO assignment (task, client) VALUES (184, 4);
INSERT INTO assignment (task, client) VALUES (184, 5);
INSERT INTO assignment (task, client) VALUES (184, 8);
INSERT INTO assignment (task, client) VALUES (184, 15);
INSERT INTO assignment (task, client) VALUES (184, 22);
INSERT INTO assignment (task, client) VALUES (185, 14);
INSERT INTO assignment (task, client) VALUES (185, 16);
INSERT INTO assignment (task, client) VALUES (185, 24);
INSERT INTO assignment (task, client) VALUES (187, 6);
INSERT INTO assignment (task, client) VALUES (187, 19);
INSERT INTO assignment (task, client) VALUES (188, 6);
INSERT INTO assignment (task, client) VALUES (188, 20);
INSERT INTO assignment (task, client) VALUES (188, 21);
INSERT INTO assignment (task, client) VALUES (190, 24);
INSERT INTO assignment (task, client) VALUES (192, 9);
INSERT INTO assignment (task, client) VALUES (192, 20);
INSERT INTO assignment (task, client) VALUES (193, 10);
INSERT INTO assignment (task, client) VALUES (193, 15);
INSERT INTO assignment (task, client) VALUES (194, 4);
INSERT INTO assignment (task, client) VALUES (194, 22);
INSERT INTO assignment (task, client) VALUES (196, 13);
INSERT INTO assignment (task, client) VALUES (196, 25);
INSERT INTO assignment (task, client) VALUES (197, 13);
INSERT INTO assignment (task, client) VALUES (198, 10);
INSERT INTO assignment (task, client) VALUES (200, 2);
INSERT INTO assignment (task, client) VALUES (200, 5);
INSERT INTO assignment (task, client) VALUES (200, 10);
INSERT INTO assignment (task, client) VALUES (201, 8);
INSERT INTO assignment (task, client) VALUES (201, 12);
INSERT INTO assignment (task, client) VALUES (202, 20);
INSERT INTO assignment (task, client) VALUES (203, 21);
INSERT INTO assignment (task, client) VALUES (204, 23);
INSERT INTO assignment (task, client) VALUES (205, 6);
INSERT INTO assignment (task, client) VALUES (205, 25);
INSERT INTO assignment (task, client) VALUES (206, 20);
INSERT INTO assignment (task, client) VALUES (207, 13);
INSERT INTO assignment (task, client) VALUES (207, 24);
INSERT INTO assignment (task, client) VALUES (208, 5);
INSERT INTO assignment (task, client) VALUES (209, 5);
INSERT INTO assignment (task, client) VALUES (209, 6);
INSERT INTO assignment (task, client) VALUES (209, 15);
INSERT INTO assignment (task, client) VALUES (210, 4);
INSERT INTO assignment (task, client) VALUES (210, 7);
INSERT INTO assignment (task, client) VALUES (210, 13);
INSERT INTO assignment (task, client) VALUES (211, 23);
INSERT INTO assignment (task, client) VALUES (212, 23);
INSERT INTO assignment (task, client) VALUES (213, 10);
INSERT INTO assignment (task, client) VALUES (213, 24);
INSERT INTO assignment (task, client) VALUES (214, 2);
INSERT INTO assignment (task, client) VALUES (214, 18);
INSERT INTO assignment (task, client) VALUES (214, 24);
INSERT INTO assignment (task, client) VALUES (216, 22);
INSERT INTO assignment (task, client) VALUES (217, 9);
INSERT INTO assignment (task, client) VALUES (217, 12);
INSERT INTO assignment (task, client) VALUES (218, 12);
INSERT INTO assignment (task, client) VALUES (218, 18);
INSERT INTO assignment (task, client) VALUES (218, 19);
INSERT INTO assignment (task, client) VALUES (219, 4);
INSERT INTO assignment (task, client) VALUES (220, 9);
INSERT INTO assignment (task, client) VALUES (220, 11);
INSERT INTO assignment (task, client) VALUES (221, 11);
INSERT INTO assignment (task, client) VALUES (222, 2);
INSERT INTO assignment (task, client) VALUES (224, 2);
INSERT INTO assignment (task, client) VALUES (224, 19);
INSERT INTO assignment (task, client) VALUES (225, 3);
INSERT INTO assignment (task, client) VALUES (226, 20);
INSERT INTO assignment (task, client) VALUES (227, 15);
INSERT INTO assignment (task, client) VALUES (230, 10);
INSERT INTO assignment (task, client) VALUES (230, 24);
INSERT INTO assignment (task, client) VALUES (231, 21);
INSERT INTO assignment (task, client) VALUES (232, 15);
INSERT INTO assignment (task, client) VALUES (233, 7);
INSERT INTO assignment (task, client) VALUES (233, 11);
INSERT INTO assignment (task, client) VALUES (233, 12);
INSERT INTO assignment (task, client) VALUES (234, 19);
INSERT INTO assignment (task, client) VALUES (236, 12);
INSERT INTO assignment (task, client) VALUES (236, 20);
INSERT INTO assignment (task, client) VALUES (237, 4);
INSERT INTO assignment (task, client) VALUES (237, 18);
INSERT INTO assignment (task, client) VALUES (238, 13);
INSERT INTO assignment (task, client) VALUES (239, 7);
INSERT INTO assignment (task, client) VALUES (239, 22);
INSERT INTO assignment (task, client) VALUES (239, 23);
INSERT INTO assignment (task, client) VALUES (240, 7);
INSERT INTO assignment (task, client) VALUES (241, 6);
INSERT INTO assignment (task, client) VALUES (241, 25);
INSERT INTO assignment (task, client) VALUES (242, 5);
INSERT INTO assignment (task, client) VALUES (243, 10);
INSERT INTO assignment (task, client) VALUES (243, 13);
INSERT INTO assignment (task, client) VALUES (244, 5);
INSERT INTO assignment (task, client) VALUES (244, 8);
INSERT INTO assignment (task, client) VALUES (244, 12);
INSERT INTO assignment (task, client) VALUES (245, 2);
INSERT INTO assignment (task, client) VALUES (245, 7);
INSERT INTO assignment (task, client) VALUES (247, 16);
INSERT INTO assignment (task, client) VALUES (248, 5);
INSERT INTO assignment (task, client) VALUES (249, 14);
INSERT INTO assignment (task, client) VALUES (249, 21);
INSERT INTO assignment (task, client) VALUES (249, 24);
INSERT INTO assignment (task, client) VALUES (250, 11);
INSERT INTO assignment (task, client) VALUES (251, 12);
INSERT INTO assignment (task, client) VALUES (251, 24);
INSERT INTO assignment (task, client) VALUES (252, 20);
INSERT INTO assignment (task, client) VALUES (253, 18);
INSERT INTO assignment (task, client) VALUES (253, 23);
INSERT INTO assignment (task, client) VALUES (254, 8);
INSERT INTO assignment (task, client) VALUES (254, 22);
INSERT INTO assignment (task, client) VALUES (254, 23);
INSERT INTO assignment (task, client) VALUES (256, 17);
INSERT INTO assignment (task, client) VALUES (256, 23);
INSERT INTO assignment (task, client) VALUES (258, 20);
INSERT INTO assignment (task, client) VALUES (259, 22);
INSERT INTO assignment (task, client) VALUES (259, 23);
INSERT INTO assignment (task, client) VALUES (260, 12);
INSERT INTO assignment (task, client) VALUES (261, 16);
INSERT INTO assignment (task, client) VALUES (263, 24);
INSERT INTO assignment (task, client) VALUES (266, 20);
INSERT INTO assignment (task, client) VALUES (267, 15);
INSERT INTO assignment (task, client) VALUES (268, 21);
INSERT INTO assignment (task, client) VALUES (269, 20);
INSERT INTO assignment (task, client) VALUES (270, 11);
INSERT INTO assignment (task, client) VALUES (271, 12);
INSERT INTO assignment (task, client) VALUES (272, 3);
INSERT INTO assignment (task, client) VALUES (272, 17);
INSERT INTO assignment (task, client) VALUES (272, 23);
INSERT INTO assignment (task, client) VALUES (274, 19);
INSERT INTO assignment (task, client) VALUES (275, 18);
INSERT INTO assignment (task, client) VALUES (278, 3);
INSERT INTO assignment (task, client) VALUES (278, 11);
INSERT INTO assignment (task, client) VALUES (279, 10);
INSERT INTO assignment (task, client) VALUES (279, 22);
INSERT INTO assignment (task, client) VALUES (280, 3);
INSERT INTO assignment (task, client) VALUES (281, 10);
INSERT INTO assignment (task, client) VALUES (281, 15);
INSERT INTO assignment (task, client) VALUES (281, 24);
INSERT INTO assignment (task, client) VALUES (282, 3);
INSERT INTO assignment (task, client) VALUES (284, 24);
INSERT INTO assignment (task, client) VALUES (286, 4);
INSERT INTO assignment (task, client) VALUES (288, 20);
INSERT INTO assignment (task, client) VALUES (289, 12);
INSERT INTO assignment (task, client) VALUES (290, 22);
INSERT INTO assignment (task, client) VALUES (291, 14);
INSERT INTO assignment (task, client) VALUES (291, 20);
INSERT INTO assignment (task, client) VALUES (293, 3);
INSERT INTO assignment (task, client) VALUES (293, 10);
INSERT INTO assignment (task, client) VALUES (295, 2);
INSERT INTO assignment (task, client) VALUES (296, 8);
INSERT INTO assignment (task, client) VALUES (296, 10);
INSERT INTO assignment (task, client) VALUES (297, 3);
INSERT INTO assignment (task, client) VALUES (297, 10);
INSERT INTO assignment (task, client) VALUES (298, 18);
INSERT INTO assignment (task, client) VALUES (299, 2);
INSERT INTO assignment (task, client) VALUES (299, 5);
INSERT INTO assignment (task, client) VALUES (300, 10);
INSERT INTO assignment (task, client) VALUES (300, 14);
INSERT INTO assignment (task, client) VALUES (301, 25);
INSERT INTO assignment (task, client) VALUES (302, 11);
INSERT INTO assignment (task, client) VALUES (302, 20);
INSERT INTO assignment (task, client) VALUES (303, 20);
INSERT INTO assignment (task, client) VALUES (304, 21);
INSERT INTO assignment (task, client) VALUES (307, 10);
INSERT INTO assignment (task, client) VALUES (307, 13);
INSERT INTO assignment (task, client) VALUES (307, 25);
INSERT INTO assignment (task, client) VALUES (308, 17);
INSERT INTO assignment (task, client) VALUES (309, 14);
INSERT INTO assignment (task, client) VALUES (309, 24);
INSERT INTO assignment (task, client) VALUES (310, 20);
INSERT INTO assignment (task, client) VALUES (312, 15);
INSERT INTO assignment (task, client) VALUES (313, 21);
INSERT INTO assignment (task, client) VALUES (315, 7);
INSERT INTO assignment (task, client) VALUES (315, 17);
INSERT INTO assignment (task, client) VALUES (316, 18);
INSERT INTO assignment (task, client) VALUES (317, 18);
INSERT INTO assignment (task, client) VALUES (318, 17);
INSERT INTO assignment (task, client) VALUES (319, 4);
INSERT INTO assignment (task, client) VALUES (321, 11);
INSERT INTO assignment (task, client) VALUES (321, 20);
INSERT INTO assignment (task, client) VALUES (322, 11);
INSERT INTO assignment (task, client) VALUES (323, 16);
INSERT INTO assignment (task, client) VALUES (324, 20);
INSERT INTO assignment (task, client) VALUES (324, 21);
INSERT INTO assignment (task, client) VALUES (325, 4);
INSERT INTO assignment (task, client) VALUES (325, 5);
INSERT INTO assignment (task, client) VALUES (325, 8);
INSERT INTO assignment (task, client) VALUES (325, 12);
INSERT INTO assignment (task, client) VALUES (326, 24);
INSERT INTO assignment (task, client) VALUES (327, 3);
INSERT INTO assignment (task, client) VALUES (327, 13);
INSERT INTO assignment (task, client) VALUES (328, 2);
INSERT INTO assignment (task, client) VALUES (329, 6);
INSERT INTO assignment (task, client) VALUES (329, 19);
INSERT INTO assignment (task, client) VALUES (330, 10);
INSERT INTO assignment (task, client) VALUES (331, 8);
INSERT INTO assignment (task, client) VALUES (331, 23);
INSERT INTO assignment (task, client) VALUES (335, 3);
INSERT INTO assignment (task, client) VALUES (335, 11);
INSERT INTO assignment (task, client) VALUES (336, 5);
INSERT INTO assignment (task, client) VALUES (338, 23);
INSERT INTO assignment (task, client) VALUES (341, 21);
INSERT INTO assignment (task, client) VALUES (342, 10);
INSERT INTO assignment (task, client) VALUES (342, 21);
INSERT INTO assignment (task, client) VALUES (343, 7);
INSERT INTO assignment (task, client) VALUES (343, 22);
INSERT INTO assignment (task, client) VALUES (346, 14);
INSERT INTO assignment (task, client) VALUES (348, 25);
INSERT INTO assignment (task, client) VALUES (349, 5);
INSERT INTO assignment (task, client) VALUES (350, 10);
INSERT INTO assignment (task, client) VALUES (351, 7);
INSERT INTO assignment (task, client) VALUES (351, 21);
INSERT INTO assignment (task, client) VALUES (352, 24);
INSERT INTO assignment (task, client) VALUES (353, 17);
INSERT INTO assignment (task, client) VALUES (355, 4);
INSERT INTO assignment (task, client) VALUES (355, 18);
INSERT INTO assignment (task, client) VALUES (357, 22);
INSERT INTO assignment (task, client) VALUES (359, 4);
INSERT INTO assignment (task, client) VALUES (359, 5);
INSERT INTO assignment (task, client) VALUES (359, 10);
INSERT INTO assignment (task, client) VALUES (360, 17);
INSERT INTO assignment (task, client) VALUES (360, 20);
INSERT INTO assignment (task, client) VALUES (362, 4);
INSERT INTO assignment (task, client) VALUES (362, 18);
INSERT INTO assignment (task, client) VALUES (362, 23);
INSERT INTO assignment (task, client) VALUES (363, 10);
INSERT INTO assignment (task, client) VALUES (364, 24);
INSERT INTO assignment (task, client) VALUES (365, 9);
INSERT INTO assignment (task, client) VALUES (365, 20);
INSERT INTO assignment (task, client) VALUES (366, 20);
INSERT INTO assignment (task, client) VALUES (366, 25);
INSERT INTO assignment (task, client) VALUES (368, 21);
INSERT INTO assignment (task, client) VALUES (369, 3);
INSERT INTO assignment (task, client) VALUES (369, 22);
INSERT INTO assignment (task, client) VALUES (370, 4);
INSERT INTO assignment (task, client) VALUES (372, 17);
INSERT INTO assignment (task, client) VALUES (372, 18);
INSERT INTO assignment (task, client) VALUES (372, 25);
INSERT INTO assignment (task, client) VALUES (373, 5);
INSERT INTO assignment (task, client) VALUES (373, 11);
INSERT INTO assignment (task, client) VALUES (374, 5);
INSERT INTO assignment (task, client) VALUES (375, 12);
INSERT INTO assignment (task, client) VALUES (375, 19);
INSERT INTO assignment (task, client) VALUES (376, 12);
INSERT INTO assignment (task, client) VALUES (376, 22);
INSERT INTO assignment (task, client) VALUES (377, 10);
INSERT INTO assignment (task, client) VALUES (378, 17);
INSERT INTO assignment (task, client) VALUES (379, 7);
INSERT INTO assignment (task, client) VALUES (379, 11);
INSERT INTO assignment (task, client) VALUES (380, 20);
INSERT INTO assignment (task, client) VALUES (381, 8);
INSERT INTO assignment (task, client) VALUES (383, 21);
INSERT INTO assignment (task, client) VALUES (384, 3);
INSERT INTO assignment (task, client) VALUES (384, 22);
INSERT INTO assignment (task, client) VALUES (385, 3);
INSERT INTO assignment (task, client) VALUES (386, 14);
INSERT INTO assignment (task, client) VALUES (386, 25);
INSERT INTO assignment (task, client) VALUES (387, 13);
INSERT INTO assignment (task, client) VALUES (388, 6);
INSERT INTO assignment (task, client) VALUES (389, 24);
INSERT INTO assignment (task, client) VALUES (390, 6);
INSERT INTO assignment (task, client) VALUES (390, 20);
INSERT INTO assignment (task, client) VALUES (392, 23);
INSERT INTO assignment (task, client) VALUES (393, 9);
INSERT INTO assignment (task, client) VALUES (393, 20);
INSERT INTO assignment (task, client) VALUES (393, 21);
INSERT INTO assignment (task, client) VALUES (394, 5);
INSERT INTO assignment (task, client) VALUES (394, 18);
INSERT INTO assignment (task, client) VALUES (394, 23);
INSERT INTO assignment (task, client) VALUES (395, 5);
INSERT INTO assignment (task, client) VALUES (395, 6);
INSERT INTO assignment (task, client) VALUES (396, 2);
INSERT INTO assignment (task, client) VALUES (396, 7);
INSERT INTO assignment (task, client) VALUES (396, 10);
INSERT INTO assignment (task, client) VALUES (396, 13);
INSERT INTO assignment (task, client) VALUES (399, 5);
INSERT INTO assignment (task, client) VALUES (399, 23);
INSERT INTO assignment (task, client) VALUES (403, 6);
INSERT INTO assignment (task, client) VALUES (404, 2);
INSERT INTO assignment (task, client) VALUES (404, 6);
INSERT INTO assignment (task, client) VALUES (404, 7);
INSERT INTO assignment (task, client) VALUES (405, 17);
INSERT INTO assignment (task, client) VALUES (406, 6);
INSERT INTO assignment (task, client) VALUES (406, 8);
INSERT INTO assignment (task, client) VALUES (406, 12);
INSERT INTO assignment (task, client) VALUES (406, 17);
INSERT INTO assignment (task, client) VALUES (407, 5);
INSERT INTO assignment (task, client) VALUES (408, 16);
INSERT INTO assignment (task, client) VALUES (408, 18);
INSERT INTO assignment (task, client) VALUES (409, 3);
INSERT INTO assignment (task, client) VALUES (410, 3);
INSERT INTO assignment (task, client) VALUES (412, 21);
INSERT INTO assignment (task, client) VALUES (413, 13);
INSERT INTO assignment (task, client) VALUES (414, 7);
INSERT INTO assignment (task, client) VALUES (414, 11);
INSERT INTO assignment (task, client) VALUES (415, 10);
INSERT INTO assignment (task, client) VALUES (416, 6);
INSERT INTO assignment (task, client) VALUES (418, 8);
INSERT INTO assignment (task, client) VALUES (418, 17);
INSERT INTO assignment (task, client) VALUES (419, 18);
INSERT INTO assignment (task, client) VALUES (420, 6);
INSERT INTO assignment (task, client) VALUES (421, 2);
INSERT INTO assignment (task, client) VALUES (421, 5);
INSERT INTO assignment (task, client) VALUES (421, 6);
INSERT INTO assignment (task, client) VALUES (421, 15);
INSERT INTO assignment (task, client) VALUES (422, 5);
INSERT INTO assignment (task, client) VALUES (422, 16);
INSERT INTO assignment (task, client) VALUES (423, 17);
INSERT INTO assignment (task, client) VALUES (424, 14);
INSERT INTO assignment (task, client) VALUES (424, 25);
INSERT INTO assignment (task, client) VALUES (425, 19);
INSERT INTO assignment (task, client) VALUES (427, 20);
INSERT INTO assignment (task, client) VALUES (427, 24);
INSERT INTO assignment (task, client) VALUES (428, 7);
INSERT INTO assignment (task, client) VALUES (428, 17);
INSERT INTO assignment (task, client) VALUES (429, 14);
INSERT INTO assignment (task, client) VALUES (429, 15);
INSERT INTO assignment (task, client) VALUES (430, 22);
INSERT INTO assignment (task, client) VALUES (432, 20);
INSERT INTO assignment (task, client) VALUES (433, 2);
INSERT INTO assignment (task, client) VALUES (435, 4);
INSERT INTO assignment (task, client) VALUES (436, 6);
INSERT INTO assignment (task, client) VALUES (437, 13);
INSERT INTO assignment (task, client) VALUES (437, 20);
INSERT INTO assignment (task, client) VALUES (438, 3);
INSERT INTO assignment (task, client) VALUES (438, 12);
INSERT INTO assignment (task, client) VALUES (442, 3);
INSERT INTO assignment (task, client) VALUES (444, 3);
INSERT INTO assignment (task, client) VALUES (444, 13);
INSERT INTO assignment (task, client) VALUES (444, 19);
INSERT INTO assignment (task, client) VALUES (444, 25);
INSERT INTO assignment (task, client) VALUES (445, 22);
INSERT INTO assignment (task, client) VALUES (447, 11);
INSERT INTO assignment (task, client) VALUES (450, 10);
INSERT INTO assignment (task, client) VALUES (451, 13);
INSERT INTO assignment (task, client) VALUES (451, 25);
INSERT INTO assignment (task, client) VALUES (453, 3);
INSERT INTO assignment (task, client) VALUES (453, 9);
INSERT INTO assignment (task, client) VALUES (453, 19);
INSERT INTO assignment (task, client) VALUES (456, 2);
INSERT INTO assignment (task, client) VALUES (456, 7);
INSERT INTO assignment (task, client) VALUES (456, 10);
INSERT INTO assignment (task, client) VALUES (457, 9);
INSERT INTO assignment (task, client) VALUES (458, 11);
INSERT INTO assignment (task, client) VALUES (459, 20);
INSERT INTO assignment (task, client) VALUES (460, 4);
INSERT INTO assignment (task, client) VALUES (460, 12);
INSERT INTO assignment (task, client) VALUES (460, 22);
INSERT INTO assignment (task, client) VALUES (461, 14);
INSERT INTO assignment (task, client) VALUES (462, 9);
INSERT INTO assignment (task, client) VALUES (468, 13);
INSERT INTO assignment (task, client) VALUES (469, 12);
INSERT INTO assignment (task, client) VALUES (470, 14);
INSERT INTO assignment (task, client) VALUES (471, 9);
INSERT INTO assignment (task, client) VALUES (471, 20);
INSERT INTO assignment (task, client) VALUES (472, 16);
INSERT INTO assignment (task, client) VALUES (474, 2);
INSERT INTO assignment (task, client) VALUES (474, 5);
INSERT INTO assignment (task, client) VALUES (474, 10);
INSERT INTO assignment (task, client) VALUES (474, 16);
INSERT INTO assignment (task, client) VALUES (475, 3);
INSERT INTO assignment (task, client) VALUES (476, 3);
INSERT INTO assignment (task, client) VALUES (476, 21);
INSERT INTO assignment (task, client) VALUES (477, 21);
INSERT INTO assignment (task, client) VALUES (477, 24);
INSERT INTO assignment (task, client) VALUES (478, 17);
INSERT INTO assignment (task, client) VALUES (478, 24);
INSERT INTO assignment (task, client) VALUES (479, 11);
INSERT INTO assignment (task, client) VALUES (479, 14);
INSERT INTO assignment (task, client) VALUES (480, 11);
INSERT INTO assignment (task, client) VALUES (480, 21);
INSERT INTO assignment (task, client) VALUES (481, 14);
INSERT INTO assignment (task, client) VALUES (481, 22);
INSERT INTO assignment (task, client) VALUES (483, 3);
INSERT INTO assignment (task, client) VALUES (483, 20);
INSERT INTO assignment (task, client) VALUES (484, 3);
INSERT INTO assignment (task, client) VALUES (485, 9);
INSERT INTO assignment (task, client) VALUES (485, 10);
INSERT INTO assignment (task, client) VALUES (485, 21);
INSERT INTO assignment (task, client) VALUES (486, 9);
INSERT INTO assignment (task, client) VALUES (486, 19);
INSERT INTO assignment (task, client) VALUES (486, 23);
INSERT INTO assignment (task, client) VALUES (487, 13);
INSERT INTO assignment (task, client) VALUES (487, 17);
INSERT INTO assignment (task, client) VALUES (488, 17);
INSERT INTO assignment (task, client) VALUES (489, 24);
INSERT INTO assignment (task, client) VALUES (490, 25);
INSERT INTO assignment (task, client) VALUES (492, 4);
INSERT INTO assignment (task, client) VALUES (492, 13);
INSERT INTO assignment (task, client) VALUES (492, 23);
INSERT INTO assignment (task, client) VALUES (493, 5);
INSERT INTO assignment (task, client) VALUES (493, 8);
INSERT INTO assignment (task, client) VALUES (493, 12);
INSERT INTO assignment (task, client) VALUES (494, 14);
INSERT INTO assignment (task, client) VALUES (495, 17);
INSERT INTO assignment (task, client) VALUES (496, 20);
INSERT INTO assignment (task, client) VALUES (497, 14);
INSERT INTO assignment (task, client) VALUES (497, 18);
INSERT INTO assignment (task, client) VALUES (499, 17);
INSERT INTO assignment (task, client) VALUES (500, 24);


-- Tag

INSERT INTO tag (project, name, color) VALUES (47, 'client-server', '#9d8ad3');
INSERT INTO tag (project, name, color) VALUES (8, 'Cross-platform', '#025181');
INSERT INTO tag (project, name, color) VALUES (11, 'cohesive', '#970123');
INSERT INTO tag (project, name, color) VALUES (20, 'throughput', '#a1d0db');
INSERT INTO tag (project, name, color) VALUES (4, 'Re-engineered', '#b1c9a5');
INSERT INTO tag (project, name, color) VALUES (1, 'Function-based', '#67d49b');
INSERT INTO tag (project, name, color) VALUES (11, 'Re-engineered', '#c0f9bd');
INSERT INTO tag (project, name, color) VALUES (4, 'User-centric', '#8b0a8d');
INSERT INTO tag (project, name, color) VALUES (8, 'non-volatile', '#14030d');
INSERT INTO tag (project, name, color) VALUES (33, 'capability', '#3a107b');
INSERT INTO tag (project, name, color) VALUES (19, 'capability', '#fd8a20');
INSERT INTO tag (project, name, color) VALUES (40, 'needs-based', '#d84136');
INSERT INTO tag (project, name, color) VALUES (13, 'Integrated', '#23d8a1');
INSERT INTO tag (project, name, color) VALUES (25, 'solution-oriented', '#f68e33');
INSERT INTO tag (project, name, color) VALUES (20, 'Persistent', '#4fc15c');
INSERT INTO tag (project, name, color) VALUES (44, 'parallelism', '#6e80ef');
INSERT INTO tag (project, name, color) VALUES (39, 'system engine', '#a01517');
INSERT INTO tag (project, name, color) VALUES (40, '4th generation', '#6a97d0');
INSERT INTO tag (project, name, color) VALUES (22, 'system-worthy', '#2af6d3');
INSERT INTO tag (project, name, color) VALUES (7, 'contingency', '#0b1834');
INSERT INTO tag (project, name, color) VALUES (41, 'reciprocal', '#45591d');
INSERT INTO tag (project, name, color) VALUES (40, 'Cloned', '#e9917b');
INSERT INTO tag (project, name, color) VALUES (42, 'structure', '#604e40');
INSERT INTO tag (project, name, color) VALUES (7, 'encoding', '#8a4b4e');
INSERT INTO tag (project, name, color) VALUES (20, 'collaboration', '#1c2b4b');
INSERT INTO tag (project, name, color) VALUES (47, 'optimizing', '#f53110');
INSERT INTO tag (project, name, color) VALUES (20, 'solution', '#be79c7');
INSERT INTO tag (project, name, color) VALUES (37, 'knowledge user', '#941ae7');
INSERT INTO tag (project, name, color) VALUES (4, 'Advanced', '#33039a');
INSERT INTO tag (project, name, color) VALUES (29, 'Automated', '#694e86');
INSERT INTO tag (project, name, color) VALUES (12, 'Phased', '#a22c66');
INSERT INTO tag (project, name, color) VALUES (29, 'task-force', '#12420a');
INSERT INTO tag (project, name, color) VALUES (28, 'service-desk', '#c2f318');
INSERT INTO tag (project, name, color) VALUES (49, 'coherent', '#d64fcc');
INSERT INTO tag (project, name, color) VALUES (44, 'projection', '#bfa147');
INSERT INTO tag (project, name, color) VALUES (17, 'knowledge user', '#24a705');
INSERT INTO tag (project, name, color) VALUES (35, 'Triple-buffered', '#ad2f00');
INSERT INTO tag (project, name, color) VALUES (7, 'Automated', '#4a73f3');
INSERT INTO tag (project, name, color) VALUES (27, 'background', '#3c2f02');
INSERT INTO tag (project, name, color) VALUES (30, 'attitude-oriented', '#4a513c');
INSERT INTO tag (project, name, color) VALUES (5, 'eco-centric', '#fc4fde');
INSERT INTO tag (project, name, color) VALUES (10, 'exuding', '#dacc23');
INSERT INTO tag (project, name, color) VALUES (14, 'Realigned', '#f29485');
INSERT INTO tag (project, name, color) VALUES (8, 'firmware', '#e9aaa3');
INSERT INTO tag (project, name, color) VALUES (10, 'user-facing', '#520003');
INSERT INTO tag (project, name, color) VALUES (49, 'methodology', '#35aed7');
INSERT INTO tag (project, name, color) VALUES (34, 'analyzing', '#487d35');
INSERT INTO tag (project, name, color) VALUES (50, 'adapter', '#726c32');
INSERT INTO tag (project, name, color) VALUES (16, 'Synergistic', '#337e5a');
INSERT INTO tag (project, name, color) VALUES (3, 'collaboration', '#1e635e');
INSERT INTO tag (project, name, color) VALUES (32, 'website', '#e55f6d');
INSERT INTO tag (project, name, color) VALUES (10, 'synergy', '#1a0760');
INSERT INTO tag (project, name, color) VALUES (13, 'empowering', '#9ece40');
INSERT INTO tag (project, name, color) VALUES (47, 'stable', '#afd8f1');
INSERT INTO tag (project, name, color) VALUES (48, 'model', '#f86707');
INSERT INTO tag (project, name, color) VALUES (49, 'focus group', '#55b3b9');
INSERT INTO tag (project, name, color) VALUES (40, 'Open-source', '#5d560b');
INSERT INTO tag (project, name, color) VALUES (28, 'radical', '#60d335');
INSERT INTO tag (project, name, color) VALUES (49, 'Compatible', '#118e9d');
INSERT INTO tag (project, name, color) VALUES (44, 'help-desk', '#bb94ce');
INSERT INTO tag (project, name, color) VALUES (3, 'software', '#ac8adb');
INSERT INTO tag (project, name, color) VALUES (36, 'User-centric', '#4d0db7');
INSERT INTO tag (project, name, color) VALUES (13, 'Open-source', '#d34af3');
INSERT INTO tag (project, name, color) VALUES (26, 'Reverse-engineered', '#31f13a');
INSERT INTO tag (project, name, color) VALUES (2, 'grid-enabled', '#d3faca');
INSERT INTO tag (project, name, color) VALUES (45, 'background', '#c814ab');
INSERT INTO tag (project, name, color) VALUES (37, 'process improvement', '#a42cd9');
INSERT INTO tag (project, name, color) VALUES (23, 'Phased', '#488369');
INSERT INTO tag (project, name, color) VALUES (26, 'website', '#3202fe');
INSERT INTO tag (project, name, color) VALUES (20, 'object-oriented', '#c33f70');
INSERT INTO tag (project, name, color) VALUES (44, 'user-facing', '#0e0d12');
INSERT INTO tag (project, name, color) VALUES (50, 'value-added', '#e74487');
INSERT INTO tag (project, name, color) VALUES (37, 'capability', '#d14605');
INSERT INTO tag (project, name, color) VALUES (4, 'Robust', '#33b60e');
INSERT INTO tag (project, name, color) VALUES (21, 'Seamless', '#8b098d');
INSERT INTO tag (project, name, color) VALUES (22, 'real-time', '#1b0006');
INSERT INTO tag (project, name, color) VALUES (13, 'Organized', '#2709ef');
INSERT INTO tag (project, name, color) VALUES (9, 'Programmable', '#b34110');
INSERT INTO tag (project, name, color) VALUES (48, 'productivity', '#4cf314');
INSERT INTO tag (project, name, color) VALUES (30, 'methodology', '#682ed9');
INSERT INTO tag (project, name, color) VALUES (21, 'maximized', '#7b6d68');
INSERT INTO tag (project, name, color) VALUES (42, 'methodical', '#d6d8c5');
INSERT INTO tag (project, name, color) VALUES (5, 'Robust', '#5ccc7b');
INSERT INTO tag (project, name, color) VALUES (29, 'exuding', '#1e52ba');
INSERT INTO tag (project, name, color) VALUES (15, 'instruction set', '#965c48');
INSERT INTO tag (project, name, color) VALUES (35, 'dedicated', '#9cc108');
INSERT INTO tag (project, name, color) VALUES (10, '4th generation', '#138832');
INSERT INTO tag (project, name, color) VALUES (46, 'task-force', '#aba2d0');
INSERT INTO tag (project, name, color) VALUES (48, 'pricing structure', '#b53111');
INSERT INTO tag (project, name, color) VALUES (13, 'logistical', '#f699bd');
INSERT INTO tag (project, name, color) VALUES (11, 'uniform', '#6860d9');
INSERT INTO tag (project, name, color) VALUES (27, 'definition', '#50e583');
INSERT INTO tag (project, name, color) VALUES (17, 'Visionary', '#0e3b86');
INSERT INTO tag (project, name, color) VALUES (24, 'Balanced', '#3ae926');
INSERT INTO tag (project, name, color) VALUES (46, 'leverage', '#b1708e');
INSERT INTO tag (project, name, color) VALUES (47, 'eco-centric', '#21bf51');
INSERT INTO tag (project, name, color) VALUES (23, '5th generation', '#a602f3');
INSERT INTO tag (project, name, color) VALUES (13, 'global', '#fe222d');
INSERT INTO tag (project, name, color) VALUES (47, 'multi-tasking', '#032a8f');
INSERT INTO tag (project, name, color) VALUES (17, 'internet solution', '#96b362');
INSERT INTO tag (project, name, color) VALUES (5, 'stable', '#4fcc44');
INSERT INTO tag (project, name, color) VALUES (49, 'Reactive', '#fb4c1d');
INSERT INTO tag (project, name, color) VALUES (23, 'even-keeled', '#d97cb0');
INSERT INTO tag (project, name, color) VALUES (6, 'Fundamental', '#9e1514');
INSERT INTO tag (project, name, color) VALUES (46, 'Open-architected', '#301079');
INSERT INTO tag (project, name, color) VALUES (35, 'Future-proofed', '#92be74');
INSERT INTO tag (project, name, color) VALUES (23, 'modular', '#10f235');
INSERT INTO tag (project, name, color) VALUES (30, 'Fundamental', '#d2ff4c');
INSERT INTO tag (project, name, color) VALUES (31, 'Programmable', '#52194c');
INSERT INTO tag (project, name, color) VALUES (7, 'neutral', '#1aa159');
INSERT INTO tag (project, name, color) VALUES (22, 'product', '#5cb7fa');
INSERT INTO tag (project, name, color) VALUES (4, 'data-warehouse', '#79d4ad');
INSERT INTO tag (project, name, color) VALUES (7, '3rd generation', '#ceaf59');
INSERT INTO tag (project, name, color) VALUES (45, 'policy', '#2e98af');
INSERT INTO tag (project, name, color) VALUES (23, 'Reduced', '#951643');
INSERT INTO tag (project, name, color) VALUES (44, 'project', '#70e44d');
INSERT INTO tag (project, name, color) VALUES (44, 'transitional', '#69b2d2');
INSERT INTO tag (project, name, color) VALUES (45, 'Fundamental', '#26db1d');
INSERT INTO tag (project, name, color) VALUES (14, 'fresh-thinking', '#84f233');
INSERT INTO tag (project, name, color) VALUES (10, 'synergy', '#ed3ffb');
INSERT INTO tag (project, name, color) VALUES (47, 'encompassing', '#d4403e');
INSERT INTO tag (project, name, color) VALUES (37, 'Quality-focused', '#53ab30');
INSERT INTO tag (project, name, color) VALUES (24, 'client-driven', '#d4e623');
INSERT INTO tag (project, name, color) VALUES (26, 'scalable', '#cbec00');
INSERT INTO tag (project, name, color) VALUES (4, 'migration', '#7be453');
INSERT INTO tag (project, name, color) VALUES (38, 'structure', '#e271f1');
INSERT INTO tag (project, name, color) VALUES (34, 'demand-driven', '#b04d78');
INSERT INTO tag (project, name, color) VALUES (4, 'capacity', '#d1c881');
INSERT INTO tag (project, name, color) VALUES (27, 'web-enabled', '#9b3f3b');
INSERT INTO tag (project, name, color) VALUES (44, 'next generation', '#3f10b0');
INSERT INTO tag (project, name, color) VALUES (29, 'benchmark', '#a91076');
INSERT INTO tag (project, name, color) VALUES (34, 'synergy', '#03c4ff');
INSERT INTO tag (project, name, color) VALUES (27, 'secondary', '#f8a084');
INSERT INTO tag (project, name, color) VALUES (5, 'non-volatile', '#1b4245');
INSERT INTO tag (project, name, color) VALUES (46, 'well-modulated', '#5f23bc');
INSERT INTO tag (project, name, color) VALUES (43, 'Right-sized', '#73f2a4');
INSERT INTO tag (project, name, color) VALUES (46, 'Team-oriented', '#d6a1f1');
INSERT INTO tag (project, name, color) VALUES (46, 'Front-line', '#015be5');
INSERT INTO tag (project, name, color) VALUES (40, 'Operative', '#240e90');
INSERT INTO tag (project, name, color) VALUES (39, 'Persistent', '#c9ee53');
INSERT INTO tag (project, name, color) VALUES (32, 'regional', '#9fd7ef');
INSERT INTO tag (project, name, color) VALUES (43, 'success', '#348717');
INSERT INTO tag (project, name, color) VALUES (27, 'concept', '#c14ba1');
INSERT INTO tag (project, name, color) VALUES (49, 'solution', '#5ac327');
INSERT INTO tag (project, name, color) VALUES (3, '3rd generation', '#2a6084');
INSERT INTO tag (project, name, color) VALUES (45, 'flexibility', '#e3bca0');
INSERT INTO tag (project, name, color) VALUES (25, 'bifurcated', '#03570c');
INSERT INTO tag (project, name, color) VALUES (21, 'real-time', '#8d88d6');
INSERT INTO tag (project, name, color) VALUES (7, 'De-engineered', '#89ebd6');
INSERT INTO tag (project, name, color) VALUES (18, 'Switchable', '#ad38cf');


-- Contains Tag

INSERT INTO contains_tag (tag, task) VALUES (2, 378);
INSERT INTO contains_tag (tag, task) VALUES (3, 60);
INSERT INTO contains_tag (tag, task) VALUES (4, 429);
INSERT INTO contains_tag (tag, task) VALUES (5, 463);
INSERT INTO contains_tag (tag, task) VALUES (6, 52);
INSERT INTO contains_tag (tag, task) VALUES (6, 173);
INSERT INTO contains_tag (tag, task) VALUES (6, 385);
INSERT INTO contains_tag (tag, task) VALUES (6, 444);
INSERT INTO contains_tag (tag, task) VALUES (7, 77);
INSERT INTO contains_tag (tag, task) VALUES (8, 463);
INSERT INTO contains_tag (tag, task) VALUES (9, 5);
INSERT INTO contains_tag (tag, task) VALUES (9, 372);
INSERT INTO contains_tag (tag, task) VALUES (9, 397);
INSERT INTO contains_tag (tag, task) VALUES (10, 113);
INSERT INTO contains_tag (tag, task) VALUES (10, 121);
INSERT INTO contains_tag (tag, task) VALUES (10, 228);
INSERT INTO contains_tag (tag, task) VALUES (10, 374);
INSERT INTO contains_tag (tag, task) VALUES (10, 465);
INSERT INTO contains_tag (tag, task) VALUES (10, 474);
INSERT INTO contains_tag (tag, task) VALUES (11, 85);
INSERT INTO contains_tag (tag, task) VALUES (11, 192);
INSERT INTO contains_tag (tag, task) VALUES (11, 203);
INSERT INTO contains_tag (tag, task) VALUES (11, 258);
INSERT INTO contains_tag (tag, task) VALUES (13, 156);
INSERT INTO contains_tag (tag, task) VALUES (14, 1);
INSERT INTO contains_tag (tag, task) VALUES (14, 267);
INSERT INTO contains_tag (tag, task) VALUES (14, 461);
INSERT INTO contains_tag (tag, task) VALUES (15, 443);
INSERT INTO contains_tag (tag, task) VALUES (16, 266);
INSERT INTO contains_tag (tag, task) VALUES (17, 212);
INSERT INTO contains_tag (tag, task) VALUES (17, 290);
INSERT INTO contains_tag (tag, task) VALUES (18, 274);
INSERT INTO contains_tag (tag, task) VALUES (19, 67);
INSERT INTO contains_tag (tag, task) VALUES (19, 150);
INSERT INTO contains_tag (tag, task) VALUES (19, 470);
INSERT INTO contains_tag (tag, task) VALUES (20, 280);
INSERT INTO contains_tag (tag, task) VALUES (21, 89);
INSERT INTO contains_tag (tag, task) VALUES (21, 260);
INSERT INTO contains_tag (tag, task) VALUES (21, 325);
INSERT INTO contains_tag (tag, task) VALUES (21, 359);
INSERT INTO contains_tag (tag, task) VALUES (23, 452);
INSERT INTO contains_tag (tag, task) VALUES (25, 227);
INSERT INTO contains_tag (tag, task) VALUES (25, 469);
INSERT INTO contains_tag (tag, task) VALUES (26, 109);
INSERT INTO contains_tag (tag, task) VALUES (26, 292);
INSERT INTO contains_tag (tag, task) VALUES (26, 306);
INSERT INTO contains_tag (tag, task) VALUES (27, 296);
INSERT INTO contains_tag (tag, task) VALUES (28, 28);
INSERT INTO contains_tag (tag, task) VALUES (28, 243);
INSERT INTO contains_tag (tag, task) VALUES (29, 315);
INSERT INTO contains_tag (tag, task) VALUES (29, 423);
INSERT INTO contains_tag (tag, task) VALUES (30, 128);
INSERT INTO contains_tag (tag, task) VALUES (30, 445);
INSERT INTO contains_tag (tag, task) VALUES (31, 50);
INSERT INTO contains_tag (tag, task) VALUES (31, 99);
INSERT INTO contains_tag (tag, task) VALUES (31, 126);
INSERT INTO contains_tag (tag, task) VALUES (31, 186);
INSERT INTO contains_tag (tag, task) VALUES (31, 411);
INSERT INTO contains_tag (tag, task) VALUES (32, 128);
INSERT INTO contains_tag (tag, task) VALUES (32, 259);
INSERT INTO contains_tag (tag, task) VALUES (33, 187);
INSERT INTO contains_tag (tag, task) VALUES (34, 55);
INSERT INTO contains_tag (tag, task) VALUES (34, 76);
INSERT INTO contains_tag (tag, task) VALUES (36, 74);
INSERT INTO contains_tag (tag, task) VALUES (37, 250);
INSERT INTO contains_tag (tag, task) VALUES (37, 316);
INSERT INTO contains_tag (tag, task) VALUES (37, 491);
INSERT INTO contains_tag (tag, task) VALUES (38, 438);
INSERT INTO contains_tag (tag, task) VALUES (39, 120);
INSERT INTO contains_tag (tag, task) VALUES (39, 196);
INSERT INTO contains_tag (tag, task) VALUES (40, 167);
INSERT INTO contains_tag (tag, task) VALUES (40, 310);
INSERT INTO contains_tag (tag, task) VALUES (40, 440);
INSERT INTO contains_tag (tag, task) VALUES (41, 122);
INSERT INTO contains_tag (tag, task) VALUES (41, 190);
INSERT INTO contains_tag (tag, task) VALUES (42, 224);
INSERT INTO contains_tag (tag, task) VALUES (43, 112);
INSERT INTO contains_tag (tag, task) VALUES (43, 210);
INSERT INTO contains_tag (tag, task) VALUES (43, 240);
INSERT INTO contains_tag (tag, task) VALUES (43, 446);
INSERT INTO contains_tag (tag, task) VALUES (44, 378);
INSERT INTO contains_tag (tag, task) VALUES (44, 397);
INSERT INTO contains_tag (tag, task) VALUES (46, 488);
INSERT INTO contains_tag (tag, task) VALUES (47, 351);
INSERT INTO contains_tag (tag, task) VALUES (47, 480);
INSERT INTO contains_tag (tag, task) VALUES (48, 161);
INSERT INTO contains_tag (tag, task) VALUES (48, 481);
INSERT INTO contains_tag (tag, task) VALUES (49, 31);
INSERT INTO contains_tag (tag, task) VALUES (49, 147);
INSERT INTO contains_tag (tag, task) VALUES (49, 153);
INSERT INTO contains_tag (tag, task) VALUES (49, 289);
INSERT INTO contains_tag (tag, task) VALUES (49, 355);
INSERT INTO contains_tag (tag, task) VALUES (49, 376);
INSERT INTO contains_tag (tag, task) VALUES (49, 398);
INSERT INTO contains_tag (tag, task) VALUES (50, 456);
INSERT INTO contains_tag (tag, task) VALUES (51, 390);
INSERT INTO contains_tag (tag, task) VALUES (52, 224);
INSERT INTO contains_tag (tag, task) VALUES (54, 407);
INSERT INTO contains_tag (tag, task) VALUES (55, 155);
INSERT INTO contains_tag (tag, task) VALUES (56, 308);
INSERT INTO contains_tag (tag, task) VALUES (57, 19);
INSERT INTO contains_tag (tag, task) VALUES (57, 274);
INSERT INTO contains_tag (tag, task) VALUES (59, 140);
INSERT INTO contains_tag (tag, task) VALUES (60, 427);
INSERT INTO contains_tag (tag, task) VALUES (61, 245);
INSERT INTO contains_tag (tag, task) VALUES (62, 40);
INSERT INTO contains_tag (tag, task) VALUES (62, 49);
INSERT INTO contains_tag (tag, task) VALUES (62, 184);
INSERT INTO contains_tag (tag, task) VALUES (63, 156);
INSERT INTO contains_tag (tag, task) VALUES (64, 424);
INSERT INTO contains_tag (tag, task) VALUES (65, 64);
INSERT INTO contains_tag (tag, task) VALUES (65, 124);
INSERT INTO contains_tag (tag, task) VALUES (65, 176);
INSERT INTO contains_tag (tag, task) VALUES (65, 309);
INSERT INTO contains_tag (tag, task) VALUES (65, 341);
INSERT INTO contains_tag (tag, task) VALUES (65, 353);
INSERT INTO contains_tag (tag, task) VALUES (65, 386);
INSERT INTO contains_tag (tag, task) VALUES (65, 478);
INSERT INTO contains_tag (tag, task) VALUES (65, 494);
INSERT INTO contains_tag (tag, task) VALUES (66, 323);
INSERT INTO contains_tag (tag, task) VALUES (67, 476);
INSERT INTO contains_tag (tag, task) VALUES (67, 495);
INSERT INTO contains_tag (tag, task) VALUES (68, 335);
INSERT INTO contains_tag (tag, task) VALUES (69, 36);
INSERT INTO contains_tag (tag, task) VALUES (70, 271);
INSERT INTO contains_tag (tag, task) VALUES (70, 296);
INSERT INTO contains_tag (tag, task) VALUES (70, 358);
INSERT INTO contains_tag (tag, task) VALUES (72, 66);
INSERT INTO contains_tag (tag, task) VALUES (72, 107);
INSERT INTO contains_tag (tag, task) VALUES (72, 169);
INSERT INTO contains_tag (tag, task) VALUES (73, 83);
INSERT INTO contains_tag (tag, task) VALUES (75, 432);
INSERT INTO contains_tag (tag, task) VALUES (76, 65);
INSERT INTO contains_tag (tag, task) VALUES (76, 134);
INSERT INTO contains_tag (tag, task) VALUES (76, 150);
INSERT INTO contains_tag (tag, task) VALUES (76, 220);
INSERT INTO contains_tag (tag, task) VALUES (77, 165);
INSERT INTO contains_tag (tag, task) VALUES (77, 214);
INSERT INTO contains_tag (tag, task) VALUES (77, 449);
INSERT INTO contains_tag (tag, task) VALUES (78, 53);
INSERT INTO contains_tag (tag, task) VALUES (78, 58);
INSERT INTO contains_tag (tag, task) VALUES (78, 248);
INSERT INTO contains_tag (tag, task) VALUES (78, 302);
INSERT INTO contains_tag (tag, task) VALUES (78, 321);
INSERT INTO contains_tag (tag, task) VALUES (79, 142);
INSERT INTO contains_tag (tag, task) VALUES (80, 102);
INSERT INTO contains_tag (tag, task) VALUES (80, 286);
INSERT INTO contains_tag (tag, task) VALUES (81, 39);
INSERT INTO contains_tag (tag, task) VALUES (82, 75);
INSERT INTO contains_tag (tag, task) VALUES (82, 326);
INSERT INTO contains_tag (tag, task) VALUES (82, 452);
INSERT INTO contains_tag (tag, task) VALUES (84, 344);
INSERT INTO contains_tag (tag, task) VALUES (84, 367);
INSERT INTO contains_tag (tag, task) VALUES (84, 419);
INSERT INTO contains_tag (tag, task) VALUES (85, 193);
INSERT INTO contains_tag (tag, task) VALUES (85, 230);
INSERT INTO contains_tag (tag, task) VALUES (85, 281);
INSERT INTO contains_tag (tag, task) VALUES (86, 80);
INSERT INTO contains_tag (tag, task) VALUES (86, 275);
INSERT INTO contains_tag (tag, task) VALUES (88, 209);
INSERT INTO contains_tag (tag, task) VALUES (89, 125);
INSERT INTO contains_tag (tag, task) VALUES (90, 165);
INSERT INTO contains_tag (tag, task) VALUES (90, 299);
INSERT INTO contains_tag (tag, task) VALUES (93, 25);
INSERT INTO contains_tag (tag, task) VALUES (93, 410);
INSERT INTO contains_tag (tag, task) VALUES (93, 442);
INSERT INTO contains_tag (tag, task) VALUES (94, 3);
INSERT INTO contains_tag (tag, task) VALUES (94, 104);
INSERT INTO contains_tag (tag, task) VALUES (95, 6);
INSERT INTO contains_tag (tag, task) VALUES (97, 166);
INSERT INTO contains_tag (tag, task) VALUES (97, 278);
INSERT INTO contains_tag (tag, task) VALUES (97, 282);
INSERT INTO contains_tag (tag, task) VALUES (98, 449);
INSERT INTO contains_tag (tag, task) VALUES (99, 306);
INSERT INTO contains_tag (tag, task) VALUES (101, 229);
INSERT INTO contains_tag (tag, task) VALUES (102, 431);
INSERT INTO contains_tag (tag, task) VALUES (102, 455);
INSERT INTO contains_tag (tag, task) VALUES (104, 24);
INSERT INTO contains_tag (tag, task) VALUES (104, 132);
INSERT INTO contains_tag (tag, task) VALUES (104, 213);
INSERT INTO contains_tag (tag, task) VALUES (104, 330);
INSERT INTO contains_tag (tag, task) VALUES (105, 6);
INSERT INTO contains_tag (tag, task) VALUES (106, 433);
INSERT INTO contains_tag (tag, task) VALUES (106, 491);
INSERT INTO contains_tag (tag, task) VALUES (107, 334);
INSERT INTO contains_tag (tag, task) VALUES (108, 167);
INSERT INTO contains_tag (tag, task) VALUES (108, 211);
INSERT INTO contains_tag (tag, task) VALUES (108, 286);
INSERT INTO contains_tag (tag, task) VALUES (108, 310);
INSERT INTO contains_tag (tag, task) VALUES (109, 59);
INSERT INTO contains_tag (tag, task) VALUES (109, 199);
INSERT INTO contains_tag (tag, task) VALUES (109, 400);
INSERT INTO contains_tag (tag, task) VALUES (109, 417);
INSERT INTO contains_tag (tag, task) VALUES (110, 384);
INSERT INTO contains_tag (tag, task) VALUES (111, 65);
INSERT INTO contains_tag (tag, task) VALUES (111, 150);
INSERT INTO contains_tag (tag, task) VALUES (112, 339);
INSERT INTO contains_tag (tag, task) VALUES (114, 2);
INSERT INTO contains_tag (tag, task) VALUES (114, 408);
INSERT INTO contains_tag (tag, task) VALUES (115, 335);
INSERT INTO contains_tag (tag, task) VALUES (117, 266);
INSERT INTO contains_tag (tag, task) VALUES (117, 319);
INSERT INTO contains_tag (tag, task) VALUES (118, 2);
INSERT INTO contains_tag (tag, task) VALUES (118, 338);
INSERT INTO contains_tag (tag, task) VALUES (119, 112);
INSERT INTO contains_tag (tag, task) VALUES (119, 210);
INSERT INTO contains_tag (tag, task) VALUES (119, 240);
INSERT INTO contains_tag (tag, task) VALUES (119, 492);
INSERT INTO contains_tag (tag, task) VALUES (120, 218);
INSERT INTO contains_tag (tag, task) VALUES (121, 332);
INSERT INTO contains_tag (tag, task) VALUES (122, 28);
INSERT INTO contains_tag (tag, task) VALUES (122, 476);
INSERT INTO contains_tag (tag, task) VALUES (123, 41);
INSERT INTO contains_tag (tag, task) VALUES (123, 104);
INSERT INTO contains_tag (tag, task) VALUES (123, 287);
INSERT INTO contains_tag (tag, task) VALUES (123, 489);
INSERT INTO contains_tag (tag, task) VALUES (125, 315);
INSERT INTO contains_tag (tag, task) VALUES (125, 349);
INSERT INTO contains_tag (tag, task) VALUES (126, 78);
INSERT INTO contains_tag (tag, task) VALUES (126, 487);
INSERT INTO contains_tag (tag, task) VALUES (127, 32);
INSERT INTO contains_tag (tag, task) VALUES (127, 233);
INSERT INTO contains_tag (tag, task) VALUES (127, 480);
INSERT INTO contains_tag (tag, task) VALUES (128, 422);
INSERT INTO contains_tag (tag, task) VALUES (131, 13);
INSERT INTO contains_tag (tag, task) VALUES (131, 298);
INSERT INTO contains_tag (tag, task) VALUES (132, 412);
INSERT INTO contains_tag (tag, task) VALUES (132, 414);
INSERT INTO contains_tag (tag, task) VALUES (134, 190);
INSERT INTO contains_tag (tag, task) VALUES (135, 27);
INSERT INTO contains_tag (tag, task) VALUES (136, 149);
INSERT INTO contains_tag (tag, task) VALUES (138, 209);
INSERT INTO contains_tag (tag, task) VALUES (140, 48);
INSERT INTO contains_tag (tag, task) VALUES (141, 390);
INSERT INTO contains_tag (tag, task) VALUES (142, 116);
INSERT INTO contains_tag (tag, task) VALUES (142, 197);
INSERT INTO contains_tag (tag, task) VALUES (142, 437);
INSERT INTO contains_tag (tag, task) VALUES (142, 451);
INSERT INTO contains_tag (tag, task) VALUES (145, 396);
INSERT INTO contains_tag (tag, task) VALUES (145, 415);
INSERT INTO contains_tag (tag, task) VALUES (147, 7);
INSERT INTO contains_tag (tag, task) VALUES (148, 118);
INSERT INTO contains_tag (tag, task) VALUES (148, 288);
INSERT INTO contains_tag (tag, task) VALUES (149, 279);
INSERT INTO contains_tag (tag, task) VALUES (149, 280);
INSERT INTO contains_tag (tag, task) VALUES (149, 293);
INSERT INTO contains_tag (tag, task) VALUES (150, 14);
INSERT INTO contains_tag (tag, task) VALUES (150, 356);
INSERT INTO contains_tag (tag, task) VALUES (150, 457);
INSERT INTO contains_tag (tag, task) VALUES (150, 458);


-- Check-List Item

INSERT INTO check_list_item (item_text, completed, task) VALUES ('cultivate plug-and-play e-commerce', TRUE, 249);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('redefine impactful systems', TRUE, 498);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('facilitate innovative technologies', FALSE, 374);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('innovate value-added technologies', TRUE, 73);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('disintermediate frictionless architectures', FALSE, 171);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('optimize front-end models', FALSE, 141);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('strategize visionary architectures', FALSE, 189);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('mesh frictionless systems', FALSE, 489);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('target customized networks', FALSE, 347);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transition transparent relationships', TRUE, 449);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale innovative applications', FALSE, 285);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('generate B2C metrics', FALSE, 280);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('evolve distributed e-commerce', FALSE, 158);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('drive seamless e-tailers', TRUE, 446);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synthesize bleeding-edge mindshare', FALSE, 415);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('e-enable efficient e-services', FALSE, 328);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('evolve innovative relationships', TRUE, 100);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('strategize killer initiatives', FALSE, 430);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('innovate seamless eyeballs', FALSE, 211);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('innovate strategic users', FALSE, 117);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('orchestrate virtual platforms', FALSE, 357);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engineer synergistic supply-chains', TRUE, 181);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('implement open-source eyeballs', FALSE, 287);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reintermediate vertical schemas', TRUE, 137);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('morph leading-edge web-readiness', TRUE, 144);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('expedite sticky bandwidth', FALSE, 351);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('architect frictionless web-readiness', FALSE, 434);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('strategize integrated action-items', FALSE, 35);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('empower strategic platforms', TRUE, 128);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('grow dynamic solutions', FALSE, 465);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synergize rich ROI', TRUE, 141);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('architect cross-platform applications', FALSE, 143);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transition innovative e-business', TRUE, 295);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synthesize one-to-one e-business', FALSE, 394);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('seize 24/7 e-commerce', FALSE, 338);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incubate robust infomediaries', TRUE, 41);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('architect robust supply-chains', TRUE, 447);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('cultivate next-generation solutions', TRUE, 451);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('recontextualize end-to-end e-markets', TRUE, 280);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('seize bricks-and-clicks systems', TRUE, 443);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('e-enable ubiquitous mindshare', TRUE, 431);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transform mission-critical synergies', FALSE, 42);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale one-to-one eyeballs', FALSE, 34);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('target compelling eyeballs', FALSE, 425);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deliver magnetic functionalities', FALSE, 159);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synthesize web-enabled systems', FALSE, 480);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('leverage innovative niches', FALSE, 487);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale bleeding-edge networks', TRUE, 11);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('redefine proactive functionalities', TRUE, 130);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('empower value-added paradigms', FALSE, 136);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engineer seamless systems', FALSE, 439);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('unleash out-of-the-box vortals', FALSE, 310);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('envisioneer 24/7 niches', TRUE, 283);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('orchestrate clicks-and-mortar initiatives', TRUE, 257);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('integrate mission-critical supply-chains', FALSE, 339);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('leverage magnetic metrics', TRUE, 40);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('generate leading-edge initiatives', TRUE, 487);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('revolutionize wireless interfaces', FALSE, 130);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('drive bleeding-edge content', FALSE, 368);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('extend value-added networks', FALSE, 222);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('envisioneer bleeding-edge markets', FALSE, 407);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incentivize efficient niches', TRUE, 55);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('matrix cross-platform applications', FALSE, 99);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale visionary deliverables', FALSE, 59);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('benchmark B2C web-readiness', FALSE, 465);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('exploit visionary supply-chains', TRUE, 226);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('target cross-platform e-business', TRUE, 187);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('utilize world-class markets', TRUE, 448);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engineer cross-media models', TRUE, 311);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('embrace world-class supply-chains', FALSE, 129);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('grow cross-media functionalities', FALSE, 114);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('unleash collaborative e-markets', FALSE, 143);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transition wireless e-commerce', TRUE, 92);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('strategize next-generation e-services', FALSE, 180);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reinvent user-centric users', FALSE, 433);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('embrace cross-media web services', FALSE, 129);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('cultivate cutting-edge mindshare', FALSE, 161);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reintermediate bleeding-edge e-tailers', TRUE, 159);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('expedite clicks-and-mortar markets', FALSE, 211);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('morph front-end experiences', FALSE, 488);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engineer granular methodologies', TRUE, 384);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reinvent bleeding-edge content', TRUE, 472);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('visualize magnetic paradigms', FALSE, 380);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('leverage cross-platform vortals', TRUE, 359);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synthesize holistic content', FALSE, 269);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('e-enable open-source technologies', TRUE, 53);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('whiteboard scalable portals', FALSE, 408);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transition robust communities', FALSE, 337);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('revolutionize 24/365 web-readiness', TRUE, 467);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deploy best-of-breed web services', FALSE, 169);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transform enterprise vortals', FALSE, 146);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('facilitate cross-platform architectures', TRUE, 375);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('unleash bleeding-edge e-tailers', FALSE, 136);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transition B2B communities', TRUE, 373);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('orchestrate mission-critical functionalities', FALSE, 180);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('integrate dot-com applications', TRUE, 411);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('monetize web-enabled vortals', FALSE, 375);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('visualize rich initiatives', FALSE, 486);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engage real-time convergence', TRUE, 424);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('extend killer e-tailers', FALSE, 148);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('drive impactful users', TRUE, 458);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('architect scalable metrics', FALSE, 218);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('envisioneer proactive e-commerce', FALSE, 453);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('mesh B2B e-services', FALSE, 483);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engineer cross-media e-markets', FALSE, 133);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('morph killer relationships', FALSE, 135);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('matrix integrated initiatives', FALSE, 183);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('productize back-end methodologies', TRUE, 313);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('visualize revolutionary infrastructures', FALSE, 448);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('unleash cross-platform functionalities', TRUE, 387);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale virtual schemas', TRUE, 463);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('enhance next-generation portals', TRUE, 306);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('whiteboard best-of-breed e-tailers', TRUE, 320);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('strategize web-enabled infrastructures', TRUE, 221);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('optimize interactive interfaces', FALSE, 10);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('envisioneer one-to-one models', FALSE, 16);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('disintermediate bleeding-edge synergies', FALSE, 441);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('exploit intuitive e-markets', TRUE, 40);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deliver web-enabled users', FALSE, 394);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('syndicate efficient applications', TRUE, 315);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('envisioneer world-class portals', TRUE, 143);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('matrix robust portals', TRUE, 329);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale granular models', TRUE, 59);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('drive robust action-items', FALSE, 214);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incubate granular mindshare', TRUE, 122);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('envisioneer efficient markets', TRUE, 116);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('disintermediate robust niches', FALSE, 238);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incubate magnetic applications', TRUE, 146);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('mesh holistic schemas', FALSE, 62);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('embrace wireless paradigms', TRUE, 302);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incubate intuitive applications', TRUE, 477);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('enhance leading-edge portals', TRUE, 132);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('innovate integrated niches', TRUE, 214);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('architect out-of-the-box architectures', FALSE, 190);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deploy frictionless users', TRUE, 245);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('cultivate rich eyeballs', FALSE, 415);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reintermediate best-of-breed supply-chains', FALSE, 347);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transform mission-critical models', FALSE, 419);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('leverage revolutionary initiatives', FALSE, 92);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('evolve proactive platforms', TRUE, 448);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incubate dot-com e-business', TRUE, 172);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale frictionless content', TRUE, 367);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('innovate compelling interfaces', TRUE, 170);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('empower 24/7 e-services', TRUE, 37);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('recontextualize B2B relationships', TRUE, 320);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('redefine visionary niches', FALSE, 433);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transform B2B mindshare', FALSE, 213);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('syndicate back-end interfaces', TRUE, 245);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('aggregate next-generation platforms', TRUE, 17);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('cultivate end-to-end action-items', FALSE, 390);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('utilize customized relationships', TRUE, 224);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incentivize leading-edge relationships', FALSE, 298);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale out-of-the-box e-services', FALSE, 148);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synergize robust initiatives', TRUE, 435);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('recontextualize open-source methodologies', TRUE, 198);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synthesize bleeding-edge schemas', FALSE, 53);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('enhance user-centric e-commerce', FALSE, 170);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('exploit proactive applications', FALSE, 320);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('matrix impactful synergies', FALSE, 419);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('aggregate granular technologies', TRUE, 130);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('morph viral architectures', FALSE, 148);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('integrate 24/7 e-business', TRUE, 369);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('monetize clicks-and-mortar networks', TRUE, 190);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('expedite magnetic bandwidth', TRUE, 83);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('architect interactive schemas', TRUE, 270);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('syndicate bleeding-edge solutions', TRUE, 161);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('exploit cutting-edge infomediaries', FALSE, 400);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('recontextualize vertical methodologies', TRUE, 429);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('embrace visionary deliverables', FALSE, 416);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('streamline innovative bandwidth', FALSE, 288);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('evolve front-end models', FALSE, 7);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('whiteboard proactive bandwidth', FALSE, 198);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('seize wireless users', FALSE, 232);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('orchestrate revolutionary e-business', FALSE, 171);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('e-enable efficient content', FALSE, 475);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale wireless users', TRUE, 490);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('harness sticky mindshare', TRUE, 251);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('optimize plug-and-play bandwidth', TRUE, 40);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deploy revolutionary web services', TRUE, 81);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('target scalable paradigms', FALSE, 264);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('strategize distributed channels', FALSE, 206);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('morph proactive e-tailers', TRUE, 476);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deploy mission-critical systems', FALSE, 355);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('target global applications', TRUE, 216);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deliver ubiquitous infrastructures', FALSE, 52);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('facilitate world-class e-business', FALSE, 177);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synthesize turn-key convergence', FALSE, 198);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('facilitate clicks-and-mortar bandwidth', FALSE, 445);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deliver dot-com niches', TRUE, 444);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('seize open-source bandwidth', TRUE, 132);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('evolve back-end bandwidth', TRUE, 138);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('maximize frictionless niches', TRUE, 154);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synthesize mission-critical vortals', TRUE, 118);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('disintermediate extensible paradigms', FALSE, 500);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('iterate user-centric interfaces', FALSE, 467);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('e-enable leading-edge metrics', TRUE, 290);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reintermediate end-to-end metrics', TRUE, 303);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale sticky convergence', TRUE, 143);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('e-enable dynamic infomediaries', TRUE, 252);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('evolve real-time initiatives', TRUE, 145);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('repurpose mission-critical networks', FALSE, 411);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('target end-to-end architectures', TRUE, 173);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('brand efficient e-markets', FALSE, 272);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('recontextualize viral communities', FALSE, 182);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engage revolutionary solutions', FALSE, 102);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('architect magnetic applications', TRUE, 158);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('productize dot-com content', FALSE, 301);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('morph B2B e-business', FALSE, 339);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('unleash transparent markets', TRUE, 37);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('brand end-to-end initiatives', TRUE, 26);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reinvent bricks-and-clicks schemas', FALSE, 413);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('productize best-of-breed partnerships', TRUE, 445);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('visualize value-added platforms', TRUE, 112);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synergize intuitive convergence', TRUE, 252);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('utilize wireless technologies', FALSE, 303);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transition viral networks', FALSE, 165);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reinvent rich bandwidth', FALSE, 97);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('unleash 24/365 markets', FALSE, 48);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('expedite sticky e-tailers', TRUE, 172);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('utilize strategic applications', TRUE, 410);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('utilize distributed relationships', TRUE, 105);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('enhance viral users', FALSE, 295);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('extend seamless niches', TRUE, 286);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('syndicate turn-key solutions', TRUE, 232);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('enable B2C technologies', TRUE, 194);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale cross-media content', FALSE, 104);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('utilize frictionless portals', TRUE, 413);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('visualize frictionless functionalities', TRUE, 179);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('enable web-enabled e-tailers', FALSE, 424);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('empower sexy interfaces', FALSE, 43);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale intuitive portals', FALSE, 398);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('syndicate e-business partnerships', FALSE, 115);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('exploit e-business communities', TRUE, 403);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synergize enterprise interfaces', TRUE, 387);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('envisioneer visionary architectures', FALSE, 185);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('aggregate killer methodologies', FALSE, 305);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('visualize best-of-breed supply-chains', TRUE, 288);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incubate open-source web-readiness', FALSE, 307);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('recontextualize bricks-and-clicks communities', TRUE, 436);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('evolve vertical e-markets', TRUE, 431);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('harness sticky applications', TRUE, 289);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('disintermediate frictionless communities', FALSE, 495);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('streamline e-business mindshare', TRUE, 62);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale revolutionary platforms', TRUE, 271);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale end-to-end bandwidth', TRUE, 439);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deliver leading-edge action-items', FALSE, 445);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reintermediate customized ROI', TRUE, 107);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('leverage enterprise convergence', FALSE, 211);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('aggregate end-to-end users', TRUE, 331);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('utilize distributed experiences', TRUE, 129);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('integrate turn-key e-tailers', FALSE, 467);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('extend impactful e-business', TRUE, 167);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synergize cutting-edge infrastructures', TRUE, 54);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('integrate compelling architectures', FALSE, 355);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('integrate impactful methodologies', TRUE, 315);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('benchmark revolutionary interfaces', FALSE, 50);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('implement sexy schemas', TRUE, 162);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('matrix scalable systems', FALSE, 11);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('e-enable integrated infrastructures', TRUE, 119);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transition end-to-end platforms', FALSE, 291);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synergize extensible supply-chains', FALSE, 292);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('generate clicks-and-mortar interfaces', TRUE, 258);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale sticky e-commerce', TRUE, 289);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('implement bricks-and-clicks supply-chains', FALSE, 171);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('aggregate B2B mindshare', FALSE, 369);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('whiteboard magnetic interfaces', TRUE, 171);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deploy mission-critical initiatives', FALSE, 303);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('evolve front-end e-markets', FALSE, 218);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('monetize frictionless web-readiness', FALSE, 323);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reinvent mission-critical technologies', FALSE, 491);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('generate proactive convergence', TRUE, 52);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('mesh granular applications', TRUE, 257);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('harness robust experiences', FALSE, 151);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('expedite synergistic infomediaries', TRUE, 333);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deploy intuitive action-items', TRUE, 380);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synthesize transparent channels', TRUE, 215);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synergize visionary supply-chains', FALSE, 106);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('orchestrate turn-key e-markets', FALSE, 279);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('harness 24/7 platforms', TRUE, 379);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('exploit enterprise initiatives', TRUE, 251);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('aggregate back-end networks', FALSE, 408);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('matrix seamless web-readiness', TRUE, 309);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reintermediate customized relationships', FALSE, 141);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('enhance end-to-end users', TRUE, 70);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('strategize open-source systems', FALSE, 38);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reinvent visionary systems', TRUE, 397);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale frictionless metrics', TRUE, 81);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale enterprise eyeballs', TRUE, 201);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('orchestrate extensible metrics', TRUE, 163);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('repurpose B2B relationships', TRUE, 350);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('seize vertical e-markets', TRUE, 80);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('evolve dot-com e-markets', FALSE, 301);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('harness integrated e-business', TRUE, 450);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incubate next-generation solutions', TRUE, 239);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('aggregate holistic systems', FALSE, 363);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('streamline web-enabled eyeballs', TRUE, 113);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('expedite open-source schemas', TRUE, 139);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transition next-generation methodologies', TRUE, 62);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('streamline synergistic mindshare', TRUE, 495);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engineer sexy technologies', TRUE, 404);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('repurpose sticky e-markets', TRUE, 180);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('seize web-enabled bandwidth', FALSE, 145);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('redefine cross-media networks', FALSE, 375);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transform end-to-end systems', TRUE, 198);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transition robust methodologies', TRUE, 41);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('implement next-generation initiatives', FALSE, 467);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reintermediate user-centric supply-chains', FALSE, 345);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('productize cross-platform models', TRUE, 414);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('cultivate out-of-the-box models', FALSE, 24);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('grow sexy paradigms', FALSE, 180);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('benchmark collaborative applications', FALSE, 35);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('iterate revolutionary partnerships', FALSE, 184);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('target cutting-edge initiatives', TRUE, 141);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('grow enterprise schemas', FALSE, 349);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('streamline plug-and-play content', FALSE, 50);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deliver magnetic networks', TRUE, 51);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('integrate granular e-business', FALSE, 445);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engineer integrated technologies', FALSE, 205);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('envisioneer front-end web services', TRUE, 372);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('harness front-end eyeballs', TRUE, 276);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('streamline leading-edge systems', TRUE, 142);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('strategize interactive schemas', FALSE, 390);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('aggregate cross-platform ROI', FALSE, 166);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('recontextualize one-to-one technologies', TRUE, 379);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('architect front-end eyeballs', FALSE, 135);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incubate collaborative eyeballs', TRUE, 219);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('strategize B2C ROI', FALSE, 278);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('cultivate customized solutions', FALSE, 28);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('leverage sexy markets', TRUE, 255);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('evolve integrated channels', TRUE, 469);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('extend real-time bandwidth', TRUE, 270);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('generate revolutionary e-commerce', TRUE, 480);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('target cutting-edge infomediaries', TRUE, 500);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('implement integrated ROI', TRUE, 393);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('unleash cutting-edge initiatives', FALSE, 214);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('enhance robust ROI', TRUE, 339);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('monetize holistic e-markets', TRUE, 145);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('brand customized technologies', TRUE, 460);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale revolutionary experiences', TRUE, 154);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('optimize integrated ROI', FALSE, 183);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incentivize extensible e-tailers', TRUE, 490);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reintermediate next-generation e-markets', FALSE, 89);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synthesize cross-platform channels', FALSE, 352);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('brand web-enabled infrastructures', TRUE, 200);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('morph bricks-and-clicks e-markets', FALSE, 453);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('empower transparent content', FALSE, 367);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('extend bleeding-edge networks', TRUE, 392);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('implement world-class models', FALSE, 403);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('syndicate interactive methodologies', FALSE, 473);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('integrate next-generation communities', FALSE, 281);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('innovate dot-com methodologies', TRUE, 153);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synergize dot-com supply-chains', TRUE, 397);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('expedite visionary deliverables', FALSE, 177);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('envisioneer bleeding-edge bandwidth', TRUE, 348);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('monetize compelling web-readiness', FALSE, 285);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('expedite e-business ROI', TRUE, 362);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('revolutionize magnetic partnerships', TRUE, 131);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transition wireless niches', FALSE, 75);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incubate bleeding-edge communities', TRUE, 185);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('strategize killer relationships', FALSE, 259);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('architect sticky e-business', FALSE, 25);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('morph viral e-business', FALSE, 394);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engage cross-platform eyeballs', TRUE, 467);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synthesize killer ROI', FALSE, 24);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('generate intuitive vortals', TRUE, 127);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('unleash B2B applications', FALSE, 38);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('facilitate customized systems', TRUE, 2);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transition interactive bandwidth', TRUE, 260);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('visualize magnetic metrics', TRUE, 202);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('orchestrate holistic methodologies', TRUE, 56);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('innovate seamless e-commerce', TRUE, 64);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('optimize impactful technologies', FALSE, 102);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engineer transparent functionalities', TRUE, 222);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('morph wireless models', TRUE, 152);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale integrated initiatives', FALSE, 225);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engineer interactive interfaces', FALSE, 193);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synergize strategic models', FALSE, 143);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('mesh world-class technologies', FALSE, 460);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reinvent enterprise interfaces', FALSE, 70);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('implement robust vortals', FALSE, 284);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incubate next-generation markets', TRUE, 114);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('maximize world-class deliverables', FALSE, 2);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('drive mission-critical portals', FALSE, 85);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('evolve open-source interfaces', TRUE, 166);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('iterate leading-edge networks', FALSE, 185);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reintermediate frictionless models', TRUE, 376);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('envisioneer value-added ROI', TRUE, 67);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('extend clicks-and-mortar e-tailers', TRUE, 222);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('innovate innovative synergies', FALSE, 256);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engineer collaborative portals', FALSE, 316);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('e-enable interactive supply-chains', FALSE, 152);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('drive strategic applications', FALSE, 246);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('envisioneer viral web-readiness', TRUE, 126);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('seize transparent initiatives', FALSE, 179);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deliver leading-edge solutions', FALSE, 293);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('seize e-business infomediaries', TRUE, 463);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transition enterprise platforms', FALSE, 32);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('generate cross-media partnerships', TRUE, 24);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('recontextualize visionary applications', TRUE, 192);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engage viral networks', FALSE, 362);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('leverage proactive e-markets', FALSE, 152);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('implement collaborative communities', FALSE, 89);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('streamline front-end ROI', TRUE, 88);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('maximize interactive experiences', TRUE, 147);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('target impactful solutions', FALSE, 490);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('productize extensible vortals', FALSE, 200);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('unleash web-enabled e-markets', FALSE, 306);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('unleash extensible applications', FALSE, 232);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('evolve back-end paradigms', FALSE, 129);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('facilitate enterprise e-markets', FALSE, 298);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('strategize scalable e-business', TRUE, 397);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synergize extensible action-items', TRUE, 448);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('monetize robust systems', FALSE, 215);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engage magnetic partnerships', TRUE, 48);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('reintermediate interactive networks', TRUE, 124);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('drive efficient platforms', TRUE, 19);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('embrace impactful e-business', FALSE, 454);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('unleash frictionless supply-chains', FALSE, 310);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('drive web-enabled e-tailers', TRUE, 261);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('disintermediate world-class e-business', FALSE, 437);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('recontextualize interactive platforms', FALSE, 239);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('benchmark e-business eyeballs', TRUE, 207);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incubate compelling markets', TRUE, 71);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incentivize next-generation infomediaries', TRUE, 280);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('redefine transparent convergence', TRUE, 167);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('generate 24/7 content', TRUE, 399);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('enhance enterprise systems', TRUE, 11);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('morph plug-and-play architectures', TRUE, 142);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('repurpose e-business applications', TRUE, 77);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deploy proactive functionalities', FALSE, 214);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('disintermediate leading-edge users', FALSE, 73);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('repurpose collaborative infomediaries', FALSE, 281);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('enhance value-added e-tailers', TRUE, 90);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synergize proactive niches', TRUE, 129);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('integrate world-class web-readiness', FALSE, 126);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engage dot-com supply-chains', FALSE, 446);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('optimize proactive synergies', TRUE, 124);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('enhance magnetic schemas', FALSE, 147);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engineer collaborative content', TRUE, 273);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('aggregate efficient bandwidth', FALSE, 266);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale best-of-breed users', TRUE, 431);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('seize clicks-and-mortar architectures', TRUE, 276);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transform virtual e-commerce', FALSE, 235);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('enable real-time e-commerce', FALSE, 120);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('benchmark B2C communities', FALSE, 75);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('engage real-time partnerships', TRUE, 226);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('revolutionize 24/365 technologies', TRUE, 138);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synthesize 24/365 web services', TRUE, 93);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('iterate compelling infomediaries', TRUE, 81);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('embrace plug-and-play experiences', TRUE, 494);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('utilize strategic e-tailers', FALSE, 443);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale collaborative relationships', FALSE, 216);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('monetize B2B users', FALSE, 75);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('monetize robust e-commerce', TRUE, 394);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incentivize enterprise e-business', FALSE, 101);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('brand end-to-end applications', TRUE, 329);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('visualize turn-key action-items', FALSE, 214);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('cultivate intuitive ROI', FALSE, 345);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('orchestrate clicks-and-mortar technologies', FALSE, 271);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('architect 24/365 channels', TRUE, 300);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('facilitate enterprise users', TRUE, 41);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('enhance dynamic synergies', TRUE, 139);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('brand scalable infomediaries', TRUE, 292);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incubate interactive channels', TRUE, 384);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('visualize interactive models', TRUE, 33);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('recontextualize scalable niches', TRUE, 469);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synthesize synergistic methodologies', TRUE, 173);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('productize revolutionary partnerships', TRUE, 197);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('seize best-of-breed infomediaries', TRUE, 500);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('implement bricks-and-clicks ROI', TRUE, 390);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transform virtual convergence', TRUE, 132);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('disintermediate dot-com solutions', FALSE, 323);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synthesize dynamic bandwidth', TRUE, 133);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deploy bricks-and-clicks supply-chains', TRUE, 114);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('whiteboard integrated experiences', FALSE, 76);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('iterate end-to-end deliverables', FALSE, 205);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('revolutionize strategic schemas', TRUE, 377);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('recontextualize mission-critical deliverables', TRUE, 222);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('e-enable best-of-breed infrastructures', TRUE, 344);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('extend synergistic technologies', TRUE, 105);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('facilitate B2C content', TRUE, 320);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('benchmark plug-and-play communities', TRUE, 340);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('harness real-time communities', FALSE, 473);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('redefine one-to-one paradigms', TRUE, 399);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('embrace real-time vortals', TRUE, 253);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('harness customized web services', FALSE, 382);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('iterate ubiquitous supply-chains', TRUE, 474);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('embrace cross-platform technologies', TRUE, 204);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('grow extensible web-readiness', TRUE, 135);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incubate seamless ROI', FALSE, 319);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('transition intuitive systems', FALSE, 281);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('deliver seamless content', TRUE, 417);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('architect turn-key e-services', FALSE, 204);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('empower proactive paradigms', FALSE, 27);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('synergize efficient solutions', TRUE, 29);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('iterate holistic schemas', FALSE, 347);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('innovate dynamic convergence', FALSE, 407);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('incentivize wireless e-tailers', FALSE, 422);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('scale enterprise ROI', TRUE, 179);
INSERT INTO check_list_item (item_text, completed, task) VALUES ('evolve world-class convergence', FALSE, 101);


-- Comment

INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (7, 15, '2021-03-22 15:00:52', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (323, 16, '2021-03-12 17:10:00', 'Donec quis orci eget orci vehicula condimentum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (437, 18, '2021-03-27 19:44:11', 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (7, 22, '2021-01-31 10:05:20', 'Quisque porta volutpat erat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (33, 3, '2021-02-20 00:13:26', 'Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (456, 10, '2021-01-28 18:41:04', 'In hac habitasse platea dictumst.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (30, 23, '2021-03-26 04:40:56', 'Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (98, 11, '2021-01-09 17:00:37', 'Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (88, 6, '2021-02-21 13:54:08', 'Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (329, 11, '2021-02-12 18:59:06', 'Donec posuere metus vitae ipsum. Aliquam non mauris.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (265, 10, '2021-02-25 13:58:21', 'Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (21, 4, '2021-01-09 13:26:03', 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (350, 23, '2021-01-06 07:44:34', 'Etiam faucibus cursus urna.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (72, 13, '2021-01-10 05:35:44', 'Nullam varius. Nulla facilisi.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (500, 20, '2021-01-18 17:32:30', 'Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (493, 4, '2021-02-03 00:17:59', 'Duis bibendum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (112, 13, '2021-03-14 21:03:40', 'Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (224, 19, '2021-03-14 16:54:10', 'Donec vitae nisi.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (85, 20, '2021-02-16 19:36:57', 'Nulla ut erat id mauris vulputate elementum. Nullam varius.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (58, 20, '2021-03-27 16:10:40', 'Aliquam non mauris.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (496, 20, '2021-02-09 00:22:16', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (115, 13, '2021-03-08 07:05:44', 'Cras pellentesque volutpat dui.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (164, 19, '2021-03-14 09:33:49', 'Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (482, 21, '2021-03-24 21:29:04', 'Sed sagittis.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (296, 12, '2021-03-15 03:58:04', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (232, 24, '2021-03-06 05:59:24', 'Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (469, 15, '2021-03-16 01:43:50', 'Aenean sit amet justo. Morbi ut odio.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (403, 9, '2021-03-15 14:15:24', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (100, 22, '2021-01-26 08:50:02', 'Phasellus in felis.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (418, 8, '2021-03-12 00:49:05', 'Fusce consequat. Nulla nisl.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (194, 18, '2021-02-10 12:09:07', 'In congue.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (50, 12, '2021-02-09 21:59:30', 'Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (191, 18, '2021-01-18 18:09:51', 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (267, 6, '2021-01-18 16:22:03', 'Suspendisse potenti. Cras in purus eu magna vulputate luctus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (331, 7, '2021-01-03 01:58:28', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (458, 6, '2021-02-19 02:22:51', 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (160, 19, '2021-02-18 20:38:25', 'Quisque porta volutpat erat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (403, 6, '2021-01-28 14:57:24', 'Aenean auctor gravida sem.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (173, 2, '2021-01-16 17:47:55', 'Praesent lectus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (394, 23, '2021-03-04 00:58:08', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (222, 2, '2021-01-13 18:22:33', 'Vestibulum rutrum rutrum neque.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (5, 18, '2021-02-21 02:22:19', 'Morbi vel lectus in quam fringilla rhoncus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (23, 10, '2021-02-17 04:14:06', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (89, 8, '2021-03-08 04:23:48', 'Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (498, 19, '2021-02-20 07:23:17', 'Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (27, 5, '2021-03-09 07:04:37', 'Phasellus sit amet erat. Nulla tempus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (82, 7, '2021-03-01 01:45:36', 'Fusce consequat. Nulla nisl. Nunc nisl.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (451, 17, '2021-03-10 07:02:50', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (413, 24, '2021-01-30 09:53:21', 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (151, 19, '2021-01-09 07:22:39', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (266, 24, '2021-02-22 12:56:53', 'Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (84, 19, '2021-02-12 15:05:09', 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (422, 8, '2021-03-03 11:34:21', 'Nunc purus. Phasellus in felis. Donec semper sapien a libero.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (49, 2, '2021-02-21 08:32:54', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (62, 11, '2021-01-24 14:59:18', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (179, 14, '2021-03-01 05:19:30', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (118, 20, '2021-01-16 02:21:29', 'Nullam sit amet turpis elementum ligula vehicula consequat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (253, 22, '2021-03-08 06:02:20', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (377, 15, '2021-02-13 14:37:46', 'In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (245, 13, '2021-02-12 06:29:54', 'Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (19, 22, '2021-03-21 16:28:17', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (197, 25, '2021-03-27 23:46:04', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (116, 17, '2021-01-17 03:55:56', 'Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (273, 16, '2021-01-15 07:59:29', 'Duis aliquam convallis nunc.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (103, 10, '2021-01-06 01:01:23', 'Pellentesque at nulla.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (38, 14, '2021-01-28 04:45:23', 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (429, 12, '2021-02-26 05:30:23', 'Morbi porttitor lorem id ligula.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (152, 10, '2021-03-06 17:01:11', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (80, 16, '2021-01-03 00:50:23', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (281, 24, '2021-01-19 11:33:05', 'In eleifend quam a odio. In hac habitasse platea dictumst.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (37, 25, '2021-03-05 23:20:37', 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (24, 25, '2021-03-26 09:53:51', 'Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (428, 23, '2021-01-06 20:34:52', 'Pellentesque eget nunc.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (85, 20, '2021-02-09 00:51:14', 'In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (238, 6, '2021-03-06 07:01:18', 'Nulla tellus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (303, 21, '2021-02-14 07:12:49', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (111, 23, '2021-02-26 04:50:30', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (297, 9, '2021-01-19 00:26:59', 'Etiam faucibus cursus urna. Ut tellus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (158, 23, '2021-03-25 11:09:23', 'Nulla justo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (115, 14, '2021-03-10 07:04:27', 'Nulla mollis molestie lorem. Quisque ut erat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (128, 18, '2021-03-18 00:06:30', 'Vivamus in felis eu sapien cursus vestibulum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (350, 23, '2021-03-15 22:50:33', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (90, 17, '2021-02-28 15:05:52', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (22, 22, '2021-01-24 21:27:58', 'Fusce posuere felis sed lacus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (180, 5, '2021-02-22 00:38:11', 'Aenean lectus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (207, 16, '2021-03-24 16:39:58', 'Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (94, 6, '2021-01-09 16:22:04', 'Duis mattis egestas metus. Aenean fermentum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (410, 21, '2021-01-25 00:20:19', 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (498, 22, '2021-02-12 08:34:29', 'Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (71, 16, '2021-01-01 16:33:52', 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (189, 3, '2021-03-14 20:50:47', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (134, 19, '2021-02-20 11:20:11', 'Donec posuere metus vitae ipsum. Aliquam non mauris.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (135, 20, '2021-03-01 13:41:59', 'Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (436, 21, '2021-01-27 18:10:49', 'Etiam pretium iaculis justo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (476, 21, '2021-01-06 13:47:10', 'Vestibulum rutrum rutrum neque.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (139, 2, '2021-03-17 03:56:12', 'In congue. Etiam justo. Etiam pretium iaculis justo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (470, 19, '2021-03-18 23:24:43', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (415, 2, '2021-03-14 03:05:23', 'Aenean fermentum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (297, 21, '2021-02-01 00:51:06', 'Suspendisse potenti.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (187, 8, '2021-03-08 00:02:06', 'Duis at velit eu est congue elementum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (249, 24, '2021-01-15 20:31:15', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (470, 12, '2021-01-26 11:27:59', 'Nullam sit amet turpis elementum ligula vehicula consequat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (469, 10, '2021-02-12 05:46:56', 'Vivamus vestibulum sagittis sapien.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (123, 19, '2021-01-29 07:05:01', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (154, 24, '2021-03-07 09:48:19', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (151, 12, '2021-01-25 07:50:48', 'In hac habitasse platea dictumst.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (493, 10, '2021-02-16 15:42:27', 'Aenean sit amet justo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (329, 16, '2021-02-21 05:14:19', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (305, 16, '2021-03-10 12:50:09', 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (416, 6, '2021-01-15 05:13:29', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (472, 5, '2021-03-18 16:33:51', 'Sed ante. Vivamus tortor.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (237, 18, '2021-03-26 15:27:45', 'Nulla mollis molestie lorem.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (122, 3, '2021-02-16 22:55:05', 'Suspendisse potenti. Cras in purus eu magna vulputate luctus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (413, 10, '2021-01-24 22:32:05', 'Duis mattis egestas metus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (444, 19, '2021-01-12 02:34:24', 'In congue.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (375, 22, '2021-02-22 17:55:26', 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (288, 20, '2021-02-05 21:55:38', 'Vestibulum rutrum rutrum neque.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (187, 8, '2021-03-10 07:50:07', 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (40, 5, '2021-02-11 23:55:58', 'Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (420, 6, '2021-03-07 23:07:19', 'Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (110, 17, '2021-03-12 10:05:14', 'Fusce consequat. Nulla nisl. Nunc nisl.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (349, 17, '2021-02-14 10:27:00', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (401, 15, '2021-01-03 17:51:28', 'Morbi a ipsum. Integer a nibh.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (295, 16, '2021-02-11 22:19:19', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (82, 2, '2021-02-28 09:31:25', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (461, 6, '2021-01-03 03:46:58', 'Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (423, 24, '2021-01-22 22:37:57', 'Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (64, 25, '2021-03-11 02:52:25', 'In blandit ultrices enim.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (224, 12, '2021-03-09 15:06:36', 'Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (142, 17, '2021-03-16 10:47:50', 'Donec semper sapien a libero. Nam dui.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (182, 17, '2021-02-18 12:45:11', 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (59, 11, '2021-01-03 06:00:21', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (177, 6, '2021-02-21 07:30:23', 'Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (240, 17, '2021-01-07 15:24:26', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (60, 3, '2021-01-25 14:25:03', 'Donec posuere metus vitae ipsum. Aliquam non mauris.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (90, 12, '2021-01-13 00:28:58', 'Donec ut mauris eget massa tempor convallis.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (316, 9, '2021-01-13 16:02:39', 'Morbi non quam nec dui luctus rutrum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (444, 25, '2021-03-26 14:12:43', 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (400, 12, '2021-02-13 03:21:13', 'Aliquam non mauris. Morbi non lectus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (396, 2, '2021-01-21 04:28:22', 'Nulla ut erat id mauris vulputate elementum. Nullam varius.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (55, 23, '2021-02-21 19:01:40', 'Aenean sit amet justo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (490, 25, '2021-01-22 09:04:37', 'Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (17, 14, '2021-02-19 20:38:27', 'Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (348, 13, '2021-03-04 03:52:55', 'Vivamus tortor.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (145, 12, '2021-02-01 00:58:03', 'Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (71, 25, '2021-01-21 06:39:16', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (165, 5, '2021-03-25 11:32:00', 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (452, 16, '2021-03-27 14:26:51', 'Sed accumsan felis. Ut at dolor quis odio consequat varius.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (476, 17, '2021-01-18 12:58:01', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (415, 10, '2021-03-13 09:18:29', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (317, 24, '2021-02-02 06:12:46', 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (497, 16, '2021-03-11 22:37:36', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (202, 20, '2021-02-09 10:06:10', 'Maecenas tincidunt lacus at velit.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (386, 21, '2021-02-11 01:42:08', 'Aenean sit amet justo. Morbi ut odio.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (397, 18, '2021-01-03 05:47:57', 'Sed ante.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (243, 3, '2021-02-21 06:00:36', 'Aenean lectus. Pellentesque eget nunc.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (44, 15, '2021-01-23 07:01:57', 'Suspendisse potenti.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (425, 16, '2021-02-15 22:00:39', 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (320, 7, '2021-01-14 00:19:02', 'In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (109, 25, '2021-01-17 11:24:54', 'Duis bibendum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (180, 20, '2021-01-05 03:44:03', 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (2, 16, '2021-01-24 14:46:35', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (25, 3, '2021-03-15 17:24:36', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (284, 10, '2021-03-06 07:20:54', 'Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (25, 23, '2021-02-20 18:48:32', 'Curabitur at ipsum ac tellus semper interdum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (65, 19, '2021-01-27 20:01:44', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (222, 16, '2021-03-20 21:47:28', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (78, 13, '2021-02-13 02:35:12', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (428, 4, '2021-02-21 08:03:47', 'Mauris sit amet eros.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (449, 24, '2021-02-23 13:43:13', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (366, 19, '2021-01-31 01:42:40', 'Aenean lectus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (299, 18, '2021-03-12 02:43:45', 'Donec ut mauris eget massa tempor convallis.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (430, 22, '2021-03-11 16:15:04', 'Donec posuere metus vitae ipsum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (96, 25, '2021-02-13 18:19:21', 'Nulla tellus. In sagittis dui vel nisl. Duis ac nibh.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (22, 12, '2021-01-28 05:34:29', 'Etiam justo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (452, 16, '2021-01-16 04:15:50', 'Vestibulum rutrum rutrum neque.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (18, 6, '2021-02-06 11:37:04', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (188, 21, '2021-01-27 19:31:31', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (438, 12, '2021-01-06 11:32:08', 'Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (151, 18, '2021-02-06 19:21:43', 'Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (92, 6, '2021-01-15 09:37:06', 'Vestibulum sed magna at nunc commodo placerat. Praesent blandit.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (79, 6, '2021-02-18 01:18:40', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (397, 5, '2021-01-30 09:58:15', 'Morbi ut odio.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (239, 7, '2021-02-27 21:37:11', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (103, 2, '2021-02-05 11:23:52', 'Integer non velit.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (175, 24, '2021-03-16 21:58:37', 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (377, 10, '2021-01-29 19:27:38', 'Vivamus tortor.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (175, 16, '2021-02-26 13:42:33', 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (141, 3, '2021-01-11 09:04:55', 'Curabitur in libero ut massa volutpat convallis.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (110, 9, '2021-02-20 08:34:48', 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (142, 3, '2021-02-03 13:36:09', 'Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (46, 5, '2021-02-13 06:14:37', 'Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (390, 19, '2021-01-17 15:13:18', 'In eleifend quam a odio.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (473, 8, '2021-01-21 04:28:52', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (433, 20, '2021-02-26 18:55:51', 'Nulla ac enim.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (434, 20, '2021-03-09 14:20:20', 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (272, 24, '2021-02-02 08:45:33', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (88, 3, '2021-02-08 19:55:28', 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (125, 25, '2021-01-11 18:30:15', 'Nulla mollis molestie lorem.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (452, 14, '2021-01-19 19:27:26', 'Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (222, 16, '2021-03-10 11:39:27', 'Fusce consequat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (240, 7, '2021-03-22 21:24:13', 'Phasellus sit amet erat. Nulla tempus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (152, 12, '2021-03-19 23:19:19', 'Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (473, 17, '2021-01-23 07:27:45', 'Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (394, 18, '2021-01-15 20:37:24', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (238, 6, '2021-03-22 12:53:19', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (377, 10, '2021-03-27 09:34:09', 'Maecenas rhoncus aliquam lacus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (413, 16, '2021-03-15 05:53:11', 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (139, 16, '2021-01-20 00:37:21', 'Integer ac neque.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (164, 3, '2021-03-06 06:59:17', 'Morbi a ipsum. Integer a nibh.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (71, 25, '2021-03-14 01:33:26', 'Nulla nisl.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (115, 14, '2021-03-10 16:52:45', 'Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (377, 15, '2021-01-08 02:10:16', 'Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (154, 24, '2021-01-06 18:52:45', 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (88, 10, '2021-03-25 02:55:41', 'Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (288, 20, '2021-01-27 21:33:18', 'Nulla mollis molestie lorem.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (224, 12, '2021-01-01 19:32:19', 'Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (25, 23, '2021-01-13 03:11:27', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (59, 12, '2021-03-06 12:17:28', 'Sed ante.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (305, 6, '2021-01-18 18:48:24', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (182, 16, '2021-02-10 15:25:05', 'Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (429, 14, '2021-03-27 16:33:56', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (65, 9, '2021-03-25 11:30:29', 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (297, 3, '2021-03-14 09:43:41', 'Integer a nibh. In quis justo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (284, 15, '2021-02-22 18:29:53', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (165, 18, '2021-02-09 11:06:15', 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (175, 14, '2021-02-08 01:39:47', 'In sagittis dui vel nisl. Duis ac nibh.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (397, 19, '2021-01-16 12:05:45', 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (222, 20, '2021-01-19 08:45:09', 'Phasellus in felis. Donec semper sapien a libero.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (50, 16, '2021-02-17 11:01:25', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (189, 11, '2021-03-16 03:17:58', 'Nunc rhoncus dui vel sem.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (253, 23, '2021-02-15 18:28:13', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (173, 16, '2021-03-15 21:01:51', 'Curabitur convallis.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (416, 25, '2021-01-20 01:42:07', 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (100, 14, '2021-02-14 01:50:51', 'Proin risus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (390, 6, '2021-03-24 15:34:52', 'Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (177, 6, '2021-02-21 04:26:57', 'Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (134, 9, '2021-02-06 10:05:37', 'Suspendisse accumsan tortor quis turpis.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (177, 9, '2021-01-14 13:26:33', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (88, 19, '2021-01-02 23:33:31', 'Duis bibendum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (458, 6, '2021-03-10 07:14:16', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (62, 3, '2021-03-25 06:37:00', 'Aenean lectus. Pellentesque eget nunc.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (22, 17, '2021-02-12 05:18:49', 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (123, 12, '2021-03-21 06:34:12', 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (288, 20, '2021-01-04 23:10:53', 'Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (194, 22, '2021-01-18 08:02:13', 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (151, 5, '2021-03-08 07:03:17', 'In hac habitasse platea dictumst.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (160, 13, '2021-02-10 17:14:02', 'Nullam porttitor lacus at turpis.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (197, 20, '2021-02-15 09:31:58', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', null);
INSERT INTO comment (task, author, comment_date, comment_text, parent) VALUES (472, 16, '2021-01-09 07:27:07', 'Etiam faucibus cursus urna. Ut tellus.', null);

-- Comment Reply

UPDATE comment SET parent = 41 WHERE id =201;
UPDATE comment SET parent = 134 WHERE id =202;
UPDATE comment SET parent = 68 WHERE id =203;
UPDATE comment SET parent = 194 WHERE id =204;
UPDATE comment SET parent = 40 WHERE id =205;
UPDATE comment SET parent = 75 WHERE id =206;
UPDATE comment SET parent = 59 WHERE id =207;
UPDATE comment SET parent = 114 WHERE id =208;
UPDATE comment SET parent = 96 WHERE id =209;
UPDATE comment SET parent = 23 WHERE id =210;
UPDATE comment SET parent = 90 WHERE id =211;
UPDATE comment SET parent = 80 WHERE id =212;
UPDATE comment SET parent = 59 WHERE id =213;
UPDATE comment SET parent = 105 WHERE id =214;
UPDATE comment SET parent = 9 WHERE id =215;
UPDATE comment SET parent = 117 WHERE id =216;
UPDATE comment SET parent = 18 WHERE id =217;
UPDATE comment SET parent = 165 WHERE id =218;
UPDATE comment SET parent = 132 WHERE id =219;
UPDATE comment SET parent = 109 WHERE id =220;
UPDATE comment SET parent = 131 WHERE id =221;
UPDATE comment SET parent = 67 WHERE id =222;
UPDATE comment SET parent = 166 WHERE id =223;
UPDATE comment SET parent = 99 WHERE id =224;
UPDATE comment SET parent = 164 WHERE id =225;
UPDATE comment SET parent = 147 WHERE id =226;
UPDATE comment SET parent = 186 WHERE id =227;
UPDATE comment SET parent = 155 WHERE id =228;
UPDATE comment SET parent = 167 WHERE id =229;
UPDATE comment SET parent = 32 WHERE id =230;
UPDATE comment SET parent = 91 WHERE id =231;
UPDATE comment SET parent = 58 WHERE id =232;
UPDATE comment SET parent = 39 WHERE id =233;
UPDATE comment SET parent = 110 WHERE id =234;
UPDATE comment SET parent = 29 WHERE id =235;
UPDATE comment SET parent = 193 WHERE id =236;
UPDATE comment SET parent = 133 WHERE id =237;
UPDATE comment SET parent = 92 WHERE id =238;
UPDATE comment SET parent = 133 WHERE id =239;
UPDATE comment SET parent = 9 WHERE id =240;
UPDATE comment SET parent = 36 WHERE id =241;
UPDATE comment SET parent = 55 WHERE id =242;
UPDATE comment SET parent = 84 WHERE id =243;
UPDATE comment SET parent = 104 WHERE id =244;
UPDATE comment SET parent = 117 WHERE id =245;
UPDATE comment SET parent = 31 WHERE id =246;
UPDATE comment SET parent = 106 WHERE id =247;
UPDATE comment SET parent = 37 WHERE id =248;
UPDATE comment SET parent = 62 WHERE id =249;
UPDATE comment SET parent = 111 WHERE id =250;


-- Social Media Account

INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Facebook', 'kglanville0', '1K6jKsRF9iWkpVzuomg1qgarhFuN524LCT');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'ccossans1', '12oPxqZsY24CPm7ciVBiEHvk6WNauR7S9b');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Facebook', 'pbhatia2', '1NKZA3eQBiMiVLMXPPzS7CE5ByvtnGiSU8');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'rjoicey3', '1Lnj4wfSKM3SApcMJHrarMKNX5euto8NsD');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'krunnicles4', '16bs2dMg4b6xPY4k8UKax2Z5gsVztXGh87');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'mtripe5', '1K5F1MaT3LJ71Pe4SbZqYRw7LGDeWtVNto');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Facebook', 'mthurlbeck6', '1P2VNu9d2souw5ALS21ZmUrtkHo1PyJNmD');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Facebook', 'cbecraft7', '197Deij7BUhkoDcEuTG6J8GPoWxH8WaofJ');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'ysheers8', '1AaDJ6PHGiqPAfW9B3TcViaKrao5fiYBgz');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'fdobbyn9', '1ETR8FKZETcdKeoBf27R6yVtTYq2T3XPiD');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'agulca', '1AmYm9w94xrURUbH1aSdV7wQ2gFjVbHk8h');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Twitter', 'eanglissb', '1CYmQsRN2e1T1gQ2dixfxKYrm2kdEjyuK2');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'ccorbouldc', '1SF1oogP96CvNnpNExqqSrGGE1gd9Yzu9');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'emeadend', '12e71U1kCtFkyzbanyVahAhaQeNvdcexYg');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Facebook', 'irishbrooke', '1BgQ7sJTy2n49L6x154g7RTZH49kKt9vKp');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Facebook', 'pmarshf', '1KxRDoER2xT1wAgjtUDxHkwzzoes5fQJTm');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Twitter', 'cpinnickg', '1GDCFDoTueAuHqJNFwYJsEvxoNJTJe4Jkr');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Twitter', 'sassenderh', '18g7CFvJj3ha46zVgkCkkzZPbwnuLZp2FL');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'wsurgeoneri', '1QAgQmGKZPR1FNinakMyZ6NykkP9W2WmzP');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'mdurhamj', '1A5cz11yjYsWYUDc5ukqzEAW5pwktD7BSY');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'mcasbonk', '1FodXT8rmD5tZidJrb32aov7zDrMQ2u2T7');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'jgreenhilll', '19iJAGge8JTMCTdVWG6ZW3ULULsZwYNVe7');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Facebook', 'htoulchm', '1KhiDkWpD8V6o9SCQrhxCEF6cVQQ6Tu2Bb');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Facebook', 'vvasiltsovn', '1A4H1GNJ2awqevFQ63uL2GBoU1VSUf5tnp');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'ctiddemano', '1MwshQmhU87To8TQXgkMHnMSrKFwmL4qVS');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Twitter', 'apickburnp', '17UPxUDmBo4TgnW2M2mz83NWBM2A6X3NN1');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Twitter', 'adudmeshq', '13T2cMXrBUEBeEqr8NQg4DSQD8aBXLKMXv');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Facebook', 'dhakenr', '1JL1d5NwxKELqWSWq8nwGufsDn8GTmTCdg');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Facebook', 'kvynalls', '1C1P1jVfBWcjc4EYea6kKzeqe3juHPtvyL');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'thurcht', '1KcTaNexV4quuiQ3tcC9dRsSQ4foKSDPAi');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Facebook', 'hfrymanu', '1F1MWZsM6Ju8kHZ63wWcBp1gdorgwzwpTQ');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'ldorwoodv', '14PC1QuQ42i3gMbpXH3AuM1MdoSLpzGHBk');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Facebook', 'mbattenw', '1EzchMtApdoWN4gea5hy1w4jaS4DZCK3R1');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Facebook', 'mdavionx', '1HVuaBRa1WNXNj2eohF9nbmw3X7FKXT1cY');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'wpassinghamy', '1J1qGSg8YY9ddQVFrsDqAdnKFkQuSpyocL');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'ibalchenz', '1NMywbSuY3fQZaW76NJntn7b1azbEVhq4b');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Twitter', 'gstronough10', '1P5JxXE5byaYL5p29Li5zSqxaQFhSDJLdZ');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'nlane11', '15nYeowU1dfeJcqcKgYmBgVwgy1kT1N1fd');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Twitter', 'kcelier12', '1G6oSQvAEKuA1VyJ8wvhHRUxPQYFmMUvEk');
INSERT INTO social_media_account (social_media, username, access_token) VALUES ('Instagram', 'dlidgate13', '183NV6sbmqPQCWd5sinBhKSxpNWfPJsfHr');


-- Associated Project Account

INSERT INTO associated_project_account (account, project) VALUES (1, 25);
INSERT INTO associated_project_account (account, project) VALUES (2, 14);
INSERT INTO associated_project_account (account, project) VALUES (3, 27);
INSERT INTO associated_project_account (account, project) VALUES (4, 37);
INSERT INTO associated_project_account (account, project) VALUES (5, 35);
INSERT INTO associated_project_account (account, project) VALUES (6, 5);
INSERT INTO associated_project_account (account, project) VALUES (7, 50);
INSERT INTO associated_project_account (account, project) VALUES (8, 7);
INSERT INTO associated_project_account (account, project) VALUES (9, 12);
INSERT INTO associated_project_account (account, project) VALUES (10, 16);
INSERT INTO associated_project_account (account, project) VALUES (11, 34);
INSERT INTO associated_project_account (account, project) VALUES (12, 21);
INSERT INTO associated_project_account (account, project) VALUES (13, 36);
INSERT INTO associated_project_account (account, project) VALUES (14, 11);
INSERT INTO associated_project_account (account, project) VALUES (15, 47);


-- Associated Client Account

INSERT INTO associated_client_account (account, client) VALUES (16, 18);
INSERT INTO associated_client_account (account, client) VALUES (17, 19);
INSERT INTO associated_client_account (account, client) VALUES (18, 10);
INSERT INTO associated_client_account (account, client) VALUES (19, 18);
INSERT INTO associated_client_account (account, client) VALUES (20, 8);
INSERT INTO associated_client_account (account, client) VALUES (21, 23);
INSERT INTO associated_client_account (account, client) VALUES (22, 23);
INSERT INTO associated_client_account (account, client) VALUES (23, 21);
INSERT INTO associated_client_account (account, client) VALUES (24, 25);
INSERT INTO associated_client_account (account, client) VALUES (25, 19);
INSERT INTO associated_client_account (account, client) VALUES (26, 3);
INSERT INTO associated_client_account (account, client) VALUES (27, 19);
INSERT INTO associated_client_account (account, client) VALUES (28, 6);
INSERT INTO associated_client_account (account, client) VALUES (29, 21);
INSERT INTO associated_client_account (account, client) VALUES (30, 6);
INSERT INTO associated_client_account (account, client) VALUES (31, 20);
INSERT INTO associated_client_account (account, client) VALUES (32, 24);
INSERT INTO associated_client_account (account, client) VALUES (33, 7);
INSERT INTO associated_client_account (account, client) VALUES (34, 25);
INSERT INTO associated_client_account (account, client) VALUES (35, 5);
INSERT INTO associated_client_account (account, client) VALUES (36, 8);
INSERT INTO associated_client_account (account, client) VALUES (37, 2);
INSERT INTO associated_client_account (account, client) VALUES (38, 11);
INSERT INTO associated_client_account (account, client) VALUES (39, 5);
INSERT INTO associated_client_account (account, client) VALUES (40, 2);


-- Report

INSERT INTO report (report_text, reporter, reported) VALUES ('Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 21, 3);
INSERT INTO report (report_text, reporter, reported) VALUES ('In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', 14, 8);
INSERT INTO report (report_text, reporter, reported) VALUES ('Morbi non quam nec dui luctus rutrum. Nulla tellus.', 25, 13);

-- Close projects

UPDATE project SET closed = TRUE WHERE id = 33;
UPDATE project SET closed = TRUE WHERE id = 3;
UPDATE project SET closed = TRUE WHERE id = 1;