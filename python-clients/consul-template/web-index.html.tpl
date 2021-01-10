<!doctype html>
<html>
	<head>
		<meta charset="utf-8"/>
		<title>Consul-aware web service</title>
	</head>
	<body>
    <h1>Hello.</h1>
    <p>I'm a web service, rendering some HTML for you!</p>

	<h2>Consul KV store</h2>
    <p>Here's a value from the consul key-value store (consul KV):</p>
    <p>web-demo-value: schnooschnarbalurg</p>

	<h2>Services</h2>
	<p>Here are all the services we know about:</p>

<ul>
	{{range services}}<li>{{.Name}}: Available at {{range service .Name}}
{{.Address}}{{end}}</li>
{{end}}
</ul>

	</body>
</html>