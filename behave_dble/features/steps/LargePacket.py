# -*- coding: utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2019/8/9 AM10:31
# @Author  : zhaohongjie@actionsky.com
#todo multiple queries
import MySQLdb
import argparse

from SQLContext import SQLContext


def large_packet_test(size_in_byte, conn, sqlContext=None):
    size_avail = size_in_byte - 2 #1 for mysql query type occupy 1 Byte in one packet, 1 for uproxy count from 0 not 1

    queries = sqlContext.get_queries(size_avail, isColumnSize=False)

    do_query(conn, queries)

def large_column_test(size_in_byte, conn, sqlContext=None):
    queries = sqlContext.get_queries(size_in_byte, isColumnSize=True)

    do_query(conn, queries)

def do_query(conn, queries):
    cursor = conn.cursor()

    for sql in queries:
        print(sql[0:100])
        cursor.execute(sql)
        cursor.fetchall()

    cursor.close()

def create_conn(args):
    host = args.host
    user = args.user
    passwd = args.passwd
    db = args.database
    port = args.port

    conn = MySQLdb.connect(host=host, user=user, passwd=passwd, db=db, port=port, autocommit=True,
                           charset='utf8mb4')
    return conn

if __name__ == "__main__":
    # parser = argparse.ArgumentParser(description="Usage example: python3 LargePacket.py --host 10.186.60.31 --user test --passwd 111111 --database schema1 --port 7131")
    # parser.add_argument('--host', type=str, default='127.0.0.1')
    # parser.add_argument('--user', type=str, default='root')
    # parser.add_argument('--passwd', type=str, default='111111')
    # parser.add_argument('--database', type=str, default=None, help="database")
    # parser.add_argument('--port', type=int, default=3307, help="port")

    parser = argparse.ArgumentParser(description="Usage example: python3 LargePacket.py --host 172.100.9.1 --user test --passwd 111111 --database schema1 --port 8066")
    parser.add_argument('--host', type=str, default='172.100.9.1')
    parser.add_argument('--user', type=str, default='test')
    parser.add_argument('--passwd', type=str, default='111111')
    parser.add_argument('--database', type=str, default='schema1', help="database")
    parser.add_argument('--port', type=int, default='8066', help="port")

    args = parser.parse_args()


    conn = create_conn(args)
    sqlContext2 = SQLContext(table="sbtest2", cols={"id":"int"}, targetCol={"c":"longblob"})
    # sqlContext3 = SQLContext(table="test2", cols={"id": "int"}, targetCol={"c": "longblob"})
    # sqlContext4 = SQLContext(table="sharding_2_t1", cols={"id": "int"}, targetCol={"c": "longblob"})
    # sqlContext5 = SQLContext(table="sharding_4_t1", cols={"id": "int"}, targetCol={"c": "longblob"})

    large_packet_test(16*1024*1024, conn, sqlContext2)
    # large_packet_test(16*1024*1024, conn, sqlContext3)
    # large_packet_test(16*1024*1024, conn, sqlContext4)
    # large_packet_test(16*1024*1024, conn, sqlContext5)



    #sqlContext = SQLContext(table="sbtest1", cols={"id":"int"}, targetCol={"c":"blob"})

    #large_column_test(4*1024*1024+1, conn, sqlContext)
    #large_column_test(4*1024*1024, conn, sqlContext)
    #large_column_test(65574, conn, sqlContext)
    #large_packet_test(16*1024*1024, conn, sqlContext)


    conn.close()