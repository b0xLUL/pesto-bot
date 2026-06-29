use Pesto;

create definer = pesto@`%` view AllChecks as
select `AllChecks`.`user_id`          AS `user_id`,
       `AllChecks`.`pp_power`         AS `pp_power`,
       `AllChecks`.`pp_expires`       AS `pp_expires`,
       `AllChecks`.`clueless_power`   AS `clueless_power`,
       `AllChecks`.`clueless_expires` AS `clueless_expires`,
       `AllChecks`.`copium_power`     AS `copium_power`,
       `AllChecks`.`copium_expires`   AS `copium_expires`,
       `AllChecks`.`horni_power`      AS `horni_power`,
       `AllChecks`.`horni_expires`    AS `horni_expires`
from (select `PPC`.`user_id`         AS `user_id`,
             `PPC`.`pp_power`        AS `pp_power`,
             `PPC`.`pp_expires`      AS `pp_expires`,
             `CL`.`clueless_power`   AS `clueless_power`,
             `CL`.`clueless_expires` AS `clueless_expires`,
             `CP`.`copium_power`     AS `copium_power`,
             `CP`.`copium_expires`   AS `copium_expires`,
             `HC`.`horni_power`      AS `horni_power`,
             `HC`.`horni_expires`    AS `horni_expires`
      from ((((select `PPC`.`user_id` AS `user_id`, `PPC`.`power` AS `pp_power`, `PPC`.`expires` AS `pp_expires`
               from `Pesto`.`PPCheck` `PPC`
               where `PPC`.`time` = (select max(`Pesto`.`PPCheck`.`time`)
                                     from `Pesto`.`PPCheck`
                                     where `Pesto`.`PPCheck`.`user_id` = `PPC`.`user_id`)) `PPC` left join (select `CL`.`user_id` AS `user_id`,
                                                                                                                   `CL`.`power`   AS `clueless_power`,
                                                                                                                   `CL`.`expires` AS `clueless_expires`
                                                                                                            from `Pesto`.`Clueless` `CL`
                                                                                                            where
                                                                                                                `CL`.`expires` =
                                                                                                                (select max(`Pesto`.`Clueless`.`expires`)
                                                                                                                 from `Pesto`.`Clueless`
                                                                                                                 where `Pesto`.`Clueless`.`user_id` = `CL`.`user_id`)) `CL`
              on (`PPC`.`user_id` = `CL`.`user_id`)) left join (select `CP`.`user_id` AS `user_id`,
                                                                       `CP`.`power`   AS `copium_power`,
                                                                       `CP`.`expires` AS `copium_expires`
                                                                from `Pesto`.`Copium` `CP`
                                                                where `CP`.`expires` =
                                                                      (select max(`Pesto`.`Clueless`.`expires`)
                                                                       from `Pesto`.`Clueless`
                                                                       where `Pesto`.`Clueless`.`user_id` = `CP`.`user_id`)) `CP`
             on (`PPC`.`user_id` = `CP`.`user_id`)) left join (select `HC`.`user_id` AS `user_id`,
                                                                      `HC`.`power`   AS `horni_power`,
                                                                      `HC`.`expires` AS `horni_expires`
                                                               from `Pesto`.`HorniCheck` `HC`
                                                               where `HC`.`expires` =
                                                                     (select max(`Pesto`.`HorniCheck`.`expires`)
                                                                      from `Pesto`.`HorniCheck`
                                                                      where `Pesto`.`HorniCheck`.`user_id` = `HC`.`user_id`)) `HC`
            on (`PPC`.`user_id` = `HC`.`user_id`))) `AllChecks`
group by `AllChecks`.`user_id`;

create definer = pesto@`%` view TeamData as
select `Pesto`.`Team`.`id`          AS `id`,
       `Pesto`.`Team`.`name`        AS `name`,
       `Pesto`.`Team`.`tag`         AS `tag`,
       coalesce(`TM`.`users`, '[]') AS `users`
from (`Pesto`.`Team` left join (select `Pesto`.`TeamMembers`.`team_id`                              AS `team_id`,
                                       json_arrayagg(json_object('id', `Pesto`.`TeamMembers`.`user_id`, 'joined_at',
                                                                 `Pesto`.`TeamMembers`.`joined_at`, 'is_owner',
                                                                 `Pesto`.`TeamMembers`.`is_owner`)) AS `users`
                                from `Pesto`.`TeamMembers`
                                group by `Pesto`.`TeamMembers`.`team_id`) `TM`
      on (`Pesto`.`Team`.`id` = `TM`.`team_id`));

create definer = pesto@`%` view TheCouncil as
select `combined`.`user_id`                                                AS `user_id`,
       round(avg(`combined`.`power`), 2)                                   AS `avg_power`,
       count(0)                                                            AS `total_rolls`,
       round(avg(least(`combined`.`power`, 100)) * log10(count(0) + 1), 2) AS `score`
