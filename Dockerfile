FROM openjdk:8-jre-alpine

MAINTAINER tacokit@talend.com

LABEL io.k8s.display-name="Talend Component Kit Server Demo" \
      io.k8s.description="Simple Talend Component Kit instance." \
      name="Talend Component Kit Server Demo" \
      version="0.0.2-SNAPSHOT"

ENV LC_ALL en_US.UTF-8

RUN set -xe && \
    apk add --no-cache gnupg ca-certificates openssl && \
    update-ca-certificates && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys E16448E7EC79DD12245C4ADFFA5FA52B5B7B42F0 && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys CF80A055A2AD28E9EFBF942A73129F58DE61ECBD

ENV MEECROWAVE_BASE /opt/talend/component-kit
ENV M2_HOME /opt/talend/maven/repository
RUN mkdir -p $MEECROWAVE_BASE
WORKDIR $MEECROWAVE_BASE

RUN set -ex && \
    export NEXUS_BASE=${NEXUS_BASE:-https://oss.sonatype.org} && \
    export GROUP_ID=${GROUP_ID:-org.talend.sdk.component} && \
    export ARTIFACT_ID=${ARTIFACT_ID:-component-server} && \
    export SERVER_VERSION=${SERVER_VERSION:-0.0.2-SNAPSHOT} && \
    export REPOSITORY=$([[ "${SERVER_VERSION%-SNAPSHOT}" != "$SERVER_VERSION" ]] && echo 'snapshots' || echo 'releases') && \
    export DOWNLOAD_URL="$NEXUS_BASE/service/local/artifact/maven/content?r=$REPOSITORY&g=$GROUP_ID&a=$ARTIFACT_ID&v=$SERVER_VERSION&e=zip" && \
    echo "Using artifact $GROUP_ID:$ARTIFACT_ID:zip:$SERVER_VERSION" && \
    wget $DOWNLOAD_URL.asc -O $ARTIFACT_ID.zip.asc && \
    wget $DOWNLOAD_URL -O $ARTIFACT_ID.zip && \
    gpg --batch --verify $ARTIFACT_ID.zip.asc $ARTIFACT_ID.zip && \
    unzip $ARTIFACT_ID.zip && \
    mv $ARTIFACT_ID-distribution/* $MEECROWAVE_BASE && \
    rm -Rf $ARTIFACT_ID-distribution && \
    rm $ARTIFACT_ID.zip* && \
    echo "$GROUP_ID:$ARTIFACT_ID:zip:$SERVER_VERSION" > conf/build.gav && \
    date > conf/build.date
COPY conf/* $MEECROWAVE_BASE/conf/
COPY bin/* $MEECROWAVE_BASE/bin/
RUN chmod +x bin/*.sh

RUN mkdir -p $M2_HOME/org/talend/components/servicenow/0.0.1-SNAPSHOT $M2_HOME/org/talend/components/widget/1.0.0-SNAPSHOT && \
    wget https://oss.sonatype.org/service/local/artifact/maven/content?r=releases&g=org.talend.components&a=servicenow&v=0.0.1-SNAPSHOT&e=jar -O $M2_HOME/org/talend/components/servicenow/0.0.1-SNAPSHOT/servicenow-0.0.1-SNAPSHOT.jar && \
    wget https://oss.sonatype.org/service/local/artifact/maven/content?r=releases&g=org.talend.components&a=widget&v=0.0.1-SNAPSHOT&e=jar -O $M2_HOME/org/talend/components/widget/1.0.0-SNAPSHOT/widget-1.0.0-SNAPSHOT.jar

EXPOSE 8080
CMD [ "./bin/meecrowave.sh", "run" ]
