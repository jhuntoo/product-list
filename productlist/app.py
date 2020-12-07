from flask import Flask, render_template

from productlist.reqres import list_products


def create_app():
    app = Flask(__name__)

    @app.route("/")
    def hello():
        products = list_products()
        return render_template(
            'product-list.html',
            title='Changes',
            products=products,
        )
    return app
