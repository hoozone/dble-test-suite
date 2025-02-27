# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_thread_usage table test

  Scenario:  dble_thread_usage  table #1
  #case desc dble_thread_usage
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_usage_1"
      | conn   | toClose | sql                    | db               |
      | conn_0 | False   | desc dble_thread_usage | dble_information |
    Then check resultset "dble_thread_usage_1" has lines with following column values
      | Field-0          | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | thread_name      | varchar(64) | NO     | PRI   | None      |         |
      | last_quarter_min | varchar(5)  | NO     |       | None      |         |
      | last_minute      | varchar(5)  | NO     |       | None      |         |
      | last_five_minute | varchar(5)  | NO     |       | None      |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                | expect            | db               |
      | conn_0 | False   | desc dble_thread_usage             | length{(4)}       | dble_information |
  #case not set useThreadUsageStat and useCostTimeStat,the result is null
      | conn_0 | True    | select * from dble_thread_usage    | length{(0)}       | dble_information |

  #case set useThreadUsageStat and useCostTimeStat
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     $a -DuseThreadUsageStat=1
     $a -DuseCostTimeStat=1
     /DbackendProcessorExecutor/d
     /DcomplexExecutor/d
     /DwriteToBackendExecutor/d
     /DbackendProcessors/d
     $a  -DbackendProcessorExecutor=8
     $a  -DcomplexExecutor=8
     $a  -DwriteToBackendExecutor=8
     $a  -DbackendProcessors=8
     """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_usage_2"
      | conn   | toClose | sql                             | db               |
      | conn_0 | True    | select * from dble_thread_usage | dble_information |
    Then check resultset "dble_thread_usage_2" has lines with following column values
      | thread_name-0               |
      | 0-NIOBackendRW              |
      | 1-NIOBackendRW              |
      | 2-NIOBackendRW              |
      | 3-NIOBackendRW              |
      | 4-NIOBackendRW              |
      | 5-NIOBackendRW              |
      | 6-NIOBackendRW              |
      | 7-NIOBackendRW              |
      | 0-NIOFrontRW                |
      | 0-frontWorker               |
      | 0-backendWorker             |
      | 1-backendWorker             |
      | 2-backendWorker             |
      | 3-backendWorker             |
      | 4-backendWorker             |
      | 5-backendWorker             |
      | 6-backendWorker             |
      | 7-backendWorker             |
      | 0-writeToBackendWorker     |
      | 1-writeToBackendWorker     |
      | 2-writeToBackendWorker     |
      | 3-writeToBackendWorker     |
      | 4-writeToBackendWorker     |
      | 5-writeToBackendWorker     |
      | 6-writeToBackendWorker     |
      | 7-writeToBackendWorker     |
  #case change bootstrap.cnf to check result
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     s/-DprocessorExecutor=1/-DprocessorExecutor=2/
     s/-DbackendProcessors=8/-DbackendProcessors=4/
     s/-DbackendProcessorExecutor=8/-DbackendProcessorExecutor=4/
     s/-DwriteToBackendExecutor=8/-DwriteToBackendExecutor=4/
     """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_usage_4"
      | conn   | toClose | sql                              | db               |
      | conn_0 | False   | select * from dble_thread_usage  | dble_information |
    Then check resultset "dble_thread_usage_4" has lines with following column values
      | thread_name-0              |
      | 0-NIOBackendRW             |
      | 1-NIOBackendRW             |
      | 2-NIOBackendRW             |
      | 3-NIOBackendRW             |
      | 0-NIOFrontRW               |
      | 0-frontWorker              |
      | 1-frontWorker              |
      | 0-backendWorker            |
      | 1-backendWorker            |
      | 2-backendWorker            |
      | 3-backendWorker            |
      | 0-writeToBackendWorker     |
      | 1-writeToBackendWorker     |
      | 2-writeToBackendWorker     |
      | 3-writeToBackendWorker     |
    Then check resultset "dble_thread_usage_4" has not lines with following column values
      | thread_name-0              |
      | 4-NIOBackendRW             |
      | 5-NIOBackendRW             |
      | 6-NIOBackendRW             |
      | 7-NIOBackendRW             |
      | 4-backendWorker            |
      | 5-backendWorker            |
      | 6-backendWorker            |
      | 7-backendWorker            |
      | 4-writeToBackendWorker     |
      | 5-writeToBackendWorker     |
      | 6-writeToBackendWorker     |
      | 7-writeToBackendWorker     |

   #case supported select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                           | expect                                 |
      | conn_0 | False   | select thread_name from dble_thread_usage limit 1                             | has{(('0-NIOBackendRW', ),)}           |
      | conn_0 | False   | select thread_name from dble_thread_usage order by thread_name desc limit 2   | success                                |
      | conn_0 | False   | select thread_name from dble_thread_usage where thread_name like '%Front%'    | has{(('0-NIOFrontRW',),)}              |
  #case supported select max/min from
      | conn_0 | False   | select max(thread_name) from dble_thread_usage                                | has{(('3-writeToBackendWorker',),)}    |
      | conn_0 | False   | select min(thread_name) from dble_thread_usage                                | has{(('0-backendWorker',),)}           |
  #case supported where [sub-query]
      | conn_0 | False   | select thread_name from dble_thread_usage where last_minute in (select last_minute from dble_thread_usage where last_five_minute < '10%') | success     |
  #case supported select field from
      | conn_0 | False   | select last_quarter_min from dble_thread_usage where thread_name = '0-frontWorker'  | success      |
  #case unsupported update/delete/insert
      | conn_0 | False   | delete from dble_thread_usage where thread_name = '0-frontWorker'                   | Access denied for table 'dble_thread_usage'  |
      | conn_0 | False   | update dble_thread_usage set thread_name = '2' where thread_name = '0-frontWorker'  | Access denied for table 'dble_thread_usage'  |
      | conn_0 | True    | insert into dble_thread_usage values ('0-NIOFrontRW','1%', '1%', '1%')              | Access denied for table 'dble_thread_usage'  |





