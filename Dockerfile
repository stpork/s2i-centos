# springboot-maven3-centos
#
# This image provide a base for running Spring Boot based applications. It
# provides a base Java 8 installation and Maven 3.

FROM openshift/base-centos7

EXPOSE 8080

ENV JAVA_VERSON=1.8.0 \
MAVEN_VERSION=3.5.2

LABEL io.k8s.description="Platform for building and running Spring Boot applications" \
      io.k8s.display-name="Spring Boot Maven 3" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,java,java8,maven,maven3,springboot"

RUN set -x \
&& yum update -y \
&& yum install -y curl unzip git java-$JAVA_VERSON-openjdk java-$JAVA_VERSON-openjdk-devel \
&& yum clean all \
&& rm -rf /var/cache/yum \
&& MAVEN_URL=http://www.nic.funet.fi/pub/mirrors/apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
&& curl -fsSL ${MAVEN_URL} | tar xzf - -C /usr/share \
&& mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
&& ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \
&& TOOL_INSTALL=/usr/local/bin \
&& OCP_VERSION=v3.6.1 \
&& OCP_BUILD=008f2d5 \
&& CLI_VERSION=7.2.0 \
&& CLI_BUILD=16285777 \
&& OC_URL=http://github.com/openshift/origin/releases/download/${OCP_VERSION}/openshift-origin-client-tools-${OCP_VERSION}-${OCP_BUILD}-linux-64bit.tar.gz \
&& CLI_URL=http://bobswift.atlassian.net/wiki/download/attachments/${CLI_BUILD}/atlassian-cli-${CLI_VERSION}-distribution.zip \
&& curl -fsSL ${OC_URL} | tar -xz --strip-components=1 -C "$TOOL_INSTALL" \
&& cd /opt \
&& curl -o atlassian-cli.zip -fsSL ${CLI_URL} \
&& unzip -q atlassian-cli.zip \
&& mv atlassian-cli-${CLI_VERSION}/* "$TOOL_INSTALL" \
&& rm -rf atlassian-cli* \
&& chown -R ${RUN_USER}:${RUN_GROUP} ${TOOL_INSTALL} \
&& chmod -R 777 ${TOOL_INSTALL}

ENV JAVA_HOME /usr/lib/jvm/java
ENV MAVEN_HOME /usr/share/maven

# Add configuration files, bashrc and other tweaks
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

RUN chown -R 1001:0 /opt/app-root
USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage
