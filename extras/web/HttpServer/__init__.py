"""
cherrypy torberry app
alex.a.bravo@gmail.com
"""

import os
import sys
import cherrypy
import PAM
from jinja2 import Environment, FileSystemLoader
from torcon import TorCon
from cherrypy.lib.static import serve_file
from subprocess import *
from configBerry import *

env = Environment(loader=FileSystemLoader('/root/HttpServer/templates'))

def authenticate():
	user = cherrypy.session.get('user',None)
	if not user:
		raise cherrypy.HTTPRedirect('/?errMsg=You%20are%20not%20logged%20in')

cherrypy.tools.authenticate = cherrypy.Tool('before_handler', authenticate)

class HttpServer:
	@cherrypy.expose
	def index(self, errMsg=''):
		user = cherrypy.session.get('user',None)
		if not user:
			tmpl = env.get_template('login.tpl')
			if not errMsg:
				errMsg = ''
			return tmpl.render(errMsg=errMsg)
		else:	
			tmpl = env.get_template('frame.tpl')
			return tmpl.render()

	@cherrypy.expose
	def login(self,user,passwd,ok):
		def pam_conv(aut, query_list, user_data):
		        resp = []
		        for item in query_list:
		        	query, qtype = item
		                                
		                # If PAM asks for an input, give the password
		                if qtype == PAM.PAM_PROMPT_ECHO_ON or qtype == PAM.PAM_PROMPT_ECHO_OFF:
		         	       resp.append((str(passwd), 0))
		                                                                               
		                elif qtype == PAM.PAM_PROMPT_ERROR_MSG or qtype == PAM.PAM_PROMPT_TEXT_INFO:
		                       resp.append(('', 0))
		                                                                                                                            
		        return resp

		auth = PAM.pam()
		auth.start('login')
		auth.set_item(PAM.PAM_USER, user)
		auth.set_item(PAM.PAM_CONV, pam_conv)
		#if user == 'root' and passwd == 'raspberry':
		try:
			auth.authenticate()
			auth.acct_mgmt()
		except PAM.error,resp:	
			raise cherrypy.HTTPRedirect('/?errMsg=Invalid%20credentials')
		except:
			raise cherrypy.HTTPRedirect('/?errMsg=Invalid%20credentials')
				
		cherrypy.session['user'] = user
		return self.index() 

	@cherrypy.expose
	@cherrypy.tools.authenticate()	
	def logout(self):
		cherrypy.session.clear()
		tmpl = env.get_template('frame.tpl')
		return tmpl.render(msg="Session terminated")
		
				
	@cherrypy.expose
	@cherrypy.tools.authenticate()	
	def torStat(self):
		torcon = TorCon()
		logListener = torcon.LogsListener()
		conn = torcon.myconnect(logListener)
		if conn:
		        version = conn.get_info("version")["version"]
		        config = conn.get_info("config-file")["config-file"] 
		        extip = conn.get_info("address")["address"]
		        live = conn.is_live()
		        circuit = conn.get_info("circuit-status")["circuit-status"]
		        flog = open("/var/log/tor/notices.log","r")
		        logs = flog.read()
		        tmpl = env.get_template('status.tpl')
		        return tmpl.render(version=version, config=config,extip=extip,live=live,circuit=circuit,logs=logs)
		else:
			tmpl = env.get_template('frame.tpl')
			return tmpl.render(msg="TOR doesn't seem to be running")

	@cherrypy.expose
	@cherrypy.tools.authenticate()	
        def renewip(self):
                torcon = TorCon()
                logListener = torcon.LogsListener()
                conn = torcon.myconnect(logListener)
                if conn:
                        conn.sendAndRecv('signal newnym\r\n')
                        tmpl = env.get_template('frame.tpl')
                        return tmpl.render(msg="IP Renew requested")

        @cherrypy.expose
	@cherrypy.tools.authenticate()	
        def halt(self):
        	torcon = TorCon()
        	logListener = torcon.LogsListener()
        	conn = torcon.myconnect(logListener)
        	if torcon:
        		conn.sendAndRecv('signal halt\r\n')
        		tmpl = env.get_template('frame.tpl')
        		return tmpl.render(msg="TOR halted")

        @cherrypy.expose
	@cherrypy.tools.authenticate()	
        def sysStat(self):
        	uptime = Popen("uptime", stdout=PIPE, shell=True).stdout.read()
        	uname = Popen("uname -a", stdout=PIPE, shell=True).stdout.read()
        	free = Popen("free -m | grep Mem | cut -d: -f2", stdout=PIPE, shell=True).stdout.read()
        	disk = Popen("df -h", stdout=PIPE, shell=True).stdout.read()
        	net = Popen("ip a", stdout=PIPE, shell=True).stdout.read()
        	modules = Popen("lsmod", stdout=PIPE, shell=True).stdout.read()
        	dmesg = Popen("dmesg", stdout=PIPE, shell=True).stdout.read()
        	iptables = Popen("iptables -L && iptables -t nat -L", stdout=PIPE, shell=True).stdout.read()
        	sysctl = Popen("sysctl -a", stdout=PIPE, shell=True).stdout.read()
      		tmpl = env.get_template('sysstatus.tpl')
       		return tmpl.render(uptime=uptime,uname=uname,free=free,disk=disk,net=net,modules=modules,dmesg=dmesg,iptables=iptables,sysctl=sysctl)
        	
	@cherrypy.expose
	@cherrypy.tools.authenticate()	
	def torCtl(self):
		tmpl = env.get_template('control.tpl')
		return tmpl.render()

	@cherrypy.expose
	@cherrypy.tools.authenticate()	
	def restoreConfig(self):
		tmpl = env.get_template('uconfig.tpl')
		return tmpl.render()	

	@cherrypy.expose	
	@cherrypy.tools.authenticate()	
	def upload(self,conffile):
		size = 0
		while True:
			data = conffile.file.read(8192)
		        if not data:
		        	break
		        size += len(data)
		        cfig = ""
		        cfig = cfig + data
		if conffile.filename != "torberry.conf":
			tmpl = env.get_template('frame.tpl')
			return tmpl.render(msg="You aren't uploading a torberry conf file. Ensure that filename is torberry.conf")
		f = open("/etc/torberry.conf","w")
		f.write(cfig)
		f.close()
		tmpl = env.get_template('ufile.tpl')	
		return tmpl.render(length=size,filename=conffile.filename,filetype=conffile.content_type)

		
	@cherrypy.expose
	@cherrypy.tools.authenticate()	
	def downloadConfig(self):
		return serve_file("/etc/torberry.conf", "application/x-download", "attachment")
		
	@cherrypy.expose
	@cherrypy.tools.authenticate()	
	def reset(self):
		os.system("reboot")
		tmpl = env.get_template('reset.tpl')
		return tmpl.render()
		
	@cherrypy.expose
	@cherrypy.tools.authenticate()	
	def configNetwork(self):
		conf = configBerry()
		operation_mode = conf.readConf("OPERATION_MODE")
		upstream_if = conf.readConf("UPSTREAM_IF")
		upstream_ip_mode = conf.readConf("UPSTREAM_IP_MODE")
		upstream_ip_ipaddr = conf.readConf("UPSTREAM_IP_IPADDR")
		upstream_ip_netmask = conf.readConf("UPSTREAM_IP_NETMASK")
		upstream_ip_network = conf.readConf("UPSTREAM_IP_NETWORK")
		upstream_ip_broadcast = conf.readConf("UPSTREAM_IP_BROADCAST")
		upstream_ip_gateway = conf.readConf("UPSTREAM_IP_GATEWAY")
		upstream_ip_dns = conf.readConf("UPSTREAM_IP_DNS")
		upstream_wireless = conf.readConf("UPSTREAM_WIRELESS")
		upstream_wl_ssid = conf.readConf("UPSTREAM_WL_SSID")
		upstream_wl_proto = conf.readConf("UPSTREAM_WL_PROTO")
		upstream_wl_keymgmt = conf.readConf("UPSTREAM_WL_KEYMGMT")
		upstream_wl_passwd = conf.readConf("UPSTREAM_WL_PASSWD")
		downstream_if = conf.readConf("DOWNSTREAM_IF")
		downstream_ip_ipaddr = conf.readConf("DOWNSTREAM_IP_IPADDR")
		downstream_ip_netmask = conf.readConf("DOWNSTREAM_IP_NETMASK")
		downstream_ip_network = conf.readConf("DOWNSTREAM_IP_NETWORK")
		downstream_ip_broadcast = conf.readConf("DOWNSTREAM_IP_BROADCAST")
		downstream_dhcp_from = conf.readConf("DOWNSTREAM_DHCP_FROM")
		downstream_dhcp_to = conf.readConf("DOWNSTREAM_DHCP_TO")
		tmpl = env.get_template('config.tpl')
		return tmpl.render(operation_mode=operation_mode,upstream_if=upstream_if,upstream_ip_mode=upstream_ip_mode,
		upstream_ip_ipaddr=upstream_ip_ipaddr,upstream_ip_netmask=upstream_ip_netmask,upstream_ip_network=upstream_ip_network,
		upstream_ip_broadcast=upstream_ip_broadcast,upstream_ip_gateway=upstream_ip_gateway,upstream_ip_dns=upstream_ip_dns,
		upstream_wireless=upstream_wireless,upstream_wl_ssid=upstream_wl_ssid,upstream_wl_proto=upstream_wl_proto,
		upstream_wl_keymgmt=upstream_wl_keymgmt,upstream_wl_passwd=upstream_wl_passwd,downstream_if=downstream_if,
		downstream_ip_ipaddr=downstream_ip_ipaddr,downstream_ip_netmask=downstream_ip_netmask,downstream_ip_network=downstream_ip_network,
		downstream_ip_broadcast=downstream_ip_broadcast,downstream_dhcp_from=downstream_dhcp_from,downstream_dhcp_to=downstream_dhcp_to)

        @cherrypy.expose
        @cherrypy.tools.authenticate()
        def applyConfig(self,operation_mode,upstream_if,upstream_ip_mode,upstream_ip_ipaddr,upstream_ip_netmask,upstream_ip_network,
        upstream_ip_broadcast,upstream_ip_gateway,upstream_ip_dns,upstream_wireless,upstream_wl_ssid,upstream_wl_proto,
        upstream_wl_keymgmt,upstream_wl_passwd,downstream_if,downstream_ip_ipaddr,downstream_ip_netmask,downstream_ip_network,
        downstream_ip_broadcast,downstream_dhcp_from,downstream_dhcp_to,send):
	        conf = configBerry()
	        conf.writeConf("OPERATION_MODE",operation_mode)	
        	conf.writeConf("UPSTREAM_IF",upstream_if)
                conf.writeConf("UPSTREAM_IP_MODE",upstream_ip_mode)
                conf.writeConf("UPSTREAM_IP_IPADDR",upstream_ip_ipaddr)
                conf.writeConf("UPSTREAM_IP_NETMASK",upstream_ip_netmask)
                conf.writeConf("UPSTREAM_IP_NETWORK",upstream_ip_network)
                conf.writeConf("UPSTREAM_IP_BROADCAST",upstream_ip_broadcast)
                conf.writeConf("UPSTREAM_IP_GATEWAY",upstream_ip_gateway)
                conf.writeConf("UPSTREAM_IP_DNS",upstream_ip_dns)
                conf.writeConf("UPSTREAM_WIRELESS",upstream_wireless)
                conf.writeConf("UPSTREAM_WL_SSID",upstream_wl_ssid)
                conf.writeConf("UPSTREAM_WL_PROTO",upstream_wl_proto)
                conf.writeConf("UPSTREAM_WL_KEYMGMT",upstream_wl_keymgmt)
                try:
                	hexval = int(upstream_wl_passwd,16)
                	hex = 0
                except:
                	hex = 1
                if hex == 0:
                	if upstream_wl_passwd.__len__() == 64:
                		conf.writeConf("UPSTREAM_WL_PASSWD",upstream_wl_passwd)
                if hex == 1:	
                	newpass = str(conf.genWlPass(upstream_wl_ssid,upstream_wl_passwd))
                	conf.writeConf("UPSTREAM_WL_PASSWD",newpass)
                conf.writeConf("DOWNSTREAM_IF",downstream_if)
                conf.writeConf("DOWNSTREAM_IP_IPADDR",downstream_ip_ipaddr)
                conf.writeConf("DOWNSTREAM_IP_NETMASK",downstream_ip_netmask)
                conf.writeConf("DOWNSTREAM_IP_NETWORK",downstream_ip_network)
                conf.writeConf("DOWNSTREAM_IP_BROADCAST",downstream_ip_broadcast)
                conf.writeConf("DOWNSTREAM_DHCP_FROM",downstream_dhcp_from)
                conf.writeConf("DOWNSTREAM_DHCP_TO",downstream_dhcp_to)
                if send == "Save and Reset":
      	                os.system("reboot")
                        tmpl = env.get_template('reset.tpl')
                        return tmpl.render()
                else:
        		tmpl = env.get_template('frame.tpl')
        		return tmpl.render(msg="You must reset to apply changes")

        @cherrypy.expose
        @cherrypy.tools.authenticate()
	def configOR(self):
		conf = configBerry()
		onion_router = conf.readConf("ONION_ROUTER")
		onion_router_orport = conf.readConf("ONION_ROUTER_ORPORT")
		onion_router_dirport = conf.readConf("ONION_ROUTER_DIRPORT")
		onion_router_nickname = conf.readConf("ONION_ROUTER_NICKNAME")
		onion_router_exitpolicy = conf.readConf("ONION_ROUTER_EXITPOLICY")
		onion_router_bwrate = conf.readConf("ONION_ROUTER_BWRATE")
		onion_router_bwburst = conf.readConf("ONION_ROUTER_BWBURST")
		onion_router_maxonionpending = conf.readConf("ONION_ROUTER_MAXONIONPENDING")
		onion_router_maxadbw = conf.readConf("ONION_ROUTER_MAXADBW")
		tmpl = env.get_template('orconfig.tpl')
       		return tmpl.render(onion_router=onion_router,onion_router_orport=onion_router_orport,
       		onion_router_dirport=onion_router_dirport,onion_router_nickname=onion_router_nickname,
       		onion_router_exitpolicy=onion_router_exitpolicy,onion_router_bwrate=onion_router_bwrate,
       		onion_router_bwburst=onion_router_bwburst,onion_router_maxonionpending=onion_router_maxonionpending,
       		onion_router_maxadbw=onion_router_maxadbw)
       		
       		
        @cherrypy.expose
        @cherrypy.tools.authenticate()
        def applyConfigOR(self,onion_router,onion_router_orport,onion_router_dirport,onion_router_nickname,
        onion_router_exitpolicy,onion_router_bwrate,onion_router_bwburst,onion_router_maxonionpending,
        onion_router_maxadbw,send):
        	conf = configBerry()
                conf.writeConf("ONION_ROUTER",onion_router)
                conf.writeConf("ONION_ROUTER_ORPORT",onion_router_orport)
                conf.writeConf("ONION_ROUTER_DIRPORT",onion_router_dirport)
                conf.writeConf("ONION_ROUTER_NICKNAME",onion_router_nickname)
                conf.writeConf("ONION_ROUTER_EXITPOLICY",onion_router_exitpolicy)
                conf.writeConf("ONION_ROUTER_BWRATE",onion_router_bwrate)
                conf.writeConf("ONION_ROUTER_BWBURST",onion_router_bwburst)
                conf.writeConf("ONION_ROUTER_MAXONIONPENDING",onion_router_maxonionpending)
                conf.writeConf("ONION_ROUTER_MAXADBW",onion_router_maxadbw)
	        if send == "Save and Reset":
	        	os.system("reboot")
                        tmpl = env.get_template('reset.tpl')
                        return tmpl.render()
                else:
                        tmpl = env.get_template('frame.tpl')
                        return tmpl.render(msg="You must reset to apply changes")

settings={
            '/': {
            	    'tools.sessions.on': True,
            	    'tools.sessions.timeout': 60,
            	    'tools.sessions.storage_type': "file",
            	    'tools.sessions.storage_path': "/var/log/tor/",
                 }
}
cherrypy.config.update(settings)

httpserver = HttpServer()

if __name__ == '__main__':
	cherrypy.config.update({'server.socket_host': '0.0.0.0','server.socket_port': 8080})
	root = Root()
	cherrypy.quickstart(root)

