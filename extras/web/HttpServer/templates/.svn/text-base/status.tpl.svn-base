{% include 'header.tpl' %}
<h2>TOR Status</h2>
Tor version: {{ version }}<br />
Config file: {{ config }}<br />
Ext IP: {{ extip }}<br />
{% if live %}
    Tor status: Connected<br />
<!--    Circuit status:<br />
        {% for item in circuit.split("\n") %}
        	{{ item }} <br />
        {% endfor %}  -->
{% else %}
    Tor status: Disconnected<br /> 
{% endif %}
TOR Logs:<br />
    	{% for item in logs.split("\n") %}
    		{{ item }} <br />
    	{% endfor %}
{% include 'footer.tpl' %}
