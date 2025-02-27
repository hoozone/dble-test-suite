# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/1 PM1:35
# @Author  : irene-coming
import logging
from threading import Thread

from steps.lib.utils import get_node
from steps.lib.Flag import Flag
from steps.lib.DbleObject import DbleObject
from steps.lib.PostQueryCheck import PostQueryCheck
from steps.lib.PreQueryPrepare import PreQueryPrepare
from steps.lib.QueryMeta import QueryMeta
from steps.lib.ObjectFactory import ObjectFactory
from behave import *
import time

global sql_threads
sql_threads = []

logger = logging.getLogger('root')


@Given('restart mysql in "{host_name}" with sed cmds to update mysql config')
@Given('restart mysql in "{host_name}"')
def restart_mysql(context, host_name, sed_str=None):
    if not sed_str and context.text is not None and len(context.text) > 0:
        sed_str = context.text

    mysql = ObjectFactory.create_mysql_object(host_name)
    # this is temp for debug stop mysql fail
    execute_sql_in_host(host_name, {'sql': 'show processlist'})
    # end debug stop mysql fail
    mysql.restart(sed_str)


@Given('stop mysql in host "{host_name}"')
def stop_mysql(context, host_name):
    mysql = ObjectFactory.create_mysql_object(host_name)

    # this is temp for debug stop mysql fail
    execute_sql_in_host(host_name, {'sql': 'show processlist'})
    # end debug stop mysql fail

    mysql.stop()


@Given('start mysql in host "{host_name}"')
def start_mysql(context, host_name, sed_str=None):
    if not sed_str and context.text is not None and len(context.text) > 0:
        sed_str = context.text

    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.start(sed_str)


@Given('turn on general log in "{host_name}"')
def step_impl(context, host_name):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.turn_on_general_log()


@Given('turn off general log in "{host_name}"')
def turn_off_general_log(context, host_name):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.turn_off_general_log()


@Then('check general log in host "{host_name}" has not "{query}"')
def step_impl(context, host_name, query):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.check_query_in_general_log(query, expect_exist=False)


@Then('check general log in host "{host_name}" has "{query}"')
@Then('check general log in host "{host_name}" has "{query}" occured "{occur_times_expr}" times')
def step_impl(context, host_name, query, occur_times_expr=None):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.check_query_in_general_log(query, expect_exist=True, expect_occur_times_expr=occur_times_expr)


@Given('execute sql in "{host_name}"')
@Then('execute sql in "{host_name}"')
def step_impl(context, host_name):
    for row in context.table:
        execute_sql_in_host(host_name, row.as_dict())


def execute_sql_in_host(host_name, info_dic, mode="mysql"):
    if mode in ["admin", "user"]:  # query to dble
        obj = ObjectFactory.create_dble_object(host_name)
        query_meta = QueryMeta(info_dic, mode, obj._dble_meta)
    else:
        obj = ObjectFactory.create_mysql_object(host_name)
        query_meta = QueryMeta(info_dic, mode, obj._mysql_meta)

    pre_delegater = PreQueryPrepare(query_meta)
    pre_delegater.prepare()

    if not info_dic.get("timeout") :
        timeout = 1
    elif "," in info_dic.get("timeout"):
        timeout=int(info_dic.get("timeout").split(",")[0])
        sep_time=float(info_dic.get("timeout").split(",")[1])
    else:
        timeout=int(info_dic.get("timeout"))
        sep_time=1

    for i in range(timeout):
        try:
            res, err, time_cost = obj.do_execute_query(query_meta)
            post_delegater = PostQueryCheck(res, err, time_cost, query_meta)
            post_delegater.check_result()
            break
        except Exception as e:
            logger.info(f"result is not out yet,retry {i} times")
            if i == timeout-1:
                raise e
            else:
                time.sleep(sep_time)
    return res, err
 
    


