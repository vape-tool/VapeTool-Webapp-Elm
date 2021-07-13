module Route exposing (Route(..), fromUrl, replaceUrl)

import Url exposing (Url)
import Url.Parser exposing (Parser, parse, (</>), int, map, oneOf, s, string, top)
import Browser.Navigation as Nav

type Route
  = Root
  | Home
  | OhmLaw

routeParser : Parser (Route -> a) a
routeParser =
  oneOf
        [ map Home top
        , map OhmLaw (s "ohm-law")
    ]

-- /topic/pottery        ==>  Just (Topic "pottery")
-- /topic/collage        ==>  Just (Topic "collage")
-- /topic/               ==>  Nothing

-- /blog/42              ==>  Just (Blog 42)
-- /blog/123             ==>  Just (Blog 123)
-- /blog/mosaic          ==>  Nothing

-- /user/tom/            ==>  Just (User "tom")
-- /user/sue/            ==>  Just (User "sue")
-- /user/bob/comment/42  ==>  Just (Comment "bob" 42)
-- /user/sam/comment/35  ==>  Just (Comment "sam" 35)
-- /user/sam/comment/    ==>  Nothing
-- /user/                ==>  Nothing


fromUrl : Url -> Maybe Route
fromUrl url =
    -- The RealWorld spec treats the fragment like a path.
    -- This makes it *literally* the path, so we can proceed
    -- with parsing as if it had been a normal path all along.
    parse routeParser url

replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)



routeToString : Route -> String
routeToString page =
    "/" ++ String.join "/" (routeToPieces page)



routeToPieces : Route -> List String
routeToPieces page =
    case page of
        Home ->
            []

        Root ->
            []

        OhmLaw ->
            [ "ohm-law" ]
