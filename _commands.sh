# this file contain a collection of commands used to do the demo and during the research


# reference: about whole project
# https://aws.amazon.com/blogs/big-data/apply-record-level-changes-from-relational-databases-to-amazon-s3-data-lake-using-apache-hudi-on-amazon-emr-and-aws-database-migration-service/
# https://cwiki.apache.org/confluence/pages/viewrecentblogposts.action?key=HUDI

# this project on github:
# https://github.com/cognizant-aia-cloud/aws-hudi-demo


git init
git add .
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/cognizant-aia-cloud/aws-hudi-demo.git
git push -u origin main

# fix untracked changes
git rm -r --cached .



# prerequisites
brew install parquet-tools

# key pair permissions
chmod og-rwx /Users/marian.dumitrascu/Dropbox/Work/current/hudi/aws-hudi-demo/key-pairs/md-labs-key-pair.pem

# s3 target options:
compressionType=NONE;csvDelimiter=,;csvRowDelimiter=\n;dataFormat=parquet;parquetTimestampInMillisecond=true;DatePartitionedEnabled=true
compressionType=NONE;csvDelimiter=,;csvRowDelimiter=\n;dataFormat=parquet;datePartitionEnabled=false;parquetTimestampInMillisecond=true;

# cli for creating endpoint
aws dms create-endpoint --endpoint-identifier s3-target-endpoint --engine-name s3 --endpoint-type target
--s3-settings '{"ServiceAccessRoleArn": "your-service-access-ARN", "DataFormat": "parquet"}'

aws dms create-endpoint --endpoint-identifier s3-target-endpoint --engine-name s3 --endpoint-type target
--s3-settings '{"ServiceAccessRoleArn": "your-service-access-ARN", "DataFormat": "parquet"}'

# delete s3 bucket
aws s3 rb s3://aws-logs-156021229203-us-east-1 --force
aws s3 rb s3://cf-templates-4zzhzactpkq4-us-east-1 --force
aws s3 rb s3://md-labs-hudi-demo-156021229203-data --force

# copy apache hudi jars to s3
aws s3 cp /usr/lib/hudi/hudi-spark-bundle.jar s3://aws-analytics-course/hudi/jar/
aws s3 cp /usr/lib/spark/external/lib/spark-avro.jar s3://aws-analytics-course/hudi/jar/
aws s3 ls s3://aws-analytics-course/hudi/jar/


# copy artifacts to s3
aws s3 sync /Users/marian.dumitrascu/Dropbox/Work/current/hudi/aws-hudi-demo/artifacts/ s3://md-labs-hudi-demo-artifacts-bucket/hudi-demo/

# replacements
aws-bigdata-blog/artifacts/hudiblog
md-labs-hudi-demo-artifacts-bucket/hudi-demo

hudi-blog-bootstrap.sh
hudi-bootstrap.sh

aws-bigdata-blog
md-labs-hudi-demo-artifacts-bucket


# delete resources:
aws dms stop-replication-task --replication-task-arn $TASK_ARN
aws dms delete-replication-task --replication-task-arn $TASK_ARN
export DMS_END_SOURCE='arn:aws:dms:us-east-1:156021229203:endpoint:7YIKMPT4COV2GEEB5FVONY534HZFBIUMMN3IITA'
export DMS_END_DEST='arn:aws:dms:us-east-1:156021229203:endpoint:U7AOG5JCSFPX6OG72J5RHH3RHBW4LMVGLG4IGRA'
export REP_ARN='arn:aws:dms:us-east-1:156021229203:rep:DJ2WULNQVCATIYYA47RLB66X3IH5TFMPRCE4B2A'
aws dms delete-endpoint --endpoint-arn $DMS_END_SOURCE
aws dms delete-endpoint --endpoint-arn $DMS_END_DEST
aws dms delete-replication-instance --replication-instance-arn $REP_ARN
aws rds delete-db-instance --db-instance-identifier cognizant-aia-hudi-demo-rds-02 --skip-final-snapshot

