window.Social ||= {}

$ ->

  Social.reRequest = (scope, callback) ->
    FB.login callback,
      scope: scope
      auth_type: "rerequest"

  Social.friendCache =
    me: {}
    reRequests: {}


  Social.showConfirmationPopup = (message, callback) ->
    c = confirm(message)
    if c
      callback Social.CONFIRM_YES
    else
      callback Social.CONFIRM_NO

  Social.CONFIRM_YES = 1
  Social.CONFIRM_NO = 0    


  Social.login = (callback) ->
    FB.login(callback, {scope: 'user_friends', return_scopes: true})
  Social.loginCallback = (response) ->
    console.log "loginCallback", response
    top.location.href = "https://www.facebook.com/appcenter/YOUR_APP_NAMESPACE"  unless response.status is "connected"
  
  Social.onStatusChange = (response) ->
    unless response.status is "connected"
      Social.login Social.loginCallback
    else
      Social.getMe ->
        Social.getPermissions ->
          if Social.hasPermission("user_friends")
            Social.getFriends ->
              console.log("got friends")
          else
            console.log("no permission")


  onAuthResponseChange = (response) ->
    console.log "onAuthResponseChange", response

  FB.init
    appId: 1440904569532160
    frictionlessRequests: true
    status: true
    version: 'v2.0'

  FB.Event.subscribe('auth.authResponseChange', Social.onAuthResponseChange)
  FB.Event.subscribe('auth.statusChange', Social.onStatusChange)

  Social.sendScore = (score, callback) ->
    FB.api "/me/scores/", "post",
      score: score,
      (response) ->
        if response.error
          console.error "sendScore failed", response
        else
          console.log "Score posted to Facebook", response
        callback()

  Social.getMe = (callback) ->
    FB.api "/me",
      fields: "id,name,first_name,picture.width(120).height(120)"
    , (response) ->
      unless response.error
        Social.friendCache.me = response
        callback()
      else
        console.error "/me", response

  Social.getFriends = (callback) ->
    FB.api "/me/friends",
      fields: "id,name,first_name,picture.width(120).height(120)"
    , (response) ->
      unless response.error
        Social.friendCache.friends = response
        callback()
      else
        console.error "/me/friends", response

  Social.getPermissions = (callback) ->
    FB.api "/me/permissions", (response) ->
      unless response.error
        Social.friendCache.permissions = response
        callback()
      else
        console.error "/me/permissions", response

  Social.hasPermission = (permission) ->
    for i of Social.friendCache.permissions
      return true  if Social.friendCache.permissions[i].permission is permission and Game.friendCache.permissions[i].status is "granted"
    false        