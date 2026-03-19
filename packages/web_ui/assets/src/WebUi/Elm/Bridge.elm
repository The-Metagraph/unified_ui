module WebUi.Elm.Bridge exposing (OutboundMessage, InboundMessage, outbound, serializeOutbound)

{-| Bridge module for communication between Elm and Phoenix server.

This module provides the message types and serialization functions
for client-server communication.

-}

import Json.Encode as Encode


type alias OutboundMessage =
    { type_ : String
    , payload : Encode.Value
    , timestamp : String
    }


type alias InboundMessage =
    { type_ : String
    , data : Encode.Value
    , checksum : String
    }


outbound : String -> Encode.Value -> OutboundMessage
outbound type_ payload =
    { type_ = type_
    , payload = payload
    , timestamp = "" -- Would be filled in by ports
    }


serializeOutbound : OutboundMessage -> String
serializeOutbound message =
    Encode.object
        [ ( "type", Encode.string message.type_ )
        , ( "payload", message.payload )
        , ( "timestamp", Encode.string message.timestamp )
        ]
        |> Encode.encode 0
