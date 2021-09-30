#!/usr/bin/env python

"""
Part of torberry http://torberry.googlecode.com
This python script shows Tor availability
"""

import time
import TorCtl
import socket
import os

def connect_socket(socketPath="/var/run/tor/control", ConnClass=TorCtl.Connection):
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


def myconnect():
        global conn
        conn = connect_socket()
        if conn:                                                                   
                conn.set_events(["NOTICE","WARN","ERR"])                      
                conn.add_event_listener(logListener)                               
                                                                                   
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
                                                                                          
logListener = LogsListener()                                                              
myconnect()                                                                               
status = 1
if conn:                                                                          
        print "Tor version "+conn.get_info("version")["version"]                
        print "Connection established"                                              
        status = 0                                                                  
try:                                                                                
        while True:                                                                 
                oldstatus = status                                                  
                if conn:                                                            
                        if conn.is_live() == True:                                  
                                status = 0                                          
                        else:                                                       
                                status = 1                                          
                                myconnect()                                         
                else:                             
                        status = 1                
                        myconnect()               
                time.sleep(1)                     
                if oldstatus != status:           
                        if status == 0:           
                                print "Connection established"
                        if status == 1:                       
                                print "[WARNING] Connection is down"
except KeyboardInterrupt: pass
