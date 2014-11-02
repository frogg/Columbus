import telnetlib
from flask import current_app, Markup, render_template, request, jsonify
from werkzeug.exceptions import default_exceptions, HTTPException

def error_handler(error):
    msg = "Request resulted in {}".format(error)
    current_app.logger.warning(msg, exc_info=error)


    if isinstance(error, HTTPException):
        description = error.get_description(request.environ)
        code = error.code
        name = error.name
    else:
        description = getErrorMessage()
        code = 500
        name = 'Internal Server Error'

    # Flask supports looking up multiple templates and rendering the first
    # one it finds.  This will let us create specific error pages
    # for errors where we can provide the user some additional help.
    # (Like a 404, for example).
    error = {'success': False, "error": {"message": getErrorMessage()}}
    return jsonify(error)


def getErrorMessage():
    host = "towel.Blinkenlights.nl"
    tn = telnetlib.Telnet()
    tn.open(host, 666)
    description = tn.read_all().decode('ascii').replace("\n","").replace("\r","").split("===")[4]
    return description
