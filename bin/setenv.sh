#! /bin/sh

export MEECROWAVE_PID=$MEECROWAVE_BASE/conf/server.pid
export MEECROWAVE_OPTS="$MEECROWAVE_OPTS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"
export MEECROWAVE_OPTS="$MEECROWAVE_OPTS -Dtalend.component.exit-on-destroy=true"
export MEECROWAVE_OPTS="$MEECROWAVE_OPTS -Dtalend.component.server.maven.repository=/opt/talend/maven/repository"
export MEECROWAVE_OPTS="$MEECROWAVE_OPTS -Dtalend.component.server.component.coordinates=org.talend.components:widget:jar:1.0.0-SNAPSHOT:compile,org.talend.components:servicenow:jar:0.0.1-SNAPSHOT:compile"
