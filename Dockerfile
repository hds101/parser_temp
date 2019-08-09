FROM ruby:2.6.3

RUN apt-get update -qq && apt-get install -q -y lsof unzip wget tar openssl xvfb chromium # firefox-esr

RUN cd /tmp && \
    wget https://chromedriver.storage.googleapis.com/2.44/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip -d /usr/local/bin && \
    rm -f chromedriver_linux64.zip
#
#RUN cd /tmp && \
#    wget https://github.com/mozilla/geckodriver/releases/download/v0.23.0/geckodriver-v0.23.0-linux64.tar.gz && \
#    tar -xvzf geckodriver-v0.23.0-linux64.tar.gz -C /usr/local/bin && \
#    rm -f geckodriver-v0.23.0-linux64.tar.gz
#
#RUN apt-get install -q -y chrpath libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev && \
#    cd /tmp && \
#    wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
#    tar -xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
#    mv phantomjs-2.1.1-linux-x86_64 /usr/local/lib && \
#    ln -s /usr/local/lib/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin && \
#    rm -f phantomjs-2.1.1-linux-x86_64.tar.bz2

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN gem install bundler
RUN bundle install

COPY . /app

EXPOSE 80

CMD ["ruby", "app.rb"]
