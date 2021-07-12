module Main exposing (main)

import Browser exposing (Document)
import Url exposing (Url)
import Page exposing (Page)
import Page.Blank as Blank
import Page.Home as Home
import Browser.Navigation as Nav
import Json.Decode as Decode exposing (Value)
import Page.NotFound as NotFound



type Model
    = NotFound
    | Home
    
-- MODEL


init : () -> Url -> Nav.Key ->  ( Model, Cmd Msg )
init flags url key  = ( Home, Cmd.none )



-- VIEW




view : Model -> Document Msg
view model =
    case model of
        -- Redirect _ ->
        --     Page.view viewer Page.Other Blank.view

        NotFound ->
            Page.view Page.Other NotFound.view

        Home ->
            Page.view Page.Home Home.view

            

-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model = ( model, Cmd.none )

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        NotFound ->
            Sub.none
        Home ->
            Sub.none



-- MAIN


main : Program () Model Msg
main =
  Browser.application
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
