module Domain.User exposing (User, FirebaseUser)

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

type alias FirebaseUser = 
  { uid:  String
  , displayName : String
  , email : String
  , emailVerified : Bool
  , isAnonymous : Bool 
  }
