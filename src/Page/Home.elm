module Page.Home exposing (Model, Msg, view, init)

import Html exposing (..)
import Html.Attributes exposing(..)

type Model = 
  Ok

type Msg = 
  GotOkMsg

init : ( Model, Cmd Msg )
init = ( Ok , Cmd.none )

view : { title: String, content : Html msg }
view = { title = "Home"
    , content =
        p [ ] [text "Hello World"]
    }

