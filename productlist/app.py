from datetime import datetime

import asyncio
import aiohttp
from sanic import Sanic, response
from sanic.response import json as sanic_json
from jinja2 import Template
import json

app = Sanic()

html_template = '''
<table>
    <thead>
    <th>Id</th>
    <th>Name</th>
    <th>Year</th>
    <th>Color</th>
    <th>pantone_value</th>
    </thead>

    <tbody>
    {% for product in products %}
    <tr>
        <td>{{ product.id }}</td>
        <td>{{ product.name }}</td>
        <td>{{ product.year }}</td>
        <td>{{ product.color }}</td>
        <td>{{ product.pantone_value }}</td>
    </tr>
    {% endfor %}
    </tbody>
</table>
'''


async def list_products():
    current_page = 1
    products = []
    last_page_hit = False
    while not last_page_hit:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"https://reqres.in/api/products/?page={current_page}") as r:
                text = await r.text()
                obj = json.loads(text)
                products.extend(obj['data'])
                last_page_hit = current_page == obj['total_pages']
                current_page += 1
    return products


async def factorial(number):
    f = 1
    for i in range(2, number+1):
        await asyncio.sleep(0.001)
        f *= i


async def add_cpu_load():
    start_time = datetime.now()
    while (datetime.now() - start_time).seconds < 1.5:
        await factorial(100)


@app.route('/')
async def index(request):
    await add_cpu_load()
    products = await list_products()
    template = Template(html_template)
    return response.html(template.render(products=products))


@app.route("/health")
async def health(request):
    return sanic_json(status=200)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

