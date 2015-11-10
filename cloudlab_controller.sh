#!/bin/bash
echo Yong:1|sudo chpasswd
sudo apt-get update -q=2
sudo apt-get install -y vim openjdk-7-jdk ant axel
git clone https://github.com/floodlight/floodlight.git
cd floodlight
ant
sudo java -jar target/floodlight.jar
