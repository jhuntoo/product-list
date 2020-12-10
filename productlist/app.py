from datetime import datetime
from math import factorial

from flask import Flask, render_template, Response

from productlist.reqres import list_products


def add_cpu_load():
    start_time = datetime.now()
    while (datetime.now() - start_time).seconds < 1.5:
        factorial(100)


def create_app():
    app = Flask(__name__)

    @app.route("/")
    def index():
        add_cpu_load()
        products = list_products()
        return render_template(
            'product-list.html',
            title='Changes',
            products=products,
        )

    @app.route("/health")
    def health():
        return Response(status=200)
    return app
