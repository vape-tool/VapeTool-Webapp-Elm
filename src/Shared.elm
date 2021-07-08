module Shared exposing
    ( Flags
    , Model
    , Msg
    , init
    , subscriptions
    , update
    , FirebaseUser
    )

import Json.Decode as Json
import Request exposing (Request)
import Domain.User


type alias Flags =
    Json.Value


type alias Model =
  { firebaseUser : Maybe FirebaseUser 
  , user : Maybe Domain.User.User
  }

type alias FirebaseUser = 
  { uid:  String
  , displayName : String
  , email : String
  , emailVerified : Bool
  , isAnonymous : Bool 
  }



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
