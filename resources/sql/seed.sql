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

CREATE TABLE account
(
    id       SERIAL PRIMARY KEY,
    username VARCHAR UNIQUE NOT NULL,
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
    id              INTEGER PRIMARY KEY NOT NULL REFERENCES account (id) ON DELETE CASCADE,
    fullname        VARCHAR,
    company         VARCHAR,
    avatar          VARCHAR,
    client_gender   gender DEFAULT 'Unspecified',
    country         INTEGER REFERENCES country (id) ON DELETE CASCADE,
    allowNoti       BOOLEAN             NOT NULL DEFAULT TRUE,
    inviteNoti      BOOLEAN             NOT NULL DEFAULT TRUE,
    memberNoti      BOOLEAN             NOT NULL DEFAULT TRUE,
    assignNoti      BOOLEAN             NOT NULL DEFAULT TRUE,
    waitingNoti     BOOLEAN             NOT NULL DEFAULT TRUE,
    commentNoti     BOOLEAN             NOT NULL DEFAULT TRUE,
    reportNoti      BOOLEAN             NOT NULL DEFAULT TRUE,
    hideCompleted   BOOLEAN             NOT NULL DEFAULT FALSE,
    simplifiedTasks BOOLEAN             NOT NULL DEFAULT FALSE,
    color           VARCHAR             NOT NULL,
    search          TSVECTOR
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
    comment_date TIMESTAMP NOT NULL DEFAULT NOW(),
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
                        setweight(to_tsvector(coalesce(NEW.fullname, '')), 'B') ||
                        setweight(to_tsvector(coalesce(NEW.company, '')), 'C')
                 FROM account
                 WHERE NEW.id = account.id);
    ELSIF TG_OP = 'UPDATE' AND (NEW.fullname <> OLD.fullname OR NEW.company <> OLD.company) THEN
        NEW.search =
                (SELECT setweight(to_tsvector(account.username), 'A') || setweight(to_tsvector(account.email), 'A') ||
                        setweight(to_tsvector(coalesce(NEW.fullname, '')), 'B') ||
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
        NEW.search = (SELECT setweight(to_tsvector(NEW.name), 'A') || setweight(to_tsvector(NEW.description), 'B'));
    ELSIF TG_OP = 'UPDATE' AND (NEW.name <> OLD.name OR NEW.description <> OLD.description) THEN
        NEW.search = (SELECT setweight(to_tsvector(NEW.name), 'A') || setweight(to_tsvector(NEW.description), 'B'));
    END IF;
    RETURN NEW;
END;
$BODY$
    LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION task_search_update() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.search = (SELECT setweight(to_tsvector(NEW.name), 'A') ||
                             setweight(to_tsvector(coalesce(NEW.description, '')), 'B'));
    ELSIF TG_OP = 'UPDATE' AND (NEW.name <> OLD.name OR NEW.description <> OLD.description) THEN
        NEW.search = (SELECT setweight(to_tsvector(NEW.name), 'A') ||
                             setweight(to_tsvector(coalesce(NEW.description, '')), 'B'));
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
    IF OLD.member_role = 'Owner' AND (SELECT count(*) FROM team_member WHERE project_id = OLD.project_id AND member_role = 'Owner') = 1
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
    IF OLD.decision = NULL AND NEW.decision = TRUE
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


CREATE OR REPLACE FUNCTION check_sub_date() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF (SELECT due_date FROM task WHERE NEW.id = task.id) > (SELECT due_date FROM task WHERE NEW.parent = task.id)
    THEN
        RAISE EXCEPTION 'Date is greater than that of its parent task';
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

DROP TRIGGER IF EXISTS insert_client_search ON client;
DROP TRIGGER IF EXISTS update_client_search ON client;
DROP TRIGGER IF EXISTS insert_project_search ON project;
DROP TRIGGER IF EXISTS update_project_search ON project;
DROP TRIGGER IF EXISTS insert_task_search ON task;
DROP TRIGGER IF EXISTS update_task_search ON task;
DROP TRIGGER IF EXISTS assign_tag ON contains_tag;
DROP TRIGGER IF EXISTS assign_member ON assignment;
DROP TRIGGER IF EXISTS check_project_owner ON team_member;
DROP TRIGGER IF EXISTS accept_invite ON invite;
DROP TRIGGER IF EXISTS check_task_date ON task;
DROP TRIGGER IF EXISTS check_sub_date ON subtask;
DROP TRIGGER IF EXISTS add_invite_notification ON invite;
DROP TRIGGER IF EXISTS add_project_notification ON team_member;
DROP TRIGGER IF EXISTS add_assignment_notification ON assignment;
DROP TRIGGER IF EXISTS add_comment_notification ON comment;
DROP TRIGGER IF EXISTS add_report_notification ON report;


-- TRIGGER01
CREATE TRIGGER insert_client_search
    AFTER INSERT
    ON client
    FOR EACH ROW
EXECUTE PROCEDURE client_search_update();

CREATE TRIGGER update_client_search
    AFTER UPDATE
    ON client
    FOR EACH ROW
EXECUTE PROCEDURE client_search_update();


-- TRIGGER02
CREATE TRIGGER insert_project_search
    AFTER INSERT
    ON project
    FOR EACH ROW
EXECUTE PROCEDURE project_search_update();

CREATE TRIGGER update_project_search
    AFTER UPDATE
    ON project
    FOR EACH ROW
EXECUTE PROCEDURE project_search_update();


-- TRIGGER03
CREATE TRIGGER insert_task_search
    AFTER INSERT
    ON task
    FOR EACH ROW
EXECUTE PROCEDURE task_search_update();

CREATE TRIGGER update_task_search
    AFTER UPDATE
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
CREATE TRIGGER check_sub_date
    BEFORE INSERT OR UPDATE
    ON subtask
    FOR EACH ROW
EXECUTE PROCEDURE check_sub_date();


-- TRIGGER10
CREATE TRIGGER add_invite_notification
    AFTER INSERT
    ON invite
    FOR EACH ROW
EXECUTE PROCEDURE add_invite_notification();


-- TRIGGER11
CREATE TRIGGER add_project_notification
    AFTER INSERT
    ON team_member
    FOR EACH ROW
EXECUTE PROCEDURE add_project_notification();


-- TRIGGER12
CREATE TRIGGER add_assignment_notification
    AFTER INSERT
    ON assignment
    FOR EACH ROW
EXECUTE PROCEDURE add_assignment_notification();


-- TRIGGER013
CREATE TRIGGER add_comment_notification
    AFTER INSERT
    ON comment
    FOR EACH ROW
EXECUTE PROCEDURE add_comment_notification();


-- TRIGGER14
CREATE TRIGGER add_report_notification
    AFTER UPDATE OF state
    ON report
    FOR EACH ROW
EXECUTE PROCEDURE add_report_notification();


-- Indexes

DROP INDEX IF EXISTS client_member_index;
DROP INDEX IF EXISTS project_member_index;
DROP INDEX IF EXISTS task_index;
DROP INDEX IF EXISTS subtask_index;
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
CREATE INDEX subtask_index ON subtask USING hash (parent);

-- IDX05
CREATE INDEX waiting_index ON waiting_on USING hash (task1);

-- IDX06
CREATE INDEX task_assign_index ON assignment USING hash (task);

-- IDX07
CREATE INDEX client_assign_index ON assignment USING hash (task);

-- IDX08
CREATE INDEX tag_index ON tag USING hash (project);

-- IDX09
CREATE INDEX task_tag_index ON contains_tag USING hash (task);

-- IDX10
CREATE INDEX tag_task_index ON contains_tag USING hash (tag);

-- IDX11
CREATE INDEX check_list_index ON check_list_item USING hash (task);

-- IDX12
CREATE INDEX comment_index ON comment USING btree (task, comment_date);

-- IDX13
CREATE INDEX notification_index ON notification USING btree (client, notification_date);

-- IDX14
CREATE INDEX search_client ON client USING GIN (search);

-- IDX15
CREATE INDEX search_project ON project USING GIN (search);

-- IDX16
CREATE INDEX search_task ON task USING GIN (search);


-- Populate

-- Country

INSERT INTO country (id, iso, name) VALUES (1, 'AF', 'Afghanistan');
INSERT INTO country (id, iso, name) VALUES (2, 'AL', 'Albania');
INSERT INTO country (id, iso, name) VALUES (3, 'DZ', 'Algeria');
INSERT INTO country (id, iso, name) VALUES (4, 'AS', 'American Samoa');
INSERT INTO country (id, iso, name) VALUES (5, 'AD', 'Andorra');
INSERT INTO country (id, iso, name) VALUES (6, 'AO', 'Angola');
INSERT INTO country (id, iso, name) VALUES (7, 'AI', 'Anguilla');
INSERT INTO country (id, iso, name) VALUES (8, 'AQ', 'Antarctica');
INSERT INTO country (id, iso, name) VALUES (9, 'AG', 'Antigua and Barbuda');
INSERT INTO country (id, iso, name) VALUES (10, 'AR', 'Argentina');
INSERT INTO country (id, iso, name) VALUES (11, 'AM', 'Armenia');
INSERT INTO country (id, iso, name) VALUES (12, 'AW', 'Aruba');
INSERT INTO country (id, iso, name) VALUES (13, 'AU', 'Australia');
INSERT INTO country (id, iso, name) VALUES (14, 'AT', 'Austria');
INSERT INTO country (id, iso, name) VALUES (15, 'AZ', 'Azerbaijan');
INSERT INTO country (id, iso, name) VALUES (16, 'BS', 'Bahamas');
INSERT INTO country (id, iso, name) VALUES (17, 'BH', 'Bahrain');
INSERT INTO country (id, iso, name) VALUES (18, 'BD', 'Bangladesh');
INSERT INTO country (id, iso, name) VALUES (19, 'BB', 'Barbados');
INSERT INTO country (id, iso, name) VALUES (20, 'BY', 'Belarus');
INSERT INTO country (id, iso, name) VALUES (21, 'BE', 'Belgium');
INSERT INTO country (id, iso, name) VALUES (22, 'BZ', 'Belize');
INSERT INTO country (id, iso, name) VALUES (23, 'BJ', 'Benin');
INSERT INTO country (id, iso, name) VALUES (24, 'BM', 'Bermuda');
INSERT INTO country (id, iso, name) VALUES (25, 'BT', 'Bhutan');
INSERT INTO country (id, iso, name) VALUES (26, 'BO', 'Bolivia');
INSERT INTO country (id, iso, name) VALUES (27, 'BA', 'Bosnia and Herzegovina');
INSERT INTO country (id, iso, name) VALUES (28, 'BW', 'Botswana');
INSERT INTO country (id, iso, name) VALUES (29, 'BV', 'Bouvet Island');
INSERT INTO country (id, iso, name) VALUES (30, 'BR', 'Brazil');
INSERT INTO country (id, iso, name) VALUES (31, 'IO', 'British Indian Ocean Territory');
INSERT INTO country (id, iso, name) VALUES (32, 'BN', 'Brunei Darussalam');
INSERT INTO country (id, iso, name) VALUES (33, 'BG', 'Bulgaria');
INSERT INTO country (id, iso, name) VALUES (34, 'BF', 'Burkina Faso');
INSERT INTO country (id, iso, name) VALUES (35, 'BI', 'Burundi');
INSERT INTO country (id, iso, name) VALUES (36, 'KH', 'Cambodia');
INSERT INTO country (id, iso, name) VALUES (37, 'CM', 'Cameroon');
INSERT INTO country (id, iso, name) VALUES (38, 'CA', 'Canada');
INSERT INTO country (id, iso, name) VALUES (39, 'CV', 'Cape Verde');
INSERT INTO country (id, iso, name) VALUES (40, 'KY', 'Cayman Islands');
INSERT INTO country (id, iso, name) VALUES (41, 'CF', 'Central African Republic');
INSERT INTO country (id, iso, name) VALUES (42, 'TD', 'Chad');
INSERT INTO country (id, iso, name) VALUES (43, 'CL', 'Chile');
INSERT INTO country (id, iso, name) VALUES (44, 'CN', 'China');
INSERT INTO country (id, iso, name) VALUES (45, 'CX', 'Christmas Island');
INSERT INTO country (id, iso, name) VALUES (46, 'CC', 'Cocos (Keeling) Islands');
INSERT INTO country (id, iso, name) VALUES (47, 'CO', 'Colombia');
INSERT INTO country (id, iso, name) VALUES (48, 'KM', 'Comoros');
INSERT INTO country (id, iso, name) VALUES (49, 'CG', 'Congo');
INSERT INTO country (id, iso, name) VALUES (50, 'CD', 'Congo, the Democratic Republic of the');
INSERT INTO country (id, iso, name) VALUES (51, 'CK', 'Cook Islands');
INSERT INTO country (id, iso, name) VALUES (52, 'CR', 'Costa Rica');
INSERT INTO country (id, iso, name) VALUES (53, 'CI', 'Cote D''Ivoire');
INSERT INTO country (id, iso, name) VALUES (54, 'HR', 'Croatia');
INSERT INTO country (id, iso, name) VALUES (55, 'CU', 'Cuba');
INSERT INTO country (id, iso, name) VALUES (56, 'CY', 'Cyprus');
INSERT INTO country (id, iso, name) VALUES (57, 'CZ', 'Czech Republic');
INSERT INTO country (id, iso, name) VALUES (58, 'DK', 'Denmark');
INSERT INTO country (id, iso, name) VALUES (59, 'DJ', 'Djibouti');
INSERT INTO country (id, iso, name) VALUES (60, 'DM', 'Dominica');
INSERT INTO country (id, iso, name) VALUES (61, 'DO', 'Dominican Republic');
INSERT INTO country (id, iso, name) VALUES (62, 'EC', 'Ecuador');
INSERT INTO country (id, iso, name) VALUES (63, 'EG', 'Egypt');
INSERT INTO country (id, iso, name) VALUES (64, 'SV', 'El Salvador');
INSERT INTO country (id, iso, name) VALUES (65, 'GQ', 'Equatorial Guinea');
INSERT INTO country (id, iso, name) VALUES (66, 'ER', 'Eritrea');
INSERT INTO country (id, iso, name) VALUES (67, 'EE', 'Estonia');
INSERT INTO country (id, iso, name) VALUES (68, 'ET', 'Ethiopia');
INSERT INTO country (id, iso, name) VALUES (69, 'FK', 'Falkland Islands (Malvinas)');
INSERT INTO country (id, iso, name) VALUES (70, 'FO', 'Faroe Islands');
INSERT INTO country (id, iso, name) VALUES (71, 'FJ', 'Fiji');
INSERT INTO country (id, iso, name) VALUES (72, 'FI', 'Finland');
INSERT INTO country (id, iso, name) VALUES (73, 'FR', 'France');
INSERT INTO country (id, iso, name) VALUES (74, 'GF', 'French Guiana');
INSERT INTO country (id, iso, name) VALUES (75, 'PF', 'French Polynesia');
INSERT INTO country (id, iso, name) VALUES (76, 'TF', 'French Southern Territories');
INSERT INTO country (id, iso, name) VALUES (77, 'GA', 'Gabon');
INSERT INTO country (id, iso, name) VALUES (78, 'GM', 'Gambia');
INSERT INTO country (id, iso, name) VALUES (79, 'GE', 'Georgia');
INSERT INTO country (id, iso, name) VALUES (80, 'DE', 'Germany');
INSERT INTO country (id, iso, name) VALUES (81, 'GH', 'Ghana');
INSERT INTO country (id, iso, name) VALUES (82, 'GI', 'Gibraltar');
INSERT INTO country (id, iso, name) VALUES (83, 'GR', 'Greece');
INSERT INTO country (id, iso, name) VALUES (84, 'GL', 'Greenland');
INSERT INTO country (id, iso, name) VALUES (85, 'GD', 'Grenada');
INSERT INTO country (id, iso, name) VALUES (86, 'GP', 'Guadeloupe');
INSERT INTO country (id, iso, name) VALUES (87, 'GU', 'Guam');
INSERT INTO country (id, iso, name) VALUES (88, 'GT', 'Guatemala');
INSERT INTO country (id, iso, name) VALUES (89, 'GN', 'Guinea');
INSERT INTO country (id, iso, name) VALUES (90, 'GW', 'Guinea-Bissau');
INSERT INTO country (id, iso, name) VALUES (91, 'GY', 'Guyana');
INSERT INTO country (id, iso, name) VALUES (92, 'HT', 'Haiti');
INSERT INTO country (id, iso, name) VALUES (93, 'HM', 'Heard Island and Mcdonald Islands');
INSERT INTO country (id, iso, name) VALUES (94, 'VA', 'Holy See (Vatican City State)');
INSERT INTO country (id, iso, name) VALUES (95, 'HN', 'Honduras');
INSERT INTO country (id, iso, name) VALUES (96, 'HK', 'Hong Kong');
INSERT INTO country (id, iso, name) VALUES (97, 'HU', 'Hungary');
INSERT INTO country (id, iso, name) VALUES (98, 'IS', 'Iceland');
INSERT INTO country (id, iso, name) VALUES (99, 'IN', 'India');
INSERT INTO country (id, iso, name) VALUES (100, 'ID', 'Indonesia');
INSERT INTO country (id, iso, name) VALUES (101, 'IR', 'Iran, Islamic Republic of');
INSERT INTO country (id, iso, name) VALUES (102, 'IQ', 'Iraq');
INSERT INTO country (id, iso, name) VALUES (103, 'IE', 'Ireland');
INSERT INTO country (id, iso, name) VALUES (104, 'IL', 'Israel');
INSERT INTO country (id, iso, name) VALUES (105, 'IT', 'Italy');
INSERT INTO country (id, iso, name) VALUES (106, 'JM', 'Jamaica');
INSERT INTO country (id, iso, name) VALUES (107, 'JP', 'Japan');
INSERT INTO country (id, iso, name) VALUES (108, 'JO', 'Jordan');
INSERT INTO country (id, iso, name) VALUES (109, 'KZ', 'Kazakhstan');
INSERT INTO country (id, iso, name) VALUES (110, 'KE', 'Kenya');
INSERT INTO country (id, iso, name) VALUES (111, 'KI', 'Kiribati');
INSERT INTO country (id, iso, name) VALUES (112, 'KP', 'Korea, Democratic People''s Republic of');
INSERT INTO country (id, iso, name) VALUES (113, 'KR', 'Korea, Republic of');
INSERT INTO country (id, iso, name) VALUES (114, 'KW', 'Kuwait');
INSERT INTO country (id, iso, name) VALUES (115, 'KG', 'Kyrgyzstan');
INSERT INTO country (id, iso, name) VALUES (116, 'LA', 'Lao People''s Democratic Republic');
INSERT INTO country (id, iso, name) VALUES (117, 'LV', 'Latvia');
INSERT INTO country (id, iso, name) VALUES (118, 'LB', 'Lebanon');
INSERT INTO country (id, iso, name) VALUES (119, 'LS', 'Lesotho');
INSERT INTO country (id, iso, name) VALUES (120, 'LR', 'Liberia');
INSERT INTO country (id, iso, name) VALUES (121, 'LY', 'Libyan Arab Jamahiriya');
INSERT INTO country (id, iso, name) VALUES (122, 'LI', 'Liechtenstein');
INSERT INTO country (id, iso, name) VALUES (123, 'LT', 'Lithuania');
INSERT INTO country (id, iso, name) VALUES (124, 'LU', 'Luxembourg');
INSERT INTO country (id, iso, name) VALUES (125, 'MO', 'Macao');
INSERT INTO country (id, iso, name) VALUES (126, 'MK', 'North Macedonia');
INSERT INTO country (id, iso, name) VALUES (127, 'MG', 'Madagascar');
INSERT INTO country (id, iso, name) VALUES (128, 'MW', 'Malawi');
INSERT INTO country (id, iso, name) VALUES (129, 'MY', 'Malaysia');
INSERT INTO country (id, iso, name) VALUES (130, 'MV', 'Maldives');
INSERT INTO country (id, iso, name) VALUES (131, 'ML', 'Mali');
INSERT INTO country (id, iso, name) VALUES (132, 'MT', 'Malta');
INSERT INTO country (id, iso, name) VALUES (133, 'MH', 'Marshall Islands');
INSERT INTO country (id, iso, name) VALUES (134, 'MQ', 'Martinique');
INSERT INTO country (id, iso, name) VALUES (135, 'MR', 'Mauritania');
INSERT INTO country (id, iso, name) VALUES (136, 'MU', 'Mauritius');
INSERT INTO country (id, iso, name) VALUES (137, 'YT', 'Mayotte');
INSERT INTO country (id, iso, name) VALUES (138, 'MX', 'Mexico');
INSERT INTO country (id, iso, name) VALUES (139, 'FM', 'Micronesia, Federated States of');
INSERT INTO country (id, iso, name) VALUES (140, 'MD', 'Moldova, Republic of');
INSERT INTO country (id, iso, name) VALUES (141, 'MC', 'Monaco');
INSERT INTO country (id, iso, name) VALUES (142, 'MN', 'Mongolia');
INSERT INTO country (id, iso, name) VALUES (143, 'MS', 'Montserrat');
INSERT INTO country (id, iso, name) VALUES (144, 'MA', 'Morocco');
INSERT INTO country (id, iso, name) VALUES (145, 'MZ', 'Mozambique');
INSERT INTO country (id, iso, name) VALUES (146, 'MM', 'Myanmar');
INSERT INTO country (id, iso, name) VALUES (147, 'NA', 'Namibia');
INSERT INTO country (id, iso, name) VALUES (148, 'NR', 'Nauru');
INSERT INTO country (id, iso, name) VALUES (149, 'NP', 'Nepal');
INSERT INTO country (id, iso, name) VALUES (150, 'NL', 'Netherlands');
INSERT INTO country (id, iso, name) VALUES (151, 'AN', 'Netherlands Antilles');
INSERT INTO country (id, iso, name) VALUES (152, 'NC', 'New Caledonia');
INSERT INTO country (id, iso, name) VALUES (153, 'NZ', 'New Zealand');
INSERT INTO country (id, iso, name) VALUES (154, 'NI', 'Nicaragua');
INSERT INTO country (id, iso, name) VALUES (155, 'NE', 'Niger');
INSERT INTO country (id, iso, name) VALUES (156, 'NG', 'Nigeria');
INSERT INTO country (id, iso, name) VALUES (157, 'NU', 'Niue');
INSERT INTO country (id, iso, name) VALUES (158, 'NF', 'Norfolk Island');
INSERT INTO country (id, iso, name) VALUES (159, 'MP', 'Northern Mariana Islands');
INSERT INTO country (id, iso, name) VALUES (160, 'NO', 'Norway');
INSERT INTO country (id, iso, name) VALUES (161, 'OM', 'Oman');
INSERT INTO country (id, iso, name) VALUES (162, 'PK', 'Pakistan');
INSERT INTO country (id, iso, name) VALUES (163, 'PW', 'Palau');
INSERT INTO country (id, iso, name) VALUES (164, 'PS', 'Palestinian Territory, Occupied');
INSERT INTO country (id, iso, name) VALUES (165, 'PA', 'Panama');
INSERT INTO country (id, iso, name) VALUES (166, 'PG', 'Papua New Guinea');
INSERT INTO country (id, iso, name) VALUES (167, 'PY', 'Paraguay');
INSERT INTO country (id, iso, name) VALUES (168, 'PE', 'Peru');
INSERT INTO country (id, iso, name) VALUES (169, 'PH', 'Philippines');
INSERT INTO country (id, iso, name) VALUES (170, 'PN', 'Pitcairn');
INSERT INTO country (id, iso, name) VALUES (171, 'PL', 'Poland');
INSERT INTO country (id, iso, name) VALUES (172, 'PT', 'Portugal');
INSERT INTO country (id, iso, name) VALUES (173, 'PR', 'Puerto Rico');
INSERT INTO country (id, iso, name) VALUES (174, 'QA', 'Qatar');
INSERT INTO country (id, iso, name) VALUES (175, 'RE', 'Reunion');
INSERT INTO country (id, iso, name) VALUES (176, 'RO', 'Romania');
INSERT INTO country (id, iso, name) VALUES (177, 'RU', 'Russian Federation');
INSERT INTO country (id, iso, name) VALUES (178, 'RW', 'Rwanda');
INSERT INTO country (id, iso, name) VALUES (179, 'SH', 'Saint Helena');
INSERT INTO country (id, iso, name) VALUES (180, 'KN', 'Saint Kitts and Nevis');
INSERT INTO country (id, iso, name) VALUES (181, 'LC', 'Saint Lucia');
INSERT INTO country (id, iso, name) VALUES (182, 'PM', 'Saint Pierre and Miquelon');
INSERT INTO country (id, iso, name) VALUES (183, 'VC', 'Saint Vincent and the Grenadines');
INSERT INTO country (id, iso, name) VALUES (184, 'WS', 'Samoa');
INSERT INTO country (id, iso, name) VALUES (185, 'SM', 'San Marino');
INSERT INTO country (id, iso, name) VALUES (186, 'ST', 'Sao Tome and Principe');
INSERT INTO country (id, iso, name) VALUES (187, 'SA', 'Saudi Arabia');
INSERT INTO country (id, iso, name) VALUES (188, 'SN', 'Senegal');
INSERT INTO country (id, iso, name) VALUES (189, 'RS', 'Serbia');
INSERT INTO country (id, iso, name) VALUES (190, 'SC', 'Seychelles');
INSERT INTO country (id, iso, name) VALUES (191, 'SL', 'Sierra Leone');
INSERT INTO country (id, iso, name) VALUES (192, 'SG', 'Singapore');
INSERT INTO country (id, iso, name) VALUES (193, 'SK', 'Slovakia');
INSERT INTO country (id, iso, name) VALUES (194, 'SI', 'Slovenia');
INSERT INTO country (id, iso, name) VALUES (195, 'SB', 'Solomon Islands');
INSERT INTO country (id, iso, name) VALUES (196, 'SO', 'Somalia');
INSERT INTO country (id, iso, name) VALUES (197, 'ZA', 'South Africa');
INSERT INTO country (id, iso, name) VALUES (198, 'GS', 'South Georgia and the South Sandwich Islands');
INSERT INTO country (id, iso, name) VALUES (199, 'ES', 'Spain');
INSERT INTO country (id, iso, name) VALUES (200, 'LK', 'Sri Lanka');
INSERT INTO country (id, iso, name) VALUES (201, 'SD', 'Sudan');
INSERT INTO country (id, iso, name) VALUES (202, 'SR', 'Suriname');
INSERT INTO country (id, iso, name) VALUES (203, 'SJ', 'Svalbard and Jan Mayen');
INSERT INTO country (id, iso, name) VALUES (204, 'SZ', 'Swaziland');
INSERT INTO country (id, iso, name) VALUES (205, 'SE', 'Sweden');
INSERT INTO country (id, iso, name) VALUES (206, 'CH', 'Switzerland');
INSERT INTO country (id, iso, name) VALUES (207, 'SY', 'Syrian Arab Republic');
INSERT INTO country (id, iso, name) VALUES (208, 'TW', 'Taiwan, Province of China');
INSERT INTO country (id, iso, name) VALUES (209, 'TJ', 'Tajikistan');
INSERT INTO country (id, iso, name) VALUES (210, 'TZ', 'Tanzania, United Republic of');
INSERT INTO country (id, iso, name) VALUES (211, 'TH', 'Thailand');
INSERT INTO country (id, iso, name) VALUES (212, 'TL', 'Timor-Leste');
INSERT INTO country (id, iso, name) VALUES (213, 'TG', 'Togo');
INSERT INTO country (id, iso, name) VALUES (214, 'TK', 'Tokelau');
INSERT INTO country (id, iso, name) VALUES (215, 'TO', 'Tonga');
INSERT INTO country (id, iso, name) VALUES (216, 'TT', 'Trinidad and Tobago');
INSERT INTO country (id, iso, name) VALUES (217, 'TN', 'Tunisia');
INSERT INTO country (id, iso, name) VALUES (218, 'TR', 'Turkey');
INSERT INTO country (id, iso, name) VALUES (219, 'TM', 'Turkmenistan');
INSERT INTO country (id, iso, name) VALUES (220, 'TC', 'Turks and Caicos Islands');
INSERT INTO country (id, iso, name) VALUES (221, 'TV', 'Tuvalu');
INSERT INTO country (id, iso, name) VALUES (222, 'UG', 'Uganda');
INSERT INTO country (id, iso, name) VALUES (223, 'UA', 'Ukraine');
INSERT INTO country (id, iso, name) VALUES (224, 'AE', 'United Arab Emirates');
INSERT INTO country (id, iso, name) VALUES (225, 'GB', 'United Kingdom');
INSERT INTO country (id, iso, name) VALUES (226, 'US', 'United States');
INSERT INTO country (id, iso, name) VALUES (227, 'UM', 'United States Minor Outlying Islands');
INSERT INTO country (id, iso, name) VALUES (228, 'UY', 'Uruguay');
INSERT INTO country (id, iso, name) VALUES (229, 'UZ', 'Uzbekistan');
INSERT INTO country (id, iso, name) VALUES (230, 'VU', 'Vanuatu');
INSERT INTO country (id, iso, name) VALUES (231, 'VE', 'Venezuela');
INSERT INTO country (id, iso, name) VALUES (232, 'VN', 'Viet Nam');
INSERT INTO country (id, iso, name) VALUES (233, 'VG', 'Virgin Islands, British');
INSERT INTO country (id, iso, name) VALUES (234, 'VI', 'Virgin Islands, U.s.');
INSERT INTO country (id, iso, name) VALUES (235, 'WF', 'Wallis and Futuna');
INSERT INTO country (id, iso, name) VALUES (236, 'EH', 'Western Sahara');
INSERT INTO country (id, iso, name) VALUES (237, 'YE', 'Yemen');
INSERT INTO country (id, iso, name) VALUES (238, 'ZM', 'Zambia');
INSERT INTO country (id, iso, name) VALUES (239, 'ZW', 'Zimbabwe');
INSERT INTO country (id, iso, name) VALUES (240, 'ME', 'Montenegro');
INSERT INTO country (id, iso, name) VALUES (241, 'XK', 'Kosovo');
INSERT INTO country (id, iso, name) VALUES (242, 'AX', 'Aland Islands');
INSERT INTO country (id, iso, name) VALUES (243, 'BQ', 'Bonaire, Sint Eustatius and Saba');
INSERT INTO country (id, iso, name) VALUES (244, 'CW', 'Curacao');
INSERT INTO country (id, iso, name) VALUES (245, 'GG', 'Guernsey');
INSERT INTO country (id, iso, name) VALUES (246, 'IM', 'Isle of Man');
INSERT INTO country (id, iso, name) VALUES (247, 'JE', 'Jersey');
INSERT INTO country (id, iso, name) VALUES (248, 'BL', 'Saint Barthelemy');
INSERT INTO country (id, iso, name) VALUES (249, 'MF', 'Saint Martin');
INSERT INTO country (id, iso, name) VALUES (250, 'SX', 'Sint Maarten');
INSERT INTO country (id, iso, name) VALUES (251, 'SS', 'South Sudan');

-- Account

INSERT INTO account (id, username, password, email) VALUES (1, 'admin', '$2a$10$iSI3q01xt.uTMkYxWnge7Odfi3TGjN700NjgcupWlFz9lXXSbhNN6', 'admin@gmail.com');
INSERT INTO account (id, username, password, email) VALUES (2, 'nenieats', '$2a$10$iSI3q01xt.uTMkYxWnge7Odfi3TGjN700NjgcupWlFz9lXXSbhNN6', 'nenieats@gmail.com');
INSERT INTO account (id, username, password, email) VALUES (3, 'pedgojodge', '$2a$10$iSI3q01xt.uTMkYxWnge7Odfi3TGjN700NjgcupWlFz9lXXSbhNN6', 'pedgojodge@gmail.com');
INSERT INTO account (id, username, password, email) VALUES (4, 'guninha_uwu', '$2a$10$iSI3q01xt.uTMkYxWnge7Odfi3TGjN700NjgcupWlFz9lXXSbhNN6', 'kbaby69@gmail.com');
INSERT INTO account (id, username, password, email) VALUES (5, 'bababooey', '$2a$10$iSI3q01xt.uTMkYxWnge7Odfi3TGjN700NjgcupWlFz9lXXSbhNN6', 'nhonholoro@gmail.com');
INSERT INTO account (id, username, password, email) VALUES (6, 'ccominotti0', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'tgaynes0@unicef.org');
INSERT INTO account (id, username, password, email) VALUES (7, 'csand1', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'kgonneau1@ca.gov');
INSERT INTO account (id, username, password, email) VALUES (8, 'apusey2', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'fjanjic2@rambler.ru');
INSERT INTO account (id, username, password, email) VALUES (9, 'llevi3', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'lrobbins3@jigsy.com');
INSERT INTO account (id, username, password, email) VALUES (10, 'aillesley4', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'dluddy4@about.com');
INSERT INTO account (id, username, password, email) VALUES (11, 'nallkins5', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'edederick5@ftc.gov');
INSERT INTO account (id, username, password, email) VALUES (12, 'acaruth6', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'dfathers6@geocities.jp');
INSERT INTO account (id, username, password, email) VALUES (13, 'gdunklee7', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'cearle7@oracle.com');
INSERT INTO account (id, username, password, email) VALUES (14, 'mthackeray8', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'hlincke8@oracle.com');
INSERT INTO account (id, username, password, email) VALUES (15, 'tbrewins9', '$2a$10$SH3botEyAbvJZb8kOMnK7eLr995uBIiXVri6vzxcPGftld/lwopYG', 'drendell9@sbwire.com');
INSERT INTO account (id, username, password, email) VALUES (16, 'oviant0', 'f6L2ma4MRCc', 'hlocal0@timesonline.co.uk');
INSERT INTO account (id, username, password, email) VALUES (17, 'jcromack1', 'yGw3dkXzAob', 'jpoetz1@123-reg.co.uk');
INSERT INTO account (id, username, password, email) VALUES (18, 'acunliffe2', 'z3OQFy', 'mdemann2@dion.ne.jp');
INSERT INTO account (id, username, password, email) VALUES (19, 'nlewton3', 'CNnrtyMoU4', 'jdillon3@wix.com');
INSERT INTO account (id, username, password, email) VALUES (20, 'hlawleff4', 'sjJODsGwd', 'cgertray4@nbcnews.com');
INSERT INTO account (id, username, password, email) VALUES (21, 'kgindghill5', 'dUjCNV4', 'amusterd5@engadget.com');
INSERT INTO account (id, username, password, email) VALUES (22, 'edesquesnes6', 'lxIAtI', 'bstrathearn6@list-manage.com');
INSERT INTO account (id, username, password, email) VALUES (23, 'mkleinhaus7', '1PSHByUI3', 'kscripture7@fc2.com');
INSERT INTO account (id, username, password, email) VALUES (24, 'tmorecomb8', 'Qssd6h1SB71N', 'gben8@huffingtonpost.com');
INSERT INTO account (id, username, password, email) VALUES (25, 'mbrockelsby9', 'FjzyCDRFEZ', 'waustin9@baidu.com');


-- Admin

INSERT INTO admin (id) VALUES (1);


-- Client

INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (2, 'Whitby Dumberell', 'Centimia', 'avatars/AvatarMaker1.png', '#69ca7f', 'Unspecified', 26);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (3, 'Consalve Abys', 'Photobug', 'avatars/AvatarMaker2.png', '#83c20b', 'Male', 161);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (4, 'Effie Yuille', 'Oba', 'avatars/AvatarMaker3.png', '#67dfd5', 'Female', 211);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (5, 'Analise Gooderick', 'Rhybox', 'avatars/AvatarMaker4.png', '#1431c5', 'Unspecified', 116);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (6, 'Orville Gostage', 'Vitz', 'avatars/AvatarMaker5.png', '#56f8fb', 'Unspecified', 178);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (7, 'Burt Yearnsley', 'Izio', 'avatars/AvatarMaker6.png', '#1b3404', 'Unspecified', 246);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (8, 'Wynnie Wey', 'Yodoo', 'avatars/AvatarMaker7.png', '#006205', 'Unspecified', 129);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (9, 'Pearla Gaine of England', 'Skinix', 'avatars/AvatarMaker8.png', '#efdca5', 'Unspecified', 245);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (10, 'Wernher O''Dowling', 'Leenti', 'avatars/AvatarMaker9.png', '#aba97c', 'Unspecified', 96);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (11, 'Mary Pietersma', 'Fivebridge', 'avatars/AvatarMaker10.png', '#dd6d7b', 'Unspecified', 236);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (12, 'Hanan Tryme', 'Shuffledrive', 'avatars/AvatarMaker11.png', '#0e565d', 'Female', 98);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (13, 'Madel Dunkinson', 'Centizu', 'avatars/AvatarMaker12.png', '#adc321', 'Female', 198);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (14, 'Kirby Woolway', 'Realpoint', 'avatars/AvatarMaker13.png', '#dee419', 'Unspecified', 39);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (15, 'Birdie Tertre', 'Quinu', 'avatars/AvatarMaker14.png', '#cc2207', 'Unspecified', 38);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (16, 'Jacquie Meran', 'Divanoodle', 'avatars/AvatarMaker15.png', '#cf64db', 'Unspecified', 142);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (17, 'Agatha Lockhurst', 'Skyndu', 'avatars/AvatarMaker16.png', '#bbcaa3', 'Unspecified', 94);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (18, 'Chad Outhwaite', 'Dabjam', 'avatars/AvatarMaker17.png', '#c098a9', 'Female', 110);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (19, 'Nathalia Pues', 'Browsebug', 'avatars/AvatarMaker18.png', '#7fdc98', 'Male', 160);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (20, 'Marcelline Ruske', 'Yakijo', 'avatars/AvatarMaker19.png', '#e65f3f', 'Female', 240);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (21, 'Cordie Kareman', 'Ooba', 'avatars/AvatarMaker20.png', '#03f5cb', 'Male', 231);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (22, 'Georgeanna Gruczka', 'Dablist', 'avatars/AvatarMaker21.png', '#831dcd', 'Female', 100);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (23, 'Amber Terrans', 'Yodo', 'avatars/AvatarMaker22.png', '#16887b', 'Unspecified', 40);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (24, 'Darcee Bullas', 'Quatz', 'avatars/AvatarMaker23.png', '#44ea40', 'Unspecified', 226);
INSERT INTO client (id, fullname, company, avatar, color, client_gender, country) VALUES (25, 'Lilla Ridel', 'Babbleopia', 'avatars/AvatarMaker24.png', '#eb7680', 'Unspecified', 247);


-- Project

INSERT INTO project (id, name, description, due_date) VALUES (1, 'repurpose efficient portals', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', '2022-12-20');
INSERT INTO project (id, name, description, due_date) VALUES (2, 'mesh collaborative platforms', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', '2022-02-06');
INSERT INTO project (id, name, description, due_date) VALUES (3, 'maximize plug-and-play applications', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', '2022-09-26');
INSERT INTO project (id, name, description, due_date) VALUES (4, 'synergize intuitive interfaces', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', '2022-08-27');
INSERT INTO project (id, name, description, due_date) VALUES (5, 'facilitate dot-com deliverables', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', '2022-01-09');
INSERT INTO project (id, name, description, due_date) VALUES (6, 'whiteboard integrated web services', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl.', '2022-06-27');
INSERT INTO project (id, name, description, due_date) VALUES (7, 'engage integrated infrastructures', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', '2022-06-26');
INSERT INTO project (id, name, description, due_date) VALUES (8, 'seize web-enabled ROI', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '2022-05-07');
INSERT INTO project (id, name, description, due_date) VALUES (9, 'innovate compelling applications', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', '2022-10-28');
INSERT INTO project (id, name, description, due_date) VALUES (10, 'mesh impactful users', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', null);
INSERT INTO project (id, name, description, due_date) VALUES (11, 'recontextualize 24/365 applications', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', '2022-07-11');
INSERT INTO project (id, name, description, due_date) VALUES (12, 'unleash revolutionary communities', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', '2022-03-12');
INSERT INTO project (id, name, description, due_date) VALUES (13, 'repurpose integrated models', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', null);
INSERT INTO project (id, name, description, due_date) VALUES (14, 'evolve dynamic partnerships', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl.', '2022-03-25');
INSERT INTO project (id, name, description, due_date) VALUES (15, 'grow 24/365 infrastructures', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', '2022-03-24');
INSERT INTO project (id, name, description, due_date) VALUES (16, 'disintermediate one-to-one infomediaries', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', '2021-08-30');
INSERT INTO project (id, name, description, due_date) VALUES (17, 'envisioneer cross-media mindshare', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.', null);
INSERT INTO project (id, name, description, due_date) VALUES (18, 'implement front-end architectures', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '2022-06-26');
INSERT INTO project (id, name, description, due_date) VALUES (19, 'grow wireless vortals', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', null);
INSERT INTO project (id, name, description, due_date) VALUES (20, 'mesh vertical architectures', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', '2022-04-14');
INSERT INTO project (id, name, description, due_date) VALUES (21, 'whiteboard magnetic technologies', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', null);
INSERT INTO project (id, name, description, due_date) VALUES (22, 'orchestrate best-of-breed users', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', null);
INSERT INTO project (id, name, description, due_date) VALUES (23, 'repurpose integrated e-commerce', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', '2021-11-09');
INSERT INTO project (id, name, description, due_date) VALUES (24, 'enhance cutting-edge channels', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '2022-10-29');
INSERT INTO project (id, name, description, due_date) VALUES (25, 'empower real-time models', 'Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', '2021-08-14');
INSERT INTO project (id, name, description, due_date) VALUES (26, 'visualize dynamic experiences', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', null);
INSERT INTO project (id, name, description, due_date) VALUES (27, 'morph collaborative methodologies', 'Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', '2022-07-24');
INSERT INTO project (id, name, description, due_date) VALUES (28, 'enhance robust convergence', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', '2021-08-28');
INSERT INTO project (id, name, description, due_date) VALUES (29, 'empower cross-media channels', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '2021-12-05');
INSERT INTO project (id, name, description, due_date) VALUES (30, 'orchestrate e-business technologies', 'Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '2022-12-08');
INSERT INTO project (id, name, description, due_date) VALUES (31, 'scale dynamic metrics', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '2022-06-11');
INSERT INTO project (id, name, description, due_date) VALUES (32, 'incubate open-source e-markets', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', null);
INSERT INTO project (id, name, description, due_date) VALUES (33, 'morph efficient mindshare', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', null);
INSERT INTO project (id, name, description, due_date) VALUES (34, 'grow impactful interfaces', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', '2022-07-30');
INSERT INTO project (id, name, description, due_date) VALUES (35, 'seize mission-critical niches', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '2022-06-09');
INSERT INTO project (id, name, description, due_date) VALUES (36, 'expedite intuitive infomediaries', 'Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', '2022-09-14');
INSERT INTO project (id, name, description, due_date) VALUES (37, 'morph e-business vortals', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '2022-06-11');
INSERT INTO project (id, name, description, due_date) VALUES (38, 'engineer cross-platform synergies', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', null);
INSERT INTO project (id, name, description, due_date) VALUES (39, 'repurpose extensible eyeballs', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', '2022-04-02');
INSERT INTO project (id, name, description, due_date) VALUES (40, 'facilitate end-to-end models', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2022-04-27');
INSERT INTO project (id, name, description, due_date) VALUES (41, 'enhance next-generation markets', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', null);
INSERT INTO project (id, name, description, due_date) VALUES (42, 'matrix killer web-readiness', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', '2022-10-27');
INSERT INTO project (id, name, description, due_date) VALUES (43, 'productize turn-key e-services', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '2021-09-06');
INSERT INTO project (id, name, description, due_date) VALUES (44, 'seize open-source infrastructures', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', null);
INSERT INTO project (id, name, description, due_date) VALUES (45, 'integrate rich relationships', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '2022-02-23');
INSERT INTO project (id, name, description, due_date) VALUES (46, 'deliver rich convergence', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '2022-08-06');
INSERT INTO project (id, name, description, due_date) VALUES (47, 'seize strategic mindshare', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '2021-07-20');
INSERT INTO project (id, name, description, due_date) VALUES (48, 'engineer integrated platforms', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', '2022-09-20');
INSERT INTO project (id, name, description, due_date) VALUES (49, 'enable dot-com applications', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', '2022-06-07');
INSERT INTO project (id, name, description, due_date) VALUES (50, 'morph out-of-the-box partnerships', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '2022-06-16');


-- Invite

INSERT INTO invite (client_id, project_id, decision) VALUES (2, 1, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (2, 3, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (2, 8, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (2, 10, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (2, 13, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (2, 24, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (2, 33, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (2, 35, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (2, 36, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (2, 46, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (3, 1, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (3, 5, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (3, 7, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (3, 11, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (3, 17, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (3, 23, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (3, 32, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (3, 37, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (3, 40, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (3, 47, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (3, 48, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 7, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 8, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 9, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 12, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 14, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 16, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 17, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 22, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 30, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 36, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 38, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 41, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 42, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 43, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 44, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (4, 50, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (5, 4, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (5, 5, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (5, 8, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (5, 9, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (5, 10, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (5, 13, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (5, 17, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (5, 28, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (5, 33, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (5, 36, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (5, 38, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (5, 41, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (5, 45, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (5, 46, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (5, 47, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (6, 5, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (6, 9, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (6, 11, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (6, 14, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (6, 18, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (6, 24, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (6, 25, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (6, 26, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (6, 27, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (6, 28, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (6, 30, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (6, 32, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (6, 38, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (6, 46, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (6, 47, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (7, 3, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (7, 4, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (7, 14, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (7, 34, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (7, 37, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (7, 39, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (7, 46, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (7, 47, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (7, 50, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (8, 4, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (8, 20, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (8, 24, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (8, 28, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (8, 36, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (8, 39, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (8, 41, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (8, 44, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (9, 11, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (9, 18, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (9, 19, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (9, 22, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (9, 24, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (9, 31, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (9, 35, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (9, 40, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (9, 43, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (9, 48, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (10, 3, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (10, 6, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (10, 7, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (10, 11, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (10, 15, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (10, 20, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (10, 31, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (10, 32, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (10, 33, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (10, 37, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (10, 41, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (10, 47, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (11, 5, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (11, 9, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (11, 17, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (11, 18, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (11, 22, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (11, 23, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (11, 25, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (11, 31, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (11, 34, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (11, 35, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (11, 38, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (11, 39, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (12, 1, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (12, 7, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (12, 10, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (12, 12, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (12, 16, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (12, 20, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (12, 22, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (12, 23, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (12, 24, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (12, 28, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (12, 31, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (12, 34, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (12, 40, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (12, 41, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (12, 48, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (13, 1, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (13, 3, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (13, 5, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (13, 6, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (13, 14, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (13, 17, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (13, 27, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (13, 31, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (13, 37, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (13, 38, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (13, 43, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (14, 2, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (14, 20, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (14, 22, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (14, 25, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (14, 26, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (14, 38, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (14, 42, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (14, 50, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (15, 15, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (15, 20, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (15, 24, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (15, 25, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (15, 27, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (15, 36, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (15, 46, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (16, 1, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (16, 4, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (16, 5, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (16, 6, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (16, 12, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (16, 17, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (16, 26, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (16, 33, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (16, 35, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (16, 38, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (16, 42, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (16, 43, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (16, 45, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (17, 2, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (17, 4, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (17, 8, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (17, 12, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (17, 14, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (17, 28, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (17, 37, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (17, 38, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (17, 43, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (17, 44, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (17, 48, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (17, 49, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (18, 8, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (18, 10, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (18, 13, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (18, 16, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (18, 26, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (18, 29, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (18, 35, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (18, 43, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (18, 45, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (19, 1, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (19, 5, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (19, 8, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (19, 10, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (19, 12, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (19, 17, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (19, 22, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (19, 28, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (19, 32, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (19, 38, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (19, 40, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (19, 48, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (20, 1, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (20, 9, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (20, 11, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (20, 17, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (20, 19, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (20, 21, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (20, 25, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (20, 30, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (20, 31, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (20, 32, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (20, 35, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (20, 43, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (20, 44, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (21, 2, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (21, 5, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (21, 11, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (21, 17, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (21, 18, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (21, 19, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (21, 30, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (21, 31, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (21, 34, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (21, 37, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (22, 7, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (22, 12, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (22, 16, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (22, 24, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (22, 25, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (22, 29, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (22, 36, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (22, 39, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (22, 40, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (22, 50, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (23, 6, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (23, 8, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (23, 14, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (23, 17, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (23, 29, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (23, 30, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (23, 39, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (23, 40, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (23, 45, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (23, 47, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (23, 48, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (23, 49, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (24, 2, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (24, 4, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (24, 5, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (24, 6, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (24, 13, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (24, 15, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (24, 24, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (24, 26, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (24, 31, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (24, 42, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (24, 44, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (24, 48, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (25, 1, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (25, 2, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (25, 5, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (25, 6, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (25, 8, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (25, 26, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (25, 27, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (25, 43, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (25, 47, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (25, 48, TRUE);
INSERT INTO invite (client_id, project_id, decision) VALUES (25, 49, TRUE);


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

INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (1, 25, 'drive proactive solutions', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat.', '2020-08-23 17:41:34', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (2, 45, 'generate collaborative synergies', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (3, 24, 'harness bleeding-edge e-business', null, '2020-12-26 00:39:36', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (4, 5, 'deploy impactful portals', null, '2020-12-13 08:15:07', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (5, 8, 'aggregate real-time functionalities', 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', '2021-01-05 07:07:11', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (6, 46, 'grow integrated synergies', 'Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (7, 25, 'repurpose out-of-the-box experiences', 'Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (8, 21, 'target 24/365 mindshare', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (9, 23, 'mesh open-source content', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (10, 13, 'architect killer functionalities', 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (11, 40, 'disintermediate B2B interfaces', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (12, 32, 'expedite dot-com supply-chains', null, '2020-05-27 10:57:57', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (13, 29, 'revolutionize enterprise e-business', 'Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (14, 18, 'transition strategic interfaces', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (15, 5, 'grow revolutionary communities', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (16, 27, 'harness compelling methodologies', null, '2020-10-07 17:29:43', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (17, 26, 'evolve interactive partnerships', null, '2020-11-12 18:59:50', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (18, 26, 'incentivize bricks-and-clicks markets', null, '2021-01-06 23:26:48', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (19, 40, 'reinvent rich architectures', 'Sed ante.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (20, 40, 'enhance ubiquitous architectures', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '2021-01-01 13:47:30', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (21, 8, 'implement bleeding-edge portals', 'Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia.', '2021-02-17 09:46:55', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (22, 12, 'recontextualize rich content', null, '2020-11-08 08:48:25', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (23, 32, 'transform holistic users', 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (24, 6, 'synergize one-to-one models', null, '2020-08-19 21:20:34', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (25, 17, 'transition wireless niches', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (26, 19, 'whiteboard collaborative e-markets', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo.', '2021-01-11 06:08:26', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (27, 46, 'optimize bleeding-edge functionalities', 'In est risus, auctor sed, tristique in, tempus sit amet, sem.', '2020-09-15 02:02:28', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (28, 37, 'expedite extensible infomediaries', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (29, 24, 'benchmark out-of-the-box schemas', null, '2020-11-20 08:40:16', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (30, 29, 'synergize innovative solutions', 'Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (31, 16, 'incentivize frictionless initiatives', 'Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis.', '2020-11-09 23:52:37', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (32, 34, 'mesh ubiquitous web-readiness', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (33, 17, 'evolve turn-key synergies', 'Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '2020-04-15 22:49:34', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (34, 12, 'deliver strategic paradigms', 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis.', '2020-06-20 18:03:07', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (35, 1, 'syndicate holistic deliverables', null, null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (36, 26, 'empower wireless functionalities', 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', '2020-07-05 01:27:11', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (37, 26, 'engage dot-com eyeballs', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (38, 26, 'generate extensible communities', null, '2020-08-20 14:52:03', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (39, 21, 'maximize cross-media solutions', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (40, 36, 'revolutionize frictionless functionalities', 'Phasellus id sapien in sapien iaculis congue.', '2020-12-18 09:12:14', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (41, 24, 'unleash plug-and-play relationships', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', '2020-12-10 07:58:36', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (42, 14, 'utilize end-to-end methodologies', 'Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (43, 5, 'cultivate out-of-the-box eyeballs', 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', '2020-09-28 05:39:15', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (44, 46, 'deploy next-generation eyeballs', 'Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (45, 44, 'matrix user-centric interfaces', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (46, 38, 'seize frictionless initiatives', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (47, 47, 'enhance intuitive communities', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (48, 39, 'maximize sticky partnerships', 'Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (49, 36, 'incubate plug-and-play mindshare', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', '2020-04-06 10:41:13', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (50, 12, 'grow compelling systems', 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (51, 1, 'engineer bleeding-edge networks', 'In hac habitasse platea dictumst.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (52, 1, 'deploy best-of-breed networks', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (53, 9, 'leverage best-of-breed vortals', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (54, 47, 'orchestrate robust ROI', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.', '2021-02-19 20:11:54', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (55, 49, 'drive clicks-and-mortar platforms', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (56, 49, 'repurpose value-added architectures', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.', '2020-10-20 19:04:47', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (57, 15, 'engage next-generation infomediaries', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (58, 9, 'reintermediate granular networks', 'Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (59, 31, 'leverage one-to-one schemas', 'Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (60, 11, 'enhance B2C supply-chains', 'Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (61, 49, 'aggregate intuitive schemas', 'Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque.', '2020-11-04 16:05:55', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (62, 23, 'disintermediate sexy solutions', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (63, 44, 'reinvent mission-critical web-readiness', null, '2021-03-15 03:45:18', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (64, 2, 'scale interactive mindshare', 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.', '2020-09-30 13:42:46', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (65, 22, 'deliver vertical e-services', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (66, 50, 'target dynamic channels', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (67, 22, 'synthesize rich channels', 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam. Nam tristique tortor eu pede.', '2021-01-21 04:52:12', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (68, 50, 'transform bleeding-edge models', 'Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (69, 44, 'deploy impactful networks', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (70, 4, 'reintermediate B2B communities', 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.', '2021-02-01 09:10:12', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (71, 43, 'generate sexy e-markets', 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (72, 17, 'incentivize out-of-the-box convergence', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '2020-12-21 10:36:25', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (73, 6, 'scale global networks', 'Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.', '2020-05-06 16:45:49', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (74, 17, 'redefine scalable schemas', 'Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', '2020-04-30 03:03:19', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (75, 42, 'visualize cross-platform eyeballs', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (76, 49, 'transition magnetic web services', 'Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2020-12-31 08:51:31', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (77, 11, 'evolve one-to-one users', 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (78, 38, 'deliver revolutionary technologies', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.', '2021-02-26 21:39:44', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (79, 27, 'orchestrate one-to-one communities', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (80, 35, 'whiteboard clicks-and-mortar e-services', 'Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (81, 8, 'grow leading-edge methodologies', 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (82, 3, 'visualize intuitive infrastructures', 'Duis aliquam convallis nunc.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (83, 37, 'envisioneer synergistic paradigms', 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2020-09-17 05:13:31', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (84, 10, 'expedite wireless ROI', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (85, 19, 'engineer ubiquitous markets', 'Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis.', '2021-02-07 18:47:09', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (86, 12, 'utilize efficient synergies', null, '2020-10-18 00:49:17', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (87, 20, 'envisioneer front-end partnerships', 'Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (88, 32, 'harness wireless eyeballs', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (89, 41, 'monetize distributed e-business', null, '2020-12-25 18:43:52', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (90, 12, 'monetize viral infomediaries', null, '2021-03-02 10:33:17', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (91, 7, 'maximize bricks-and-clicks metrics', null, '2020-08-14 21:26:46', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (92, 25, 'engineer one-to-one web services', 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (93, 32, 'repurpose best-of-breed infomediaries', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (94, 30, 'morph dot-com applications', 'Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam. Nam tristique tortor eu pede.', '2021-01-08 16:31:16', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (95, 49, 'scale killer users', 'Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (96, 48, 'envisioneer cross-media niches', 'Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (97, 34, 'monetize bricks-and-clicks e-commerce', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem.', '2021-02-15 17:39:21', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (98, 9, 'cultivate seamless interfaces', 'Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis.', '2020-09-03 06:23:01', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (99, 12, 'enable interactive markets', null, '2020-07-12 03:08:52', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (100, 25, 'benchmark frictionless architectures', 'Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (101, 6, 'enhance impactful methodologies', null, '2020-04-14 10:05:00', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (102, 30, 'envisioneer leading-edge metrics', 'Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (103, 33, 'engineer collaborative technologies', 'Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', '2020-10-25 01:43:35', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (104, 24, 'expedite collaborative systems', 'Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (105, 43, 'brand 24/7 communities', 'Donec posuere metus vitae ipsum.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (106, 21, 'iterate rich web-readiness', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (107, 50, 'engineer plug-and-play initiatives', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (108, 24, 'cultivate holistic metrics', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (109, 47, 'maximize cross-media metrics', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst.', '2020-09-03 11:30:15', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (110, 43, 'optimize killer e-tailers', 'Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', '2020-10-25 23:00:46', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (111, 39, 'repurpose sticky convergence', 'Praesent id massa id nisl venenatis lacinia.', '2020-10-14 11:07:26', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (112, 14, 'embrace ubiquitous functionalities', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (113, 33, 'scale magnetic e-services', null, '2020-05-29 22:13:03', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (114, 12, 'synergize impactful experiences', null, '2020-04-07 09:24:47', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (115, 38, 'disintermediate seamless experiences', 'Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.', '2020-04-08 02:49:34', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (116, 43, 'enhance best-of-breed partnerships', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.', '2021-02-15 21:07:51', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (117, 18, 'monetize revolutionary mindshare', null, '2021-02-15 04:29:49', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (118, 21, 'innovate cutting-edge infomediaries', 'Curabitur convallis.', '2020-05-08 14:52:54', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (119, 48, 'architect virtual eyeballs', 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus.', '2020-06-15 07:25:31', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (120, 27, 'unleash synergistic vortals', null, '2020-06-28 13:34:46', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (121, 33, 'reintermediate wireless technologies', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (122, 5, 'expedite integrated eyeballs', null, '2020-10-01 23:17:52', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (123, 28, 'morph impactful functionalities', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.', '2020-06-04 07:08:23', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (124, 2, 'streamline global functionalities', null, '2021-01-28 07:41:23', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (125, 48, 'transition sticky deliverables', 'In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst.', '2021-01-25 22:33:53', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (126, 12, 'architect compelling schemas', 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo.', '2020-11-23 12:07:47', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (127, 7, 'empower customized e-markets', 'Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla.', '2020-09-13 08:40:32', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (128, 29, 'target intuitive interfaces', 'Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.', '2020-09-20 12:56:30', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (129, 18, 'morph sexy niches', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (130, 40, 'expedite customized architectures', 'Proin eu mi.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (131, 49, 'streamline synergistic niches', 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.', '2020-06-29 17:31:11', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (132, 6, 'expedite seamless platforms', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo.', '2021-02-19 06:12:04', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (133, 7, 'aggregate transparent synergies', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (134, 22, 'transition magnetic partnerships', 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (135, 11, 'syndicate open-source architectures', 'Mauris lacinia sapien quis libero.', '2020-06-23 00:05:10', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (136, 11, 'generate global communities', null, '2021-02-23 18:27:16', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (137, 17, 'transition wireless partnerships', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (138, 11, 'disintermediate leading-edge content', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (139, 33, 'matrix vertical relationships', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (140, 49, 'empower world-class methodologies', 'Pellentesque viverra pede ac diam.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (141, 5, 'cultivate user-centric solutions', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (142, 48, 'incentivize virtual solutions', 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2020-05-20 15:00:42', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (143, 44, 'deliver extensible interfaces', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien.', '2021-01-01 23:03:36', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (144, 32, 'integrate proactive infomediaries', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', '2020-12-17 12:35:18', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (145, 31, 'generate world-class experiences', 'Ut tellus. Nulla ut erat id mauris vulputate elementum.', '2020-04-17 00:59:44', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (146, 8, 'aggregate end-to-end web services', null, '2020-08-17 06:42:36', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (147, 16, 'reintermediate viral infrastructures', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', '2020-06-13 13:16:25', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (148, 24, 'reintermediate best-of-breed web-readiness', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (149, 43, 'e-enable real-time convergence', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.', '2021-02-16 13:22:14', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (150, 22, 'target leading-edge web-readiness', 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', '2020-07-08 03:21:49', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (151, 10, 'engage real-time niches', 'Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', '2020-05-23 20:04:04', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (152, 7, 'enhance open-source systems', null, '2020-03-26 07:26:19', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (153, 16, 'harness integrated markets', null, '2020-12-26 19:51:59', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (154, 5, 'matrix bricks-and-clicks web services', 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', '2020-04-18 17:57:21', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (155, 48, 'visualize B2C e-commerce', 'Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '2020-08-02 21:21:52', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (156, 13, 'optimize cutting-edge supply-chains', 'Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', '2021-03-03 00:47:24', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (157, 14, 'expedite world-class eyeballs', 'Pellentesque ultrices mattis odio.', '2020-11-02 03:23:31', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (158, 49, 'benchmark back-end technologies', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (159, 1, 'disintermediate frictionless synergies', 'Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (160, 38, 'envisioneer frictionless solutions', null, '2020-12-20 17:47:22', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (161, 50, 'whiteboard viral e-tailers', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', '2020-12-31 02:11:35', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (162, 47, 'strategize back-end architectures', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', '2020-07-20 04:03:11', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (163, 31, 'streamline open-source relationships', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (164, 5, 'implement world-class action-items', 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', '2020-11-12 10:09:48', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (165, 13, 'morph best-of-breed solutions', null, '2020-07-07 04:23:24', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (166, 23, 'innovate web-enabled interfaces', 'Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (167, 30, 'integrate innovative partnerships', 'Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (168, 32, 'synthesize killer methodologies', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', '2020-11-16 05:12:38', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (169, 50, 'recontextualize web-enabled channels', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio.', '2021-02-06 20:01:09', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (170, 50, 'harness 24/7 paradigms', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (171, 21, 'visualize 24/365 eyeballs', 'Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', '2021-02-08 17:39:12', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (172, 38, 'generate distributed applications', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (173, 1, 'strategize scalable niches', null, '2020-07-16 11:33:10', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (174, 27, 'utilize web-enabled channels', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (175, 42, 'transform e-business architectures', null, '2021-01-31 07:11:28', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (176, 2, 'maximize viral partnerships', null, '2020-07-13 22:43:22', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (177, 11, 'cultivate sticky infomediaries', null, '2020-12-05 05:39:09', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (178, 20, 'implement next-generation deliverables', 'Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (179, 25, 'embrace dynamic relationships', 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', '2020-10-12 10:25:51', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (180, 9, 'streamline granular platforms', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (181, 45, 'mesh one-to-one portals', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (182, 4, 'embrace visionary technologies', null, '2020-11-06 13:51:14', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (183, 1, 'harness cross-media communities', 'Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (184, 36, 'deliver open-source mindshare', null, '2020-08-15 21:38:18', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (185, 42, 'streamline visionary architectures', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.', '2020-06-29 03:16:44', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (186, 12, 'transform revolutionary platforms', null, '2020-05-07 20:18:24', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (187, 28, 'incubate virtual channels', 'Integer ac leo.', '2020-09-14 16:52:15', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (188, 30, 'transform web-enabled infomediaries', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.', '2021-02-15 03:51:06', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (189, 23, 'redefine best-of-breed deliverables', 'Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (190, 5, 'integrate next-generation e-markets', 'Nulla facilisi.', '2020-10-30 22:32:42', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (191, 45, 'reinvent customized initiatives', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (192, 19, 'deliver ubiquitous e-commerce', 'Donec vitae nisi.', '2020-07-27 11:14:53', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (193, 15, 'syndicate sticky models', 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', '2020-11-15 15:53:48', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (194, 16, 'expedite plug-and-play supply-chains', 'Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (195, 27, 'mesh frictionless methodologies', 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', '2020-11-16 04:46:35', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (196, 27, 'maximize ubiquitous channels', 'Nam nulla.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (197, 43, 'strategize efficient metrics', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', '2020-05-11 10:12:04', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (198, 7, 'maximize back-end eyeballs', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (199, 31, 'brand back-end convergence', 'Proin risus.', '2020-04-13 03:39:24', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (200, 33, 'whiteboard leading-edge niches', null, '2020-11-28 14:52:22', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (201, 41, 'extend cross-platform mindshare', null, '2020-09-30 15:54:48', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (202, 21, 'visualize plug-and-play convergence', 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (203, 19, 'facilitate enterprise e-business', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.', '2020-09-24 01:48:08', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (204, 17, 'generate seamless technologies', null, '2020-09-08 10:30:28', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (205, 27, 'transition integrated bandwidth', 'Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (206, 21, 'facilitate visionary relationships', null, '2020-03-27 08:02:07', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (207, 6, 'reintermediate enterprise partnerships', 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', '2020-04-11 15:56:17', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (208, 47, 'reinvent enterprise ROI', 'Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis.', '2021-02-01 18:47:27', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (209, 46, 'visualize proactive initiatives', null, '2020-09-28 05:53:08', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (210, 14, 'facilitate extensible solutions', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (211, 30, 'synthesize e-business partnerships', null, null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (212, 39, 'redefine frictionless e-markets', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (213, 6, 'engage dot-com e-business', null, '2020-11-26 16:32:39', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (214, 13, 'recontextualize turn-key portals', 'Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', '2020-07-28 10:50:49', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (215, 13, 'whiteboard virtual markets', 'In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', '2020-05-11 14:37:01', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (216, 40, 'optimize seamless e-markets', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (217, 31, 'monetize dynamic paradigms', 'Donec dapibus. Duis at velit eu est congue elementum.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (218, 10, 'productize rich networks', 'Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (219, 12, 'cultivate user-centric eyeballs', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (220, 22, 'whiteboard strategic functionalities', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.', '2021-03-08 03:09:39', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (221, 34, 'extend e-business paradigms', 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis.', '2020-04-18 20:22:50', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (222, 35, 'deploy world-class relationships', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (223, 39, 'envisioneer bleeding-edge metrics', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (224, 10, 'aggregate e-business partnerships', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.', '2020-09-18 09:01:56', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (225, 23, 'incubate killer bandwidth', 'Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.', '2020-09-18 03:53:35', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (226, 21, 'scale front-end systems', 'Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.', '2020-04-14 17:06:59', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (227, 20, 'target value-added users', null, '2020-08-06 21:23:06', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (228, 33, 'seize back-end partnerships', 'Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (229, 5, 'envisioneer impactful applications', null, '2020-12-17 19:11:24', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (230, 15, 'transform holistic platforms', 'Morbi porttitor lorem id ligula.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (231, 18, 'seize end-to-end functionalities', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla.', '2020-06-22 21:45:36', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (232, 15, 'disintermediate mission-critical web-readiness', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '2021-03-06 03:44:33', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (233, 34, 'extend 24/7 action-items', null, null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (234, 12, 'reintermediate front-end schemas', null, null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (235, 12, 'extend next-generation content', 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', '2020-08-28 07:46:50', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (236, 1, 'incentivize e-business web services', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (237, 16, 'deploy impactful architectures', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (238, 27, 'maximize B2B web services', 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (239, 39, 'repurpose integrated partnerships', 'Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (240, 14, 'synthesize B2B architectures', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.', '2020-08-06 14:56:22', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (241, 27, 'incentivize visionary bandwidth', null, '2021-01-13 03:10:28', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (242, 13, 'architect best-of-breed e-commerce', 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', '2021-03-14 14:42:44', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (243, 37, 'cultivate B2B bandwidth', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (244, 28, 'target magnetic infrastructures', 'In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (245, 3, 'utilize magnetic models', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (246, 40, 'whiteboard holistic interfaces', 'Aliquam non mauris. Morbi non lectus.', '2020-06-12 02:53:49', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (247, 1, 'aggregate virtual infomediaries', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (248, 9, 'utilize real-time e-commerce', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (249, 2, 'deliver transparent initiatives', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (250, 35, 'target seamless convergence', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo.', '2020-09-24 03:06:26', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (251, 24, 'enable ubiquitous convergence', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', '2020-10-06 21:07:18', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (252, 21, 'harness strategic channels', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (253, 29, 'deliver plug-and-play web services', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (254, 39, 'expedite scalable methodologies', null, '2020-07-04 05:06:03', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (255, 19, 'recontextualize B2C applications', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', '2020-06-03 13:07:02', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (256, 49, 'maximize 24/7 ROI', 'In est risus, auctor sed, tristique in, tempus sit amet, sem.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (257, 35, 'drive holistic e-business', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (258, 19, 'orchestrate e-business e-services', 'Nunc purus. Phasellus in felis. Donec semper sapien a libero.', '2020-06-10 07:35:39', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (259, 29, 'extend granular channels', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (260, 41, 'engage value-added networks', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '2020-08-28 02:18:49', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (261, 5, 'cultivate cross-media infomediaries', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', '2020-12-14 08:29:53', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (262, 30, 'generate intuitive platforms', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (263, 31, 'architect frictionless paradigms', 'Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '2020-07-20 20:40:43', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (264, 12, 'disintermediate extensible niches', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (265, 20, 'expedite magnetic e-services', 'Etiam faucibus cursus urna.', '2020-08-24 08:04:38', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (266, 44, 'benchmark collaborative applications', 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.', '2020-10-29 15:59:55', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (267, 25, 'envisioneer plug-and-play architectures', null, '2020-04-22 05:32:04', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (268, 2, 'recontextualize value-added solutions', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (269, 19, 'facilitate killer niches', null, '2020-07-02 22:09:35', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (270, 39, 'reintermediate front-end systems', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.', '2020-07-18 19:41:18', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (271, 20, 'implement transparent infomediaries', 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (272, 48, 'synthesize turn-key vortals', 'Nunc nisl.', '2020-05-24 15:50:02', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (273, 12, 'reinvent interactive platforms', 'Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (274, 40, 'benchmark sexy action-items', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (275, 35, 'iterate dynamic platforms', null, '2020-05-17 16:01:15', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (276, 47, 'drive synergistic e-tailers', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (277, 12, 'drive web-enabled methodologies', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', '2020-07-27 20:27:15', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (278, 23, 'scale efficient solutions', 'Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.', '2020-11-01 23:09:10', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (279, 7, 'revolutionize out-of-the-box synergies', null, '2020-11-25 08:33:05', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (280, 7, 'revolutionize front-end paradigms', 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', '2021-02-03 00:26:39', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (281, 15, 'benchmark synergistic web-readiness', 'Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (282, 23, 'disintermediate virtual web services', 'Aenean lectus. Pellentesque eget nunc.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (283, 11, 'optimize holistic mindshare', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (284, 15, 'scale back-end eyeballs', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.', '2020-06-29 18:00:22', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (285, 19, 'expedite mission-critical paradigms', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', '2020-06-29 03:47:40', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (286, 30, 'expedite mission-critical relationships', 'Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (287, 24, 'transform virtual e-business', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', '2020-07-21 23:56:13', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (288, 21, 'transform collaborative action-items', 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '2021-01-16 20:51:59', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (289, 16, 'incentivize leading-edge channels', 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.', '2020-04-27 14:31:32', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (290, 39, 'aggregate cross-platform convergence', 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (291, 25, 'synthesize B2C platforms', 'Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', '2021-01-16 02:21:07', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (292, 47, 'drive strategic portals', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (293, 7, 'envisioneer dynamic eyeballs', 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (294, 40, 'reintermediate distributed relationships', null, '2020-05-11 22:38:26', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (295, 33, 'deploy synergistic systems', null, '2020-09-12 00:08:51', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (296, 20, 'synergize cutting-edge applications', 'Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.', '2021-01-24 11:43:22', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (297, 11, 'leverage enterprise infomediaries', 'Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.', '2020-08-16 00:32:40', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (298, 29, 'matrix sticky web services', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (299, 13, 'maximize magnetic portals', null, '2020-06-02 20:12:05', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (300, 20, 'engineer cross-platform deliverables', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', '2020-10-05 05:18:57', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (301, 47, 'morph extensible bandwidth', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus.', '2020-11-02 17:34:00', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (302, 9, 'visualize compelling models', null, null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (303, 19, 'whiteboard distributed channels', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (304, 34, 'matrix out-of-the-box deliverables', 'Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (305, 26, 'syndicate B2C networks', 'Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (306, 47, 'revolutionize end-to-end architectures', 'Aliquam erat volutpat. In congue.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (307, 6, 'harness intuitive vortals', null, '2020-11-27 09:31:24', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (308, 49, 'implement user-centric relationships', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.', '2020-04-21 06:06:08', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (309, 2, 'seize virtual supply-chains', null, null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (310, 30, 'streamline 24/7 e-business', null, '2020-09-02 11:24:45', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (311, 20, 'enable front-end interfaces', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (312, 24, 'iterate back-end relationships', 'Proin risus. Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend.', '2020-09-05 17:43:30', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (313, 30, 'morph back-end synergies', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (314, 20, 'synthesize bleeding-edge content', null, '2020-12-04 10:54:03', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (315, 4, 'reintermediate dynamic methodologies', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (316, 35, 'visualize revolutionary e-markets', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (317, 13, 'visualize next-generation applications', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (318, 44, 'deliver revolutionary architectures', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo.', '2020-08-13 15:03:17', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (319, 44, 'architect sexy e-commerce', 'Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (320, 4, 'strategize innovative mindshare', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (321, 9, 'scale dot-com metrics', 'Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (322, 35, 'monetize end-to-end content', null, '2020-11-25 22:47:04', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (323, 45, 'incentivize B2C portals', null, '2020-06-25 23:06:48', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (324, 19, 'incubate bricks-and-clicks metrics', 'Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (325, 41, 'envisioneer value-added channels', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (326, 42, 'strategize sticky mindshare', 'Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (327, 17, 'incentivize virtual action-items', null, '2020-04-10 23:23:53', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (328, 33, 'engineer wireless niches', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (329, 5, 'grow one-to-one initiatives', 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (330, 6, 'harness visionary communities', 'Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', '2020-05-13 18:28:06', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (331, 39, 'utilize robust deliverables', 'Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '2020-05-13 12:06:48', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (332, 47, 'expedite scalable relationships', 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '2020-04-03 08:07:57', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (333, 12, 'deploy intuitive web-readiness', 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis.', '2021-01-26 12:18:45', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (334, 23, 'target cross-media infrastructures', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (335, 23, 'transform compelling partnerships', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', '2020-12-15 09:18:05', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (336, 45, 'reintermediate distributed platforms', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', '2020-10-03 20:46:45', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (337, 18, 'deliver plug-and-play functionalities', null, '2021-01-20 23:25:53', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (338, 45, 'integrate customized initiatives', 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2020-11-05 16:57:09', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (339, 4, 'deploy plug-and-play e-services', null, '2020-06-14 12:30:09', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (340, 12, 'enhance dot-com communities', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (341, 2, 'maximize scalable supply-chains', 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (342, 31, 'e-enable B2C paradigms', 'In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum.', '2020-06-16 06:17:49', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (343, 39, 'drive real-time vortals', 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (344, 29, 'maximize interactive networks', null, '2021-02-20 16:40:17', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (345, 19, 'monetize holistic supply-chains', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (346, 50, 'repurpose visionary vortals', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (347, 18, 'synergize sexy methodologies', 'Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.', '2021-01-02 19:07:37', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (348, 6, 'implement plug-and-play markets', 'In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', '2020-07-28 21:42:14', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (349, 4, 'deliver bleeding-edge e-services', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (350, 47, 'implement sticky paradigms', 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', '2020-11-06 21:34:31', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (351, 34, 'generate strategic portals', null, '2020-11-22 23:02:31', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (352, 4, 'iterate viral synergies', null, '2020-09-15 02:39:30', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (353, 2, 'redefine intuitive supply-chains', 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (354, 2, 'productize B2C e-tailers', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (355, 16, 'enable visionary functionalities', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2021-03-16 15:07:32', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (356, 18, 'reinvent mission-critical web services', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (357, 40, 'deliver proactive synergies', 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (358, 20, 'brand extensible mindshare', 'Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '2020-05-28 08:43:07', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (359, 41, 'cultivate 24/7 web services', 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (360, 44, 'enhance intuitive e-business', null, null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (361, 44, 'matrix frictionless markets', null, '2020-06-02 06:10:25', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (362, 8, 'aggregate sexy e-tailers', 'Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio.', '2021-01-08 18:56:43', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (363, 47, 'morph cutting-edge e-tailers', 'Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (364, 48, 'cultivate seamless users', null, '2020-11-22 23:04:26', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (365, 19, 'incentivize frictionless supply-chains', null, '2020-04-02 18:46:13', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (366, 1, 'streamline back-end functionalities', 'Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '2020-12-17 03:40:02', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (367, 29, 'target intuitive e-markets', 'Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.', '2020-12-05 11:46:08', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (368, 5, 'aggregate wireless technologies', null, null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (369, 7, 'facilitate sexy supply-chains', 'Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', '2021-03-24 13:12:47', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (370, 44, 'scale open-source functionalities', 'Quisque ut erat.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (371, 44, 'harness user-centric methodologies', 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius.', '2020-06-09 20:09:28', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (372, 8, 'streamline extensible systems', null, '2020-07-25 07:24:57', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (373, 9, 'matrix user-centric platforms', null, '2020-04-01 23:16:06', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (374, 33, 'leverage sticky synergies', 'Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (375, 40, 'implement integrated networks', null, '2020-04-18 09:01:52', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (376, 16, 'expedite ubiquitous eyeballs', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', '2020-12-10 10:53:39', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (377, 15, 'optimize proactive deliverables', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (378, 8, 'implement scalable deliverables', 'Aenean lectus. Pellentesque eget nunc.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (379, 34, 'synergize 24/365 niches', null, null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (380, 31, 'synergize B2C mindshare', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (381, 44, 'architect turn-key eyeballs', 'Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia.', '2020-08-24 16:32:28', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (382, 12, 'reintermediate bleeding-edge convergence', 'Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.', '2020-10-27 01:29:54', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (383, 19, 'strategize turn-key niches', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '2020-10-12 15:50:07', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (384, 7, 'integrate front-end networks', null, null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (385, 1, 'facilitate out-of-the-box users', 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst.', '2020-08-06 01:03:36', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (386, 2, 'whiteboard customized interfaces', 'Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', '2021-02-24 03:41:22', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (387, 1, 'e-enable dot-com convergence', 'Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (388, 47, 'implement out-of-the-box functionalities', null, null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (389, 44, 'reinvent visionary e-tailers', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.', '2021-01-14 19:09:36', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (390, 32, 'innovate viral relationships', 'Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (391, 19, 'syndicate bleeding-edge initiatives', 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (392, 49, 'aggregate clicks-and-mortar architectures', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (393, 11, 'expedite wireless e-business', 'Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '2020-05-01 23:27:23', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (394, 45, 'enable web-enabled functionalities', 'Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', '2020-04-23 21:23:22', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (395, 9, 'transition world-class applications', 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.', '2020-10-12 17:57:56', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (396, 3, 'leverage turn-key technologies', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', '2020-05-31 10:58:10', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (397, 8, 'incentivize granular web services', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (398, 16, 'architect best-of-breed relationships', 'Vestibulum sed magna at nunc commodo placerat.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (399, 45, 'synthesize leading-edge bandwidth', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (400, 31, 'productize turn-key eyeballs', 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante.', '2020-06-29 04:35:27', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (401, 46, 'synthesize next-generation infrastructures', 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.', '2020-11-01 09:26:21', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (402, 19, 'facilitate B2B partnerships', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.', '2020-06-08 09:24:06', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (403, 18, 'visualize magnetic eyeballs', 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis.', '2020-09-09 01:06:19', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (404, 46, 'maximize scalable technologies', 'Integer a nibh. In quis justo.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (405, 44, 'reinvent integrated action-items', 'Aenean sit amet justo. Morbi ut odio.', '2020-04-19 17:08:03', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (406, 28, 'transition dot-com vortals', 'Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', '2020-11-03 20:08:14', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (407, 47, 'drive out-of-the-box technologies', null, '2020-12-28 11:15:03', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (408, 45, 'architect proactive functionalities', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '2020-11-28 21:55:17', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (409, 23, 'mesh bricks-and-clicks deliverables', null, '2020-12-01 21:49:03', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (410, 17, 'disintermediate extensible schemas', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.', '2020-04-11 08:26:07', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (411, 12, 'whiteboard front-end convergence', null, '2020-12-17 06:09:56', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (412, 34, 'recontextualize front-end systems', 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus.', '2020-12-09 00:34:54', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (413, 6, 'aggregate real-time communities', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (414, 34, 'transition B2B partnerships', 'Nam tristique tortor eu pede.', '2020-10-07 21:11:31', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (415, 3, 'morph leading-edge relationships', 'Praesent blandit.', '2020-09-16 00:47:57', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (416, 27, 'evolve interactive e-commerce', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (417, 31, 'envisioneer viral infrastructures', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (418, 44, 'benchmark revolutionary methodologies', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (419, 29, 'utilize mission-critical e-commerce', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (420, 27, 'morph value-added methodologies', 'Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (421, 46, 'exploit magnetic synergies', 'Ut at dolor quis odio consequat varius.', '2021-01-31 16:21:33', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (422, 4, 'disintermediate holistic e-markets', 'Mauris lacinia sapien quis libero.', '2020-04-07 17:25:39', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (423, 4, 'extend end-to-end architectures', 'Etiam justo. Etiam pretium iaculis justo.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (424, 26, 'seize intuitive e-business', 'Fusce consequat.', '2020-10-14 18:51:05', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (425, 1, 'orchestrate e-business platforms', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti.', '2020-04-24 13:40:21', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (426, 14, 'extend sexy web services', null, '2020-09-22 07:32:34', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (427, 44, 'engineer cross-platform experiences', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (428, 14, 'grow customized interfaces', 'Aenean sit amet justo.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (429, 20, 'mesh bleeding-edge web-readiness', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.', '2021-02-06 11:51:58', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (430, 40, 'aggregate killer ROI', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (431, 49, 'transform clicks-and-mortar functionalities', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (432, 21, 'disintermediate efficient synergies', null, '2021-01-30 06:43:07', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (433, 35, 'innovate bleeding-edge markets', 'Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (434, 9, 'evolve next-generation synergies', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue.', '2020-07-19 07:35:43', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (435, 44, 'visualize compelling initiatives', 'Praesent blandit. Nam nulla.', '2021-02-03 06:53:37', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (436, 11, 'brand end-to-end users', 'Cras pellentesque volutpat dui.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (437, 43, 'enhance one-to-one platforms', 'Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (438, 7, 'deploy leading-edge partnerships', null, '2020-04-19 09:04:10', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (439, 9, 'optimize web-enabled functionalities', 'In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', '2020-05-08 18:44:10', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (440, 30, 'e-enable back-end supply-chains', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (441, 12, 'matrix next-generation initiatives', 'Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', '2020-10-10 14:08:00', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (442, 17, 'benchmark B2B niches', 'Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (443, 20, 'enable value-added systems', 'Maecenas tincidunt lacus at velit.', '2020-10-18 18:14:49', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (444, 1, 'cultivate efficient interfaces', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (445, 29, 'architect sexy interfaces', null, '2020-06-04 02:00:05', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (446, 14, 'utilize cutting-edge e-commerce', 'Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (447, 9, 'exploit 24/365 paradigms', 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (448, 20, 'maximize robust supply-chains', 'Fusce consequat. Nulla nisl.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (449, 13, 'disintermediate sticky platforms', null, null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (450, 41, 'matrix one-to-one e-markets', null, '2020-10-20 06:15:56', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (451, 43, 'deploy synergistic portals', 'In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', '2020-11-20 13:41:19', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (452, 42, 'utilize world-class experiences', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (453, 40, 'streamline granular paradigms', 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '2021-01-12 07:16:58', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (454, 31, 'seize intuitive users', 'Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (455, 49, 'utilize front-end methodologies', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.', '2020-09-23 02:58:39', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (456, 3, 'matrix front-end web-readiness', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (457, 18, 'embrace rich eyeballs', null, '2020-04-08 04:52:42', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (458, 18, 'empower bricks-and-clicks applications', null, '2021-01-24 19:54:41', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (459, 11, 'utilize cutting-edge deliverables', 'Quisque porta volutpat erat.', '2020-12-15 15:14:39', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (460, 16, 'deploy back-end action-items', 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (461, 25, 'brand cutting-edge convergence', 'Nullam molestie nibh in lectus.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (462, 24, 'deploy virtual content', null, '2020-10-16 16:05:55', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (463, 4, 'whiteboard frictionless experiences', null, '2020-08-27 20:51:51', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (464, 23, 'mesh next-generation platforms', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.', '2020-04-23 23:54:38', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (465, 33, 'envisioneer frictionless e-tailers', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.', '2020-09-09 20:11:50', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (466, 24, 'aggregate B2C web-readiness', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '2020-08-19 06:18:37', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (467, 24, 'engineer bleeding-edge portals', 'Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.', '2020-05-01 14:35:39', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (468, 27, 'orchestrate sticky experiences', null, '2020-04-06 07:11:41', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (469, 20, 'embrace real-time users', 'Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (470, 22, 'disintermediate clicks-and-mortar initiatives', null, '2020-05-17 04:04:59', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (471, 31, 'deliver web-enabled communities', 'Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.', '2020-11-24 06:32:53', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (472, 4, 'scale ubiquitous partnerships', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (473, 44, 'matrix extensible bandwidth', 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', '2020-11-08 19:36:39', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (474, 33, 'utilize front-end markets', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.', '2020-12-21 21:38:10', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (475, 40, 'redefine plug-and-play communities', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', '2020-09-26 08:54:26', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (476, 37, 'morph plug-and-play mindshare', 'Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '2020-05-13 19:10:16', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (477, 2, 'optimize ubiquitous networks', 'Donec ut dolor.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (478, 2, 'architect granular users', 'Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (479, 25, 'incubate out-of-the-box supply-chains', null, null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (480, 34, 'reintermediate 24/365 channels', 'Nulla nisl.', '2020-08-22 03:05:40', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (481, 50, 'synergize front-end markets', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (482, 18, 'seize revolutionary systems', 'Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (483, 32, 'synthesize cross-media markets', 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (484, 40, 'architect intuitive infrastructures', null, '2020-06-10 11:24:30', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (485, 11, 'synthesize dynamic e-services', 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (486, 48, 'implement enterprise partnerships', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', '2020-09-15 16:34:53', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (487, 38, 'target 24/365 interfaces', 'Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (488, 49, 'morph intuitive deliverables', 'Morbi a ipsum. Integer a nibh. In quis justo.', null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (489, 24, 'empower best-of-breed schemas', 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit.', '2020-08-26 23:26:31', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (490, 1, 'architect virtual schemas', 'Nullam porttitor lacus at turpis.', '2021-02-06 11:37:14', 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (491, 35, 'extend holistic solutions', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', null, 'Waiting');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (492, 14, 'repurpose vertical functionalities', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.', '2021-03-15 19:39:34', 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (493, 41, 'whiteboard one-to-one interfaces', 'Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (494, 2, 'implement sexy metrics', null, null, 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (495, 37, 'mesh compelling e-markets', 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.', '2021-01-31 20:40:18', 'In Progress');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (496, 21, 'incubate cross-platform synergies', 'Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', null, 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (497, 26, 'transform real-time mindshare', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2020-08-27 03:59:39', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (498, 12, 'innovate leading-edge convergence', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.', '2020-05-26 00:53:03', 'Completed');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (499, 12, 'monetize synergistic convergence', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', null, 'Not Started');
INSERT INTO task (id, project, name, description, due_date, task_status) VALUES (500, 44, 'repurpose leading-edge web-readiness', 'Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam.', null, 'In Progress');


-- Subtask

INSERT INTO subtask (id, parent) VALUES (1, 479);
INSERT INTO subtask (id, parent) VALUES (2, 399);
INSERT INTO subtask (id, parent) VALUES (5, 81);
INSERT INTO subtask (id, parent) VALUES (6, 209);
INSERT INTO subtask (id, parent) VALUES (13, 253);
INSERT INTO subtask (id, parent) VALUES (16, 196);
INSERT INTO subtask (id, parent) VALUES (27, 421);
INSERT INTO subtask (id, parent) VALUES (28, 243);
INSERT INTO subtask (id, parent) VALUES (30, 344);
INSERT INTO subtask (id, parent) VALUES (33, 204);
INSERT INTO subtask (id, parent) VALUES (35, 490);
INSERT INTO subtask (id, parent) VALUES (39, 202);
INSERT INTO subtask (id, parent) VALUES (41, 104);
INSERT INTO subtask (id, parent) VALUES (45, 361);
INSERT INTO subtask (id, parent) VALUES (47, 388);
INSERT INTO subtask (id, parent) VALUES (50, 235);
INSERT INTO subtask (id, parent) VALUES (57, 284);
INSERT INTO subtask (id, parent) VALUES (59, 400);
INSERT INTO subtask (id, parent) VALUES (62, 335);
INSERT INTO subtask (id, parent) VALUES (79, 120);
INSERT INTO subtask (id, parent) VALUES (82, 415);
INSERT INTO subtask (id, parent) VALUES (83, 243);
INSERT INTO subtask (id, parent) VALUES (84, 151);
INSERT INTO subtask (id, parent) VALUES (85, 303);
INSERT INTO subtask (id, parent) VALUES (87, 265);
INSERT INTO subtask (id, parent) VALUES (88, 483);
INSERT INTO subtask (id, parent) VALUES (91, 279);
INSERT INTO subtask (id, parent) VALUES (100, 479);
INSERT INTO subtask (id, parent) VALUES (116, 437);
INSERT INTO subtask (id, parent) VALUES (122, 368);
INSERT INTO subtask (id, parent) VALUES (123, 406);
INSERT INTO subtask (id, parent) VALUES (135, 436);
INSERT INTO subtask (id, parent) VALUES (142, 486);
INSERT INTO subtask (id, parent) VALUES (146, 397);
INSERT INTO subtask (id, parent) VALUES (148, 467);
INSERT INTO subtask (id, parent) VALUES (151, 224);
INSERT INTO subtask (id, parent) VALUES (158, 256);
INSERT INTO subtask (id, parent) VALUES (159, 173);
INSERT INTO subtask (id, parent) VALUES (163, 454);
INSERT INTO subtask (id, parent) VALUES (164, 261);
INSERT INTO subtask (id, parent) VALUES (166, 278);
INSERT INTO subtask (id, parent) VALUES (173, 490);
INSERT INTO subtask (id, parent) VALUES (176, 353);
INSERT INTO subtask (id, parent) VALUES (178, 271);
INSERT INTO subtask (id, parent) VALUES (180, 373);
INSERT INTO subtask (id, parent) VALUES (185, 452);
INSERT INTO subtask (id, parent) VALUES (187, 244);
INSERT INTO subtask (id, parent) VALUES (193, 230);
INSERT INTO subtask (id, parent) VALUES (207, 213);
INSERT INTO subtask (id, parent) VALUES (208, 292);
INSERT INTO subtask (id, parent) VALUES (210, 240);
INSERT INTO subtask (id, parent) VALUES (212, 290);
INSERT INTO subtask (id, parent) VALUES (219, 498);
INSERT INTO subtask (id, parent) VALUES (221, 233);
INSERT INTO subtask (id, parent) VALUES (222, 275);
INSERT INTO subtask (id, parent) VALUES (228, 295);
INSERT INTO subtask (id, parent) VALUES (231, 458);
INSERT INTO subtask (id, parent) VALUES (233, 480);
INSERT INTO subtask (id, parent) VALUES (237, 376);
INSERT INTO subtask (id, parent) VALUES (243, 495);
INSERT INTO subtask (id, parent) VALUES (253, 259);
INSERT INTO subtask (id, parent) VALUES (272, 364);
INSERT INTO subtask (id, parent) VALUES (275, 316);
INSERT INTO subtask (id, parent) VALUES (279, 280);
INSERT INTO subtask (id, parent) VALUES (280, 384);
INSERT INTO subtask (id, parent) VALUES (282, 464);
INSERT INTO subtask (id, parent) VALUES (289, 460);
INSERT INTO subtask (id, parent) VALUES (304, 480);
INSERT INTO subtask (id, parent) VALUES (306, 350);
INSERT INTO subtask (id, parent) VALUES (310, 313);
INSERT INTO subtask (id, parent) VALUES (318, 473);
INSERT INTO subtask (id, parent) VALUES (322, 491);
INSERT INTO subtask (id, parent) VALUES (325, 359);
INSERT INTO subtask (id, parent) VALUES (337, 482);
INSERT INTO subtask (id, parent) VALUES (357, 375);
INSERT INTO subtask (id, parent) VALUES (361, 435);
INSERT INTO subtask (id, parent) VALUES (365, 383);
INSERT INTO subtask (id, parent) VALUES (380, 400);
INSERT INTO subtask (id, parent) VALUES (390, 483);
INSERT INTO subtask (id, parent) VALUES (463, 472);


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

INSERT INTO tag (id, project, name, color) VALUES (1, 47, 'client-server', '#9d8ad3');
INSERT INTO tag (id, project, name, color) VALUES (2, 8, 'Cross-platform', '#025181');
INSERT INTO tag (id, project, name, color) VALUES (3, 11, 'cohesive', '#970123');
INSERT INTO tag (id, project, name, color) VALUES (4, 20, 'throughput', '#a1d0db');
INSERT INTO tag (id, project, name, color) VALUES (5, 4, 'Re-engineered', '#b1c9a5');
INSERT INTO tag (id, project, name, color) VALUES (6, 1, 'Function-based', '#67d49b');
INSERT INTO tag (id, project, name, color) VALUES (7, 11, 'Re-engineered', '#c0f9bd');
INSERT INTO tag (id, project, name, color) VALUES (8, 4, 'User-centric', '#8b0a8d');
INSERT INTO tag (id, project, name, color) VALUES (9, 8, 'non-volatile', '#14030d');
INSERT INTO tag (id, project, name, color) VALUES (10, 33, 'capability', '#3a107b');
INSERT INTO tag (id, project, name, color) VALUES (11, 19, 'capability', '#fd8a20');
INSERT INTO tag (id, project, name, color) VALUES (12, 40, 'needs-based', '#d84136');
INSERT INTO tag (id, project, name, color) VALUES (13, 13, 'Integrated', '#23d8a1');
INSERT INTO tag (id, project, name, color) VALUES (14, 25, 'solution-oriented', '#f68e33');
INSERT INTO tag (id, project, name, color) VALUES (15, 20, 'Persistent', '#4fc15c');
INSERT INTO tag (id, project, name, color) VALUES (16, 44, 'parallelism', '#6e80ef');
INSERT INTO tag (id, project, name, color) VALUES (17, 39, 'system engine', '#a01517');
INSERT INTO tag (id, project, name, color) VALUES (18, 40, '4th generation', '#6a97d0');
INSERT INTO tag (id, project, name, color) VALUES (19, 22, 'system-worthy', '#2af6d3');
INSERT INTO tag (id, project, name, color) VALUES (20, 7, 'contingency', '#0b1834');
INSERT INTO tag (id, project, name, color) VALUES (21, 41, 'reciprocal', '#45591d');
INSERT INTO tag (id, project, name, color) VALUES (22, 40, 'Cloned', '#e9917b');
INSERT INTO tag (id, project, name, color) VALUES (23, 42, 'structure', '#604e40');
INSERT INTO tag (id, project, name, color) VALUES (24, 7, 'encoding', '#8a4b4e');
INSERT INTO tag (id, project, name, color) VALUES (25, 20, 'collaboration', '#1c2b4b');
INSERT INTO tag (id, project, name, color) VALUES (26, 47, 'optimizing', '#f53110');
INSERT INTO tag (id, project, name, color) VALUES (27, 20, 'solution', '#be79c7');
INSERT INTO tag (id, project, name, color) VALUES (28, 37, 'knowledge user', '#941ae7');
INSERT INTO tag (id, project, name, color) VALUES (29, 4, 'Advanced', '#33039a');
INSERT INTO tag (id, project, name, color) VALUES (30, 29, 'Automated', '#694e86');
INSERT INTO tag (id, project, name, color) VALUES (31, 12, 'Phased', '#a22c66');
INSERT INTO tag (id, project, name, color) VALUES (32, 29, 'task-force', '#12420a');
INSERT INTO tag (id, project, name, color) VALUES (33, 28, 'service-desk', '#c2f318');
INSERT INTO tag (id, project, name, color) VALUES (34, 49, 'coherent', '#d64fcc');
INSERT INTO tag (id, project, name, color) VALUES (35, 44, 'projection', '#bfa147');
INSERT INTO tag (id, project, name, color) VALUES (36, 17, 'knowledge user', '#24a705');
INSERT INTO tag (id, project, name, color) VALUES (37, 35, 'Triple-buffered', '#ad2f00');
INSERT INTO tag (id, project, name, color) VALUES (38, 7, 'Automated', '#4a73f3');
INSERT INTO tag (id, project, name, color) VALUES (39, 27, 'background', '#3c2f02');
INSERT INTO tag (id, project, name, color) VALUES (40, 30, 'attitude-oriented', '#4a513c');
INSERT INTO tag (id, project, name, color) VALUES (41, 5, 'eco-centric', '#fc4fde');
INSERT INTO tag (id, project, name, color) VALUES (42, 10, 'exuding', '#dacc23');
INSERT INTO tag (id, project, name, color) VALUES (43, 14, 'Realigned', '#f29485');
INSERT INTO tag (id, project, name, color) VALUES (44, 8, 'firmware', '#e9aaa3');
INSERT INTO tag (id, project, name, color) VALUES (45, 10, 'user-facing', '#520003');
INSERT INTO tag (id, project, name, color) VALUES (46, 49, 'methodology', '#35aed7');
INSERT INTO tag (id, project, name, color) VALUES (47, 34, 'analyzing', '#487d35');
INSERT INTO tag (id, project, name, color) VALUES (48, 50, 'adapter', '#726c32');
INSERT INTO tag (id, project, name, color) VALUES (49, 16, 'Synergistic', '#337e5a');
INSERT INTO tag (id, project, name, color) VALUES (50, 3, 'collaboration', '#1e635e');
INSERT INTO tag (id, project, name, color) VALUES (51, 32, 'website', '#e55f6d');
INSERT INTO tag (id, project, name, color) VALUES (52, 10, 'synergy', '#1a0760');
INSERT INTO tag (id, project, name, color) VALUES (53, 13, 'empowering', '#9ece40');
INSERT INTO tag (id, project, name, color) VALUES (54, 47, 'stable', '#afd8f1');
INSERT INTO tag (id, project, name, color) VALUES (55, 48, 'model', '#f86707');
INSERT INTO tag (id, project, name, color) VALUES (56, 49, 'focus group', '#55b3b9');
INSERT INTO tag (id, project, name, color) VALUES (57, 40, 'Open-source', '#5d560b');
INSERT INTO tag (id, project, name, color) VALUES (58, 28, 'radical', '#60d335');
INSERT INTO tag (id, project, name, color) VALUES (59, 49, 'Compatible', '#118e9d');
INSERT INTO tag (id, project, name, color) VALUES (60, 44, 'help-desk', '#bb94ce');
INSERT INTO tag (id, project, name, color) VALUES (61, 3, 'software', '#ac8adb');
INSERT INTO tag (id, project, name, color) VALUES (62, 36, 'User-centric', '#4d0db7');
INSERT INTO tag (id, project, name, color) VALUES (63, 13, 'Open-source', '#d34af3');
INSERT INTO tag (id, project, name, color) VALUES (64, 26, 'Reverse-engineered', '#31f13a');
INSERT INTO tag (id, project, name, color) VALUES (65, 2, 'grid-enabled', '#d3faca');
INSERT INTO tag (id, project, name, color) VALUES (66, 45, 'background', '#c814ab');
INSERT INTO tag (id, project, name, color) VALUES (67, 37, 'process improvement', '#a42cd9');
INSERT INTO tag (id, project, name, color) VALUES (68, 23, 'Phased', '#488369');
INSERT INTO tag (id, project, name, color) VALUES (69, 26, 'website', '#3202fe');
INSERT INTO tag (id, project, name, color) VALUES (70, 20, 'object-oriented', '#c33f70');
INSERT INTO tag (id, project, name, color) VALUES (71, 44, 'user-facing', '#0e0d12');
INSERT INTO tag (id, project, name, color) VALUES (72, 50, 'value-added', '#e74487');
INSERT INTO tag (id, project, name, color) VALUES (73, 37, 'capability', '#d14605');
INSERT INTO tag (id, project, name, color) VALUES (74, 4, 'Robust', '#33b60e');
INSERT INTO tag (id, project, name, color) VALUES (75, 21, 'Seamless', '#8b098d');
INSERT INTO tag (id, project, name, color) VALUES (76, 22, 'real-time', '#1b0006');
INSERT INTO tag (id, project, name, color) VALUES (77, 13, 'Organized', '#2709ef');
INSERT INTO tag (id, project, name, color) VALUES (78, 9, 'Programmable', '#b34110');
INSERT INTO tag (id, project, name, color) VALUES (79, 48, 'productivity', '#4cf314');
INSERT INTO tag (id, project, name, color) VALUES (80, 30, 'methodology', '#682ed9');
INSERT INTO tag (id, project, name, color) VALUES (81, 21, 'maximized', '#7b6d68');
INSERT INTO tag (id, project, name, color) VALUES (82, 42, 'methodical', '#d6d8c5');
INSERT INTO tag (id, project, name, color) VALUES (83, 5, 'Robust', '#5ccc7b');
INSERT INTO tag (id, project, name, color) VALUES (84, 29, 'exuding', '#1e52ba');
INSERT INTO tag (id, project, name, color) VALUES (85, 15, 'instruction set', '#965c48');
INSERT INTO tag (id, project, name, color) VALUES (86, 35, 'dedicated', '#9cc108');
INSERT INTO tag (id, project, name, color) VALUES (87, 10, '4th generation', '#138832');
INSERT INTO tag (id, project, name, color) VALUES (88, 46, 'task-force', '#aba2d0');
INSERT INTO tag (id, project, name, color) VALUES (89, 48, 'pricing structure', '#b53111');
INSERT INTO tag (id, project, name, color) VALUES (90, 13, 'logistical', '#f699bd');
INSERT INTO tag (id, project, name, color) VALUES (91, 11, 'uniform', '#6860d9');
INSERT INTO tag (id, project, name, color) VALUES (92, 27, 'definition', '#50e583');
INSERT INTO tag (id, project, name, color) VALUES (93, 17, 'Visionary', '#0e3b86');
INSERT INTO tag (id, project, name, color) VALUES (94, 24, 'Balanced', '#3ae926');
INSERT INTO tag (id, project, name, color) VALUES (95, 46, 'leverage', '#b1708e');
INSERT INTO tag (id, project, name, color) VALUES (96, 47, 'eco-centric', '#21bf51');
INSERT INTO tag (id, project, name, color) VALUES (97, 23, '5th generation', '#a602f3');
INSERT INTO tag (id, project, name, color) VALUES (98, 13, 'global', '#fe222d');
INSERT INTO tag (id, project, name, color) VALUES (99, 47, 'multi-tasking', '#032a8f');
INSERT INTO tag (id, project, name, color) VALUES (100, 17, 'internet solution', '#96b362');
INSERT INTO tag (id, project, name, color) VALUES (101, 5, 'stable', '#4fcc44');
INSERT INTO tag (id, project, name, color) VALUES (102, 49, 'Reactive', '#fb4c1d');
INSERT INTO tag (id, project, name, color) VALUES (103, 23, 'even-keeled', '#d97cb0');
INSERT INTO tag (id, project, name, color) VALUES (104, 6, 'Fundamental', '#9e1514');
INSERT INTO tag (id, project, name, color) VALUES (105, 46, 'Open-architected', '#301079');
INSERT INTO tag (id, project, name, color) VALUES (106, 35, 'Future-proofed', '#92be74');
INSERT INTO tag (id, project, name, color) VALUES (107, 23, 'modular', '#10f235');
INSERT INTO tag (id, project, name, color) VALUES (108, 30, 'Fundamental', '#d2ff4c');
INSERT INTO tag (id, project, name, color) VALUES (109, 31, 'Programmable', '#52194c');
INSERT INTO tag (id, project, name, color) VALUES (110, 7, 'neutral', '#1aa159');
INSERT INTO tag (id, project, name, color) VALUES (111, 22, 'product', '#5cb7fa');
INSERT INTO tag (id, project, name, color) VALUES (112, 4, 'data-warehouse', '#79d4ad');
INSERT INTO tag (id, project, name, color) VALUES (113, 7, '3rd generation', '#ceaf59');
INSERT INTO tag (id, project, name, color) VALUES (114, 45, 'policy', '#2e98af');
INSERT INTO tag (id, project, name, color) VALUES (115, 23, 'Reduced', '#951643');
INSERT INTO tag (id, project, name, color) VALUES (116, 44, 'project', '#70e44d');
INSERT INTO tag (id, project, name, color) VALUES (117, 44, 'transitional', '#69b2d2');
INSERT INTO tag (id, project, name, color) VALUES (118, 45, 'Fundamental', '#26db1d');
INSERT INTO tag (id, project, name, color) VALUES (119, 14, 'fresh-thinking', '#84f233');
INSERT INTO tag (id, project, name, color) VALUES (120, 10, 'synergy', '#ed3ffb');
INSERT INTO tag (id, project, name, color) VALUES (121, 47, 'encompassing', '#d4403e');
INSERT INTO tag (id, project, name, color) VALUES (122, 37, 'Quality-focused', '#53ab30');
INSERT INTO tag (id, project, name, color) VALUES (123, 24, 'client-driven', '#d4e623');
INSERT INTO tag (id, project, name, color) VALUES (124, 26, 'scalable', '#cbec00');
INSERT INTO tag (id, project, name, color) VALUES (125, 4, 'migration', '#7be453');
INSERT INTO tag (id, project, name, color) VALUES (126, 38, 'structure', '#e271f1');
INSERT INTO tag (id, project, name, color) VALUES (127, 34, 'demand-driven', '#b04d78');
INSERT INTO tag (id, project, name, color) VALUES (128, 4, 'capacity', '#d1c881');
INSERT INTO tag (id, project, name, color) VALUES (129, 27, 'web-enabled', '#9b3f3b');
INSERT INTO tag (id, project, name, color) VALUES (130, 44, 'next generation', '#3f10b0');
INSERT INTO tag (id, project, name, color) VALUES (131, 29, 'benchmark', '#a91076');
INSERT INTO tag (id, project, name, color) VALUES (132, 34, 'synergy', '#03c4ff');
INSERT INTO tag (id, project, name, color) VALUES (133, 27, 'secondary', '#f8a084');
INSERT INTO tag (id, project, name, color) VALUES (134, 5, 'non-volatile', '#1b4245');
INSERT INTO tag (id, project, name, color) VALUES (135, 46, 'well-modulated', '#5f23bc');
INSERT INTO tag (id, project, name, color) VALUES (136, 43, 'Right-sized', '#73f2a4');
INSERT INTO tag (id, project, name, color) VALUES (137, 46, 'Team-oriented', '#d6a1f1');
INSERT INTO tag (id, project, name, color) VALUES (138, 46, 'Front-line', '#015be5');
INSERT INTO tag (id, project, name, color) VALUES (139, 40, 'Operative', '#240e90');
INSERT INTO tag (id, project, name, color) VALUES (140, 39, 'Persistent', '#c9ee53');
INSERT INTO tag (id, project, name, color) VALUES (141, 32, 'regional', '#9fd7ef');
INSERT INTO tag (id, project, name, color) VALUES (142, 43, 'success', '#348717');
INSERT INTO tag (id, project, name, color) VALUES (143, 27, 'concept', '#c14ba1');
INSERT INTO tag (id, project, name, color) VALUES (144, 49, 'solution', '#5ac327');
INSERT INTO tag (id, project, name, color) VALUES (145, 3, '3rd generation', '#2a6084');
INSERT INTO tag (id, project, name, color) VALUES (146, 45, 'flexibility', '#e3bca0');
INSERT INTO tag (id, project, name, color) VALUES (147, 25, 'bifurcated', '#03570c');
INSERT INTO tag (id, project, name, color) VALUES (148, 21, 'real-time', '#8d88d6');
INSERT INTO tag (id, project, name, color) VALUES (149, 7, 'De-engineered', '#89ebd6');
INSERT INTO tag (id, project, name, color) VALUES (150, 18, 'Switchable', '#ad38cf');


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

INSERT INTO check_list_item (id, item_text, completed, task) VALUES (1, 'cultivate plug-and-play e-commerce', TRUE, 249);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (2, 'redefine impactful systems', TRUE, 498);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (3, 'facilitate innovative technologies', FALSE, 374);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (4, 'innovate value-added technologies', TRUE, 73);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (5, 'disintermediate frictionless architectures', FALSE, 171);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (6, 'optimize front-end models', FALSE, 141);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (7, 'strategize visionary architectures', FALSE, 189);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (8, 'mesh frictionless systems', FALSE, 489);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (9, 'target customized networks', FALSE, 347);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (10, 'transition transparent relationships', TRUE, 449);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (11, 'scale innovative applications', FALSE, 285);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (12, 'generate B2C metrics', FALSE, 280);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (13, 'evolve distributed e-commerce', FALSE, 158);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (14, 'drive seamless e-tailers', TRUE, 446);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (15, 'synthesize bleeding-edge mindshare', FALSE, 415);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (16, 'e-enable efficient e-services', FALSE, 328);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (17, 'evolve innovative relationships', TRUE, 100);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (18, 'strategize killer initiatives', FALSE, 430);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (19, 'innovate seamless eyeballs', FALSE, 211);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (20, 'innovate strategic users', FALSE, 117);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (21, 'orchestrate virtual platforms', FALSE, 357);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (22, 'engineer synergistic supply-chains', TRUE, 181);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (23, 'implement open-source eyeballs', FALSE, 287);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (24, 'reintermediate vertical schemas', TRUE, 137);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (25, 'morph leading-edge web-readiness', TRUE, 144);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (26, 'expedite sticky bandwidth', FALSE, 351);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (27, 'architect frictionless web-readiness', FALSE, 434);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (28, 'strategize integrated action-items', FALSE, 35);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (29, 'empower strategic platforms', TRUE, 128);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (30, 'grow dynamic solutions', FALSE, 465);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (31, 'synergize rich ROI', TRUE, 141);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (32, 'architect cross-platform applications', FALSE, 143);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (33, 'transition innovative e-business', TRUE, 295);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (34, 'synthesize one-to-one e-business', FALSE, 394);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (35, 'seize 24/7 e-commerce', FALSE, 338);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (36, 'incubate robust infomediaries', TRUE, 41);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (37, 'architect robust supply-chains', TRUE, 447);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (38, 'cultivate next-generation solutions', TRUE, 451);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (39, 'recontextualize end-to-end e-markets', TRUE, 280);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (40, 'seize bricks-and-clicks systems', TRUE, 443);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (41, 'e-enable ubiquitous mindshare', TRUE, 431);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (42, 'transform mission-critical synergies', FALSE, 42);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (43, 'scale one-to-one eyeballs', FALSE, 34);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (44, 'target compelling eyeballs', FALSE, 425);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (45, 'deliver magnetic functionalities', FALSE, 159);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (46, 'synthesize web-enabled systems', FALSE, 480);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (47, 'leverage innovative niches', FALSE, 487);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (48, 'scale bleeding-edge networks', TRUE, 11);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (49, 'redefine proactive functionalities', TRUE, 130);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (50, 'empower value-added paradigms', FALSE, 136);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (51, 'engineer seamless systems', FALSE, 439);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (52, 'unleash out-of-the-box vortals', FALSE, 310);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (53, 'envisioneer 24/7 niches', TRUE, 283);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (54, 'orchestrate clicks-and-mortar initiatives', TRUE, 257);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (55, 'integrate mission-critical supply-chains', FALSE, 339);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (56, 'leverage magnetic metrics', TRUE, 40);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (57, 'generate leading-edge initiatives', TRUE, 487);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (58, 'revolutionize wireless interfaces', FALSE, 130);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (59, 'drive bleeding-edge content', FALSE, 368);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (60, 'extend value-added networks', FALSE, 222);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (61, 'envisioneer bleeding-edge markets', FALSE, 407);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (62, 'incentivize efficient niches', TRUE, 55);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (63, 'matrix cross-platform applications', FALSE, 99);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (64, 'scale visionary deliverables', FALSE, 59);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (65, 'benchmark B2C web-readiness', FALSE, 465);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (66, 'exploit visionary supply-chains', TRUE, 226);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (67, 'target cross-platform e-business', TRUE, 187);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (68, 'utilize world-class markets', TRUE, 448);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (69, 'engineer cross-media models', TRUE, 311);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (70, 'embrace world-class supply-chains', FALSE, 129);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (71, 'grow cross-media functionalities', FALSE, 114);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (72, 'unleash collaborative e-markets', FALSE, 143);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (73, 'transition wireless e-commerce', TRUE, 92);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (74, 'strategize next-generation e-services', FALSE, 180);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (75, 'reinvent user-centric users', FALSE, 433);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (76, 'embrace cross-media web services', FALSE, 129);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (77, 'cultivate cutting-edge mindshare', FALSE, 161);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (78, 'reintermediate bleeding-edge e-tailers', TRUE, 159);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (79, 'expedite clicks-and-mortar markets', FALSE, 211);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (80, 'morph front-end experiences', FALSE, 488);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (81, 'engineer granular methodologies', TRUE, 384);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (82, 'reinvent bleeding-edge content', TRUE, 472);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (83, 'visualize magnetic paradigms', FALSE, 380);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (84, 'leverage cross-platform vortals', TRUE, 359);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (85, 'synthesize holistic content', FALSE, 269);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (86, 'e-enable open-source technologies', TRUE, 53);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (87, 'whiteboard scalable portals', FALSE, 408);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (88, 'transition robust communities', FALSE, 337);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (89, 'revolutionize 24/365 web-readiness', TRUE, 467);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (90, 'deploy best-of-breed web services', FALSE, 169);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (91, 'transform enterprise vortals', FALSE, 146);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (92, 'facilitate cross-platform architectures', TRUE, 375);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (93, 'unleash bleeding-edge e-tailers', FALSE, 136);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (94, 'transition B2B communities', TRUE, 373);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (95, 'orchestrate mission-critical functionalities', FALSE, 180);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (96, 'integrate dot-com applications', TRUE, 411);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (97, 'monetize web-enabled vortals', FALSE, 375);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (98, 'visualize rich initiatives', FALSE, 486);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (99, 'engage real-time convergence', TRUE, 424);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (100, 'extend killer e-tailers', FALSE, 148);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (101, 'drive impactful users', TRUE, 458);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (102, 'architect scalable metrics', FALSE, 218);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (103, 'envisioneer proactive e-commerce', FALSE, 453);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (104, 'mesh B2B e-services', FALSE, 483);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (105, 'engineer cross-media e-markets', FALSE, 133);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (106, 'morph killer relationships', FALSE, 135);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (107, 'matrix integrated initiatives', FALSE, 183);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (108, 'productize back-end methodologies', TRUE, 313);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (109, 'visualize revolutionary infrastructures', FALSE, 448);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (110, 'unleash cross-platform functionalities', TRUE, 387);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (111, 'scale virtual schemas', TRUE, 463);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (112, 'enhance next-generation portals', TRUE, 306);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (113, 'whiteboard best-of-breed e-tailers', TRUE, 320);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (114, 'strategize web-enabled infrastructures', TRUE, 221);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (115, 'optimize interactive interfaces', FALSE, 10);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (116, 'envisioneer one-to-one models', FALSE, 16);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (117, 'disintermediate bleeding-edge synergies', FALSE, 441);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (118, 'exploit intuitive e-markets', TRUE, 40);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (119, 'deliver web-enabled users', FALSE, 394);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (120, 'syndicate efficient applications', TRUE, 315);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (121, 'envisioneer world-class portals', TRUE, 143);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (122, 'matrix robust portals', TRUE, 329);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (123, 'scale granular models', TRUE, 59);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (124, 'drive robust action-items', FALSE, 214);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (125, 'incubate granular mindshare', TRUE, 122);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (126, 'envisioneer efficient markets', TRUE, 116);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (127, 'disintermediate robust niches', FALSE, 238);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (128, 'incubate magnetic applications', TRUE, 146);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (129, 'mesh holistic schemas', FALSE, 62);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (130, 'embrace wireless paradigms', TRUE, 302);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (131, 'incubate intuitive applications', TRUE, 477);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (132, 'enhance leading-edge portals', TRUE, 132);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (133, 'innovate integrated niches', TRUE, 214);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (134, 'architect out-of-the-box architectures', FALSE, 190);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (135, 'deploy frictionless users', TRUE, 245);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (136, 'cultivate rich eyeballs', FALSE, 415);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (137, 'reintermediate best-of-breed supply-chains', FALSE, 347);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (138, 'transform mission-critical models', FALSE, 419);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (139, 'leverage revolutionary initiatives', FALSE, 92);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (140, 'evolve proactive platforms', TRUE, 448);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (141, 'incubate dot-com e-business', TRUE, 172);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (142, 'scale frictionless content', TRUE, 367);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (143, 'innovate compelling interfaces', TRUE, 170);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (144, 'empower 24/7 e-services', TRUE, 37);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (145, 'recontextualize B2B relationships', TRUE, 320);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (146, 'redefine visionary niches', FALSE, 433);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (147, 'transform B2B mindshare', FALSE, 213);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (148, 'syndicate back-end interfaces', TRUE, 245);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (149, 'aggregate next-generation platforms', TRUE, 17);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (150, 'cultivate end-to-end action-items', FALSE, 390);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (151, 'utilize customized relationships', TRUE, 224);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (152, 'incentivize leading-edge relationships', FALSE, 298);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (153, 'scale out-of-the-box e-services', FALSE, 148);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (154, 'synergize robust initiatives', TRUE, 435);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (155, 'recontextualize open-source methodologies', TRUE, 198);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (156, 'synthesize bleeding-edge schemas', FALSE, 53);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (157, 'enhance user-centric e-commerce', FALSE, 170);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (158, 'exploit proactive applications', FALSE, 320);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (159, 'matrix impactful synergies', FALSE, 419);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (160, 'aggregate granular technologies', TRUE, 130);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (161, 'morph viral architectures', FALSE, 148);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (162, 'integrate 24/7 e-business', TRUE, 369);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (163, 'monetize clicks-and-mortar networks', TRUE, 190);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (164, 'expedite magnetic bandwidth', TRUE, 83);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (165, 'architect interactive schemas', TRUE, 270);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (166, 'syndicate bleeding-edge solutions', TRUE, 161);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (167, 'exploit cutting-edge infomediaries', FALSE, 400);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (168, 'recontextualize vertical methodologies', TRUE, 429);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (169, 'embrace visionary deliverables', FALSE, 416);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (170, 'streamline innovative bandwidth', FALSE, 288);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (171, 'evolve front-end models', FALSE, 7);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (172, 'whiteboard proactive bandwidth', FALSE, 198);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (173, 'seize wireless users', FALSE, 232);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (174, 'orchestrate revolutionary e-business', FALSE, 171);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (175, 'e-enable efficient content', FALSE, 475);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (176, 'scale wireless users', TRUE, 490);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (177, 'harness sticky mindshare', TRUE, 251);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (178, 'optimize plug-and-play bandwidth', TRUE, 40);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (179, 'deploy revolutionary web services', TRUE, 81);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (180, 'target scalable paradigms', FALSE, 264);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (181, 'strategize distributed channels', FALSE, 206);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (182, 'morph proactive e-tailers', TRUE, 476);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (183, 'deploy mission-critical systems', FALSE, 355);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (184, 'target global applications', TRUE, 216);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (185, 'deliver ubiquitous infrastructures', FALSE, 52);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (186, 'facilitate world-class e-business', FALSE, 177);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (187, 'synthesize turn-key convergence', FALSE, 198);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (188, 'facilitate clicks-and-mortar bandwidth', FALSE, 445);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (189, 'deliver dot-com niches', TRUE, 444);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (190, 'seize open-source bandwidth', TRUE, 132);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (191, 'evolve back-end bandwidth', TRUE, 138);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (192, 'maximize frictionless niches', TRUE, 154);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (193, 'synthesize mission-critical vortals', TRUE, 118);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (194, 'disintermediate extensible paradigms', FALSE, 500);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (195, 'iterate user-centric interfaces', FALSE, 467);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (196, 'e-enable leading-edge metrics', TRUE, 290);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (197, 'reintermediate end-to-end metrics', TRUE, 303);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (198, 'scale sticky convergence', TRUE, 143);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (199, 'e-enable dynamic infomediaries', TRUE, 252);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (200, 'evolve real-time initiatives', TRUE, 145);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (201, 'repurpose mission-critical networks', FALSE, 411);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (202, 'target end-to-end architectures', TRUE, 173);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (203, 'brand efficient e-markets', FALSE, 272);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (204, 'recontextualize viral communities', FALSE, 182);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (205, 'engage revolutionary solutions', FALSE, 102);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (206, 'architect magnetic applications', TRUE, 158);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (207, 'productize dot-com content', FALSE, 301);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (208, 'morph B2B e-business', FALSE, 339);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (209, 'unleash transparent markets', TRUE, 37);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (210, 'brand end-to-end initiatives', TRUE, 26);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (211, 'reinvent bricks-and-clicks schemas', FALSE, 413);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (212, 'productize best-of-breed partnerships', TRUE, 445);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (213, 'visualize value-added platforms', TRUE, 112);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (214, 'synergize intuitive convergence', TRUE, 252);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (215, 'utilize wireless technologies', FALSE, 303);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (216, 'transition viral networks', FALSE, 165);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (217, 'reinvent rich bandwidth', FALSE, 97);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (218, 'unleash 24/365 markets', FALSE, 48);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (219, 'expedite sticky e-tailers', TRUE, 172);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (220, 'utilize strategic applications', TRUE, 410);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (221, 'utilize distributed relationships', TRUE, 105);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (222, 'enhance viral users', FALSE, 295);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (223, 'extend seamless niches', TRUE, 286);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (224, 'syndicate turn-key solutions', TRUE, 232);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (225, 'enable B2C technologies', TRUE, 194);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (226, 'scale cross-media content', FALSE, 104);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (227, 'utilize frictionless portals', TRUE, 413);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (228, 'visualize frictionless functionalities', TRUE, 179);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (229, 'enable web-enabled e-tailers', FALSE, 424);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (230, 'empower sexy interfaces', FALSE, 43);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (231, 'scale intuitive portals', FALSE, 398);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (232, 'syndicate e-business partnerships', FALSE, 115);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (233, 'exploit e-business communities', TRUE, 403);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (234, 'synergize enterprise interfaces', TRUE, 387);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (235, 'envisioneer visionary architectures', FALSE, 185);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (236, 'aggregate killer methodologies', FALSE, 305);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (237, 'visualize best-of-breed supply-chains', TRUE, 288);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (238, 'incubate open-source web-readiness', FALSE, 307);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (239, 'recontextualize bricks-and-clicks communities', TRUE, 436);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (240, 'evolve vertical e-markets', TRUE, 431);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (241, 'harness sticky applications', TRUE, 289);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (242, 'disintermediate frictionless communities', FALSE, 495);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (243, 'streamline e-business mindshare', TRUE, 62);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (244, 'scale revolutionary platforms', TRUE, 271);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (245, 'scale end-to-end bandwidth', TRUE, 439);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (246, 'deliver leading-edge action-items', FALSE, 445);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (247, 'reintermediate customized ROI', TRUE, 107);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (248, 'leverage enterprise convergence', FALSE, 211);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (249, 'aggregate end-to-end users', TRUE, 331);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (250, 'utilize distributed experiences', TRUE, 129);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (251, 'integrate turn-key e-tailers', FALSE, 467);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (252, 'extend impactful e-business', TRUE, 167);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (253, 'synergize cutting-edge infrastructures', TRUE, 54);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (254, 'integrate compelling architectures', FALSE, 355);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (255, 'integrate impactful methodologies', TRUE, 315);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (256, 'benchmark revolutionary interfaces', FALSE, 50);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (257, 'implement sexy schemas', TRUE, 162);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (258, 'matrix scalable systems', FALSE, 11);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (259, 'e-enable integrated infrastructures', TRUE, 119);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (260, 'transition end-to-end platforms', FALSE, 291);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (261, 'synergize extensible supply-chains', FALSE, 292);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (262, 'generate clicks-and-mortar interfaces', TRUE, 258);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (263, 'scale sticky e-commerce', TRUE, 289);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (264, 'implement bricks-and-clicks supply-chains', FALSE, 171);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (265, 'aggregate B2B mindshare', FALSE, 369);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (266, 'whiteboard magnetic interfaces', TRUE, 171);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (267, 'deploy mission-critical initiatives', FALSE, 303);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (268, 'evolve front-end e-markets', FALSE, 218);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (269, 'monetize frictionless web-readiness', FALSE, 323);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (270, 'reinvent mission-critical technologies', FALSE, 491);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (271, 'generate proactive convergence', TRUE, 52);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (272, 'mesh granular applications', TRUE, 257);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (273, 'harness robust experiences', FALSE, 151);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (274, 'expedite synergistic infomediaries', TRUE, 333);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (275, 'deploy intuitive action-items', TRUE, 380);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (276, 'synthesize transparent channels', TRUE, 215);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (277, 'synergize visionary supply-chains', FALSE, 106);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (278, 'orchestrate turn-key e-markets', FALSE, 279);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (279, 'harness 24/7 platforms', TRUE, 379);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (280, 'exploit enterprise initiatives', TRUE, 251);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (281, 'aggregate back-end networks', FALSE, 408);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (282, 'matrix seamless web-readiness', TRUE, 309);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (283, 'reintermediate customized relationships', FALSE, 141);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (284, 'enhance end-to-end users', TRUE, 70);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (285, 'strategize open-source systems', FALSE, 38);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (286, 'reinvent visionary systems', TRUE, 397);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (287, 'scale frictionless metrics', TRUE, 81);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (288, 'scale enterprise eyeballs', TRUE, 201);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (289, 'orchestrate extensible metrics', TRUE, 163);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (290, 'repurpose B2B relationships', TRUE, 350);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (291, 'seize vertical e-markets', TRUE, 80);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (292, 'evolve dot-com e-markets', FALSE, 301);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (293, 'harness integrated e-business', TRUE, 450);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (294, 'incubate next-generation solutions', TRUE, 239);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (295, 'aggregate holistic systems', FALSE, 363);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (296, 'streamline web-enabled eyeballs', TRUE, 113);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (297, 'expedite open-source schemas', TRUE, 139);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (298, 'transition next-generation methodologies', TRUE, 62);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (299, 'streamline synergistic mindshare', TRUE, 495);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (300, 'engineer sexy technologies', TRUE, 404);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (301, 'repurpose sticky e-markets', TRUE, 180);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (302, 'seize web-enabled bandwidth', FALSE, 145);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (303, 'redefine cross-media networks', FALSE, 375);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (304, 'transform end-to-end systems', TRUE, 198);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (305, 'transition robust methodologies', TRUE, 41);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (306, 'implement next-generation initiatives', FALSE, 467);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (307, 'reintermediate user-centric supply-chains', FALSE, 345);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (308, 'productize cross-platform models', TRUE, 414);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (309, 'cultivate out-of-the-box models', FALSE, 24);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (310, 'grow sexy paradigms', FALSE, 180);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (311, 'benchmark collaborative applications', FALSE, 35);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (312, 'iterate revolutionary partnerships', FALSE, 184);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (313, 'target cutting-edge initiatives', TRUE, 141);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (314, 'grow enterprise schemas', FALSE, 349);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (315, 'streamline plug-and-play content', FALSE, 50);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (316, 'deliver magnetic networks', TRUE, 51);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (317, 'integrate granular e-business', FALSE, 445);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (318, 'engineer integrated technologies', FALSE, 205);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (319, 'envisioneer front-end web services', TRUE, 372);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (320, 'harness front-end eyeballs', TRUE, 276);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (321, 'streamline leading-edge systems', TRUE, 142);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (322, 'strategize interactive schemas', FALSE, 390);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (323, 'aggregate cross-platform ROI', FALSE, 166);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (324, 'recontextualize one-to-one technologies', TRUE, 379);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (325, 'architect front-end eyeballs', FALSE, 135);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (326, 'incubate collaborative eyeballs', TRUE, 219);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (327, 'strategize B2C ROI', FALSE, 278);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (328, 'cultivate customized solutions', FALSE, 28);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (329, 'leverage sexy markets', TRUE, 255);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (330, 'evolve integrated channels', TRUE, 469);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (331, 'extend real-time bandwidth', TRUE, 270);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (332, 'generate revolutionary e-commerce', TRUE, 480);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (333, 'target cutting-edge infomediaries', TRUE, 500);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (334, 'implement integrated ROI', TRUE, 393);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (335, 'unleash cutting-edge initiatives', FALSE, 214);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (336, 'enhance robust ROI', TRUE, 339);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (337, 'monetize holistic e-markets', TRUE, 145);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (338, 'brand customized technologies', TRUE, 460);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (339, 'scale revolutionary experiences', TRUE, 154);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (340, 'optimize integrated ROI', FALSE, 183);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (341, 'incentivize extensible e-tailers', TRUE, 490);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (342, 'reintermediate next-generation e-markets', FALSE, 89);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (343, 'synthesize cross-platform channels', FALSE, 352);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (344, 'brand web-enabled infrastructures', TRUE, 200);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (345, 'morph bricks-and-clicks e-markets', FALSE, 453);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (346, 'empower transparent content', FALSE, 367);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (347, 'extend bleeding-edge networks', TRUE, 392);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (348, 'implement world-class models', FALSE, 403);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (349, 'syndicate interactive methodologies', FALSE, 473);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (350, 'integrate next-generation communities', FALSE, 281);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (351, 'innovate dot-com methodologies', TRUE, 153);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (352, 'synergize dot-com supply-chains', TRUE, 397);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (353, 'expedite visionary deliverables', FALSE, 177);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (354, 'envisioneer bleeding-edge bandwidth', TRUE, 348);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (355, 'monetize compelling web-readiness', FALSE, 285);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (356, 'expedite e-business ROI', TRUE, 362);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (357, 'revolutionize magnetic partnerships', TRUE, 131);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (358, 'transition wireless niches', FALSE, 75);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (359, 'incubate bleeding-edge communities', TRUE, 185);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (360, 'strategize killer relationships', FALSE, 259);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (361, 'architect sticky e-business', FALSE, 25);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (362, 'morph viral e-business', FALSE, 394);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (363, 'engage cross-platform eyeballs', TRUE, 467);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (364, 'synthesize killer ROI', FALSE, 24);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (365, 'generate intuitive vortals', TRUE, 127);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (366, 'unleash B2B applications', FALSE, 38);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (367, 'facilitate customized systems', TRUE, 2);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (368, 'transition interactive bandwidth', TRUE, 260);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (369, 'visualize magnetic metrics', TRUE, 202);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (370, 'orchestrate holistic methodologies', TRUE, 56);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (371, 'innovate seamless e-commerce', TRUE, 64);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (372, 'optimize impactful technologies', FALSE, 102);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (373, 'engineer transparent functionalities', TRUE, 222);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (374, 'morph wireless models', TRUE, 152);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (375, 'scale integrated initiatives', FALSE, 225);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (376, 'engineer interactive interfaces', FALSE, 193);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (377, 'synergize strategic models', FALSE, 143);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (378, 'mesh world-class technologies', FALSE, 460);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (379, 'reinvent enterprise interfaces', FALSE, 70);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (380, 'implement robust vortals', FALSE, 284);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (381, 'incubate next-generation markets', TRUE, 114);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (382, 'maximize world-class deliverables', FALSE, 2);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (383, 'drive mission-critical portals', FALSE, 85);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (384, 'evolve open-source interfaces', TRUE, 166);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (385, 'iterate leading-edge networks', FALSE, 185);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (386, 'reintermediate frictionless models', TRUE, 376);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (387, 'envisioneer value-added ROI', TRUE, 67);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (388, 'extend clicks-and-mortar e-tailers', TRUE, 222);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (389, 'innovate innovative synergies', FALSE, 256);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (390, 'engineer collaborative portals', FALSE, 316);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (391, 'e-enable interactive supply-chains', FALSE, 152);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (392, 'drive strategic applications', FALSE, 246);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (393, 'envisioneer viral web-readiness', TRUE, 126);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (394, 'seize transparent initiatives', FALSE, 179);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (395, 'deliver leading-edge solutions', FALSE, 293);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (396, 'seize e-business infomediaries', TRUE, 463);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (397, 'transition enterprise platforms', FALSE, 32);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (398, 'generate cross-media partnerships', TRUE, 24);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (399, 'recontextualize visionary applications', TRUE, 192);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (400, 'engage viral networks', FALSE, 362);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (401, 'leverage proactive e-markets', FALSE, 152);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (402, 'implement collaborative communities', FALSE, 89);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (403, 'streamline front-end ROI', TRUE, 88);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (404, 'maximize interactive experiences', TRUE, 147);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (405, 'target impactful solutions', FALSE, 490);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (406, 'productize extensible vortals', FALSE, 200);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (407, 'unleash web-enabled e-markets', FALSE, 306);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (408, 'unleash extensible applications', FALSE, 232);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (409, 'evolve back-end paradigms', FALSE, 129);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (410, 'facilitate enterprise e-markets', FALSE, 298);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (411, 'strategize scalable e-business', TRUE, 397);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (412, 'synergize extensible action-items', TRUE, 448);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (413, 'monetize robust systems', FALSE, 215);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (414, 'engage magnetic partnerships', TRUE, 48);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (415, 'reintermediate interactive networks', TRUE, 124);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (416, 'drive efficient platforms', TRUE, 19);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (417, 'embrace impactful e-business', FALSE, 454);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (418, 'unleash frictionless supply-chains', FALSE, 310);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (419, 'drive web-enabled e-tailers', TRUE, 261);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (420, 'disintermediate world-class e-business', FALSE, 437);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (421, 'recontextualize interactive platforms', FALSE, 239);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (422, 'benchmark e-business eyeballs', TRUE, 207);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (423, 'incubate compelling markets', TRUE, 71);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (424, 'incentivize next-generation infomediaries', TRUE, 280);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (425, 'redefine transparent convergence', TRUE, 167);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (426, 'generate 24/7 content', TRUE, 399);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (427, 'enhance enterprise systems', TRUE, 11);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (428, 'morph plug-and-play architectures', TRUE, 142);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (429, 'repurpose e-business applications', TRUE, 77);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (430, 'deploy proactive functionalities', FALSE, 214);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (431, 'disintermediate leading-edge users', FALSE, 73);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (432, 'repurpose collaborative infomediaries', FALSE, 281);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (433, 'enhance value-added e-tailers', TRUE, 90);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (434, 'synergize proactive niches', TRUE, 129);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (435, 'integrate world-class web-readiness', FALSE, 126);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (436, 'engage dot-com supply-chains', FALSE, 446);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (437, 'optimize proactive synergies', TRUE, 124);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (438, 'enhance magnetic schemas', FALSE, 147);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (439, 'engineer collaborative content', TRUE, 273);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (440, 'aggregate efficient bandwidth', FALSE, 266);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (441, 'scale best-of-breed users', TRUE, 431);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (442, 'seize clicks-and-mortar architectures', TRUE, 276);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (443, 'transform virtual e-commerce', FALSE, 235);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (444, 'enable real-time e-commerce', FALSE, 120);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (445, 'benchmark B2C communities', FALSE, 75);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (446, 'engage real-time partnerships', TRUE, 226);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (447, 'revolutionize 24/365 technologies', TRUE, 138);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (448, 'synthesize 24/365 web services', TRUE, 93);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (449, 'iterate compelling infomediaries', TRUE, 81);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (450, 'embrace plug-and-play experiences', TRUE, 494);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (451, 'utilize strategic e-tailers', FALSE, 443);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (452, 'scale collaborative relationships', FALSE, 216);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (453, 'monetize B2B users', FALSE, 75);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (454, 'monetize robust e-commerce', TRUE, 394);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (455, 'incentivize enterprise e-business', FALSE, 101);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (456, 'brand end-to-end applications', TRUE, 329);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (457, 'visualize turn-key action-items', FALSE, 214);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (458, 'cultivate intuitive ROI', FALSE, 345);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (459, 'orchestrate clicks-and-mortar technologies', FALSE, 271);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (460, 'architect 24/365 channels', TRUE, 300);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (461, 'facilitate enterprise users', TRUE, 41);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (462, 'enhance dynamic synergies', TRUE, 139);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (463, 'brand scalable infomediaries', TRUE, 292);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (464, 'incubate interactive channels', TRUE, 384);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (465, 'visualize interactive models', TRUE, 33);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (466, 'recontextualize scalable niches', TRUE, 469);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (467, 'synthesize synergistic methodologies', TRUE, 173);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (468, 'productize revolutionary partnerships', TRUE, 197);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (469, 'seize best-of-breed infomediaries', TRUE, 500);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (470, 'implement bricks-and-clicks ROI', TRUE, 390);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (471, 'transform virtual convergence', TRUE, 132);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (472, 'disintermediate dot-com solutions', FALSE, 323);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (473, 'synthesize dynamic bandwidth', TRUE, 133);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (474, 'deploy bricks-and-clicks supply-chains', TRUE, 114);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (475, 'whiteboard integrated experiences', FALSE, 76);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (476, 'iterate end-to-end deliverables', FALSE, 205);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (477, 'revolutionize strategic schemas', TRUE, 377);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (478, 'recontextualize mission-critical deliverables', TRUE, 222);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (479, 'e-enable best-of-breed infrastructures', TRUE, 344);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (480, 'extend synergistic technologies', TRUE, 105);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (481, 'facilitate B2C content', TRUE, 320);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (482, 'benchmark plug-and-play communities', TRUE, 340);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (483, 'harness real-time communities', FALSE, 473);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (484, 'redefine one-to-one paradigms', TRUE, 399);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (485, 'embrace real-time vortals', TRUE, 253);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (486, 'harness customized web services', FALSE, 382);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (487, 'iterate ubiquitous supply-chains', TRUE, 474);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (488, 'embrace cross-platform technologies', TRUE, 204);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (489, 'grow extensible web-readiness', TRUE, 135);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (490, 'incubate seamless ROI', FALSE, 319);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (491, 'transition intuitive systems', FALSE, 281);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (492, 'deliver seamless content', TRUE, 417);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (493, 'architect turn-key e-services', FALSE, 204);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (494, 'empower proactive paradigms', FALSE, 27);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (495, 'synergize efficient solutions', TRUE, 29);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (496, 'iterate holistic schemas', FALSE, 347);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (497, 'innovate dynamic convergence', FALSE, 407);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (498, 'incentivize wireless e-tailers', FALSE, 422);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (499, 'scale enterprise ROI', TRUE, 179);
INSERT INTO check_list_item (id, item_text, completed, task) VALUES (500, 'evolve world-class convergence', FALSE, 101);


-- Comment

INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (1, 7, 15, '2021-03-22 15:00:52', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (2, 323, 16, '2021-03-12 17:10:00', 'Donec quis orci eget orci vehicula condimentum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (3, 437, 18, '2021-03-27 19:44:11', 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (4, 7, 22, '2021-01-31 10:05:20', 'Quisque porta volutpat erat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (5, 33, 3, '2021-02-20 00:13:26', 'Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (6, 456, 10, '2021-01-28 18:41:04', 'In hac habitasse platea dictumst.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (7, 30, 23, '2021-03-26 04:40:56', 'Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (8, 98, 11, '2021-01-09 17:00:37', 'Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (9, 88, 6, '2021-02-21 13:54:08', 'Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (10, 329, 11, '2021-02-12 18:59:06', 'Donec posuere metus vitae ipsum. Aliquam non mauris.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (11, 265, 10, '2021-02-25 13:58:21', 'Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (12, 21, 4, '2021-01-09 13:26:03', 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (13, 350, 23, '2021-01-06 07:44:34', 'Etiam faucibus cursus urna.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (14, 72, 13, '2021-01-10 05:35:44', 'Nullam varius. Nulla facilisi.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (15, 500, 20, '2021-01-18 17:32:30', 'Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (16, 493, 4, '2021-02-03 00:17:59', 'Duis bibendum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (17, 112, 13, '2021-03-14 21:03:40', 'Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (18, 224, 19, '2021-03-14 16:54:10', 'Donec vitae nisi.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (19, 85, 20, '2021-02-16 19:36:57', 'Nulla ut erat id mauris vulputate elementum. Nullam varius.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (20, 58, 20, '2021-03-27 16:10:40', 'Aliquam non mauris.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (21, 496, 20, '2021-02-09 00:22:16', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (22, 115, 13, '2021-03-08 07:05:44', 'Cras pellentesque volutpat dui.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (23, 164, 19, '2021-03-14 09:33:49', 'Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (24, 482, 21, '2021-03-24 21:29:04', 'Sed sagittis.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (25, 296, 12, '2021-03-15 03:58:04', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (26, 232, 24, '2021-03-06 05:59:24', 'Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (27, 469, 15, '2021-03-16 01:43:50', 'Aenean sit amet justo. Morbi ut odio.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (28, 403, 9, '2021-03-15 14:15:24', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (29, 100, 22, '2021-01-26 08:50:02', 'Phasellus in felis.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (30, 418, 8, '2021-03-12 00:49:05', 'Fusce consequat. Nulla nisl.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (31, 194, 18, '2021-02-10 12:09:07', 'In congue.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (32, 50, 12, '2021-02-09 21:59:30', 'Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (33, 191, 18, '2021-01-18 18:09:51', 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (34, 267, 6, '2021-01-18 16:22:03', 'Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (35, 331, 7, '2021-01-03 01:58:28', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (36, 458, 6, '2021-02-19 02:22:51', 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (37, 160, 19, '2021-02-18 20:38:25', 'Quisque porta volutpat erat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (38, 403, 6, '2021-01-28 14:57:24', 'Aenean auctor gravida sem.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (39, 173, 2, '2021-01-16 17:47:55', 'Praesent lectus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (40, 394, 23, '2021-03-04 00:58:08', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (41, 222, 2, '2021-01-13 18:22:33', 'Vestibulum rutrum rutrum neque.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (42, 5, 18, '2021-02-21 02:22:19', 'Morbi vel lectus in quam fringilla rhoncus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (43, 23, 10, '2021-02-17 04:14:06', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (44, 89, 8, '2021-03-08 04:23:48', 'Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (45, 498, 19, '2021-02-20 07:23:17', 'Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (46, 27, 5, '2021-03-09 07:04:37', 'Phasellus sit amet erat. Nulla tempus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (47, 82, 7, '2021-03-01 01:45:36', 'Fusce consequat. Nulla nisl. Nunc nisl.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (48, 451, 17, '2021-03-10 07:02:50', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (49, 413, 24, '2021-01-30 09:53:21', 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (50, 151, 19, '2021-01-09 07:22:39', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (51, 266, 24, '2021-02-22 12:56:53', 'Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (52, 84, 19, '2021-02-12 15:05:09', 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (53, 422, 8, '2021-03-03 11:34:21', 'Nunc purus. Phasellus in felis. Donec semper sapien a libero.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (54, 49, 2, '2021-02-21 08:32:54', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (55, 62, 11, '2021-01-24 14:59:18', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (56, 179, 14, '2021-03-01 05:19:30', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (57, 118, 20, '2021-01-16 02:21:29', 'Nullam sit amet turpis elementum ligula vehicula consequat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (58, 253, 22, '2021-03-08 06:02:20', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (59, 377, 15, '2021-02-13 14:37:46', 'In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (60, 245, 13, '2021-02-12 06:29:54', 'Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (61, 19, 22, '2021-03-21 16:28:17', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (62, 197, 25, '2021-03-27 23:46:04', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (63, 116, 17, '2021-01-17 03:55:56', 'Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (64, 273, 16, '2021-01-15 07:59:29', 'Duis aliquam convallis nunc.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (65, 103, 10, '2021-01-06 01:01:23', 'Pellentesque at nulla.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (66, 38, 14, '2021-01-28 04:45:23', 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (67, 429, 12, '2021-02-26 05:30:23', 'Morbi porttitor lorem id ligula.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (68, 152, 10, '2021-03-06 17:01:11', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (69, 80, 16, '2021-01-03 00:50:23', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (70, 281, 24, '2021-01-19 11:33:05', 'In eleifend quam a odio. In hac habitasse platea dictumst.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (71, 37, 25, '2021-03-05 23:20:37', 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (72, 24, 25, '2021-03-26 09:53:51', 'Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (73, 428, 23, '2021-01-06 20:34:52', 'Pellentesque eget nunc.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (74, 85, 20, '2021-02-09 00:51:14', 'In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (75, 238, 6, '2021-03-06 07:01:18', 'Nulla tellus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (76, 303, 21, '2021-02-14 07:12:49', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (77, 111, 23, '2021-02-26 04:50:30', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (78, 297, 9, '2021-01-19 00:26:59', 'Etiam faucibus cursus urna. Ut tellus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (79, 158, 23, '2021-03-25 11:09:23', 'Nulla justo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (80, 115, 14, '2021-03-10 07:04:27', 'Nulla mollis molestie lorem. Quisque ut erat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (81, 128, 18, '2021-03-18 00:06:30', 'Vivamus in felis eu sapien cursus vestibulum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (82, 350, 23, '2021-03-15 22:50:33', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (83, 90, 17, '2021-02-28 15:05:52', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (84, 22, 22, '2021-01-24 21:27:58', 'Fusce posuere felis sed lacus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (85, 180, 5, '2021-02-22 00:38:11', 'Aenean lectus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (86, 207, 16, '2021-03-24 16:39:58', 'Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (87, 94, 6, '2021-01-09 16:22:04', 'Duis mattis egestas metus. Aenean fermentum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (88, 410, 21, '2021-01-25 00:20:19', 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (89, 498, 22, '2021-02-12 08:34:29', 'Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (90, 71, 16, '2021-01-01 16:33:52', 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (91, 189, 3, '2021-03-14 20:50:47', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (92, 134, 19, '2021-02-20 11:20:11', 'Donec posuere metus vitae ipsum. Aliquam non mauris.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (93, 135, 20, '2021-03-01 13:41:59', 'Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (94, 436, 21, '2021-01-27 18:10:49', 'Etiam pretium iaculis justo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (95, 476, 21, '2021-01-06 13:47:10', 'Vestibulum rutrum rutrum neque.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (96, 139, 2, '2021-03-17 03:56:12', 'In congue. Etiam justo. Etiam pretium iaculis justo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (97, 470, 19, '2021-03-18 23:24:43', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (98, 415, 2, '2021-03-14 03:05:23', 'Aenean fermentum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (99, 297, 21, '2021-02-01 00:51:06', 'Suspendisse potenti.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (100, 187, 8, '2021-03-08 00:02:06', 'Duis at velit eu est congue elementum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (101, 249, 24, '2021-01-15 20:31:15', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (102, 470, 12, '2021-01-26 11:27:59', 'Nullam sit amet turpis elementum ligula vehicula consequat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (103, 469, 10, '2021-02-12 05:46:56', 'Vivamus vestibulum sagittis sapien.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (104, 123, 19, '2021-01-29 07:05:01', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (105, 154, 24, '2021-03-07 09:48:19', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (106, 151, 12, '2021-01-25 07:50:48', 'In hac habitasse platea dictumst.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (107, 493, 10, '2021-02-16 15:42:27', 'Aenean sit amet justo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (108, 329, 16, '2021-02-21 05:14:19', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (109, 305, 16, '2021-03-10 12:50:09', 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (110, 416, 6, '2021-01-15 05:13:29', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (111, 472, 5, '2021-03-18 16:33:51', 'Sed ante. Vivamus tortor.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (112, 237, 18, '2021-03-26 15:27:45', 'Nulla mollis molestie lorem.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (113, 122, 3, '2021-02-16 22:55:05', 'Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (114, 413, 10, '2021-01-24 22:32:05', 'Duis mattis egestas metus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (115, 444, 19, '2021-01-12 02:34:24', 'In congue.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (116, 375, 22, '2021-02-22 17:55:26', 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (117, 288, 20, '2021-02-05 21:55:38', 'Vestibulum rutrum rutrum neque.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (118, 187, 8, '2021-03-10 07:50:07', 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (119, 40, 5, '2021-02-11 23:55:58', 'Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (120, 420, 6, '2021-03-07 23:07:19', 'Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (121, 110, 17, '2021-03-12 10:05:14', 'Fusce consequat. Nulla nisl. Nunc nisl.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (122, 349, 17, '2021-02-14 10:27:00', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (123, 401, 15, '2021-01-03 17:51:28', 'Morbi a ipsum. Integer a nibh.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (124, 295, 16, '2021-02-11 22:19:19', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (125, 82, 2, '2021-02-28 09:31:25', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (126, 461, 6, '2021-01-03 03:46:58', 'Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (127, 423, 24, '2021-01-22 22:37:57', 'Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (128, 64, 25, '2021-03-11 02:52:25', 'In blandit ultrices enim.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (129, 224, 12, '2021-03-09 15:06:36', 'Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (130, 142, 17, '2021-03-16 10:47:50', 'Donec semper sapien a libero. Nam dui.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (131, 182, 17, '2021-02-18 12:45:11', 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (132, 59, 11, '2021-01-03 06:00:21', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (133, 177, 6, '2021-02-21 07:30:23', 'Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (134, 240, 17, '2021-01-07 15:24:26', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (135, 60, 3, '2021-01-25 14:25:03', 'Donec posuere metus vitae ipsum. Aliquam non mauris.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (136, 90, 12, '2021-01-13 00:28:58', 'Donec ut mauris eget massa tempor convallis.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (137, 316, 9, '2021-01-13 16:02:39', 'Morbi non quam nec dui luctus rutrum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (138, 444, 25, '2021-03-26 14:12:43', 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (139, 400, 12, '2021-02-13 03:21:13', 'Aliquam non mauris. Morbi non lectus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (140, 396, 2, '2021-01-21 04:28:22', 'Nulla ut erat id mauris vulputate elementum. Nullam varius.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (141, 55, 23, '2021-02-21 19:01:40', 'Aenean sit amet justo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (142, 490, 25, '2021-01-22 09:04:37', 'Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (143, 17, 14, '2021-02-19 20:38:27', 'Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (144, 348, 13, '2021-03-04 03:52:55', 'Vivamus tortor.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (145, 145, 12, '2021-02-01 00:58:03', 'Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (146, 71, 25, '2021-01-21 06:39:16', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (147, 165, 5, '2021-03-25 11:32:00', 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (148, 452, 16, '2021-03-27 14:26:51', 'Sed accumsan felis. Ut at dolor quis odio consequat varius.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (149, 476, 17, '2021-01-18 12:58:01', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (150, 415, 10, '2021-03-13 09:18:29', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (151, 317, 24, '2021-02-02 06:12:46', 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (152, 497, 16, '2021-03-11 22:37:36', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (153, 202, 20, '2021-02-09 10:06:10', 'Maecenas tincidunt lacus at velit.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (154, 386, 21, '2021-02-11 01:42:08', 'Aenean sit amet justo. Morbi ut odio.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (155, 397, 18, '2021-01-03 05:47:57', 'Sed ante.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (156, 243, 3, '2021-02-21 06:00:36', 'Aenean lectus. Pellentesque eget nunc.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (157, 44, 15, '2021-01-23 07:01:57', 'Suspendisse potenti.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (158, 425, 16, '2021-02-15 22:00:39', 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (159, 320, 7, '2021-01-14 00:19:02', 'In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (160, 109, 25, '2021-01-17 11:24:54', 'Duis bibendum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (161, 180, 20, '2021-01-05 03:44:03', 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (162, 2, 16, '2021-01-24 14:46:35', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (163, 25, 3, '2021-03-15 17:24:36', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (164, 284, 10, '2021-03-06 07:20:54', 'Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (165, 25, 23, '2021-02-20 18:48:32', 'Curabitur at ipsum ac tellus semper interdum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (166, 65, 19, '2021-01-27 20:01:44', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (167, 222, 16, '2021-03-20 21:47:28', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (168, 78, 13, '2021-02-13 02:35:12', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (169, 428, 4, '2021-02-21 08:03:47', 'Mauris sit amet eros.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (170, 449, 24, '2021-02-23 13:43:13', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (171, 366, 19, '2021-01-31 01:42:40', 'Aenean lectus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (172, 299, 18, '2021-03-12 02:43:45', 'Donec ut mauris eget massa tempor convallis.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (173, 430, 22, '2021-03-11 16:15:04', 'Donec posuere metus vitae ipsum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (174, 96, 25, '2021-02-13 18:19:21', 'Nulla tellus. In sagittis dui vel nisl. Duis ac nibh.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (175, 22, 12, '2021-01-28 05:34:29', 'Etiam justo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (176, 452, 16, '2021-01-16 04:15:50', 'Vestibulum rutrum rutrum neque.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (177, 18, 6, '2021-02-06 11:37:04', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (178, 188, 21, '2021-01-27 19:31:31', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (179, 438, 12, '2021-01-06 11:32:08', 'Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (180, 151, 18, '2021-02-06 19:21:43', 'Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (181, 92, 6, '2021-01-15 09:37:06', 'Vestibulum sed magna at nunc commodo placerat. Praesent blandit.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (182, 79, 6, '2021-02-18 01:18:40', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (183, 397, 5, '2021-01-30 09:58:15', 'Morbi ut odio.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (184, 239, 7, '2021-02-27 21:37:11', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (185, 103, 2, '2021-02-05 11:23:52', 'Integer non velit.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (186, 175, 24, '2021-03-16 21:58:37', 'Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (187, 377, 10, '2021-01-29 19:27:38', 'Vivamus tortor.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (188, 175, 16, '2021-02-26 13:42:33', 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (189, 141, 3, '2021-01-11 09:04:55', 'Curabitur in libero ut massa volutpat convallis.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (190, 110, 9, '2021-02-20 08:34:48', 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (191, 142, 3, '2021-02-03 13:36:09', 'Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (192, 46, 5, '2021-02-13 06:14:37', 'Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (193, 390, 19, '2021-01-17 15:13:18', 'In eleifend quam a odio.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (194, 473, 8, '2021-01-21 04:28:52', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (195, 433, 20, '2021-02-26 18:55:51', 'Nulla ac enim.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (196, 434, 20, '2021-03-09 14:20:20', 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (197, 272, 24, '2021-02-02 08:45:33', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (198, 88, 3, '2021-02-08 19:55:28', 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (199, 125, 25, '2021-01-11 18:30:15', 'Nulla mollis molestie lorem.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (200, 452, 14, '2021-01-19 19:27:26', 'Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (201, 222, 16, '2021-03-10 11:39:27', 'Fusce consequat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (202, 240, 7, '2021-03-22 21:24:13', 'Phasellus sit amet erat. Nulla tempus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (203, 152, 12, '2021-03-19 23:19:19', 'Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (204, 473, 17, '2021-01-23 07:27:45', 'Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (205, 394, 18, '2021-01-15 20:37:24', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (206, 238, 6, '2021-03-22 12:53:19', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (207, 377, 10, '2021-03-27 09:34:09', 'Maecenas rhoncus aliquam lacus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (208, 413, 16, '2021-03-15 05:53:11', 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (209, 139, 16, '2021-01-20 00:37:21', 'Integer ac neque.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (210, 164, 3, '2021-03-06 06:59:17', 'Morbi a ipsum. Integer a nibh.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (211, 71, 25, '2021-03-14 01:33:26', 'Nulla nisl.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (212, 115, 14, '2021-03-10 16:52:45', 'Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (213, 377, 15, '2021-01-08 02:10:16', 'Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (214, 154, 24, '2021-01-06 18:52:45', 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (215, 88, 10, '2021-03-25 02:55:41', 'Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (216, 288, 20, '2021-01-27 21:33:18', 'Nulla mollis molestie lorem.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (217, 224, 12, '2021-01-01 19:32:19', 'Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (218, 25, 23, '2021-01-13 03:11:27', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (219, 59, 12, '2021-03-06 12:17:28', 'Sed ante.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (220, 305, 6, '2021-01-18 18:48:24', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (221, 182, 16, '2021-02-10 15:25:05', 'Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (222, 429, 14, '2021-03-27 16:33:56', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (223, 65, 9, '2021-03-25 11:30:29', 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (224, 297, 3, '2021-03-14 09:43:41', 'Integer a nibh. In quis justo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (225, 284, 15, '2021-02-22 18:29:53', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (226, 165, 18, '2021-02-09 11:06:15', 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (227, 175, 14, '2021-02-08 01:39:47', 'In sagittis dui vel nisl. Duis ac nibh.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (228, 397, 19, '2021-01-16 12:05:45', 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (229, 222, 20, '2021-01-19 08:45:09', 'Phasellus in felis. Donec semper sapien a libero.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (230, 50, 16, '2021-02-17 11:01:25', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (231, 189, 11, '2021-03-16 03:17:58', 'Nunc rhoncus dui vel sem.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (232, 253, 23, '2021-02-15 18:28:13', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (233, 173, 16, '2021-03-15 21:01:51', 'Curabitur convallis.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (234, 416, 25, '2021-01-20 01:42:07', 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (235, 100, 14, '2021-02-14 01:50:51', 'Proin risus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (236, 390, 6, '2021-03-24 15:34:52', 'Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (237, 177, 6, '2021-02-21 04:26:57', 'Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (238, 134, 9, '2021-02-06 10:05:37', 'Suspendisse accumsan tortor quis turpis.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (239, 177, 9, '2021-01-14 13:26:33', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (240, 88, 19, '2021-01-02 23:33:31', 'Duis bibendum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (241, 458, 6, '2021-03-10 07:14:16', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (242, 62, 3, '2021-03-25 06:37:00', 'Aenean lectus. Pellentesque eget nunc.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (243, 22, 17, '2021-02-12 05:18:49', 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (244, 123, 12, '2021-03-21 06:34:12', 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (245, 288, 20, '2021-01-04 23:10:53', 'Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (246, 194, 22, '2021-01-18 08:02:13', 'Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (247, 151, 5, '2021-03-08 07:03:17', 'In hac habitasse platea dictumst.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (248, 160, 13, '2021-02-10 17:14:02', 'Nullam porttitor lacus at turpis.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (249, 197, 20, '2021-02-15 09:31:58', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
INSERT INTO comment (id, task, author, comment_date, comment_text) VALUES (250, 472, 16, '2021-01-09 07:27:07', 'Etiam faucibus cursus urna. Ut tellus.');


-- Comment Reply

INSERT INTO comment_reply (id, parent) VALUES (201, 41);
INSERT INTO comment_reply (id, parent) VALUES (202, 134);
INSERT INTO comment_reply (id, parent) VALUES (203, 68);
INSERT INTO comment_reply (id, parent) VALUES (204, 194);
INSERT INTO comment_reply (id, parent) VALUES (205, 40);
INSERT INTO comment_reply (id, parent) VALUES (206, 75);
INSERT INTO comment_reply (id, parent) VALUES (207, 59);
INSERT INTO comment_reply (id, parent) VALUES (208, 114);
INSERT INTO comment_reply (id, parent) VALUES (209, 96);
INSERT INTO comment_reply (id, parent) VALUES (210, 23);
INSERT INTO comment_reply (id, parent) VALUES (211, 90);
INSERT INTO comment_reply (id, parent) VALUES (212, 80);
INSERT INTO comment_reply (id, parent) VALUES (213, 59);
INSERT INTO comment_reply (id, parent) VALUES (214, 105);
INSERT INTO comment_reply (id, parent) VALUES (215, 9);
INSERT INTO comment_reply (id, parent) VALUES (216, 117);
INSERT INTO comment_reply (id, parent) VALUES (217, 18);
INSERT INTO comment_reply (id, parent) VALUES (218, 165);
INSERT INTO comment_reply (id, parent) VALUES (219, 132);
INSERT INTO comment_reply (id, parent) VALUES (220, 109);
INSERT INTO comment_reply (id, parent) VALUES (221, 131);
INSERT INTO comment_reply (id, parent) VALUES (222, 67);
INSERT INTO comment_reply (id, parent) VALUES (223, 166);
INSERT INTO comment_reply (id, parent) VALUES (224, 99);
INSERT INTO comment_reply (id, parent) VALUES (225, 164);
INSERT INTO comment_reply (id, parent) VALUES (226, 147);
INSERT INTO comment_reply (id, parent) VALUES (227, 186);
INSERT INTO comment_reply (id, parent) VALUES (228, 155);
INSERT INTO comment_reply (id, parent) VALUES (229, 167);
INSERT INTO comment_reply (id, parent) VALUES (230, 32);
INSERT INTO comment_reply (id, parent) VALUES (231, 91);
INSERT INTO comment_reply (id, parent) VALUES (232, 58);
INSERT INTO comment_reply (id, parent) VALUES (233, 39);
INSERT INTO comment_reply (id, parent) VALUES (234, 110);
INSERT INTO comment_reply (id, parent) VALUES (235, 29);
INSERT INTO comment_reply (id, parent) VALUES (236, 193);
INSERT INTO comment_reply (id, parent) VALUES (237, 133);
INSERT INTO comment_reply (id, parent) VALUES (238, 92);
INSERT INTO comment_reply (id, parent) VALUES (239, 133);
INSERT INTO comment_reply (id, parent) VALUES (240, 9);
INSERT INTO comment_reply (id, parent) VALUES (241, 36);
INSERT INTO comment_reply (id, parent) VALUES (242, 55);
INSERT INTO comment_reply (id, parent) VALUES (243, 84);
INSERT INTO comment_reply (id, parent) VALUES (244, 104);
INSERT INTO comment_reply (id, parent) VALUES (245, 117);
INSERT INTO comment_reply (id, parent) VALUES (246, 31);
INSERT INTO comment_reply (id, parent) VALUES (247, 106);
INSERT INTO comment_reply (id, parent) VALUES (248, 37);
INSERT INTO comment_reply (id, parent) VALUES (249, 62);
INSERT INTO comment_reply (id, parent) VALUES (250, 111);


-- Social Media Account

INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (1, 'Facebook', 'kglanville0', '1K6jKsRF9iWkpVzuomg1qgarhFuN524LCT');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (2, 'Instagram', 'ccossans1', '12oPxqZsY24CPm7ciVBiEHvk6WNauR7S9b');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (3, 'Facebook', 'pbhatia2', '1NKZA3eQBiMiVLMXPPzS7CE5ByvtnGiSU8');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (4, 'Instagram', 'rjoicey3', '1Lnj4wfSKM3SApcMJHrarMKNX5euto8NsD');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (5, 'Instagram', 'krunnicles4', '16bs2dMg4b6xPY4k8UKax2Z5gsVztXGh87');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (6, 'Instagram', 'mtripe5', '1K5F1MaT3LJ71Pe4SbZqYRw7LGDeWtVNto');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (7, 'Facebook', 'mthurlbeck6', '1P2VNu9d2souw5ALS21ZmUrtkHo1PyJNmD');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (8, 'Facebook', 'cbecraft7', '197Deij7BUhkoDcEuTG6J8GPoWxH8WaofJ');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (9, 'Instagram', 'ysheers8', '1AaDJ6PHGiqPAfW9B3TcViaKrao5fiYBgz');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (10, 'Instagram', 'fdobbyn9', '1ETR8FKZETcdKeoBf27R6yVtTYq2T3XPiD');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (11, 'Instagram', 'agulca', '1AmYm9w94xrURUbH1aSdV7wQ2gFjVbHk8h');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (12, 'Twitter', 'eanglissb', '1CYmQsRN2e1T1gQ2dixfxKYrm2kdEjyuK2');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (13, 'Instagram', 'ccorbouldc', '1SF1oogP96CvNnpNExqqSrGGE1gd9Yzu9');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (14, 'Instagram', 'emeadend', '12e71U1kCtFkyzbanyVahAhaQeNvdcexYg');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (15, 'Facebook', 'irishbrooke', '1BgQ7sJTy2n49L6x154g7RTZH49kKt9vKp');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (16, 'Facebook', 'pmarshf', '1KxRDoER2xT1wAgjtUDxHkwzzoes5fQJTm');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (17, 'Twitter', 'cpinnickg', '1GDCFDoTueAuHqJNFwYJsEvxoNJTJe4Jkr');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (18, 'Twitter', 'sassenderh', '18g7CFvJj3ha46zVgkCkkzZPbwnuLZp2FL');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (19, 'Instagram', 'wsurgeoneri', '1QAgQmGKZPR1FNinakMyZ6NykkP9W2WmzP');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (20, 'Instagram', 'mdurhamj', '1A5cz11yjYsWYUDc5ukqzEAW5pwktD7BSY');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (21, 'Instagram', 'mcasbonk', '1FodXT8rmD5tZidJrb32aov7zDrMQ2u2T7');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (22, 'Instagram', 'jgreenhilll', '19iJAGge8JTMCTdVWG6ZW3ULULsZwYNVe7');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (23, 'Facebook', 'htoulchm', '1KhiDkWpD8V6o9SCQrhxCEF6cVQQ6Tu2Bb');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (24, 'Facebook', 'vvasiltsovn', '1A4H1GNJ2awqevFQ63uL2GBoU1VSUf5tnp');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (25, 'Instagram', 'ctiddemano', '1MwshQmhU87To8TQXgkMHnMSrKFwmL4qVS');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (26, 'Twitter', 'apickburnp', '17UPxUDmBo4TgnW2M2mz83NWBM2A6X3NN1');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (27, 'Twitter', 'adudmeshq', '13T2cMXrBUEBeEqr8NQg4DSQD8aBXLKMXv');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (28, 'Facebook', 'dhakenr', '1JL1d5NwxKELqWSWq8nwGufsDn8GTmTCdg');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (29, 'Facebook', 'kvynalls', '1C1P1jVfBWcjc4EYea6kKzeqe3juHPtvyL');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (30, 'Instagram', 'thurcht', '1KcTaNexV4quuiQ3tcC9dRsSQ4foKSDPAi');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (31, 'Facebook', 'hfrymanu', '1F1MWZsM6Ju8kHZ63wWcBp1gdorgwzwpTQ');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (32, 'Instagram', 'ldorwoodv', '14PC1QuQ42i3gMbpXH3AuM1MdoSLpzGHBk');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (33, 'Facebook', 'mbattenw', '1EzchMtApdoWN4gea5hy1w4jaS4DZCK3R1');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (34, 'Facebook', 'mdavionx', '1HVuaBRa1WNXNj2eohF9nbmw3X7FKXT1cY');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (35, 'Instagram', 'wpassinghamy', '1J1qGSg8YY9ddQVFrsDqAdnKFkQuSpyocL');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (36, 'Instagram', 'ibalchenz', '1NMywbSuY3fQZaW76NJntn7b1azbEVhq4b');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (37, 'Twitter', 'gstronough10', '1P5JxXE5byaYL5p29Li5zSqxaQFhSDJLdZ');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (38, 'Instagram', 'nlane11', '15nYeowU1dfeJcqcKgYmBgVwgy1kT1N1fd');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (39, 'Twitter', 'kcelier12', '1G6oSQvAEKuA1VyJ8wvhHRUxPQYFmMUvEk');
INSERT INTO social_media_account (id, social_media, username, access_token) VALUES (40, 'Instagram', 'dlidgate13', '183NV6sbmqPQCWd5sinBhKSxpNWfPJsfHr');


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

INSERT INTO report (id, report_text, reporter, reported) VALUES (1, 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 21, 3);
INSERT INTO report (id, report_text, reporter, reported) VALUES (2, 'In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', 14, 8);
INSERT INTO report (id, report_text, reporter, reported) VALUES (3, 'Morbi non quam nec dui luctus rutrum. Nulla tellus.', 25, 13);

