// config/tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}', // This line tells Tailwind where to find your HTML/ERB files
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}