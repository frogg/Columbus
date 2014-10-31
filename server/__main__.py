import wikipedia
from flask import Flask
app = Flask(__name__)
@app.route('/')
def hi():
    return "hey"

@app.route('/locations/push/<latitude>/<longtitude>')
def pushLocations(latitude, longtitude):
    return wikipedia.geosearch(latitude, longtitude)
    return 'Hello World!'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')