#!/usr/bin/env python

from subprocess import *

class configBerry:
	def readConf(self,value):
		var = Popen("grep --only-matching --perl-regex \"(?<=" + value + "\=).*\" /etc/torberry.conf", stdout=PIPE, shell=True).stdout.read()
                var = var.replace('"','')
                var = var.replace("'","")
                var = var.replace("\n","")
                var = var.replace("\r","")
                return var	

	def writeConf(self,option,ovalue):
		ovalue = ovalue.replace("\n","")
		ovalue = ovalue.replace("\r","")
		var = Popen("grep \"" + option + "=\" /etc/torberry.conf || echo " + option + "=\"" + ovalue + "\" >> /etc/torberry.conf", stdout=PIPE, shell=True).stdout.read()
                var = Popen("sed -i 's/" + option + "=.*/" + option + "=\"" + ovalue + "\"/' /etc/torberry.conf || echo " + option + "=\"" + ovalue + "\" >> /etc/torberry.conf", stdout=PIPE, shell=True).stdout.read()
                

	def genWlPass(self,ap,newpass):
		var = Popen("wpa_passphrase \"" + ap + "\" \"" + newpass + "\" | grep \"psk=\" | grep -v \"#\" | cut -d\"=\" -f 2", stdout=PIPE, shell=True).stdout.read()
		return var
