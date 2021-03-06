FROM ruby:2.6.3

RUN apt-get update -qq && apt-get install -q -y netcat lsof unzip wget tar openssl xvfb chromium

RUN cd /tmp && \
    wget https://chromedriver.storage.googleapis.com/2.44/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip -d /usr/local/bin && \
    rm -f chromedriver_linux64.zip

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN gem install bundler
RUN bundle install

COPY . /app

COPY gust-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/gust-entrypoint.sh
ENTRYPOINT ["gust-entrypoint.sh"]

#CMD ["ruby", "app.rb"]
CMD ["tail", "-f", "/dev/null"]
