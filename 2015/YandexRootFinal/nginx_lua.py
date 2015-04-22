#!/usr/bin/env python3
# ACHTUNG! THIS IS NOT HOW I USUALLY WRITE SCRIPTS!
from bottle import route, get, run, template, \
  static_file, request, response, HTTPError

import Image
import time
import re

SIZES = dict(xsmall=50,  small=100, medium=500, large=1000, xlarge=2000)

@get('<uri:path>')
def static(uri):
  print("URI:", uri)
  print("COOKIES:", [x for x in request.cookies.items()])
  if uri.find('/static/remote/') != -1:
    toks = uri.split('/')
    size = toks[3]
    fname = toks[-1]
    if fname.endswith('png'):
      fname = 'dog.png'
    else:
      fname = 'turtle.jpg'
    uri = '/static/local/%s/%s' %(size, fname)
    print("!!! reconstructed URI:", uri)
    return static_file(uri, root='.')
  if uri.startswith('/auth'):

    fname = uri.split('/')[2:]
    fname = "/".join(fname)
    response.set_header('Set-Cookie', '%s=%s; path=/; expires=%s' % ('auth_' + fname, 'xxx', int(time.time())+24*3600 ))
    return ""
  if uri.endswith('.css') or uri.endswith('.js'):
    if uri == "/auth/local/jquery.min.js":
      response.set_cookie("auth_local", "jquery.min.js")
      response.set_header('Set-Cookie', 'auth_local/jquery.min.js')
      uri  = "/static/local/jquery.min.js"
    return open('.'+ uri, 'rb')  # DO NOT DO THIS IN PROD!!1
  if uri.endswith(".png") or uri.endswith('.jpg'):
    for c in request.cookies:
      if c.startswith('auth_'):
        uri = '/static/' + c.split('auth_')[1]
        print("URI AFTER:", uri)
        break
    else:
      raise HTTPError(403)
    # SIZE
    r = re.match('/static/local/([a-zA-Z]+)/(.+)', uri)
    vsize, fname = r.groups()
    img = Image.open('static/local/' + fname)
    size = SIZES[vsize]
    img = img.resize((size,size))
    img.save('.'+uri)
    return static_file(uri, root='.')
    #import pdb; pdb.set_trace()
  raise HTTPError(404)
    #return template('<b>Hello {{name}}</b>!', name=name)


run(host='0.0.0.0', port=8000, debug=True, reloader=True)
