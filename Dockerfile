FROM resin/rpi-raspbian
MAINTAINER naronA

ENV DOCKER_PYTHON_VERSION 3.5.4


RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
RUN apt-get update \
    && apt-get upgrade \
    && apt-get install -y git \
                       curl \
                       wget \
                       cron \
                       build-essential \
                       make \
                       zlib1g-dev \
                       libssl-dev \
                       libbz2-dev \
                       xz-utils \
                       file mecab \
                       libmecab-dev \
                       mecab-ipadic \
                       mecab-ipadic-utf8 \
                       libxml2-dev \
                       libxslt1-dev \
                       libffi-dev \
                       libsqlite3-dev \
                       libreadline-dev \
                       less \
   && apt-get autoremove \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/*

# pythonのインストール
WORKDIR /root

RUN wget https://www.python.org/ftp/python/$DOCKER_PYTHON_VERSION/Python-$DOCKER_PYTHON_VERSION.tgz \
    && tar xzf Python-$DOCKER_PYTHON_VERSION.tgz

# makeでインストール
WORKDIR ./Python-$DOCKER_PYTHON_VERSION

RUN ./configure --with-threads --enable-optimizations \
    && make install \
    && pip3 install --upgrade pip \
    && pip3 list --outdated --format columns \
       | awk 'NR>2{print $1}' \
       | xargs pip3 install --upgrade

# news_crawlerの取得
WORKDIR /root
RUN git clone https://github.com/naronA/news_crawler news_crawler \
    && wget https://www.dropbox.com/s/gfr8mzpk1mq62ee/mecab-ipadic-neologd.tar.gz \
    && tar xzf mecab-ipadic-neologd.tar.gz \
    && mkdir -p /usr/lib/mecab/dic \
    && mv mecab-ipadic-neologd /usr/lib/mecab/dic \
    && rm mecab-ipadic-neologd.tar.gz

# news_crawlerの設定
WORKDIR /root/news_crawler
RUN pip3 install -r requirements.txt scrapyd scrapyd-client \
    && cp cron.conf /etc/cron.d/scrapy-cron \
    && chmod 0644 /etc/cron.d/scrapy-cron \
    && cp -rf scrapyd.conf /root/scrapyd.conf

# ScrapydへのクローラープロジェクトDeploy
RUN cd /root \
    && scrapyd & sleep 20s \
    && cd /root/news_crawler/news_crawler \
    && scrapyd-deploy \
    && curl http://localhost:46800/listprojects.json

# Cleaning
RUN rm -rf /root/Python* /root/news_crawler
EXPOSE 46800

WORKDIR /root
CMD ["/usr/local/bin/scrapyd", "--pidfile="]
