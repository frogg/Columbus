import telnetlib

def getErrorMessage():
    host = "towel.Blinkenlights.nl"
    tn = telnetlib.Telnet()
    tn.open(host, 666)
    description = tn.read_all().decode('ascii').replace("\n","").replace("\r","").split("===")[2]
    print(description)
    print("test")
    return description
getErrorMessage