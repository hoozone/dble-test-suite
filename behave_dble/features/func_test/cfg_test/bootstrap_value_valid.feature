# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2019/1/3
Feature: if childnodes value of system in bootstrap.cnf are invalid, replace them with default values
  only check part of system childnodes, not all, list from https://github.com/actiontech/dble/issues/579

  @NORMAL @test-00
  Scenario: config all system property, some values are illegal, start dble success #1
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
    """
    $a\sequenceHandlerType=20
    $a\showBinlogStatusTimeout=60000
    """
    # invalid data
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      $a\-DmaxCon=-1
      $a\-DserverBacklog=2048.55
      $a\-DuseOuterHa=1
      $a\-Dautocommit=-1
      $a\-DuseCostTimeStat=false
      $a\-DmaxCostStatSize=-10
      $a\-DcostSamplePercent=-2
      $a\-DorderMemSize=4.5
      $a\-DotherMemSize=4.5
      $a\-DjoinMemSize=4.5
      $a\-DmappedFileSize=abc
      $a\-DtransactionRotateSize=16.59
      $a\-DxaRetryCount=-1
      $a\-DviewPersistenceConfBaseDir=///opt/dble/viewConf/
      $a\-DviewPersistenceConfBaseName=view/Json
      $a\-DjoinQueueSize=1024.59
      $a\-DmergeQueueSize=-1024
      $a\-DorderByQueueSize=-1024
      $a\-DslowLogBaseDir=///opt/dble/slowlogs/
      $a\-DslowLogBaseName=slow/query
      $a\-DflushSlowLogPeriod=-1
      $a\-DflushSlowLogSize=-1000
      $a\-DmaxCharsPerColumn=65535.59
      $a\-DmaxRowSizeToFile=-10000
      $a\-DenableFlowControl=1
      $a\-DflowControlStartThreshold=-4096
      $a\-DflowControlStopThreshold=-256
      $a\-DsqlSlowTime=100.59
      $a\-DuseSqlStat=false
      $a\-DuseCompression=true
      $a\-Dcharset=utf-8
      $a\-DtxIsolation=30
      $a\-DrecordTxn=false
      $a\-DbufferUsagePercent=80%
      $a\-DfrontSocketNoDelay=true
      $a\-DbackSocketNoDelay=true
      $a\-DusingAIO=false
      $a\-DcheckTableConsistency=false
      $a\-DuseCostTimeStat=false
      $a\-DuseThreadUsageStat=false
      $a\-DusePerformanceMode=false
      $a\-DenableSlowLog=false
      $a\-DuseJoinStrategy=0
      $a\-DbindIp=256.256.256.258
      $a\-DserverPort=-1
      $a\-DmanagerPort=-2
      $a\-DbackendProcessors=-3
      $a\-DbackendProcessorExecutor=-4
      $a\-DcomplexExecutor=-4
      $a\-DwriteToBackendExecutor=-4
      $a\-DfakeMySQLVersion=5.6.24.00
      $a\-DmaxPacketSize=3.5
      $a\-DcheckTableConsistencyPeriod=1800.59
      $a\-DprocessorCheckPeriod=-1000
      $a\-DsqlExecuteTimeout=-20
      $a\-DtransactionLogBaseDir=///txlogs
      $a\-DtransactionLogBaseName=server/tx
      $a\-DtransactionRotateSize=16
      $a\-DxaSessionCheckPeriod=-1000
      $a\-DxaLogCleanPeriod=-1000
      $a\-DxaRecoveryLogBaseDir=///tmlogs
      $a\-DxaRecoveryLogBaseName=tm/log
      $a\-DnestLoopConnSize=4.5
      $a\-DnestLoopRowsSize=2000.59
      $a\-DbufferPoolChunkSize=abc
      $a\-DbufferPoolPageNumber=-512
      $a\-DbufferPoolPageSize=abc
      $a\-DclearBigSQLResultSetMapMs=600000.59
      $a\-DsqlRecordCount=-10
      $a\-DmaxResultSet=-524288
      $a\-DbackSocketSoRcvbuf=-4194304
      $a\-DbackSocketSoSndbuf=-1048576
      $a\-DfrontSocketSoRcvbuf=-1048576
      $a\-DfrontSocketSoSndbuf=-4194304
    """
    Then restart dble in "dble-1" failed for
    """
      Property [ autocommit ] '-1' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      property [ backSocketNoDelay ] 'true' data type should be int
      Property [ backSocketSoRcvbuf ] '-4194304' in bootstrap.cnf is illegal, you may need use the default value 4194304 replaced
      Property [ backSocketSoSndbuf ] '-1048576' in bootstrap.cnf is illegal, you may need use the default value 1048576 replaced
      Property [ backendProcessorExecutor ] '-4' in bootstrap.cnf is illegal, you may need use the default value 5 replaced
      Property [ backendProcessors ] '-3' in bootstrap.cnf is illegal, you may need use the default value 5 replaced
      property [ bufferPoolChunkSize ] 'abc' data type should be short
      Property [ bufferPoolPageNumber ] '-512' in bootstrap.cnf is illegal, you may need use the default value 409 replaced
      property [ bufferPoolPageSize ] 'abc' data type should be int
      property [ bufferUsagePercent ] '80%' data type should be int
      Property [ charset ] 'utf-8' in bootstrap.cnf is illegal, use utf8mb4 replaced
      property [ checkTableConsistency ] 'false' data type should be int
      property [ checkTableConsistencyPeriod ] '1800.59' data type should be long
      property [ clearBigSQLResultSetMapMs ] '600000.59' data type should be long
      Property [ complexExecutor ] '-4' in bootstrap.cnf is illegal, you may need use the default value 5 replaced
      Property [ costSamplePercent ] '-2' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      property [ enableFlowControl ] '1' data type should be boolean
      property [ enableSlowLog ] 'false' data type should be int
      Property [ flushSlowLogPeriod ] '-1' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      Property [ flushSlowLogSize ] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
      property [ frontSocketNoDelay ] 'true' data type should be int
      Property [ frontSocketSoRcvbuf ] '-1048576' in bootstrap.cnf is illegal, you may need use the default value 1048576 replaced
      Property [ frontSocketSoSndbuf ] '-4194304' in bootstrap.cnf is illegal, you may need use the default value 4194304 replaced
      property [ joinMemSize ] '4.5' data type should be int
      property [ joinQueueSize ] '1024.59' data type should be int
      property [ mappedFileSize ] 'abc' data type should be int
      property [ maxCharsPerColumn ] '65535.59' data type should be int
      Property [ maxCon ] '-1' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      Property [ maxCostStatSize ] '-10' in bootstrap.cnf is illegal, you may need use the default value 100 replaced
      property [ maxPacketSize ] '3.5' data type should be int
      Property [ maxResultSet ] '-524288' in bootstrap.cnf is illegal, you may need use the default value 524288 replaced
      Property [ maxRowSizeToFile ] '-10000' in bootstrap.cnf is illegal, you may need use the default value 10000 replaced
      Property [ mergeQueueSize ] '-1024' in bootstrap.cnf is illegal, you may need use the default value 1024 replaced
      property [ nestLoopConnSize ] '4.5' data type should be int
      property [ nestLoopRowsSize ] '2000.59' data type should be int
      Property [ orderByQueueSize ] '-1024' in bootstrap.cnf is illegal, you may need use the default value 1024 replaced
      property [ orderMemSize ] '4.5' data type should be int
      property [ otherMemSize ] '4.5' data type should be int
      Property [ processorCheckPeriod ] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
      property [ recordTxn ] 'false' data type should be int
      property [ serverBacklog ] '2048.55' data type should be int
      Property [ sqlExecuteTimeout ] '-20' in bootstrap.cnf is illegal, you may need use the default value 300 replaced
      Property [ sqlRecordCount ] '-10' in bootstrap.cnf is illegal, you may need use the default value 10 replaced
      property [ sqlSlowTime ] '100.59' data type should be int
      Property [ txIsolation ] '30' in bootstrap.cnf is illegal, you may need use the default value 3 replaced
      property [ useCompression ] 'true' data type should be int
      property [ useCostTimeStat ] 'false' data type should be int
      property [ useJoinStrategy ] '0' data type should be boolean
      property [ useOuterHa ] '1' data type should be boolean
      property [ usePerformanceMode ] 'false' data type should be int
      property [ useSqlStat ] 'false' data type should be int
      property [ useThreadUsageStat ] 'false' data type should be int
      property [ usingAIO ] 'false' data type should be int
      Property [ writeToBackendExecutor ] '-4' in bootstrap.cnf is illegal, you may need use the default value 5 replaced
      Property [ xaLogCleanPeriod ] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
      Property [ xaRetryCount ] '-1' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      Property [ xaSessionCheckPeriod ] '-1000' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
      The specified MySQL Version (5.6.24.00) is not valid, the version should look like 'x.y.z'
    """
    
  @test-01
  Scenario: if bootstrap.cnf is not exist, check the log
    Given delete file "/opt/dble/conf/bootstrap.cnf" on "dble-1"
    Then restart dble in "dble-1" failed for
    """
        Configuration file not found: conf/bootstrap.cnf
    """

  @test-02
  Scenario: if bootstrap.dynamic.cnf is not exist, check the log
    Given delete file "/opt/dble/conf/bootstrap.dynamic.cnf" on "dble-1"
    Given Restart dble in "dble-1" success
    Then check following " " exist in dir "/opt/dble/conf/" in "dble-1"
      """
        bootstrap.dynamic.cnf
      """
    Then check "/opt/dble/conf/bootstrap.dynamic.cnf" in "dble-1" was empty

  @test-03
  Scenario: if bootstrap.cnf is empty, check the log
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      1,$d
    """
    Then restart dble in "dble-1" failed for
    """
        You must config instanceName in bootstrap.cnf and make sure it is an unique key for cluster
    """

