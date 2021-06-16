from plyer import gps

def print_locations(**kwargs):
    print('lat: {lat}, lon: {lon}'.format(**kwargs))

gps.configure(on_location=print_locations)
gps.start()
# later
gps.stop()