port module Pages.SignIn exposing (Model, Msg, page)


import Gen.Params.SignIn exposing (Params)
import Html exposing (Html, button, div, h1, h2, h3, img, input, p, text)
import Html.Events as Events
import Json.Decode
import Json.Decode.Pipeline
import Json.Encode
import Page
import Request
import Shared
import UI
import View exposing (View)


port signInGoogle : () -> Cmd msg


port signInFacebook : () -> Cmd msg


type alias ErrorData =
    { code : Maybe String, message : Maybe String, credential : Maybe String }


type alias UserData =
    { token : String, email : String, uid : String }


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page _ _ =
    Page.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { userData : Maybe UserData, error : ErrorData, inputContent : String, messages : List String }


init : ( Model, Cmd Msg )
init =
    ( { userData = Maybe.Nothing, error = emptyError, inputContent = "", messages = [] }, Cmd.none )


emptyError : ErrorData
emptyError =
    { code = Maybe.Nothing, credential = Maybe.Nothing, message = Maybe.Nothing }



-- UPDATE


type Msg
    = ClickedLoginWithGoogle
    | ClickedLoginWithFacebook
    | LoggedInData (Result Json.Decode.Error UserData)
    | LoggedInError (Result Json.Decode.Error ErrorData)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLoginWithGoogle ->
            ( model, signInGoogle () )

        ClickedLoginWithFacebook ->
            ( model, signInFacebook () )

        LoggedInData result ->
            case result of
                Ok value ->
                    ( { model | userData = Just value }, Cmd.none )

                Err error ->
                    ( { model | error = messageToError <| Json.Decode.errorToString error }, Cmd.none )

        LoggedInError result ->
            case result of
                Ok value ->
                    ( { model | error = value }, Cmd.none )

                Err error ->
                    ( { model | error = messageToError <| Json.Decode.errorToString error }, Cmd.none )


view : Model -> View Msg
view model =
    { title = "Sign In"
    , body = UI.layout
            [ button [ Events.onClick ClickedLoginWithGoogle ] [ text "Login with Google" ]
            , button [ Events.onClick ClickedLoginWithFacebook ] [ text "Login with Facebook" ]
            , h2 [] [ text <| errorPrinter model.error ]
            ]
            }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


messageToError : String -> ErrorData
messageToError message =
    { code = Maybe.Nothing, credential = Maybe.Nothing, message = Just message }


errorPrinter : ErrorData -> String
errorPrinter errorData =
    Maybe.withDefault "" errorData.code ++ " " ++ Maybe.withDefault "" errorData.credential ++ " " ++ Maybe.withDefault "" errorData.message
