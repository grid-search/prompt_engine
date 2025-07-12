defmodule PromptEngineWeb.Router do
  defmacro __using__(_opts) do
    quote do
      use Phoenix.Router

      scope "/", PromptEngineWeb do
        pipe_through [:browser]

        live "/prompt_engine", DashboardLive, :index
      end

      # This is the magic part for serving assets
      scope "/prompt_engine_static" do
        pipe_through [:browser]
        get "/:path", Phoenix.LiveView.Static, from: {:prompt_engine, "priv/static"}
      end
    end
  end
end
