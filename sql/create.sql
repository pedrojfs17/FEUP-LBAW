DROP TABLE IF EXISTS "user";
DROP TABLE IF EXISTS admin;
DROP TABLE IF EXISTS country;
DROP TABLE IF EXISTS client;
DROP TABLE IF EXISTS project;
DROP TABLE IF EXISTS team_member;
DROP TABLE IF EXISTS task;
DROP TABLE IF EXISTS waiting_on;
DROP TABLE IF EXISTS "assignment";
DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS contains_tag;
DROP TABLE IF EXISTS check_list_item;
DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS social_media_account;
DROP TABLE IF EXISTS associated_project_account;
DROP TABLE IF EXISTS associated_client_account;
DROP TABLE IF EXISTS report;
DROP TABLE IF EXISTS notification;
DROP TABLE IF EXISTS comment_notification;
DROP TABLE IF EXISTS assignment_notification;
DROP TABLE IF EXISTS project_notification;
DROP TABLE IF EXISTS report_notification;

DROP TYPE IF EXISTS today;
DROP TYPE IF EXISTS status;
DROP TYPE IF EXISTS gender;
DROP TYPE IF EXISTS role;

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

-- Tables

CREATE TABLE "user" (
    id SERIAL PRIMARY KEY,
    username VARCHAR UNIQUE NOT NULL,
    password VARCHAR NOT NULL,
    email VARCHAR UNIQUE NOT NULL
);

CREATE TABLE admin (
    id INTEGER PRIMARY KEY NOT NULL REFERENCES "user"(id)
);

CREATE TABLE country (
    id SERIAL PRIMARY KEY,
    iso char(2) NOT NULL,
    name varchar(80) NOT NULL
);

CREATE TABLE client (
    id INTEGER PRIMARY KEY NOT NULL REFERENCES "user"(id),
    fullname VARCHAR,
    company VARCHAR,
    avatar VARCHAR,
    color VARCHAR,
    client_gender gender DEFAULT 'Unspecified',
    country INTEGER NOT NULL REFERENCES country(id)
);

CREATE TABLE project (
    id SERIAL PRIMARY KEY,
    proj_name VARCHAR NOT NULL,
    proj_description VARCHAR NOT NULL,
    due_date DATE CHECK (due_date > CURRENT_DATE)
);

CREATE TABLE team_member (
    client_id INTEGER NOT NULL REFERENCES client(id),
    project_id INTEGER NOT NULL REFERENCES project(id),
    member_role role,
    PRIMARY KEY (client_id, project_id)
);

CREATE TABLE task (
    id SERIAL PRIMARY KEY,
    project INTEGER NOT NULL REFERENCES project(id),
    task_name VARCHAR NOT NULL,
    task_description VARCHAR NOT NULL,
    due_date TIMESTAMP,
    task_status status,
    parent_task INTEGER REFERENCES task(id)   
);

CREATE TABLE waiting_on (
    task1 INTEGER NOT NULL REFERENCES task(id),
    task2 INTEGER NOT NULL REFERENCES task(id),
    PRIMARY KEY (task1,task2)
);

-- Needs fix because team_member PK is (client, project) but we dont need to save the project id in the assginement
-- because it is already in the task
CREATE TABLE "assignment" (
    task INTEGER NOT NULL REFERENCES task(id),
    team_member INTEGER NOT NULL REFERENCES team_member(client_id),
    PRIMARY KEY (task, team_member)
);

CREATE TABLE tag (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES project(id),
    tag_name VARCHAR NOT NULL,
    color VARCHAR
);

CREATE TABLE contains_tag (
    tag INTEGER NOT NULL REFERENCES tag(id),
    task INTEGER NOT NULL REFERENCES task(id),
    PRIMARY KEY (tag, task)
);

CREATE TABLE check_list_item (
    id SERIAL PRIMARY KEY,
    item_text VARCHAR NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT "false",
    task INTEGER NOT NULL REFERENCES task(id) 
);

CREATE TABLE comment (
    id SERIAL PRIMARY KEY,
    comment_text VARCHAR,
    task INTEGER NOT NULL REFERENCES task(id),
    author INTEGER NOT NULL REFERENCES teamMember(id),
    replyingTo INTEGER NOT NULL REFERENCES comment(id),
    comment_date TIMESTAMP NOT NULL
);

CREATE TABLE social_media_account (
    id SERIAL PRIMARY KEY,
    username VARCHAR NOT NULL,
    access_token VARCHAR NOT NULL
);

CREATE TABLE associated_project_account (
    social_media_account INTEGER NOT NULL REFERENCES social_media_account(id),
    project INTEGER NOT NULL REFERENCES project,
    PRIMARY KEY (social_media_account, project)
);

CREATE TABLE associated_client_account (
    social_media_account INTEGER NOT NULL REFERENCES social_media_account(id),
    client INTEGER NOT NULL REFERENCES client,
    PRIMARY KEY (social_media_account, client)
);

CREATE TABLE report (
    id SERIAL PRIMARY KEY,
    text VARCHAR NOT NULL,
    reporter INTEGER NOT NULL REFERENCES client(id),
    reported INTEGER NOT NULL REFERENCES client(id)
);

CREATE TABLE notification (
    id SERIAL PRIMARY KEY,
    client INTEGER NOT NULL REFERENCES client(id),
    seen BOOLEAN NOT NULL DEFAULT "false",
    text VARCHAR NOT NULL
);

CREATE TABLE comment_notification (
    id SERIAL PRIMARY KEY,
    notification INTEGER NOT NULL REFERENCES notification(id),
    comment INTEGER NOT NULL REFERENCES comment(id) 
);

CREATE TABLE assignment_notification (
    id SERIAL PRIMARY KEY,
    notification INTEGER NOT NULL REFERENCES notification(id),
    assignment INTEGER NOT NULL REFERENCES task(id)
);

CREATE TABLE project_notification (
    id SERIAL PRIMARY KEY,
    notification INTEGER NOT NULL REFERENCES notification(id),
    project INTEGER NOT NULL REFERENCES project(id)
);

CREATE TABLE report_notification (
    id SERIAL PRIMARY KEY,
    notification INTEGER NOT NULL REFERENCES notification(id),
    report INTEGER NOT NULL REFERENCES report(id)
);