FROM python:3.7.0-alpine3.8
WORKDIR /app

EXPOSE 5000
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN addgroup -g 1000 webgroup && \
    adduser -D -u 1000 -G webgroup webuser

COPY . /app 
RUN chown -R webuser:webgroup /app
USER webuser


CMD ["gunicorn", "--workers=4", "--bind=0.0.0.0:5000", "app:app"]