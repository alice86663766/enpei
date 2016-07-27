require! koa
require! './routes'
require! './materials-mock': materials-mock
require! 'koa-bodyparser': bodyParser
require! 'koa-websocket': websockify
require! 'koa-vhost': vhost
require! 'koa-static': serve
require! 'koa-cors': cors

app = module.exports = websockify koa!
app
  .use cors!
  .use (next) ->*
    try
      yield next
    catch
      @status = e.status || 500
      @body = error: true, message: e.message
      @app.emit 'error', e, @
  .use (next) ->*
    return yield next if not @headers.'accept-encoding'
    encoding = delete @headers.'accept-encoding'
    yield next
    @headers.'accept-encoding' = encoding
  .use serve "#__dirname/../client"
  .use bodyParser jsonLimit: '2000mb'
  .use routes.control
  .use routes.wrapped
 # .use routes.doc
  .use vhost materials-mock.host, materials-mock

app.ws.use routes.ws.handle-error
app.ws.use routes.ws.mimic-novm-ws
app.ws.use routes.ws.pre-recorded-landscape
app.ws.use routes.ws.pre-recorded-portrait
app.ws.use routes.ws.corrupt-video
app.ws.use routes.ws.proxy-video
app.ws.use routes.ws.proxy-audio
app.ws.use routes.ws.proxy-ctrl
