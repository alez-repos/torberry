{% include 'header.tpl' %}
<h2>System status</h2>
<h3>Uptime:</h3>
{{ uptime }}
<h3>Kernel:</h3> 
{{ uname }}
<h3>Memory:</h3>
<table class="table">
<tr><td>total</td><td>used</td><td>free</td><td>shared</td><td>buffered</td><td>cached</td></tr>
<tr>
{% for item in free.split() %}
    <td>{{ item }}</td>
{% endfor %}
</tr>
</table>
<h3>Disk:</h3>
<table>
{% for idisk in disk.split('\n') %}
    <tr><td>{{ idisk }}</td></tr>
{% endfor %}
</table>
<h3>Network:<h3>
<table>
{% for inet in net.split('\n') %}
    <tr><td>{{ inet }}</td></tr>
{% endfor %}
</table>
<h3>Firewall:<h3>
<table>
{% for item in iptables.split('\n') %}
    <tr><td>{{ item }}</td></tr>
{% endfor %}
</table>
<h3>System logs:</h3>
<table>
{% for ilog in dmesg.split('\n') %}
    <tr><td>{{ ilog }}</td></tr>
{% endfor %}
</table>
<h3>Modules:</h3>
<table>
{% for imod in modules.split('\n') %}
    <tr><td>{{ imod }}</td></tr>
{% endfor %}
</table>
<h3>Sysctl:</h3>
<table>
{% for item in sysctl.split('\n') %}
    <tr><td>{{ item }}</td></tr>
{% endfor %}
</table>
{% include 'footer.tpl' %}
