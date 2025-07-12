defmodule PromptEngineWeb do
  @moduledoc """
  The entrypoint for defining your web interface, including
  views, components, and live views.

  It also imports the router functionality for use in the host application.
  """

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        # Use the root layout you defined for all LiveViews.
        layout: {PromptEngineWeb.Layouts, :root}

      # Helper for unaliasing this module.
      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # Import LiveView helpers for things like ~.L, sigil_H, live_patch, etc.
      import Phoenix.LiveView.Helpers

      alias PromptEngineWeb.Router.Helpers, as: Routes
    end
  end
end
