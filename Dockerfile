FROM python:3.9-alpine3.13
LABEL maintainer="w.kreativo@gmail.com"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
RUN python -m venv /py && \
    # upgrade pip image
    /py/bin/pip install --upgrade pip && \
    # install postgresql-client
    apk add --update --no-cache postgresql-client && \
    # Set up a virtual dependence package - group packages and then delete them
    apk add --update --no-cache --virtual .tmp-build-deps \
    # List packages to install psycopg2
    build-base postgresql-dev musl-dev && \
    # Install our requirements
    /py/bin/pip install -r /tmp/requirements.txt && \
    # Install our requirements for dev environment
    if [ $DEV = "true" ] ; \
    then echo "--DEV BUILD--" && /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    # delete packages listed on line 20
    apk del .tmp-build-deps && \
    # remove tmp folder
    rm -rf /tmp && \
    # add user diferent to root
    adduser \
    --disabled-password \
    --no-create-home \
    django-user

ENV PATH="/py/bin:$PATH"

USER django-user
