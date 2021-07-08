module Domain.User exposing (User)

type alias User = 
  { uid : String
  , displayName : String
  , email : String
  , paypalSubscriptionId : String
  , permission : Int
  , stripeId : String
  , subscription : Int
  , display_name : String
  }

