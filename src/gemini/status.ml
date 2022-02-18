type err =
  [ `TemporaryFailure of
    string * [ `None | `ServerUnavailable | `CgiError | `ProxyError | `SlowDown ]
  | `PermanentFailure of
    string * [ `None | `NotFound | `Gone | `ProxyRequestRefused | `BadRequest ]
  | `ClientCertificateRequired of
    string * [ `None | `CertificateNotAuthorised | `CertificateNotValid ] ]

type t =
  [ `Input of string * [ `Sensitive of bool ]
  | `Success
  | `Redirect of [ `Temporary | `Permanent ]
  | err ]

let of_int meta = function
  | 10 -> `Input (meta, `Sensitive true)
  | 11 -> `Input (meta, `Sensitive false)
  | 20 -> `Success
  | 30 -> `Redirect `Temporary
  | 31 -> `Redirect `Permanent
  | 40 -> `TemporaryFailure (meta, `None)
  | 41 -> `TemporaryFailure (meta, `ServerUnavailable)
  | 42 -> `TemporaryFailure (meta, `CgiError)
  | 43 -> `TemporaryFailure (meta, `ProxyError)
  | 44 -> `TemporaryFailure (meta, `SlowDown)
  | 50 -> `PermanentFailure (meta, `None)
  | 51 -> `PermanentFailure (meta, `NotFound)
  | 52 -> `PermanentFailure (meta, `Gone)
  | 53 -> `PermanentFailure (meta, `ProxyRequestRefused)
  | 59 -> `PermanentFailure (meta, `BadRequest)
  | 60 -> `ClientCertificateRequired (meta, `None)
  | 61 -> `ClientCertificateRequired (meta, `CertificateNotAuthorised)
  | 62 -> `ClientCertificateRequired (meta, `CertificateNotValid)
  | _ -> raise @@ Invalid_argument "GStatus.of_int"

let show =
  let open Printf in
  function
  | `TemporaryFailure (m, err) ->
      sprintf "Temporary failure: %s%s"
        (match err with
        | `None -> ""
        | `ServerUnavailable -> "server unavailable: "
        | `CgiError -> "CGI error: "
        | `ProxyError -> "proxy error: "
        | `SlowDown -> "slow down: ")
        m
  | `PermanentFailure (m, err) ->
      sprintf "Permanent failure: %s%s"
        (match err with
        | `None -> ""
        | `NotFound -> "not found: "
        | `Gone -> "gone: "
        | `ProxyRequestRefused -> "proxy request refused: "
        | `BadRequest -> "bad request: ")
        m
  | `ClientCertificateRequired (m, err) ->
      sprintf "Client certificate required: %s%s"
        (match err with
        | `None -> ""
        | `BadRequest -> "bad request: "
        | `CertificateNotAuthorised -> "cerficate not authorised: "
        | `CertificateNotValid -> "cerficate not valid: ")
        m
  | _ -> raise @@ Invalid_argument "GStatus.show"