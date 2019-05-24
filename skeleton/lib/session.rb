require 'json'
require 'byebug'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @req = req
    sesh_cookie_str = @req.cookies['_rails_lite_app']
    if sesh_cookie_str
      @sesh_cookie = JSON.parse(sesh_cookie_str)
    else
      @sesh_cookie = {}
    end
  end

  def [](key)
    @sesh_cookie[key]
  end

  def []=(key, val)
    @sesh_cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.set_cookie("_rails_lite_app", { path: "/" , value: @sesh_cookie.to_json })
  end
end
