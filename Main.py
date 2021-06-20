from kivy.uix.screenmanager import ScreenManager
from kivy.lang import Builder
from kivymd.app import MDApp
from kivy import Android
import qrcode
import plyer

class Function(ScreenManager):
	def generate_qr_code(self, root):
		if self.ids.link_text.text != '' and self.ids.image_name.text != '':
			code = qrcode.QRCode(version=1.0, box_size=15, border=4)
			code.add_data(self.ids.link_text.text)
			code.make(fit=True)
			img = code.make_image(fill = 'Black', back_color = 'White')
			img.save(f"{self.ids.image_name.text}.png")
			plyer.notification.notify(
				title = 'QR Code generator', message = "Qr Code generated"
			)
		else:
			plyer.notification.notify(
				title = "QR code generator", message = "Type some in the Text Fields"
			)
	def gps_config(self,root):
		droid = android.Android()
		droid.startLocating()
		event = droid.eventWaitFor('location',10000).result
		if event['name'] == "location":
		  try:
		    lat = str(event['data']['gps']['latitude'])
		    lng = str(event['data']['gps']['longitude'])
		  except KeyError:
		    lat = str(event['data']['network']['latitude'])
		    lng = str(event['data']['network']['longitude'])    
		  latlng = 'lat: ' + lat + ' lng: ' + lng
		  print(latlng)

	def view_image(self, root):
		self.ids.img_.source = f"{self.ids.image_name.text}.png"
		root.current = "image"

	def Main_page(self,root):
		root.current = "mainscreen"

class Main(MDApp):
	Builder.load_file('layout.kv')
	def build(self):
		return Function()

Main().run()
