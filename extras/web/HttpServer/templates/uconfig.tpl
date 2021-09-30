{% include 'header.tpl' %}
<h2>Restore config</h2>
<form action="/upload" method="post" enctype="multipart/form-data">
Filename: <input type="file" name="conffile" class="btn"/><br />
<input type="submit" value="Upload" class="btn btn-primary"/>
</form>
{% include 'footer.tpl' %}
