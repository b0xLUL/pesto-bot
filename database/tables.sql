CREATE OR REPLACE DATABASE Pesto;

use Pesto;

create table Clueless
(
    id      int auto_increment
        primary key,
    user_id varchar(20)   not null,
    power   int default 0 not null,
    expires bigint        not null
);

create table Copium
(
    id      int auto_increment
        primary key,
    user_id varchar(20) not null,
    power   int         not null,
    expires bigint      not null
);

create table HorniCheck
(
    id      int auto_increment
        primary key,
    user_id varchar(20) not null,
    power   int         not null,
    expires bigint      not null
);

create table PPCheck
(
    id      int auto_increment
        primary key,
    user_id varchar(20) not null,
    power   int         not null,
    time    bigint      not null,
    expires bigint      not null
);

create table Team
(
    id   int auto_increment
        primary key,
    name varchar(32) not null,
    tag  varchar(4)  not null,
    constraint Team_pk_2
        unique (name)
);

create table TeamMembers
(
    team_id   int                  not null,
    user_id   varchar(20)          not null,
    is_owner  tinyint(1) default 0 not null,
    joined_at int                  not null,
    primary key (team_id, user_id),
    constraint TeamMembers_Team_id_fk
        foreign key (team_id) references Team (id)
            on delete cascade
);

create table Wallet
(
    id          varchar(20)      not null
        primary key,
    coins       int    default 0 not null,
    total_coins bigint default 0 not null
);

create table WalletHistory
(
    id         varchar(20)      not null comment 'The user''s discord id',
    type       varchar(20)      not null,
    coins      bigint default 0 not null,
    created_at bigint           not null,
    expires_at bigint           not null
);