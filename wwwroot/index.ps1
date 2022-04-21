$baseUri = 'http{0}://{1}:{2}' -f (&{if($env:SERVER_PORT_SECURE){'s'}}), $env:SERVER_NAME, $env:SERVER_PORT
$currentUri = '{0}{1}{2}' -f $baseUri, $env:PATH_INFO, (&{if($env:QUERY_STRING){'?'+$env:QUERY_STRING}})

if ($env:PATH_INFO -match '^/$')
{
    'Content-Type: text/html'
    ''
    '<h1>Main Page</h1>'
    'Current URI: {0}<br>' -f $currentUri
    '<a href="/info">Info</a><br>'
    '<a href="/variable/this-is-a-variable">Variable in URL</a><br>'
    '<a href="/abc/def/ghi?aaa=bbb&ccc=ddd">Unknown request</a><br>'
    '<a href="/example.ps1">Example PowerShell 5 file</a><br>'
    '<a href="/example.pwsh.ps1">Example PowerShell 7 file</a><br>'
    '<a href="/example.cmd">Example CMD file</a><br>'
    '<br><hr>'
    'Try running this PowerShell<br>'
    '<pre>'
    "Invoke-RestMethod -Uri $baseUri/posttest -Method Get"
    "Invoke-RestMethod -Uri $baseUri/posttest -Method Post"
    "Invoke-RestMethod -Uri $baseUri/posttest -Method Post -Body 'this is not JSON'"
    "Invoke-RestMethod -Uri $baseUri/posttest -Method Post -Body '{""msg"": ""this is JSON""}'"
    '</pre>'
    '<br><hr>'
    'Image served by static file:<br><img src="/stick.png">'
}
elseif ($env:PATH_INFO -match '^/posttest$' -and $env:REQUEST_METHOD -eq 'POST')
{
    'Content-Type: application/json'
    ''
    if ($i = [string] $input)
    {
        try
        {
            $r = @{
                Msg = 'Post with JSON data'
                RawData = $i
                JsonData = $i | ConvertFrom-Json
            }            
        }
        catch
        {
            $r = @{
                Msg = 'Post with non-JSON data'
                RawData = $i
            }
        }
    }
    else
    {
        $r = @{
            Msg = 'Post without any data'
        }
    }
    $r | ConvertTo-Json -Depth 9
}
elseif ($env:PATH_INFO -match '^/posttest$')
{
    'Content-Type: application/text'
    ''
    'Why to you access {0} with a {1} request?' -f $currentUri, $env:REQUEST_METHOD
}
elseif ($env:PATH_INFO -match '^/info$')
{
    'Content-Type: text/plain'
    ''
    'Current URI: {0}' -f $currentUri
    ''
    Get-ChildItem -Path env:
    ''
    ''
    $host
}
elseif ($env:PATH_INFO -match '^/variable(/(.*))?$')
{
    'Content-Type: text/plain'
    ''
    'Current URI: {0}' -f $currentUri
    '$env:PATH_INFO: {0}' -f $env:PATH_INFO
    ''
    if ($Matches[2])
    {
        'Variable: {0}' -f $Matches[2]
    }
    else
    {
        'No variable was set'
    }
}
else
{
    'Content-Type: text/plain'
    ''
    'Current URI: {0}' -f $currentUri
    'Unknown request'
    ''
    Get-ChildItem -Path env:
}