@Given('execute sql "{num}" times in "{host_name}" at concurrent')
@Given('execute sql "{num}" times in "{host_name}" at concurrent {concur}')
@Given('execute "{mode_name}" sql "{num}" times in "{host_name}" at concurrent')
def step_impl(context, host_name, num, concur="100", mode_name="user"):
    row = context.table[0]
    num = int(num)
    info_dic = row.as_dict()
    concur = min(int(concur), num)

    tasks_per_thread = int(num / concur)
    mod_tasks = num % concur
    timestamp = int(round(time.time() * 1000))

    def do_thread_tasks(host_name, info_dic, base_id, tasks_count, eflag):
        my_dic = info_dic.copy()
        my_dic["conn"] = "concurr_conn_{0}_{1}".format(timestamp, i)
        my_dic["toClose"] = "False"
        last_count = tasks_count - 1
        sql_raw = my_dic["sql"]
        for k in range(int(tasks_count)):
            if k == last_count:
                my_dic["toClose"] = "true"
            id = base_id + k
            my_dic["sql"] = sql_raw.format(id)
            # logger.debug("debug1, my_dic:{}, conn:{}".format(my_dic["sql"], my_dic["conn"]))
            try:
                if mode_name == "admin":
                    execute_sql_in_host(host_name, my_dic, "admin")
                else:
                    execute_sql_in_host(host_name, my_dic, "user")
            except Exception as e:
                eflag.exception = e

    for i in range(concur):
        if i < mod_tasks:
            tasks_count = tasks_per_thread + 1
        else:
            tasks_count = tasks_per_thread
        base_id = i * tasks_per_thread
        thd = Thread(target=do_thread_tasks, args=(host_name, info_dic, base_id, tasks_count, Flag))
        thd.start()
        thd.join()

        if Flag.exception:
            raise Flag.exception


@Given('prepare a thread execute sql "{sql}" with "{conn_type}"')
@Given('prepare a thread execute sql "{sql}" with "{conn_type}" and save resultset in "{result_set}"')
def step_impl(context, sql, conn_type='', result_set=''):
    conn = DbleObject.dble_long_live_conns.get(conn_type, None)
    assert conn, "conn '{0}' is not exists in dble_long_live_conns".format(conn_type)
    global sql_threads
    thd = Thread(target=execute_sql_backgroud, args=(context, conn, sql, result_set), name=sql)
    sql_threads.append(thd)
    thd.setDaemon(True)
    thd.start()


def execute_sql_backgroud(context, conn, sql, result_set):
    sql_cmd = sql.strip()
    res, err = conn.execute(sql_cmd)
    if result_set:
        setattr(context, "{0}_result".format(result_set), res)
        setattr(context, "{0}_err".format(result_set), err)
    else:
        setattr(context, "sql_thread_result", res)
        setattr(context, "sql_thread_err", err)
    logger.debug("execute sql in thread end, res or err has been record in context variables")


@Given('destroy sql threads list')
def step_impl(context):
    global sql_threads
    for thd in sql_threads:
        context.logger.debug("join sql thread: {0}".format(thd.name))
        thd.join()
    sql_threads=[]

@Given('kill all backend conns in "{host_name}"')
@Given('kill all backend conns in "{host_name}" except ones in "{exclude_conn_ids}"')
def step_impl(context, host_name, exclude_conn_ids=None):
    if exclude_conn_ids:
        exclude_ids = getattr(context, exclude_conn_ids, None)
    else:
        exclude_ids = []

    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.kill_all_conns(exclude_ids)


@Given('kill mysql conns in "{host_name}" in "{conn_ids}"')
def step_impl(context, host_name, conn_ids):
    conn_ids = getattr(context, conn_ids, None)
    assert len(conn_ids) > 0, "no conns in '{}' to kill".format(conn_ids)
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.kill_conns(conn_ids)

@Then('kill the redundant connections if "{current_idle_connections}" is more then expect value "{expect_value}" in "{mysql_host_name}"')
def step_impl(context, mysql_host_name, current_idle_connections,expect_value):
    current_idle_connections = getattr(context, current_idle_connections, None)
    need_to_kill_num = len(current_idle_connections) - int(expect_value)
    if need_to_kill_num > 0:
        mysql = ObjectFactory.create_mysql_object(mysql_host_name)
        mysql.kill_redundant_conns(current_idle_connections, need_to_kill_num)

