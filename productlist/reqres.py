import json
import requests


def list_products():
    current_page = 1
    products = []
    last_page_hit = False
    while not last_page_hit:
        response = requests.get(f"https://reqres.in/api/products/?page={current_page}")
        obj = json.loads(response.text)
        products.extend(obj['data'])
        last_page_hit = current_page == obj['total_pages']
        current_page += 1
    return products