module Auth exposing
    ( 
      User,
      beforeProtectedInit
    )

{-|

@docs User
@docs beforeProtectedInit

-}

import ElmSpa.Page as ElmSpa
import Gen.Route exposing (Route)
import Request exposing (Request)
import Domain.User
import Shared


type alias User = Domain.User.User

{-| This function will run before any `protected` pages.

Here, you can provide logic on where to redirect if a user is not signed in. Here's an example:

    case shared.user of
        Just user ->
            ElmSpa.Provide user

        Nothing ->
            ElmSpa.RedirectTo Gen.Route.SignIn

-}
beforeProtectedInit : Shared.Model -> Request -> ElmSpa.Protected Domain.User.User Route
beforeProtectedInit shared req =
  case shared.user of 
      Just user ->
        ElmSpa.Provide user
      Nothing ->
        case shared.firebaseUser of
          Just firebaseUser ->
            ElmSpa.RedirectTo Gen.Route.FinishAccountCreation
          Nothing -> 
            ElmSpa.RedirectTo Gen.Route.SignIn
