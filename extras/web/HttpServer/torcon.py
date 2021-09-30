#!/usr/bin/env python

"""
Part of torberry http://torberry.googlecode.com
This python script shows Tor availability
"""

import time
import TorCtl
import socket
import os

class TorCon:

	def connect_socket(self,socketPath="/var/run/tor/control", ConnClass=TorCtl.Connection):
        	if not os.path.exists("/var/run/tor/control"):
                	print "[WARNING] Socket is closed. Tor not running?"
	                return
	        try:
        	        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                	s.connect(socketPath)
	                conn = ConnClass(s)
        	        conn.authenticate("")
	                return conn
	        except Exception, exc:
        	        raise IOError(exc)


	def myconnect(self,logListener):
        	conn = self.connect_socket()
	        if conn:                                                                   
        	        conn.set_events(["NOTICE","WARN","ERR"])                      
                	conn.add_event_listener(logListener) 
                	return conn                              
                                                                                   
	class LogsListener(TorCtl.PostEventListener):                                             
        	def __init__(self):                                                               
                	TorCtl.PostEventListener.__init__(self)                                   
                                                                                          
	        def msg_event(self, event):                                                       
        	        if event.level == "NOTICE":                                               
                	        print "["+chr(27)+"[0;32mnotice"+chr(27)+"[0m] "+event.msg        
	                if event.level == "WARN":                                                 
        	                print "["+chr(27)+"[0;33mwarn"+chr(27)+"[0m] "+event.msg          
	                if event.level == "ERR":                                                  
        	                print "["+chr(27)+"[0;31merr"+chr(27)+"[0m] "+event.msg           
                                                                                          
