#
#join syntax
#
drop table if exists a_test_no_shard
drop table if exists a_order_no_shard
drop table if exists a_manager_no_shard
CREATE TABLE a_test_no_shard(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_order_no_shard(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_manager_no_shard(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
insert into a_test_no_shard values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)
insert into a_order_no_shard values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1)
insert into a_manager_no_shard values(1,1,'manager中id为1',1),(2,2,'test_2',2),(3,3,'manager中id为3',3),(4,4,'$manager$4',4),(5,5,'manager...5',6)
select * from a_test_no_shard,a_order_no_shard where a_test_no_shard.pad=a_order_no_shard.pad
select * from a_test_no_shard a,a_order_no_shard b where a.pad=b.pad
select a.id,b.id,b.pad,a.t_id from a_test_no_shard a,(select * from a_order_no_shard where pad>3) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from (select id,t_id from a_test_no_shard) a,(select * from a_order_no_shard) b where a.t_id=b.o_id
select a.id,b.id,b.pad,a.t_id from (select a_test_no_shard.id,a_test_no_shard.pad,a_test_no_shard.t_id from a_test_no_shard join a_order_no_shard where a_test_no_shard.pad=a_order_no_shard.pad ) a,(select a_manager_no_shard.id,a_manager_no_shard.pad from a_test_no_shard join a_manager_no_shard where a_test_no_shard.pad=a_manager_no_shard.pad) b where a.pad=b.pad
select a_test_no_shard.id,a_test_no_shard.name,a.name from a_test_no_shard,(select name from a_order_no_shard) a
select * from a_test_no_shard inner join a_order_no_shard order by a_test_no_shard.id,a_order_no_shard.id
select * from a_test_no_shard cross join a_order_no_shard order by a_test_no_shard.id,a_order_no_shard.id
select * from a_test_no_shard join a_order_no_shard order by a_test_no_shard.id,a_order_no_shard.id
select a.id,a.name,a.pad,b.name from a_test_no_shard a inner join a_order_no_shard b order by a.id,b.id
select a.id,a.name,a.pad,b.name from a_test_no_shard a cross join a_order_no_shard b order by a.id,b.id
select a.id,a.name,a.pad,b.name from a_test_no_shard a join a_order_no_shard b order by a.id,b.id
select * from a_test_no_shard a inner join (select * from a_order_no_shard where pad>0) b order by a.id,b.id
select * from a_test_no_shard a cross join (select * from a_order_no_shard where pad>0) b order by a.id,b.id
select * from a_test_no_shard a join (select * from a_order_no_shard where pad>0) b order by a.id,b.id
select * from (select * from a_test_no_shard where pad>0) a inner join (select * from a_order_no_shard where pad>0) b order by a.id,b.id
select * from (select * from a_test_no_shard where pad>0) a cross join (select * from a_order_no_shard where pad>0) b order by a.id,b.id
select * from (select * from a_test_no_shard where pad>0) a join (select * from a_order_no_shard where pad>0) b order by a.id,b.id
select * from a_test_no_shard a join (select * from a_order_no_shard where pad>0) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select * from a_test_no_shard a join (select * from a_order_no_shard where pad>0) b  using(pad) order by a.id,b.id
select * from a_test_no_shard straight_join a_order_no_shard order by a_test_no_shard.id,a_order_no_shard.id
select a.id,a.name,a.pad,b.name from a_test_no_shard a straight_join a_order_no_shard b order by a.id,b.id
select * from a_test_no_shard a straight_join (select * from a_order_no_shard where pad>0) b order by a.id,b.id
select * from (select * from a_test_no_shard where pad>0) a straight_join (select * from a_order_no_shard where pad>0) b order by a.id,b.id
select * from a_test_no_shard a straight_join (select * from a_order_no_shard where pad>0) b on a.id<b.id and a.pad=b.pad order by a.id,b.id
select * from a_test_no_shard left join a_order_no_shard on a_test_no_shard.pad=a_order_no_shard.pad order by a_test_no_shard.id,a_order_no_shard.id
select * from a_test_no_shard right join a_order_no_shard on a_test_no_shard.pad=a_order_no_shard.pad order by a_test_no_shard.id,a_order_no_shard.id
select * from a_test_no_shard left outer join a_order_no_shard on a_test_no_shard.pad=a_order_no_shard.pad order by a_test_no_shard.id,a_order_no_shard.id
select * from a_test_no_shard right outer join a_order_no_shard on a_test_no_shard.pad=a_order_no_shard.pad order by a_test_no_shard.id,a_order_no_shard.id
select * from a_test_no_shard left join a_order_no_shard using(pad) order by a_test_no_shard.id,a_order_no_shard.id
select * from a_test_no_shard a left join a_order_no_shard b on a.pad=b.pad order by a.id,b.id
select * from a_test_no_shard a right join a_order_no_shard b on a.pad=b.pad order by a.id,b.id
select * from a_test_no_shard a left outer join a_order_no_shard b on a.pad=b.pad order by a.id,b.id
select * from a_test_no_shard a right outer join a_order_no_shard b on a.pad=b.pad order by a.id,b.id
select * from a_test_no_shard a left join a_order_no_shard b using(pad) order by a.id,b.id
select * from a_test_no_shard a left join (select * from a_order_no_shard where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from a_test_no_shard a right join (select * from a_order_no_shard where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from a_test_no_shard a left outer join (select * from a_order_no_shard where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from a_test_no_shard a right outer join (select * from a_order_no_shard where pad>2) b on a.pad=b.pad order by a.id,b.id
select * from a_test_no_shard a left join (select * from a_order_no_shard where pad>2) b using(pad) order by a.id,b.id
select * from (select * from a_test_no_shard where pad>1) a left join (select * from a_order_no_shard where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from a_test_no_shard where pad>1) a right join (select * from a_order_no_shard where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from a_test_no_shard where pad>1) a left outer join (select * from a_order_no_shard where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from a_test_no_shard where pad>1) a right outer join (select * from a_order_no_shard where pad>3) b on a.pad=b.pad order by a.id,b.id
select * from (select * from a_test_no_shard where pad>1) a left join (select * from a_order_no_shard where pad>3) b using(pad) order by a.id,b.id
select * from a_test_no_shard natural left join a_order_no_shard
select * from a_test_no_shard natural right join a_order_no_shard
select * from a_test_no_shard natural left outer join a_order_no_shard
select * from a_test_no_shard natural right outer join a_order_no_shard
select * from a_test_no_shard a natural left join a_order_no_shard b order by a.id,b.id
select * from a_test_no_shard a natural right join a_order_no_shard b order by a.id,b.id
select * from a_test_no_shard a natural left outer join a_order_no_shard b order by a.id,b.id
select * from a_test_no_shard a natural right outer join a_order_no_shard b order by a.id,b.id
select * from a_test_no_shard a natural left join (select * from a_order_no_shard where pad>2) b order by a.id,b.id
select * from a_test_no_shard a natural right join (select * from a_order_no_shard where pad>2) b order by a.id,b.id
select * from a_test_no_shard a natural left outer join (select * from a_order_no_shard where pad>2) b order by a.id,b.id
select * from a_test_no_shard a natural right outer join (select * from a_order_no_shard where pad>2) b order by a.id,b.id
select * from (select * from a_test_no_shard where pad>1) a natural left join (select * from a_order_no_shard where pad>3) b order by a.id,b.id
select * from (select * from a_test_no_shard where pad>1) a natural right join (select * from a_order_no_shard where pad>3) b order by a.id,b.id
select * from (select * from a_test_no_shard where pad>1) a natural left outer join (select * from a_order_no_shard where pad>3) b order by a.id,b.id
select * from (select * from a_test_no_shard where pad>1) a natural right outer join (select * from a_order_no_shard where pad>3) b order by a.id,b.id
select * from a_test_no_shard left join a_order_no_shard on a_test_no_shard.pad=a_order_no_shard.pad and a_test_no_shard.id>3 order by a_test_no_shard.id,a_order_no_shard.id
#
#distinct(special_scene)
#
(select pad from a_test_no_shard) union distinct (select pad from a_order_no_shard)
(select * from a_test_no_shard where id=2) union distinct (select * from a_order_no_shard where id=2)
select distinct a.pad from a_test_no_shard a,a_order_no_shard b where a.pad=b.pad
select distinct b.pad,a.pad from a_test_no_shard a,(select * from a_order_no_shard where pad=1) b where a.t_id=b.o_id
select count(distinct pad,name),avg(distinct t_id) from a_test_no_shard
select count(distinct id),sum(distinct name) from a_test_no_shard where id=3 or id=7
