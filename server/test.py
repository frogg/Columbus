import telnetlib



host = "towel.Blinkenlights.nl"
tn = telnetlib.Telnet()
tn.open(host, 666)
error = tn.read_all().decode('ascii').replace("\n","").replace("\r","").split("===")[2]