@Given('execute sql "{num}" times in "{host_name}" together use {concur} connection not close')
@Given('execute "{mode_name}" sql "{num}" times in "{host_name}" together use {concur} connection not close')
def step_impl(context, host_name, num, concur="100", mode_name="user"):
    row = context.table[0]
    num = int(num)
    info_dic = row.as_dict()
    concur = min(int(concur), num)

    tasks_per_thread = int(num / concur)
    mod_tasks = num % concur
    timestamp = int(round(time.time() * 1000))

    def do_thread_tasks(host_name, info_dic, base_id, tasks_count, eflag):
        my_dic = info_dic.copy()
        my_dic["conn"] = "concurr_conn_{0}_{1}".format(timestamp, i)
        my_dic["toClose"] = "False"
        last_count = tasks_count - 1
        sql_raw = my_dic["sql"]
        for k in range(int(tasks_count)):
            if k == last_count:
                my_dic["toClose"] = "False"
            id = base_id + k
            my_dic["sql"] = sql_raw.format(id)
            # logger.debug("debug1, my_dic:{}, conn:{}".format(my_dic["sql"], my_dic["conn"]))
            try:
                if mode_name == "admin":
                    execute_sql_in_host(host_name, my_dic, "admin")
                else:
                    execute_sql_in_host(host_name, my_dic, "user")
            except Exception as e:
                eflag.exception = e

    for i in range(concur):
        if i < mod_tasks:
            tasks_count = tasks_per_thread + 1
        else:
            tasks_count = tasks_per_thread
        base_id = i * tasks_per_thread
        thd = Thread(target=do_thread_tasks, args=(host_name, info_dic, base_id, tasks_count, Flag))
        thd.start()
        thd.join()

        if Flag.exception:
            raise Flag.exception


@Then('execute "{mode_name}" sql for "{seconds}" seconds in "{host_name}"')
def step_impl(context, mode_name, seconds, host_name):
    execute_seconds = int(seconds)
    current_time_before_execute = int(time.time())
    while True:
        current_time_in_execute = int(time.time())
        if current_time_in_execute - current_time_before_execute < execute_seconds:
            for row in context.table:
                execute_sql_in_host(host_name, row.as_dict(), mode_name)
        else:
            break
    context.logger.info("execute sql for {0} seconds in {1} complete".format(seconds, host_name))


# delete backend mysql tables from db1 ~ db4
# slave mysql table do not need to delete for reason master mysql table has been deleted
@Given('delete all backend mysql tables')
def delete_all_mysql_tables(context):
    mysql_install_all = ["mysql", "mysql-master1", "mysql-master2", "mysql-master3"]
    databases = ["db1", "db2", "db3", "db4"]
    for mysql_hostname in mysql_install_all:
        for db in databases:
            generate_drop_tables_sql = "select concat('drop table if exists ',table_schema,'.',table_name,';') from information_schema.TABLES where table_schema='{0}'".format(
                db)
            res1, err1 = execute_sql_in_host(mysql_hostname, {"sql": generate_drop_tables_sql}, "mysql")
            assert err1 is None, "general drop table sql failed: {}".format(err1)
            if len(res1) != 0:
                for sql_element in res1:
                    drop_table_sql = sql_element[0]
                    res2, err2 = execute_sql_in_host(mysql_hostname, {"sql": drop_table_sql}, "mysql")
                    assert err2 is None, "execute drop table sql failed: {}".format(err2)
        logger.debug("{0} tables has been delete success".format(mysql_hostname))
    logger.info("all required tables has been delete success")


@given('change the primary instance of mysql group named "{group_name}" to "{hostname}"')
@given('restore mysql replication of the mysql group named "{group_name}" to the initial state')
def step_impl(context, group_name, hostname=""):

    if hostname == "":
        hostname = context.cfg_mysql[group_name]["inst-1"]["hostname"]

    node = get_node(hostname)
    master_ip = node.ip
    master_port = node.mysql_port

    reset_sql = "reset master;stop slave;reset slave all;"
    change_to_new_master = "change master to master_host='{0}', master_port={1},master_user='rsandbox',master_password='rsandbox',master_auto_position=1;".format(master_ip, master_port)
    start_slave = "start slave;"

    execute_sql_in_host(hostname, {"sql": reset_sql})

    for _, info in context.cfg_mysql[group_name].items():
        if info["hostname"] != hostname:
            execute_sql_in_host(info["hostname"], {"sql": reset_sql})
            execute_sql_in_host(info["hostname"], {"sql": change_to_new_master})
            execute_sql_in_host(info["hostname"], {"sql": start_slave})

    logger.info("{0} primary instance has been changed to {1} success".format(group_name, hostname))