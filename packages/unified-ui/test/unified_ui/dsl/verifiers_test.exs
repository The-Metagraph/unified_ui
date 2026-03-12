defmodule UnifiedUi.Dsl.VerifiersTest do
  @moduledoc """
  Tests for the UnifiedUi DSL verifiers.

  These tests verify that:
  - UniqueIdVerifier catches duplicate IDs
  - LayoutStructureVerifier validates label references
  - SignalHandlerVerifier validates signal handler formats
  - StyleReferenceVerifier validates style attributes
  - StateReferenceVerifier validates state keys
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.Verifiers.{
    UniqueIdVerifier,
    LayoutStructureVerifier,
    SignalHandlerVerifier,
    RequiredAttributeVerifier,
    StyleReferenceVerifier,
    StateReferenceVerifier
  }

  alias UnifiedIUR.{Widgets, Layouts}
  alias UnifiedUi.Dsl.State

  # Helper to create a mock DSL state that matches Spark's structure
  # Spark.Dsl.Transformer.get_entities(dsl_state, path) expects
  # dsl_state[path][:entities] to be the list of entities
  # Note: Spark stores entities directly at dsl_state[path], not dsl_state[:sections][path]
  defp create_dsl_state(widgets_entities), do: create_dsl_state(widgets_entities, [])

  defp create_dsl_state(widgets_entities, layouts_entities) do
    %{
      persist: %{module: TestModule},
      widgets: %{entities: widgets_entities},
      layouts: %{entities: layouts_entities}
    }
  end

  describe "UniqueIdVerifier" do
    test "passes when all IDs are unique" do
      # Create mock entities with map structure (not structs)
      entities = [
        %{
          __struct__: Widgets.Button,
          id: :btn1,
          label: "Button 1",
          __meta__: [entity: "button 1"]
        },
        %{__struct__: Widgets.Text, id: :text1, content: "Text 1", __meta__: [entity: "text 1"]},
        %{__struct__: Widgets.TextInput, id: :input1, __meta__: [entity: "text_input"]},
        %{
          __struct__: Widgets.Label,
          for: :input1,
          text: "Label 1",
          id: :label1,
          __meta__: [entity: "label 1"]
        }
      ]

      dsl_state = create_dsl_state(entities)

      assert UniqueIdVerifier.verify(dsl_state) == :ok
    end

    test "passes when entities have no IDs" do
      entities = [
        %{__struct__: Widgets.Button, label: "Button 1", id: nil},
        %{__struct__: Widgets.Text, content: "Text 1", id: nil}
      ]

      dsl_state = create_dsl_state(entities)

      assert UniqueIdVerifier.verify(dsl_state) == :ok
    end

    test "detects duplicate widget IDs" do
      entities = [
        %{
          __struct__: Widgets.Button,
          id: :duplicate,
          label: "Button 1",
          __meta__: [entity: "button 1"]
        },
        %{
          __struct__: Widgets.Text,
          id: :duplicate,
          content: "Text 1",
          __meta__: [entity: "text 1"]
        }
      ]

      dsl_state = create_dsl_state(entities)

      assert_raise Spark.Error.DslError, ~r/Duplicate ID found.*:duplicate/, fn ->
        UniqueIdVerifier.verify(dsl_state)
      end
    end

    test "detects duplicate IDs across multiple entities" do
      entities = [
        %{__struct__: Widgets.Button, id: :dup, label: "B1", __meta__: [entity: "b1"]},
        %{__struct__: Widgets.Text, id: :dup, content: "T1", __meta__: [entity: "t1"]},
        %{__struct__: Widgets.TextInput, id: :dup2, __meta__: [entity: "i1"]},
        %{__struct__: Widgets.Label, for: :dup2, text: "L", id: :dup2, __meta__: [entity: "l1"]}
      ]

      dsl_state = create_dsl_state(entities)

      # Should catch one of the duplicates
      assert_raise Spark.Error.DslError, ~r/Duplicate ID found/, fn ->
        UniqueIdVerifier.verify(dsl_state)
      end
    end
  end

  describe "LayoutStructureVerifier" do
    test "passes when label for references valid input ID" do
      entities = [
        %{__struct__: Widgets.TextInput, id: :email, __meta__: [entity: "email_input"]},
        %{
          __struct__: Widgets.Label,
          for: :email,
          text: "Email:",
          __meta__: [entity: "email_label"]
        }
      ]

      dsl_state = create_dsl_state(entities)

      assert LayoutStructureVerifier.verify(dsl_state) == :ok
    end

    test "detects label for referencing non-existent input" do
      entities = [
        %{__struct__: Widgets.TextInput, id: :password, __meta__: [entity: "password_input"]},
        %{
          __struct__: Widgets.Label,
          for: :nonexistent,
          text: "Email:",
          __meta__: [entity: "email_label"]
        }
      ]

      dsl_state = create_dsl_state(entities)

      assert_raise Spark.Error.DslError,
                   ~r/Invalid label reference.*references :nonexistent/s,
                   fn ->
                     LayoutStructureVerifier.verify(dsl_state)
                   end
    end

    test "passes with multiple labels and inputs" do
      entities = [
        %{__struct__: Widgets.TextInput, id: :email, __meta__: [entity: "email_input"]},
        %{
          __struct__: Widgets.Label,
          for: :email,
          text: "Email:",
          __meta__: [entity: "email_label"]
        },
        %{__struct__: Widgets.TextInput, id: :password, __meta__: [entity: "password_input"]},
        %{
          __struct__: Widgets.Label,
          for: :password,
          text: "Password:",
          __meta__: [entity: "password_label"]
        },
        %{__struct__: Widgets.TextInput, id: :name, __meta__: [entity: "name_input"]},
        %{__struct__: Widgets.Label, for: :name, text: "Name:", __meta__: [entity: "name_label"]}
      ]

      dsl_state = create_dsl_state(entities)

      assert LayoutStructureVerifier.verify(dsl_state) == :ok
    end

    test "passes with no labels" do
      entities = [
        %{__struct__: Widgets.TextInput, id: :email, __meta__: [entity: "email_input"]},
        %{__struct__: Widgets.TextInput, id: :password, __meta__: [entity: "password_input"]}
      ]

      dsl_state = create_dsl_state(entities)

      assert LayoutStructureVerifier.verify(dsl_state) == :ok
    end
  end

  describe "SignalHandlerVerifier" do
    test "passes with atom signal handlers" do
      entities = [
        %{
          __struct__: Widgets.Button,
          on_click: :my_signal,
          label: "Click",
          __meta__: [entity: "button"]
        },
        %{
          __struct__: Widgets.TextInput,
          id: :input1,
          on_change: :value_changed,
          __meta__: [entity: "input"]
        },
        %{
          __struct__: Widgets.TextInput,
          id: :input2,
          on_submit: :form_submit,
          __meta__: [entity: "input2"]
        }
      ]

      dsl_state = create_dsl_state(entities)

      assert SignalHandlerVerifier.verify(dsl_state) == :ok
    end

    test "passes with tuple signal handlers" do
      entities = [
        %{
          __struct__: Widgets.Button,
          on_click: {:my_signal, %{data: "value"}},
          label: "Click",
          __meta__: [entity: "button"]
        },
        %{
          __struct__: Widgets.TextInput,
          id: :input1,
          on_change: {:value_changed, %{field: :input1}},
          __meta__: [entity: "input"]
        }
      ]

      dsl_state = create_dsl_state(entities)

      assert SignalHandlerVerifier.verify(dsl_state) == :ok
    end

    test "passes with MFA signal handlers for kernel modules" do
      entities = [
        %{
          __struct__: Widgets.Button,
          on_click: {Kernel, :is_atom, [true]},
          label: "Click",
          __meta__: [entity: "button"]
        },
        %{
          __struct__: Widgets.TextInput,
          id: :input1,
          on_change: {Enum, :map, [[]]},
          __meta__: [entity: "input"]
        }
      ]

      dsl_state = create_dsl_state(entities)

      assert SignalHandlerVerifier.verify(dsl_state) == :ok
    end

    test "detects invalid signal handler format (string)" do
      entities = [
        %{
          __struct__: Widgets.Button,
          on_click: "invalid_string_handler",
          label: "Click",
          __meta__: [entity: "button"]
        }
      ]

      dsl_state = create_dsl_state(entities)

      assert_raise Spark.Error.DslError, ~r/Invalid signal handler format/, fn ->
        SignalHandlerVerifier.verify(dsl_state)
      end
    end

    test "detects invalid signal handler format (list)" do
      entities = [
        %{
          __struct__: Widgets.Button,
          on_click: [:invalid, :list],
          label: "Click",
          __meta__: [entity: "button"]
        }
      ]

      dsl_state = create_dsl_state(entities)

      assert_raise Spark.Error.DslError, ~r/Invalid signal handler format/, fn ->
        SignalHandlerVerifier.verify(dsl_state)
      end
    end

    test "passes with no signal handlers" do
      entities = [
        %{__struct__: Widgets.Button, label: "Click", __meta__: [entity: "button"]},
        %{__struct__: Widgets.TextInput, id: :input1, __meta__: [entity: "input"]}
      ]

      dsl_state = create_dsl_state(entities)

      assert SignalHandlerVerifier.verify(dsl_state) == :ok
    end
  end

  describe "StyleReferenceVerifier" do
    test "passes with valid style attributes" do
      entities = [
        %{
          __struct__: Widgets.Button,
          label: "Button",
          style: [fg: :blue, bg: :white, attrs: [:bold]],
          __meta__: [entity: "button"]
        },
        %{
          __struct__: Widgets.Text,
          content: "Text",
          style: [fg: :red, padding: 2],
          __meta__: [entity: "text"]
        },
        %{
          __struct__: Widgets.TextInput,
          id: :input,
          style: [margin: 1],
          __meta__: [entity: "input"]
        }
      ]

      dsl_state = create_dsl_state(entities)

      assert StyleReferenceVerifier.verify(dsl_state) == :ok
    end

    test "passes with empty style" do
      entities = [
        %{__struct__: Widgets.Button, label: "Button", style: [], __meta__: [entity: "button"]}
      ]

      dsl_state = create_dsl_state(entities)

      assert StyleReferenceVerifier.verify(dsl_state) == :ok
    end

    test "passes with no style" do
      entities = [
        %{__struct__: Widgets.Button, label: "Button", style: nil, __meta__: [entity: "button"]}
      ]

      dsl_state = create_dsl_state(entities)

      assert StyleReferenceVerifier.verify(dsl_state) == :ok
    end

    test "passes with valid text attributes" do
      entities = [
        %{
          __struct__: Widgets.Text,
          content: "Bold",
          style: [attrs: [:bold]],
          __meta__: [entity: "text"]
        },
        %{
          __struct__: Widgets.Text,
          content: "Italic",
          style: [attrs: [:italic]],
          __meta__: [entity: "text2"]
        },
        %{
          __struct__: Widgets.Text,
          content: "Underline",
          style: [attrs: [:underline]],
          __meta__: [entity: "text3"]
        },
        %{
          __struct__: Widgets.Text,
          content: "Multiple",
          style: [attrs: [:bold, :underline, :italic]],
          __meta__: [entity: "text4"]
        },
        %{
          __struct__: Widgets.Text,
          content: "Dim",
          style: [attrs: [:dim]],
          __meta__: [entity: "text5"]
        }
      ]

      dsl_state = create_dsl_state(entities)

      assert StyleReferenceVerifier.verify(dsl_state) == :ok
    end

    test "detects invalid text attributes" do
      entities = [
        %{
          __struct__: Widgets.Text,
          content: "Invalid",
          style: [attrs: [:not_a_real_attr]],
          __meta__: [entity: "text"]
        }
      ]

      dsl_state = create_dsl_state(entities)

      assert_raise ArgumentError, ~r/Invalid text attributes/, fn ->
        StyleReferenceVerifier.verify(dsl_state)
      end
    end

    test "passes with all valid style attributes" do
      entities = [
        %{
          __struct__: Widgets.Button,
          label: "Test",
          style: [
            fg: :blue,
            bg: :white,
            attrs: [:bold],
            padding: 1,
            margin: 2,
            width: :auto,
            height: :fill,
            align: :center,
            spacing: 1,
            font_family: "JetBrains Mono",
            font_size: 14,
            font_weight: 700,
            border: [width: 1, style: :solid, color: :blue],
            border_width: 2,
            border_color: "#ff00aa",
            border_style: :dashed
          ],
          __meta__: [entity: "button"]
        }
      ]

      dsl_state = create_dsl_state(entities)

      assert StyleReferenceVerifier.verify(dsl_state) == :ok
    end
  end

  describe "RequiredAttributeVerifier" do
    test "passes when required attributes are present" do
      entities = [
        %{__struct__: Widgets.Button, label: "Click", __meta__: [entity: "button"]},
        %{__struct__: Widgets.Text, content: "Hello", __meta__: [entity: "text"]},
        %{__struct__: Widgets.Label, for: :email, text: "Email", __meta__: [entity: "label"]},
        %{__struct__: Widgets.TextInput, id: :email, __meta__: [entity: "text_input"]}
      ]

      dsl_state = create_dsl_state(entities)

      assert RequiredAttributeVerifier.verify(dsl_state) == :ok
    end

    test "detects missing required attributes" do
      entities = [
        %{__struct__: Widgets.Button, label: nil, __meta__: [entity: "button"]}
      ]

      dsl_state = create_dsl_state(entities)

      assert_raise Spark.Error.DslError, ~r/Missing required attribute.*:label/s, fn ->
        RequiredAttributeVerifier.verify(dsl_state)
      end
    end

    test "detects invalid required attribute types" do
      entities = [
        %{__struct__: Widgets.TextInput, id: "email", __meta__: [entity: "text_input"]}
      ]

      dsl_state = create_dsl_state(entities)

      assert_raise Spark.Error.DslError, ~r/Invalid type for required attribute.*:id/s, fn ->
        RequiredAttributeVerifier.verify(dsl_state)
      end
    end
  end

  describe "StateReferenceVerifier" do
    test "passes with valid atom state keys" do
      # State entity is nested under [:ui, :state]
      dsl_state = %{
        persist: %{module: TestModule},
        ui: %{state: %{entities: [%State{attrs: [count: 0, name: "default", enabled: true]}]}},
        widgets: %{entities: []},
        layouts: %{entities: []}
      }

      assert StateReferenceVerifier.verify(dsl_state) == :ok
    end

    test "passes with no state defined" do
      dsl_state = %{
        persist: %{module: TestModule},
        ui: %{state: %{entities: []}},
        widgets: %{entities: []},
        layouts: %{entities: []}
      }

      assert StateReferenceVerifier.verify(dsl_state) == :ok
    end

    test "passes with empty state" do
      dsl_state = %{
        persist: %{module: TestModule},
        ui: %{state: %{entities: [%State{attrs: []}]}},
        widgets: %{entities: []},
        layouts: %{entities: []}
      }

      assert StateReferenceVerifier.verify(dsl_state) == :ok
    end

    test "passes when state references exist and keys are defined" do
      dsl_state = %{
        persist: %{module: TestModule},
        ui: %{state: %{entities: [%State{attrs: [username: "guest"]}]}},
        widgets: %{
          entities: [
            %{
              __struct__: Widgets.Text,
              content: {:state, :username},
              __meta__: [entity: "username_text"]
            }
          ]
        },
        layouts: %{entities: []}
      }

      assert StateReferenceVerifier.verify(dsl_state) == :ok
    end

    test "fails when referenced state key is undefined" do
      dsl_state = %{
        persist: %{module: TestModule},
        ui: %{state: %{entities: [%State{attrs: [username: "guest"]}]}},
        widgets: %{
          entities: [
            %{
              __struct__: Widgets.Text,
              content: {:state, :missing_key},
              __meta__: [entity: "bad_state_ref"]
            }
          ]
        },
        layouts: %{entities: []}
      }

      assert_raise Spark.Error.DslError, ~r/Undefined state keys referenced/, fn ->
        StateReferenceVerifier.verify(dsl_state)
      end
    end

    test "fails when state reference key is not an atom" do
      dsl_state = %{
        persist: %{module: TestModule},
        ui: %{state: %{entities: [%State{attrs: [username: "guest"]}]}},
        widgets: %{
          entities: [
            %{
              __struct__: Widgets.Text,
              content: {:state, "username"},
              __meta__: [entity: "invalid_state_ref"]
            }
          ]
        },
        layouts: %{entities: []}
      }

      assert_raise Spark.Error.DslError, ~r/Invalid state references found/, fn ->
        StateReferenceVerifier.verify(dsl_state)
      end
    end
  end

  describe "integration tests" do
    test "complex UI with all features passes verification" do
      widgets = [
        %{
          __struct__: Widgets.Button,
          id: :login_btn,
          on_click: :login,
          label: "Login",
          __meta__: [entity: "login_button"]
        },
        %{
          __struct__: Widgets.Button,
          id: :cancel_btn,
          on_click: {:cancel, %{reason: :user_cancellation}},
          label: "Cancel",
          __meta__: [entity: "cancel_button"]
        },
        %{
          __struct__: Widgets.Text,
          id: :title,
          content: "Welcome!",
          style: [fg: :green, attrs: [:bold]],
          __meta__: [entity: "title_text"]
        },
        %{
          __struct__: Widgets.TextInput,
          id: :email_input,
          placeholder: "user@example.com",
          __meta__: [entity: "email_input"]
        },
        %{
          __struct__: Widgets.TextInput,
          id: :password_input,
          type: :password,
          __meta__: [entity: "password_input"]
        },
        %{
          __struct__: Widgets.Label,
          for: :email_input,
          text: "Email:",
          __meta__: [entity: "email_label"]
        },
        %{
          __struct__: Widgets.Label,
          for: :password_input,
          text: "Password:",
          __meta__: [entity: "password_label"]
        }
      ]

      layouts = [
        %{__struct__: Layouts.VBox, id: :main, spacing: 1, __meta__: [entity: "main_vbox"]},
        %{__struct__: Layouts.HBox, id: :header, __meta__: [entity: "header_hbox"]},
        %{__struct__: Layouts.VBox, id: :content, padding: 2, __meta__: [entity: "content_vbox"]},
        %{__struct__: Layouts.HBox, id: :footer, spacing: 2, __meta__: [entity: "footer_hbox"]}
      ]

      dsl_state = %{
        persist: %{module: TestModule},
        ui: %{
          state: %{
            entities: [%State{attrs: [count: 0, email: "", password: "", logged_in: false]}]
          }
        },
        widgets: %{entities: widgets},
        layouts: %{entities: layouts}
      }

      assert UniqueIdVerifier.verify(dsl_state) == :ok
      assert LayoutStructureVerifier.verify(dsl_state) == :ok
      assert SignalHandlerVerifier.verify(dsl_state) == :ok
      assert StyleReferenceVerifier.verify(dsl_state) == :ok
      assert StateReferenceVerifier.verify(dsl_state) == :ok
    end
  end
end
