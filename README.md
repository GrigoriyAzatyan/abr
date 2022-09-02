# Инструкция по сборке и запуску приложения sirius-core в Docker-контейнере
   
## 1. Список зависимостей для Python

См. файл **requirements**. Список может дополняться для новых сборок.

## 2. Текст Dockerfile

```
FROM python:latest
COPY ./ssl_conf /openssl
COPY ./secrets /openssl
COPY ./requirements /tmp/requirements
RUN pip install --upgrade pip; pip install -qr /tmp/requirements
RUN mkdir /sirius_core; useradd sirius -m -s /bin/bash; chown -R sirius:sirius /sirius_core
RUN { echo \#\!/bin/bash; cat /openssl/secrets; cat /openssl/script.txt; } > /openssl/gen_certs.sh
RUN /openssl/gen_certs.sh
USER sirius
WORKDIR /sirius_core
EXPOSE 4444
CMD ["python", "/sirius_core/app.py"]
```

### 2.1. Примечание по работе контейнера  
Подразумевается, что контейнер с приложением будет работать на одном из серверов телефонии Ростелл.  
Поэтому здесь генерируется SSL-сертификат на имя, назначенное Ростеллу, чтобы заодно использовать этот сертификат в дальнейшем также и для веб-сервера Ростелл.

Приложение sirius_core в итоге будет доступно по URL: `https://<значение переменной ROSTELL_DNS_NAME>:4444`

### 2.2. Права запуска
Для того, чтобы при сборке образа скрипт мог отработать, выполните в корневой папке репоитория:   
`chmod +x ./ssl_conf/gen_certs.sh`


## 3. Что делать, чтобы первоначально контейнер не падал
Т.к. код еще не доработан под использование переменных окружения, и может не быть соединения с нужными сервисами, рекомендуется в Dockerfile заменить последнюю строку на следующую:

```
ENTRYPOINT /bin/bash
```

В конечной сборке использовать уже первоначальный запуск питоновского приложения.


## 4. Подготовка переменных окружения
Перед сборкой Docker-образа **обязательно заполните актуальные значения переменных в файле secrets**.
Эти значения далее могут быть использованы в любом программном коде, запущенном внутри контейнера:

* Пароль PostgreSQL: **PG_PASS**

* IP кластера PostgreSQL: **PG_HOST**

* DNS-имя сервера TrueConf: **TRUECONF_DNS_NAME**

* Client_id API TrueConf сервера: **TRUECONF_CLIENT_ID**

* Client_secret API TrueConf сервера: **TRUECONF_CLIENT_SECRET**

* DNS-имя сервера Ростелл: **ROSTELL_DNS_NAME**

* Коммуникационный домен Ростелл: **ROSTELL_COMM_DOMAIN**

* Учетка Ростелл с доступом к API: **ROSTELL_LOGIN**

* Пароль учетки Ростелл: **ROSTELL_PASS**

* IP контроллера домена LDAP: **LDAP_DC**

* Краткое имя домена LDAP (префикс для учеток): **LDAP_DOMAIN**

* Учетка для доступа в LDAP: **LDAP_LOGIN**

* Пароль учетки LDAP: **LDAP_PASS**


## 5. Сборка образа из Dockerfile

Выполнить из папки с Dockerfile:

```
docker build -t sirius-core .
```


## 6. Как разместить код приложения в контейнере

Подготовьте папку на вашей Linux-машине:

```
mkdir /sirius_core
```

Перенесите все содержимое корневой папки с кодом в папку /sirius_core. 
Далее мы смонтируем эту папку в контейнер, и она станет одновременно доступной и хосту, и контейнеру.


## 7. Создание и запуск контейнера:

```
docker run -dt --name sirius-core -p 4444:4444 -v /sirius_core:/sirius_core gregory78/sirius-core:latest
```

## 8. Как запустить команду внутри контейнера:

## 8.1. Войти в командную оболочку bash:
```
docker exec -it sirius-core bash
```
Выход командой exit или Ctrl+D.

## 8.2. Запустить исполняемый код приложения:
`docker exec -it sirius-core python app.py`
