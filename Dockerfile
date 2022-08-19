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
ENTRYPOINT /bin/bash
