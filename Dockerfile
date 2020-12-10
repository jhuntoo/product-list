FROM python:alpine3.9
RUN apk update \
    && apk add build-base
RUN pip install --upgrade pip
RUN pip install pipenv


WORKDIR /app
COPY Pipfile /app
COPY Pipfile.lock /app
COPY productlist/ /app/productlist/
RUN pipenv install --system --skip-lock

CMD ["python3",   "productlist/app.py"]
