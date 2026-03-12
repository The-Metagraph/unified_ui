defmodule UnifiedUi.Dsl do
  @moduledoc """
  The main UnifiedUi DSL module for defining multi-platform user interfaces.

  This module provides a declarative DSL for building user interfaces that work
  across terminal, desktop, and web platforms. Use this module in your UI components
  to access the DSL constructs.

  Following the Reactor pattern, UI entities are written directly in the module
  body without a wrapping `ui do...end` block.

  ## Quick Start

  ```elixir
  defmodule MyApp.MyScreen do
    @behaviour UnifiedUi.ElmArchitecture
    use UnifiedUi.Dsl

    vbox style: [padding: 2] do
      text "Welcome to MyApp!", style: [fg: :cyan, attrs: [:bold]]
      hbox do
        button "OK", on_click: :ok_clicked
        button "Cancel", on_click: :cancel_clicked
      end
    end

    # Optional: override default handlers
    @impl true
    def handle_click_signal(state, %{action: action}) do
      # Handle button clicks
      state
    end
  end
  ```

  ## DSL Entities

  Once you `use UnifiedUi.Dsl`, the following DSL entities are available directly in your module:

  ### Layouts

  * `vbox` - Vertical box layout (arranges children top to bottom)
  * `hbox` - Horizontal box layout (arranges children left to right)

  ### Widgets

  * `text` - Display text content
  * `button` - Clickable button
  * `label` - Label for form inputs
  * `text_input` - Single-line text input

  ### State

  * `state` - Define initial state for the component

  ## Layout Options

  Both `vbox` and `hbox` support the following options:

  * `:id` - Unique identifier for the layout (atom)
  * `:spacing` - Space between children (integer, default: 0)
  * `:padding` - Internal padding around all children (integer)
  * `:align_items` - Cross-axis alignment (:start, :center, :end, :stretch)
  * `:justify_content` - Main-axis distribution (:start, :center, :end, :space_between, :space_around)
  * `:style` - Inline style as keyword list
  * `:visible` - Whether the layout is visible (boolean, default: true)

  ## Widget Options

  ### text

  * `:content` - The text string to display (required)
  * `:id` - Unique identifier (atom)
  * `:style` - Inline style as keyword list
  * `:visible` - Whether the text is visible (boolean, default: true)

  ### button

  * `:label` - The text to display on the button (required)
  * `:id` - Unique identifier (atom)
  * `:on_click` - Signal to emit when clicked (atom, tuple, or MFA)
  * `:disabled` - Whether the button is disabled (boolean, default: false)
  * `:style` - Inline style as keyword list
  * `:visible` - Whether the button is visible (boolean, default: true)

  ### label

  * `:for` - The id of the input this label is for (required, atom)
  * `:text` - The label text to display (required)
  * `:id` - Unique identifier (atom)
  * `:style` - Inline style as keyword list
  * `:visible` - Whether the label is visible (boolean, default: true)

  ### text_input

  * `:id` - Unique identifier for the input (required, atom)
  * `:value` - Initial value for the input (string)
  * `:placeholder` - Placeholder text when empty (string)
  * `:type` - Input type (:text, :password, :email, :number, :tel, default: :text)
  * `:on_change` - Signal to emit when value changes (atom, tuple, or MFA)
  * `:on_submit` - Signal to emit on Enter key (atom, tuple, or MFA)
  * `:form_id` - Form identifier to group this input with a form (atom)
  * `:disabled` - Whether the input is disabled (boolean, default: false)
  * `:style` - Inline style as keyword list
  * `:visible` - Whether the input is visible (boolean, default: true)

  ## Style Options

  The `:style` option accepts a keyword list with the following keys:

  * `:fg` - Foreground color (atom, tuple, or string)
  * `:bg` - Background color (atom, tuple, or string)
  * `:attrs` - Text attributes (list, e.g., [:bold, :italic, :underline])
  * `:padding` - Internal spacing (integer)
  * `:margin` - External spacing (integer)
  * `:width` - Width constraint (integer, :auto, or :fill)
  * `:height` - Height constraint (integer, :auto, or :fill)
  * `:align` - Alignment of content (:left, :center, :right, :top, :bottom, :start, :end, :stretch)

  ## Signal Handlers

  Signal handlers accept the following formats:

  * An atom signal name: `on_click: :submit`
  * A tuple with payload: `on_click: {:submit, %{form_id: :login}}`
  * An MFA tuple: `on_click: {MyModule, :my_function, []}`

  ## State Management

  Define initial state using the `state` entity:

  ```elixir
  state count: 0, username: "guest", active: true

  vbox do
    text "Count: \#{state.count}"
    button "Increment", on_click: :increment
  end
  ```

  ## Elm Architecture

  Modules using `use UnifiedUi.Dsl` automatically receive generated
  `init/1`, `update/2`, and `view/1` functions following The Elm Architecture.

  To adopt the behaviour explicitly (recommended for callback type specs):

  ```elixir
  defmodule MyComponent do
    @behaviour UnifiedUi.ElmArchitecture
    use UnifiedUi.Dsl

    # UI entities here...

    @impl true
    def init(opts), do: initial_state(opts)

    @impl true
    def update(state, signal), do: handle_signal(state, signal)

    @impl true
    def view(state), do: render_ui(state)
  end
  ```

  The `init/1` function returns `{:ok, state}` with your initial state.
  The `update/2` function handles signals and returns `{:ok, new_state}`.
  The `view/1` function returns the Intermediate UI Representation (IUR).

  ## Complete Example

  ```elixir
  defmodule MyApp.LoginScreen do
    @behaviour UnifiedUi.ElmArchitecture
    use UnifiedUi.Dsl

    state username: "", password: "", error: nil

    vbox style: [padding: 2, align_items: :center] do
      text "Login", style: [fg: :cyan, attrs: [:bold]]

      label :username, "Username:"
      text_input :username, placeholder: "Enter your username"

      label :password, "Password:"
      text_input :password, type: :password, placeholder: "Enter your password"

      if state.error do
        text state.error, style: [fg: :red]
      end

      hbox style: [spacing: 2] do
        button "Login", on_click: {:login, %{}}
        button "Cancel", on_click: :cancel
      end
    end

    @impl true
    def handle_click_signal(state, %{action: :login}) do
      if String.length(state.username) > 0 and String.length(state.password) > 0 do
        {:ok, Map.put(state, :error, nil)}
      else
        {:ok, Map.put(state, :error, "Please enter username and password")}
      end
    end

    @impl true
    def handle_click_signal(state, %{action: :cancel}) do
      {:ok, %{state | username: "", password: "", error: nil}}
    end
  end
  ```

  ## Named Styles

  You can define named styles and reference them by name:

  ```elixir
  defmodule MyApp.ThemedScreen do
    @behaviour UnifiedUi.ElmArchitecture
    use UnifiedUi.Dsl

    vbox style: [padding: 2] do
      text "Header Text", style: :header
      button "Primary Action", style: :primary_button
    end
  end
  ```

  See `UnifiedUi.Dsl.Styles` for more information on defining named styles.

  ## Form Support

  Use `form_id` to group inputs and submit them together:

  ```elixir
  vbox do
    text_input :email, form_id: :login
    text_input :password, form_id: :login, type: :password
    button "Submit", on_click: {:submit_form, %{form: :login}}
  end
  ```

  The `:submit_form` signal will collect all input values from the form.

  """

  use Spark.Dsl,
    default_extensions: [extensions: [UnifiedUi.Dsl.Extension]]

  # Functions below are generated by `use Spark.Dsl`.
  @spec __using__(keyword()) :: Macro.t()
  @spec default_extensions() :: term()
  @spec default_extension_kinds() :: term()
  @spec many_extension_kinds() :: term()
  @spec single_extension_kinds() :: term()
  @spec init(term()) :: term()
  @spec handle_opts(term()) :: term()
  @spec verify(term(), term()) :: term()
  @spec explain(term(), keyword()) :: term()
  @spec handle_before_compile(Macro.Env.t()) :: Macro.t()

  @doc """
  Returns the list of standard signal types.

  These are the standard signal types used for inter-component
  communication via the JidoSignal library.

  Delegates to `UnifiedUi.Signals.standard_signals/0` as the
  single source of truth for signal definitions.

  ## Returns

  A list of atoms representing standard signal types.

  ## Example

      iex> UnifiedUi.Dsl.standard_signals()
      [:click, :change, :submit, :focus, :blur, :select]
  """
  @spec standard_signals() :: [UnifiedUi.Signals.signal_name()]
  defdelegate standard_signals, to: UnifiedUi.Signals
end
