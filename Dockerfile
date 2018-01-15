FROM resin/rpi-raspbian
MAINTAINER naronA

ENV DOCKER_PYTHON_VERSION 3.5.4
RUN apt update
RUN apt upgrade
# base
RUN apt install -y git curl wget build-essential make zlib1g-dev\
                   xz-utils file mecab libmecab-dev mecab-ipadic mecab-ipadic-utf8 \
                   libxml2-dev libxslt1-dev libffi-dev

# pythonのインストール
WORKDIR /root
RUN wget https://www.python.org/ftp/python/$DOCKER_PYTHON_VERSION/Python-$DOCKER_PYTHON_VERSION.tgz
RUN tar xzf Python-$DOCKER_PYTHON_VERSION.tgz && Python-$DOCKER_PYTHON_VERSION

# makeでインストール
WORKDIR ./Python-DOCKER_PYTHON_VERSION
RUN ./configure --with-threads --enable-optimizations
RUN make install

# pipインストール(最新版)
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python3 get-pip.py

WORKDIR /root
RUN git clone https://github.com/naronA/news_scraper news_scraper

WORKDIR ./news_scraper
RUN pip install -r requirements.txt

RUN cp -rf etc/scrapyd /etc
RUN cp scrapyd.serive /etc/systemd/sysmtem/
RUN systemctl daemon-reload
RUN systemctl start scrapyd
RUN crontab cron.conf

WORKDIR ./news_scraper
RUN scrapy-deploy

# Cleaning
RUN rm -f Python* news_scraper