aws s3 rb s3://md-labs-hudi-demo-156021229203-data --force

####################################################################################################################################################################
# create emr cluster cli (moved to ansible script)
####################################################################################################################################################################
aws emr create-cluster \
--auto-scaling-role EMR_AutoScaling_DefaultRole \
--applications Name=Hadoop Name=Hive Name=Pig Name=Hue Name=Spark Name=Tez Name=Zeppelin Name=Presto \
--ebs-root-volume-size 10 \
--ec2-attributes '{
    "KeyName":"md-labs-key-pair",
    "InstanceProfile":"EMR_EC2_DefaultRole",
    "SubnetId":"subnet-092d9ea0082da117f",
    "EmrManagedSlaveSecurityGroup":"sg-0062d5c4cf2e16c2e",
    "EmrManagedMasterSecurityGroup":"sg-0c9a33972a312fc4d"
}' \
--service-role EMR_DefaultRole \
--enable-debugging \
--release-label emr-5.31.0 \
--log-uri 's3n://aws-logs-156021229203-us-east-1/elasticmapreduce/' \
--name 'md-labs-hudi-demo-emr-10' \
--instance-groups '[
    {
        "InstanceCount":1,
        "InstanceGroupType":"CORE",
        "InstanceType":"c3.xlarge",
        "Name":"Core - 2"
    },
    {
        "InstanceCount":1,
        "EbsConfiguration":
            {
                "EbsBlockDeviceConfigs":
                [
                    {
                        "VolumeSpecification":
                            {
                                "SizeInGB":32,
                                "VolumeType":"gp2"
                            },
                        "VolumesPerInstance":2
                    }
                ]
            },
        "InstanceGroupType":"MASTER",
        "InstanceType":"m5.xlarge",
        "Name":"Master - 1"
    }
]' \
--scale-down-behavior TERMINATE_AT_TASK_COMPLETION \
--region us-east-1

####################################################################################################################################################################
# connect to emr cluster
####################################################################################################################################################################
ssh -i /Users/marian.dumitrascu/Dropbox/Work/current/hudi/aws-hudi-demo/key-pairs/md-labs-key-pair.pem hadoop@ec2-35-170-245-98.compute-1.amazonaws.com

####################################################################################################################################################################
# loading data operations
####################################################################################################################################################################
sudo su hadoop

# move files from initial loading by CDC to another place
# this must be executed after the dms job starts first time
aws s3 mv \
s3://md-labs-hudi-demo-156021229203-data/dmsdata/dev/retail_transactions/ \
s3://md-labs-hudi-demo-156021229203-data/dmsdata/data-full/dev/retail_transactions/  \
--exclude "*" --include "LOAD*.parquet" --recursive

####################################################################################################################################################################
# spark-submit command to be executed on emr master node
# this is using deltastreamer
# reference on parameters: https://hudi.apache.org/docs/0.5.2-writing_data.html#deltastreamer

# COPY_ON_WRITE
spark-submit --class org.apache.hudi.utilities.deltastreamer.HoodieDeltaStreamer  \
    --packages org.apache.hudi:hudi-utilities-bundle_2.11:0.5.2-incubating,org.apache.spark:spark-avro_2.11:2.4.5 \
    --master yarn --deploy-mode cluster \
    --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
    --conf spark.sql.hive.convertMetastoreParquet=false \
    /usr/lib/hudi/hudi-utilities-bundle_2.11-0.5.2-incubating.jar \
    --table-type COPY_ON_WRITE \
    --source-ordering-field dms_received_ts \
    --props s3://md-labs-hudi-demo-156021229203-data/properties/dfs-source-retail-transactions-full.properties \
    --source-class org.apache.hudi.utilities.sources.ParquetDFSSource \
    --target-base-path s3://md-labs-hudi-demo-156021229203-data/hudi/retail_transactions --target-table hudi_glue_db.retail_transactions \
    --transformer-class org.apache.hudi.utilities.transform.SqlQueryBasedTransformer \
    --payload-class org.apache.hudi.payload.AWSDmsAvroPayload \
    --schemaprovider-class org.apache.hudi.utilities.schema.FilebasedSchemaProvider \
    --enable-hive-sync

