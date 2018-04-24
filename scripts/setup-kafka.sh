#!/usr/bin/env bash
#
# Script to setup a Kafka server

# unload the command line
broker_id=$1
az=$2

# update java
sudo yum remove -y java-1.7.0-openjdk
sudo yum install -y java-1.8.0

# add directories that support kafka
mkdir -p /opt/kafka
mkdir -p /var/run/kafka
mkdir -p /var/log/kafka

# download kafka
base_name=kafka_${scala_version}-${version}
cd /tmp
curl -O ${repo}/${version}/$base_name.tgz

# unpack the tarball
cd /opt/kafka
tar xzf /tmp/$base_name.tgz
rm /tmp/$base_name.tgz
cd $base_name

# configure the server
cat config/server.properties \
    | sed "s|broker.id=0|broker.id=$broker_id|" \
    | sed 's|log.dirs=/tmp/kafka-logs|log.dirs=${mount_point}/kafka-logs|' \
    | sed 's|num.partitions=1|num.partitions=${num_partitions}|' \
    | sed 's|log.retention.hours=168|log.retention.hours=${log_retention}|' \
    | sed 's|zookeeper.connect=localhost:2181|zookeeper.connect=${zookeeper_connect}|' \
    > /tmp/server.properties
echo >> /tmp/server.properties
echo "# rack ID" >> /tmp/server.properties
echo "broker.rack=$az" >> /tmp/server.properties
echo " " >> /tmp/server.properties
echo "# replication factor" >> /tmp/server.properties
echo "default.replication.factor=${repl_factor}" >> /tmp/server.properties
mv /tmp/server.properties config/server.properties


# configure aws cloudwatch agent for logs to be sent to cloudwatch
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/QuickStartEC2Instance.html

# make the config file
export aws_log_file=/opt/kafka/kafka_${scala_version}-${version}/logs/server.log

cat > /etc/awslogs.conf << EOL
[$aws_log_file]
datetime_format = %Y-%m-%d %H:%M:%S
file = $aws_log_file
buffer_duration = 5000
log_stream_name = {hostname}
initial_position = end_of_file
log_group_name = kafka
EOL

curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
sudo python ./awslogs-agent-setup.py --region us-east-1 --non-interactive --configfile /etc/awslogs.conf