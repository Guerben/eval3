
FROM python:3.11-slim

RUN useradd -m devsecops
WORKDIR /home/devsecops/App

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

USER devsecops
EXPOSE 5000

CMD["python", "app/app.py"]