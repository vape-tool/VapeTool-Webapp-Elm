module Main exposing (main)

import Browser exposing (Document)
import Url exposing (Url)
import Page exposing (Page)
import Page.Blank as Blank
import Page.Home as Home
import Page.OhmLaw as OhmLaw
import Html exposing (..)
import Browser.Navigation as Nav
import Json.Decode as Decode exposing (Value)
import Page.NotFound as NotFound
import Route exposing (Route)



type Model
    = NotFound Nav.Key
    | Redirect Nav.Key
    | Home Nav.Key
    | OhmLaw OhmLaw.Model
    
-- MODEL


init : () -> Url -> Nav.Key ->  ( Model, Cmd Msg )
init _ url key =
  changeRouteTo (Route.fromUrl url) (Redirect key)



-- VIEW




view : Model -> Document Msg
view model =
      let
        session =
            toSession model
        viewPage page toMsg config =
            let
                { title, body } =
                    Page.view session page config
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Redirect _ ->
            Page.view session Page.Other Blank.view

        NotFound _ ->
            Page.view session Page.Other NotFound.view

        Home _ ->
            Page.view session Page.Home Home.view

        OhmLaw ohmLaw ->
            viewPage Page.Other GotOhmLawMsg (OhmLaw.view ohmLaw)

            

-- UPDATE


type Msg
    = ChangedUrl Url
    | GotOhmLawMsg OhmLaw.Msg
    | ClickedLink Browser.UrlRequest

toSession : Model -> Nav.Key
toSession page =
    case page of
        Redirect session ->
            session

        NotFound session ->
            session

        Home session ->
            session

        OhmLaw ohmLaw ->
            OhmLaw.toSession ohmLaw


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let session = toSession model
    in case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Root ->
            ( model, Route.replaceUrl session Route.Home )

        Just Route.OhmLaw ->
            OhmLaw.init session
                |> updateWith OhmLaw GotOhmLawMsg model
        Just Route.Home -> 
            ( model, Route.replaceUrl session Route.Home )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    case url.fragment of
                        Nothing ->
                            -- If we got a link that didn't include a fragment,
                            -- it's from one of those (href "") attributes that
                            -- we have to include to make the RealWorld CSS work.
                            --
                            -- In an application doing path routing instead of
                            -- fragment-based routing, this entire
                            -- `case url.fragment of` expression this comment
                            -- is inside would be unnecessary.
                            ( model, Cmd.none )

                        Just _ ->
                            ( model
                            , Nav.pushUrl (toSession model) (Url.toString url)
                            )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model
        ( GotOhmLawMsg subMsg, OhmLaw ohmLaw ) ->
          OhmLaw.update subMsg ohmLaw
            |> updateWith OhmLaw GotOhmLawMsg model
        ( _, _ ) ->
          -- Disregard messages that arrived for the wrong page.
          (model, Cmd.none)


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model = Sub.none



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
