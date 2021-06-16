from plyer import gps
from kivy.app import App

class MainApp():
    def on_start():
        gps.configure(on_location=self.on_gps_location)
        gps.start()
    
    def on_gps_location(self, **kwargs):
        print(kwargs)

MainApp().run()