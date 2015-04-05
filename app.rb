require 'sinatra'
require 'sinatra-websocket'
require 'json'

set :server, 'thin'
set :sockets, []

get '/' do
  erb :index do
    'hello'
  end
end

get '/socket' do
  request.websocket do |ws|
    ws.onopen do
      ws.send('Hello world!')
      settings.sockets << ws
    end

    ws.onmessage do
      ws.onmessage do |msg|
        EM.next_tick { settings.sockets.each { |s| s.send(msg) } }
      end
    end

    ws.onclose do
      warn('websocket closed')
      settings.sockets.delete(ws)
    end
  end
end

post '/status' do
  pass unless request.accept?('application/json')

  request.body.rewind
  msg = request.body.read

  EM.next_tick do
    settings.sockets.each do |s|
      s.send(msg)
    end
  end
end
