port module Pages.SignIn exposing (Model, Msg(..), page)

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



-- import Firebase exposing (Msg(..))


port signInWithFacebook : () -> Cmd msg


port signInWithGoogle : () -> Cmd msg


port signInInfo : (Json.Encode.Value -> msg) -> Sub msg


port signOut : () -> Cmd msg


port signInError : (Json.Encode.Value -> msg) -> Sub msg


port receiveMessages : (Json.Encode.Value -> msg) -> Sub msg


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
    ( emptyModel, Cmd.none )


emptyModel : Model
emptyModel =
    { userData = Maybe.Nothing, error = emptyError, inputContent = "", messages = [] }


emptyError : ErrorData
emptyError =
    { code = Maybe.Nothing, credential = Maybe.Nothing, message = Maybe.Nothing }



-- UPDATE


type Msg
    = ClickedLoginWithGoogle
    | ClickedLoginWithFacebook
    | LoggedIn
    | LogOut
    | LoggedInData (Result Json.Decode.Error UserData)
    | LoggedInError (Result Json.Decode.Error ErrorData)
    | MessagesReceived (Result Json.Decode.Error (List String))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLoginWithGoogle ->
            ( model, signInWithGoogle () )

        ClickedLoginWithFacebook ->
            ( model, signInWithFacebook () )

        LoggedIn ->
            ( emptyModel, Cmd.none )

        LogOut ->
            ( { model | userData = Maybe.Nothing, error = emptyError }, signOut () )

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

        MessagesReceived result ->
            case result of
                Ok value ->
                    ( { model | messages = value }, Cmd.none )

                Err error ->
                    ( { model | error = messageToError <| Json.Decode.errorToString error }, Cmd.none )


view : Model -> View Msg
view model =
    { title = "Sign In"
    , body =
        UI.layout
            [ button [ Events.onClick ClickedLoginWithFacebook ] [ text "Login with Facebook" ]
            , h2 [] [ text <| errorPrinter model.error ]
            , case model.userData of
                Just _ ->
                    button [ Events.onClick LogOut ] [ text "Logout from Google" ]

                Maybe.Nothing ->
                    button [ Events.onClick ClickedLoginWithGoogle ] [ text "Login with Google" ]
            ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ signInInfo (Json.Decode.decodeValue userDataDecoder >> LoggedInData)
        , signInError (Json.Decode.decodeValue logInErrorDecoder >> LoggedInError)
        , receiveMessages (Json.Decode.decodeValue messageListDecoder >> MessagesReceived)
        ]


userDataDecoder : Json.Decode.Decoder UserData
userDataDecoder =
    Json.Decode.succeed UserData
        |> Json.Decode.Pipeline.required "token" Json.Decode.string
        |> Json.Decode.Pipeline.required "email" Json.Decode.string
        |> Json.Decode.Pipeline.required "uid" Json.Decode.string


logInErrorDecoder : Json.Decode.Decoder ErrorData
logInErrorDecoder =
    Json.Decode.succeed ErrorData
        |> Json.Decode.Pipeline.required "code" (Json.Decode.nullable Json.Decode.string)
        |> Json.Decode.Pipeline.required "message" (Json.Decode.nullable Json.Decode.string)
        |> Json.Decode.Pipeline.required "credential" (Json.Decode.nullable Json.Decode.string)


messagesDecoder =
    Json.Decode.decodeString (Json.Decode.list Json.Decode.string)


messageListDecoder : Json.Decode.Decoder (List String)
messageListDecoder =
    Json.Decode.succeed identity
        |> Json.Decode.Pipeline.required "messages" (Json.Decode.list Json.Decode.string)


messageToError : String -> ErrorData
messageToError message =
    { code = Maybe.Nothing, credential = Maybe.Nothing, message = Just message }


errorPrinter : ErrorData -> String
errorPrinter errorData =
    Maybe.withDefault "" errorData.code ++ " " ++ Maybe.withDefault "" errorData.credential ++ " " ++ Maybe.withDefault "" errorData.message
