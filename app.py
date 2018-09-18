from flask import Flask, Response
app = Flask(__name__)
@app.route("/")
def hello():
    return Response("Hi from your Flask app running in your Docker container!")
    
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int("5000"), debug=True)