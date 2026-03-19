module WebUi.Elm.Diagnostics exposing (DiagnosticLevel(..), Diagnostic, validateHydration, validateOutbound)

{-| Diagnostics module for Elm runtime validation.

This module provides validation functions for detecting
frontend runtime issues.

-}

import Json.Encode as Encode


type DiagnosticLevel
    = Info
    | Warning
    | Error


type alias Diagnostic =
    { level : DiagnosticLevel
    , type_ : String
    , message : String
    }



-- VALIDATION


validateHydration : Encode.Value -> Result Diagnostic Encode.Value
validateHydration value =
    -- Check if hydration value has required structure
    case encodeToString value of
        Just str ->
            if String.contains "schema" str && String.contains "version" str && String.contains "checksum" str then
                Ok value

            else
                Err
                    { level = Error
                    , type_ = "missing_keys"
                    , message = "Hydration state missing required keys"
                    }

        Nothing ->
            Err
                { level = Error
                , type_ = "invalid_json"
                , message = "Hydration state is not valid JSON"
                }


validateOutbound : String -> Encode.Value -> Result Diagnostic ()
validateOutbound type_ payload =
    if String.isEmpty type_ then
        Err
            { level = Error
            , type_ = "invalid_type"
            , message = "Outbound message type cannot be empty"
            }

    else if payload == Encode.null then
        Err
            { level = Warning
            , type_ = "null_payload"
            , message = "Outbound message has null payload"
            }

    else
        Ok ()



-- HELPERS


encodeToString : Encode.Value -> Maybe String
encodeToString value =
    Just (Encode.encode 0 value)
