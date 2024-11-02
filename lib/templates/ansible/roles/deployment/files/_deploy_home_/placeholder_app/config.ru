deploy_html = '
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>Title</title>
    </head>
  <body>
    <h1>Waiting for first deploy...</h1>
  </body>
  </html>
'

run ->(env) { [200, {"Content-Type" => "text/html"}, [deploy_html]] }