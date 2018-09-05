#!/bin/bash

apt update
apt install openjdk-8-jdk-headless git maven -y

git clone https://github.com/awslabs/amazon-kinesis-agent
cd amazon-kinesis-agent
git checkout 1.1.3

echo "diff --git a/pom.xml b/pom.xml
index 6a858c2..90e7d36 100644
--- a/pom.xml
+++ b/pom.xml
@@ -192,6 +192,11 @@
 
     <build>
       <directory>target</directory>
+      <resources>
+        <resource>
+          <directory>resources</directory>
+        </resource>
+      </resources>
       <outputDirectory>target/classes</outputDirectory>
       <finalName>\${project.artifactId}-\${project.version}</finalName>
       <sourceDirectory>src</sourceDirectory>
@@ -226,7 +231,18 @@
             </execution>
           </executions>
         </plugin>
+        <plugin>
+          <groupId>org.apache.maven.plugins</groupId>
+          <artifactId>maven-assembly-plugin</artifactId>
+          <configuration>
+            <archive>
+              <manifest>
+                <mainClass>com.amazon.kinesis.streaming.agent.Agent</mainClass>
+              </manifest>
+            </archive>
+          </configuration>
+        </plugin>
       </plugins>
     </build>
 
-</project>
\ No newline at end of file
+</project>

" > pom.patch

git apply pom.patch


mkdir -p resources/com/amazon/kinesis/streaming/agent/
cp src/com/amazon/kinesis/streaming/agent/custom.log4j.xml resources/com/amazon/kinesis/streaming/agent/
cp src/com/amazon/kinesis/streaming/agent/versionInfo.properties resources/com/amazon/kinesis/streaming/agent/

mvn assembly:assembly -DdescriptorId=jar-with-dependencies


cd target

java -jar amazon-kinesis-agent-1.1-jar-with-dependencies.jar -c /mnt/agent.json -L DEBUG -l /tmp/kinesis.log
