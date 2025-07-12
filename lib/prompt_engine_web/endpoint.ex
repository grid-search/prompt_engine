defmodule PromptEngineWeb.Endpoint do
  @moduledoc """
  A dummy endpoint.

  This endpoint is used for asset compilation and configuration but does not
  run as a server in the host application.
  """
  use Phoenix.Endpoint, otp_app: :prompt_engine

  # Session options.
  @session_options [
    store: :cookie,
    # A unique key for your library's session
    key: "_prompt_engine_key",
    signing_salt: "some_unique_salt",
    same_site: "Lax"
  ]

  # The socket handler for LiveView connections.
  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # This endpoint doesn't actually start a server, so most of this
  # configuration is for structure and compilation. Host app handles serving.
end
