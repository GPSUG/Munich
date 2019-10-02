

invoke-restmethod -uri "http://localhost:51401/users.json" -Method Get 

$obj = invoke-restmethod -uri "http://localhost:51401/users.json" -Method Get 

$obj
$obj[1]