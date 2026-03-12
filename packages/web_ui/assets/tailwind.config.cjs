/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.elm", "./js/**/*.js", "./index.html"],
  theme: {
    extend: {}
  },
  plugins: [require("daisyui")],
  daisyui: {
    themes: ["light", "corporate", "dark"]
  }
};
