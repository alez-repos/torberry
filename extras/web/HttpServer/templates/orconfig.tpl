{% include 'header.tpl' %}
<script type="text/javascript">
function oconfig() {
if(document.getElementById("onion_router").value == "false") {
	document.getElementById("oconfig").style.display="none";
}
if(document.getElementById("onion_router").value == "true") {
        document.getElementById("oconfig").style.display="";
}
}
</script>
<h2>OR configuration</h2>
<div class="row">
<form action="/applyConfigOR" method="post" class="navbar-form pull-left">
<div class="span2">
OR Capabilities
</div>
<div class="span1">
<select id="onion_router" name="onion_router" onChange="oconfig()">
{% if onion_router == "true" %}
	<option value="true" selected>enabled</option>
	<option value="false">disabled</option>
{% endif %}
{% if onion_router == "false" %}
	<option value="true">enabled</option>
	<option value="false" selected>disabled</option>
{% endif %}
</select>
</div>
</div>
<div id="oconfig">
<h3>Relay details</h3>
<div class="row"><div class="span2">OR Port</div><div class="span1"><input type="text" name="onion_router_orport" value="{{ onion_router_orport }}" /></div></div>
<div class="row"><div class="span2">OR Dirport</div><div class="span1"><input type="text" name="onion_router_dirport" value="{{ onion_router_dirport }}"/></div></div>
<div class="row"><div class="span2">Nickname</div><div class="span1"><input type="text" name="onion_router_nickname" value="{{ onion_router_nickname }}"/></div></div>
<div class="row"><div class="span2">Exit Policy</div><div class="span1"><input type="text" name="onion_router_exitpolicy" value="{{ onion_router_exitpolicy }}"/></div></div>
<div class="row"><div class="span2">Bandwidth Rate (KB)</div><div class="span1"><input type="text" name="onion_router_bwrate" value="{{ onion_router_bwrate }}"/></div></div>
<div class="row"><div class="span2">Bandwidth Burst (KB)</div><div class="span1"><input type="text" name="onion_router_bwburst" value="{{ onion_router_bwburst }}"/></div></div>
<div class="row"><div class="span2">Max Onion pending conn</div><div class="span1"><input type="text" name="onion_router_maxonionpending" value="{{ onion_router_maxonionpending }}"/></div></div>
<div class="row"><div class="span2">Max Advertised BW</div><div class="span1"><input type="text" name="onion_router_maxadbw" value="{{ onion_router_maxadbw }}"/></div></div>
</div>
<input class="btn" type="submit" name="send" value="Save">
<input class="btn btn-primary" type="submit" name="send" value="Save and Reset">
</form>
<script type="text/javascript">
oconfig();
</script>
{% include 'footer.tpl' %}