# MERGE_ON_READ
spark-submit --class org.apache.hudi.utilities.deltastreamer.HoodieDeltaStreamer  \
    --packages org.apache.hudi:hudi-utilities-bundle_2.11:0.5.2-incubating,org.apache.spark:spark-avro_2.11:2.4.5 \
    --master yarn --deploy-mode cluster \
    --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
    --conf spark.sql.hive.convertMetastoreParquet=false \
    /usr/lib/hudi/hudi-utilities-bundle_2.11-0.5.2-incubating.jar \
    --table-type MERGE_ON_READ \
    --source-ordering-field dms_received_ts \
    --props s3://md-labs-hudi-demo-156021229203-data/properties/dfs-source-retail-transactions-full.properties \
    --source-class org.apache.hudi.utilities.sources.ParquetDFSSource \
    --target-base-path s3://md-labs-hudi-demo-156021229203-data/hudi/retail_transactions_mor --target-table hudi_glue_db.retail_transactions_mor \
    --transformer-class org.apache.hudi.utilities.transform.SqlQueryBasedTransformer \
    --payload-class org.apache.hudi.payload.AWSDmsAvroPayload \
    --schemaprovider-class org.apache.hudi.utilities.schema.FilebasedSchemaProvider \
    --enable-hive-sync



############################################################################################################################################
spark-shell \
--conf "spark.serializer=org.apache.spark.serializer.KryoSerializer" \
--conf "spark.sql.hive.convertMetastoreParquet=false" \
--packages org.apache.hudi:hudi-spark-bundle_2.11:0.5.2-incubating,org.apache.spark:spark-avro_2.11:2.4.5 \
--jars /usr/lib/hudi/hudi-spark-bundle_2.11-0.5.2-incubating.jar,/usr/lib/spark/external/lib/spark-avro.jar

# now you are in a spark shell for scala

# execute a sql query in spark
spark.sql("show databases").show()
spark.sql("select * from hudi_glue_db.retail_transactions order by tran_id").show()


# another way to read data, this is for dms data
spark.read.parquet("s3://md-labs-hudi-demo-156021229203-data/dmsdata/data-full/dev/retail_transactions/*").sort("tran_id").show
spark.read.parquet("s3://md-labs-hudi-demo-156021229203-data/dmsdata/dev/retail_transactions/*").sort("tran_id").show


############################################################################################################################################
# spark-submit command to get the incremental changes

# COPY_ON_WRITE
spark-submit --class org.apache.hudi.utilities.deltastreamer.HoodieDeltaStreamer  \
    --packages org.apache.hudi:hudi-utilities-bundle_2.11:0.5.2-incubating,org.apache.spark:spark-avro_2.11:2.4.5 \
    --master yarn --deploy-mode cluster \
    --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
    --conf spark.sql.hive.convertMetastoreParquet=false \
    /usr/lib/hudi/hudi-utilities-bundle_2.11-0.5.2-incubating.jar \
    --table-type COPY_ON_WRITE \
    --source-ordering-field dms_received_ts \
    --props s3://md-labs-hudi-demo-156021229203-data/properties/dfs-source-retail-transactions-incremental.properties --source-class org.apache.hudi.utilities.sources.ParquetDFSSource \
    --target-base-path s3://md-labs-hudi-demo-156021229203-data/hudi/retail_transactions --target-table hudi_glue_db.retail_transactions \
    --transformer-class org.apache.hudi.utilities.transform.SqlQueryBasedTransformer \
    --payload-class org.apache.hudi.payload.AWSDmsAvroPayload \
    --schemaprovider-class org.apache.hudi.utilities.schema.FilebasedSchemaProvider \
    --enable-hive-sync \
    --checkpoint 0  # include this only on the first incremental

