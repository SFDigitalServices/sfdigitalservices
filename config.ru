use Rack::Static, 
  :urls => ["/assets", "/css", "/fonts", "/CDSO.html", "/thanks.html", "/404.html", "/favicon.ico", "/joinus.html", "/housingproductmanager.html"],
  :root => "public"

run lambda { |env|
  [
    200, 
    {
      'Content-Type'  => 'text/html', 
      'Cache-Control' => 'public, max-age=86400' 
    },
    File.open('public/index.html', File::RDONLY)
  ]
}