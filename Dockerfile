from ubuntu:22.04
RUN apt-get update
RUN apt-get install -y python3-dev git vim wget curl  openjdk-11-jre cloc gnupg2 python3-pip
RUN git clone  https://github.com/adamtornhill/maat-scripts.git 
RUN cd maat-scripts && git checkout python3 && git checkout 3f1afce &&  pip install -r requirements.txt
RUN curl -L -o  /usr/bin/maat  https://github.com/adamtornhill/code-maat/releases/download/v1.0.4/code-maat-1.0.4-standalone.jar
RUN chmod +x /usr/bin/maat
RUN apt-get install -y openssh-client &&  ssh-keygen -b 1024 -t rsa -f /root/.ssh/id_rsa -N "" &&  chmod 600 /root/.ssh/id_rsa
#RUN git config --global http.postBuffer 524288000 && git clone https://github.com/hibernate/hibernate-orm.git
RUN pip install numpy==1.26.4  # Specify a version compatible with your dependencies
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
# Add the Google Chrome repository
RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update 

# Install Google Chrome

RUN apt-get install -y google-chrome-stable 

