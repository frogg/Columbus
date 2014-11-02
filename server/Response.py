import requests
import json
import random

from error_handler import getErrorMessage
class Response():
    def __init__(self, returnvalue, statusid):
        self.returnvalue = returnvalue
        self.statusid = statusid

    def response(self):
        if self.statusid == requests.codes.ok:
            r = {'success': True, 'error': ""}
            r.update(self.returnvalue)
        else:
            r = {'success': False}

            if self.returnvalue:
                errormessage = random.choice([getErrorMessage(), self.returnvalue])
            else:
                errormessage = getErrorMessage()
            r.update({'error': {'message': errormessage,'status_code': self.statusid}})
        return json.dumps(r)
