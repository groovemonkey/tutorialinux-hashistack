<!DOCTYPE html>
<html>
<head>
<title>Consul Madness!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Hello {{ key "/nginx/name" }}!</h1>
<p>It looks like you've got nginx configured If you see a value from the Consul Key-Value store above, that means you've got everything configured!</p>

<p>Here's the custom content you set in the consul KV store, at /nginx/content:</p>

<p>{{ key "/nginx/content" }}</p>

</body>
</html>