#!/usr/bin/env python3
# ACHTUNG! THIS IS NOT HOW I USUALLY WRITE SCRIPTS!

# This supposed to be code in nginx+lua, but I found
# python more convenient for handling tricky URLs and
# image manipulations. Sorry :)

from bottle import route, get, run, template, \
  static_file, request, response, HTTPError

import Image
import time
import re

SIZES = dict(xsmall=50,  small=100, medium=500, large=1000, xlarge=2000)

@get('<uri:path>')
def static(uri):
  # HERE IS WHERE YANDEX EXPETS CACHE TO BE
  if uri.find('/static/remote/') != -1:
    # quick and dirty way to parse URL, do not do in so in prod, sons
    toks = uri.split('/')
    size = toks[3]
    fname = toks[-1]
    if fname.endswith('png'):
      fname = 'dog.png'
    else:
      fname = 'turtle.jpg'
    uri = '/static/local/%s/%s' %(size, fname)
    return static_file(uri, root='.')

  # AUTH REQUEST, LET'S SET COOKIE
  elif uri.startswith('/auth'):
    fname = uri.split('/')[2:]
    fname = "/".join(fname)
    # bits and pieces from reverse engineered lua code
    response.set_header('Set-Cookie', '%s=%s; path=/; expires=%s' % ('auth_' + fname, 'xxx', int(time.time())+24*3600 ))
    return ""  # doesn't really matter what to return

  # STATIC FILES!
  elif uri.endswith('.css') or uri.endswith('.js'):
    if uri == "/auth/local/jquery.min.js":
      response.set_cookie("auth_local", "jquery.min.js")
      response.set_header('Set-Cookie', 'auth_local/jquery.min.js')
      uri  = "/static/local/jquery.min.js"
    # static_files() screws headers, so I use open() :(((
    return open('.'+ uri, 'rb')  # DO NOT DO THIS IN PROD!!1

  # IMAGES
  elif uri.endswith(".png") or uri.endswith('.jpg'):
    # check all cookies if there is auth cookie....
    for c in request.cookies:
      if c.startswith('auth_'):
        # oh no, what a dirty code...
        uri = '/static/' + c.split('auth_')[1]
        break
    else:
      # no auth cookie, get out!
      raise HTTPError(403)

    # got auth cookie, let's resize img and put in on disk
    r = re.match('/static/local/([a-zA-Z]+)/(.+)', uri)
    vsize, fname = r.groups()
    img = Image.open('static/local/' + fname)
    size = SIZES[vsize]
    img = img.resize((size,size))
    img.save('.'+uri)
    return static_file(uri, root='.')

  # all other URLs are forbidden (doesn't really matter)
  raise HTTPError(404)


run(host='0.0.0.0', port=8000, debug=True, reloader=True)
