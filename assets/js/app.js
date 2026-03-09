const root = document.getElementById("elm-root");

if (root && window.Elm && window.Elm.Main) {
  window.Elm.Main.init({ node: root });
}
