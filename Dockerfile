FROM python:3.9.0-slim
RUN apt-get update
RUN pip install --upgrade pip
RUN pip install pipenv


WORKDIR /app
COPY . /app
RUN pipenv install --system --skip-lock

CMD ["gunicorn", "--bind", ":5000", "productlist:create_app()"]
