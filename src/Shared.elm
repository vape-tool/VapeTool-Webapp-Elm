module Shared exposing
    ( Flags
    , Model
    , Msg
    , init
    , subscriptions
    , update
    , User
    )

import Json.Decode as Json
import Request exposing (Request)
import Domain.User


type alias Flags =
    Json.Value


type alias Model =
  { firebaseUser : Maybe Domain.User.FirebaseUser 
  , user : Maybe Domain.User.User
  }

type alias User = Domain.User.User




type Msg
    = NoOp


init : Request -> Flags -> ( Model, Cmd Msg )
init _ _ =
    ( {firebaseUser = Nothing, user = Nothing}, Cmd.none )


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none
