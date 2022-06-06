from flask import Flask, Response, request
app = Flask(__name__)

@app.before_request
def log_request():
    app.logger.debug("Request Headers %s", request.headers)
    return None

@app.route("/")
def hello():
    return Response("Hi from your Flask app running in your Docker container!")

@app.route("/healthz")
def healthz():
     return  Response("OK")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int("5000"), debug=True)