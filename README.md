# docker_news_crawler

Raspberry Pi 上で(news_crawler)[https://github.com/naronA/news_crawler]をデーモン化するDockerfile

Raspberry Piなので`FROM resin/rpi-raspbian`となっていますが、Debian系なら変更可能です。
また一部が<https://github.com/naronA/news_crawler>専用になっていますので、
その部分を書き換えれば Scrapy + Scrapyd のクローラーは何でも動かせると思います。