from (select `Pesto`.`PPCheck`.`user_id` AS `user_id`,
             `Pesto`.`PPCheck`.`power`   AS `power`,
             `Pesto`.`PPCheck`.`expires` AS `expires`
      from `Pesto`.`PPCheck`
      where `Pesto`.`PPCheck`.`expires` >=
            unix_timestamp(date_format(curdate() - interval 1 month, '%Y-%m-01 00:00:00')) * 1000
        and `Pesto`.`PPCheck`.`expires` < unix_timestamp(date_format(curdate(), '%Y-%m-01 00:00:00')) * 1000
        and `Pesto`.`PPCheck`.`user_id` not in ('236642620506374145', '124963012321738752')
      union all
      select `Pesto`.`Clueless`.`user_id` AS `user_id`,
             `Pesto`.`Clueless`.`power`   AS `power`,
             `Pesto`.`Clueless`.`expires` AS `expires`
      from `Pesto`.`Clueless`
      where `Pesto`.`Clueless`.`expires` >=
            unix_timestamp(date_format(curdate() - interval 1 month, '%Y-%m-01 00:00:00')) * 1000
        and `Pesto`.`Clueless`.`expires` < unix_timestamp(date_format(curdate(), '%Y-%m-01 00:00:00')) * 1000
        and `Pesto`.`Clueless`.`user_id` not in ('236642620506374145', '124963012321738752')
      union all
      select `Pesto`.`Copium`.`user_id` AS `user_id`,
             `Pesto`.`Copium`.`power`   AS `power`,
             `Pesto`.`Copium`.`expires` AS `expires`
      from `Pesto`.`Copium`
      where `Pesto`.`Copium`.`expires` >=
            unix_timestamp(date_format(curdate() - interval 1 month, '%Y-%m-01 00:00:00')) * 1000
        and `Pesto`.`Copium`.`expires` < unix_timestamp(date_format(curdate(), '%Y-%m-01 00:00:00')) * 1000
        and `Pesto`.`Copium`.`user_id` not in ('236642620506374145', '124963012321738752')
      union all
      select `Pesto`.`HorniCheck`.`user_id` AS `user_id`,
             `Pesto`.`HorniCheck`.`power`   AS `power`,
             `Pesto`.`HorniCheck`.`expires` AS `expires`
      from `Pesto`.`HorniCheck`
      where `Pesto`.`HorniCheck`.`expires` >=
            unix_timestamp(date_format(curdate() - interval 1 month, '%Y-%m-01 00:00:00')) * 1000
        and `Pesto`.`HorniCheck`.`expires` < unix_timestamp(date_format(curdate(), '%Y-%m-01 00:00:00')) * 1000
        and `Pesto`.`HorniCheck`.`user_id` not in ('236642620506374145', '124963012321738752')) `combined`
group by `combined`.`user_id`
having `total_rolls` >= 20
order by round(avg(least(`combined`.`power`, 100)) * log10(count(0) + 1), 2) desc
limit 10;

create definer = pesto@`%` view TheCouncilFull as
select `combined`.`user_id`                                                AS `user_id`,
       round(avg(`combined`.`power`), 2)                                   AS `avg_power`,
       count(0)                                                            AS `total_rolls`,
       round(avg(least(`combined`.`power`, 100)) * log10(count(0) + 1), 2) AS `score`
from (select `Pesto`.`PPCheck`.`user_id` AS `user_id`,
             `Pesto`.`PPCheck`.`power`   AS `power`,
             `Pesto`.`PPCheck`.`expires` AS `expires`
      from `Pesto`.`PPCheck`
      where `Pesto`.`PPCheck`.`expires` >=
            unix_timestamp(date_format(curdate() - interval 1 month, '%Y-%m-01 00:00:00')) * 1000
        and `Pesto`.`PPCheck`.`expires` < unix_timestamp(date_format(curdate(), '%Y-%m-01 00:00:00')) * 1000
      union all
      select `Pesto`.`Clueless`.`user_id` AS `user_id`,
             `Pesto`.`Clueless`.`power`   AS `power`,
             `Pesto`.`Clueless`.`expires` AS `expires`
      from `Pesto`.`Clueless`
      where `Pesto`.`Clueless`.`expires` >=
            unix_timestamp(date_format(curdate() - interval 1 month, '%Y-%m-01 00:00:00')) * 1000
        and `Pesto`.`Clueless`.`expires` < unix_timestamp(date_format(curdate(), '%Y-%m-01 00:00:00')) * 1000
      union all
      select `Pesto`.`Copium`.`user_id` AS `user_id`,
             `Pesto`.`Copium`.`power`   AS `power`,
             `Pesto`.`Copium`.`expires` AS `expires`
      from `Pesto`.`Copium`
      where `Pesto`.`Copium`.`expires` >=
            unix_timestamp(date_format(curdate() - interval 1 month, '%Y-%m-01 00:00:00')) * 1000
        and `Pesto`.`Copium`.`expires` < unix_timestamp(date_format(curdate(), '%Y-%m-01 00:00:00')) * 1000
      union all
      select `Pesto`.`HorniCheck`.`user_id` AS `user_id`,
             `Pesto`.`HorniCheck`.`power`   AS `power`,
             `Pesto`.`HorniCheck`.`expires` AS `expires`
      from `Pesto`.`HorniCheck`
      where `Pesto`.`HorniCheck`.`expires` >=
            unix_timestamp(date_format(curdate() - interval 1 month, '%Y-%m-01 00:00:00')) * 1000
        and `Pesto`.`HorniCheck`.`expires` <
            unix_timestamp(date_format(curdate(), '%Y-%m-01 00:00:00')) * 1000) `combined`
group by `combined`.`user_id`
having `total_rolls` >= 20
order by round(avg(least(`combined`.`power`, 100)) * log10(count(0) + 1), 2) desc;