# MERGE_ON_READ
spark-submit --class org.apache.hudi.utilities.deltastreamer.HoodieDeltaStreamer  \
    --packages org.apache.hudi:hudi-utilities-bundle_2.11:0.5.2-incubating,org.apache.spark:spark-avro_2.11:2.4.5 \
    --master yarn --deploy-mode cluster \
    --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
    --conf spark.sql.hive.convertMetastoreParquet=false \
    /usr/lib/hudi/hudi-utilities-bundle_2.11-0.5.2-incubating.jar \
    --table-type MERGE_ON_READ \
    --source-ordering-field dms_received_ts \
    --props s3://md-labs-hudi-demo-156021229203-data/properties/dfs-source-retail-transactions-incremental.properties --source-class org.apache.hudi.utilities.sources.ParquetDFSSource \
    --target-base-path s3://md-labs-hudi-demo-156021229203-data/hudi/retail_transactions_mor --target-table hudi_glue_db.retail_transactions_mor \
    --transformer-class org.apache.hudi.utilities.transform.SqlQueryBasedTransformer \
    --payload-class org.apache.hudi.payload.AWSDmsAvroPayload \
    --schemaprovider-class org.apache.hudi.utilities.schema.FilebasedSchemaProvider \
    --enable-hive-sync \
    --checkpoint 0 # include this only on the first incremental

--disable-compaction

# continuos
spark-submit --class org.apache.hudi.utilities.deltastreamer.HoodieDeltaStreamer  \
    --packages org.apache.hudi:hudi-utilities-bundle_2.11:0.5.2-incubating,org.apache.spark:spark-avro_2.11:2.4.5 \
    --master yarn --deploy-mode cluster \
    --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
    --conf spark.sql.hive.convertMetastoreParquet=false \
    --conf spark.yarn.maxAppAttempts=20 \
    --conf spark.yarn.max.executor.failures=10 \
    --conf spark.yarn.am.attemptFailuresValidityInterval=1h \
    --conf spark.yarn.executor.failuresValidityInterval=1h \
    --conf spark.task.maxFailures=8 \
    /usr/lib/hudi/hudi-utilities-bundle_2.11-0.5.2-incubating.jar \
    --table-type COPY_ON_WRITE \
    --source-ordering-field dms_received_ts \
    --props s3://md-labs-hudi-demo-156021229203-data/properties/dfs-source-retail-transactions-incremental.properties --source-class org.apache.hudi.utilities.sources.ParquetDFSSource \
    --target-base-path s3://md-labs-hudi-demo-156021229203-data/hudi/retail_transactions --target-table hudi_glue_db.retail_transactions \
    --transformer-class org.apache.hudi.utilities.transform.SqlQueryBasedTransformer \
    --payload-class org.apache.hudi.payload.AWSDmsAvroPayload \
    --schemaprovider-class org.apache.hudi.utilities.schema.FilebasedSchemaProvider \
    --enable-hive-sync \
    --checkpoint 0 \
    --continuous

# http://mkuthan.github.io/blog/2016/09/30/spark-streaming-on-yarn/

    ##########################################################################################
    # connect to hudi cli

    /usr/lib/hudi/cli/bin/hudi-cli.sh

    connect --path s3://md-labs-hudi-demo-156021229203-data/hudi/retail_transactions

    # reference:
    # https://hudi.apache.org/docs/0.5.2-querying_data.html
    # https://hudi.apache.org/docs/0.5.2-quick-start-guide.html#incremental-query
    commits show



    ###########################################################################################
    #  prepare for working with emr notebook

hdfs dfs -mkdir -p /apps/hudi/lib
hdfs dfs -copyFromLocal /usr/lib/hudi/hudi-spark-bundle.jar /apps/hudi/lib/hudi-spark-bundle.jar
hdfs dfs -copyFromLocal /usr/lib/spark/external/lib/spark-avro.jar /apps/hudi/lib/spark-avro.jar



# #############################################################################################
# reference on hudi queries
# https://hudi.apache.org/docs/querying_data.html
# https://hudi.apache.org/docs/quick-start-guide.html