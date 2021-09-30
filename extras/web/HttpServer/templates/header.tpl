<html>
<head>
<title>Torberry</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="/bootstrap/css/bootstrap.css" type="text/css" />
<link rel="stylesheet" href="/bootstrap/css/bootstrap-responsive.css" type="text/css" />
<script src="/js/jquery-1.10.1.min.js"/></script>
<script src="/bootstrap/js/bootstrap.js"/></script>
<script src="/bootstrap/js/bootstrap.file-input.js"/></script>
<style>
body {
padding-top:60px;
padding-bottom:50px;
}

input[type="text"] ,
input[type="password"] {
    font-size: 16px;
    height: auto;
    margin-bottom: 15px;
    padding: 7px 9px;
    width: 220px;
}

.form-signin {
	min-width: 262px;
        padding: 19px 29px 29px;
        margin: 0 auto 20px;
        background: #4d4d4d;
        border: 1px solid #e5e5e5;
        -webkit-border-radius: 5px;
        -moz-border-radius: 5px;
        border-radius: 5px;
        -webkit-box-shadow: 0 1px 2px rgba(0,0,0,.05);
        -moz-box-shadow: 0 1px 2px rgba(0,0,0,.05);
        box-shadow: 0 1px 2px rgba(0,0,0,.05);
}

.container {
}

</style>
<!--link rel="stylesheet" href="/style.css" type="text/css" /-->
</head>
<body>
<div class="navbar navbar-inverse navbar-fixed-top">
<div class="navbar-inner">
<ul id="navigation" class="nav">
    <li><a href="/sysStat">System Status</a></li>
    <li><a href="/torStat">Tor Status</a></li>
    <li><a href="/torCtl">Tor Control</a></li>
    <li class="dropdown"><a class="dropdown-toggle" data-toggle="dropdown" href="#">Configuration<b class="caret"></b></a>
     <ul class="dropdown-menu">
        <li><a href="/configNetwork">Network Config</a></li>
        <li><a href="/configOR">OR Config</a></li>
        <li class="divider"></li>
        <li><a href="/downloadConfig">Backup Config</a></li>
        <li><a href="/restoreConfig">Restore Config</a></li>
     </ul>
    </li>
    <li><a href="/reset">Reset</a></li>
    <li><a href="/logout">Logout</a></li>
</ul>
<ul class="nav pull-right">
    <li><a class="brand" href="http://torberry.googlecode.com">Torberry</a></li>
</ul>
</div>
</div>
<div class="container">
