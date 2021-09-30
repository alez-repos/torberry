{% include 'header.tpl' %}
<script type="text/javascript">
function econfig() {
if(document.getElementById("operation_mode").value == "nonphys") {
	document.getElementById("econfig").style.display="none";
}
if(document.getElementById("operation_mode").value == "physical-isolation") {
        document.getElementById("econfig").style.display="";
}
}
function e2config() {
if(document.getElementById("upstream_ip_mode").value == "dhcp") {
        document.getElementById("econfig2").style.display="none";
}
if(document.getElementById("upstream_ip_mode").value == "manual") {
        document.getElementById("econfig2").style.display="";
}
}
function e3config() {
if(document.getElementById("upstream_wireless").value == "false") {
        document.getElementById("econfig3").style.display="none";
}
if(document.getElementById("upstream_wireless").value == "true") {
        document.getElementById("econfig3").style.display="";
}
}
</script>
<h2>Network configuration</h2>
<div class="row">
<form action="/applyConfig" method="post" class="navbar-form pull-left">
<div class="span2">
Config mode
</div>
<div class="span1">
<select id="operation_mode" name="operation_mode" onChange="econfig()">
{% if operation_mode == "nonphys" %}
	<option value="nonphys" selected>Nonphys (only eth0)</option>
	<option value="physical-isolation">Physical isolation</option>
{% endif %}
{% if operation_mode == "physical-isolation" %}
	<option value="nonphys">Nonphys (only eth0)</option>
	<option value="physical-isolation" selected>Physical isolation</option>
{% endif %}
</select>
</div>
</div>
<div id="econfig">
<h3>Upstream</h3>
<div class="row">
<div class="span2">Upstream Interface</div>
<div class="span1">
<input type="text" name="upstream_if" value="{{ upstream_if }}"/><br />
</div>
</div>
<div class="row">
<div class="span2">
Upstream IP mode</div>
<div class="span1">
<select id="upstream_ip_mode" name="upstream_ip_mode" onChange="e2config()">
{% if upstream_ip_mode == "dhcp" %}
        <option value="dhcp" selected>dhcp</option>
        <option value="manual">manual</option>
{% endif %}
{% if upstream_ip_mode == "manual" %}
        <option value="dhcp">dhcp</option>
        <option value="manual" selected>manual</option>
{% endif %}
</select>
</div>
</div>
<div id="econfig2">
<div class="row"><div class="span2">Upstream IP Address</div><div class="span1"><input type="text" name="upstream_ip_ipaddr" value="{{ upstream_ip_ipaddr }}" /></div></div>
<div class="row"><div class="span2">Upstream IP Netmask</div><div class="span1"><input type="text" name="upstream_ip_netmask" value="{{ upstream_ip_netmask }}"/></div></div>
<div class="row"><div class="span2">Upstream IP Network</div><div class="span1"><input type="text" name="upstream_ip_network" value="{{ upstream_ip_network }}"/></div></div>
<div class="row"><div class="span2">Upstream IP Broadcast</div><div class="span1"><input type="text" name="upstream_ip_broadcast" value="{{ upstream_ip_broadcast }}"/></div></div>
<div class="row"><div class="span2">Upstream IP Gateway</div><div class="span1"><input type="text" name="upstream_ip_gateway" value="{{ upstream_ip_gateway }}"/></div></div>
<div class="row"><div class="span2">Upstream IP DNS</div><div class="span1"><input type="text" name="upstream_ip_dns" value="{{ upstream_ip_dns }}"/></div></div>
</div>
<div class="row">
<div class="span2">
Upstream Wireless</div>
<div class="span1">
<select id="upstream_wireless" name="upstream_wireless" onChange="e3config()">
{% if upstream_wireless == "true" %}
        <option value="true" selected>true</option>
        <option value="false">false</option>
{% endif %}
{% if upstream_wireless == "false" %}
        <option value="true">true</option>
        <option value="false" selected>false</option>
{% endif %}
</select>
</div>
</div>
<div id="econfig3">
<div class="row"><div class="span2">SSID</div><div class="span1"><input type="text" name="upstream_wl_ssid" value="{{ upstream_wl_ssid }}" /></div></div>
<div class="row"><div class="span2">Protocol</div><div class="span1"><input type="text" name="upstream_wl_proto" value="{{ upstream_wl_proto }}" /></div></div>
<div class="row"><div class="span2">Key Management</div><div class="span1"><input type="text" name="upstream_wl_keymgmt" value="{{ upstream_wl_keymgmt }}" /></div></div>
<div class="row"><div class="span2">Password</div><div class="span1"><input type="password" name="upstream_wl_passwd" value="{{ upstream_wl_passwd }}" /></div></div>
</div>
<h3>Downstream</h3>
<div class="row"><div class="span2">Downstream Interface</div><div class="span1"><input type="text" name="downstream_if" value="{{ downstream_if }}"/></div></div>
<div class="row"><div class="span2">Downstream IP Address</div><div class="span1"><input type="text" name="downstream_ip_ipaddr" value="{{ downstream_ip_ipaddr }}" /></div></div>
<div class="row"><div class="span2">Downstream IP Netmask</div><div class="span1"><input type="text" name="downstream_ip_netmask" value="{{ downstream_ip_netmask }}"/></div></div>
<div class="row"><div class="span2">Downstream IP Network</div><div class="span1"><input type="text" name="downstream_ip_network" value="{{ downstream_ip_network }}"/></div></div>
<div class="row"><div class="span2">Downstream IP Broadcast</div><div class="span1"><input type="text" name="downstream_ip_broadcast" value="{{ downstream_ip_broadcast }}"/></div></div>
<div class="row"><div class="span2">Downstream DHCP range from</div><div class="span1"><input type="text" name="downstream_dhcp_from" value="{{ downstream_dhcp_from }}"/></div></div>
<div class="row"><div class="span2">Downstream DHCP range to</div><div class="span1"><input type="text" name="downstream_dhcp_to" value="{{ downstream_dhcp_to }}"/></div></div>
</div>
<input class="btn" type="submit" name="send" value="Save">
<input class="btn btn-primary" type="submit" name="send" value="Save and Reset">
</form>
<script type="text/javascript">
econfig();
e2config();
e3config();
</script>
{% include 'footer.tpl' %}
