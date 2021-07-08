module Pages.User exposing (page)

import View exposing (View)
import Page exposing (Page)
import Request exposing (Request)
import Shared
import Auth

page : Shared.Model -> Request -> Page
page shared _ =
  Page.protected.static
  (\user -> { view = view user })

view : Auth.User -> View msg
view user =
    View.placeholder "User"

