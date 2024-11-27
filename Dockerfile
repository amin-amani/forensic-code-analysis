from ubuntu:22.04
RUN apt-get update
RUN apt-get install -y python3-dev git vim wget curl  openjdk-11-jre 
RUN git clone  https://github.com/adamtornhill/maat-scripts.git
RUN cd maat-scripts && git checkout python3 &&  pip install -r requirements.txt
RUN curl -L -o  /usr/bin/maat  https://github.com/adamtornhill/code-maat/releases/download/v1.0.4/code-maat-1.0.4-standalone.jar
RUN chmod +x /usr/bin/maat
RUN   git config --global http.postBuffer 524288000 && git clone https://github.com/hibernate/hibernate-orm.git
