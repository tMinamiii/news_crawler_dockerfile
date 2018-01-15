FROM resin/rpi-raspbian
MAINTAINER naronA

ENV DOCKER_PYTHON_VERSION 3.5.4

RUN apt-get update && apt-get upgrade && \
    apt-get install -y git \
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
                       libffi-dev && \
   apt-get clean

# pythonのインストール
WORKDIR /root
RUN wget https://www.python.org/ftp/python/$DOCKER_PYTHON_VERSION/Python-$DOCKER_PYTHON_VERSION.tgz
RUN tar xzf Python-$DOCKER_PYTHON_VERSION.tgz

# makeでインストール
WORKDIR ./Python-$DOCKER_PYTHON_VERSION
RUN ./configure --with-threads --enable-optimizations
RUN make install
RUN pip3 install --upgrade pip && pip3 list --outdated --format columns | awk 'NR>2{print $1}' | xargs pip3 install --upgrade
# pipインストール(最新版)
# RUN wget https://bootstrap.pypa.io/get-pip.py
# RUN python3 get-pip.py

WORKDIR /root
RUN git clone https://github.com/naronA/news_crawler news_crawler

WORKDIR /root/news_crawler
RUN pip3 install -r requirements.txt scrapyd scrapyd-client
RUN crontab cron.conf
RUN cp -rf etc/scrapyd/conf.d/scrapyd.conf ~/scrapyd.conf


WORKDIR /root
CMD ['scrapyd']

WORKDIR /root/news_crawler/news_crawler
RUN scrapyd-deploy

# Cleaning
RUN rm -f /root/Python* /root/news_crawler
