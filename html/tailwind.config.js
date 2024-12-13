/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./*.html"],
  theme: {
    extend: {
      fontFamily: {
        western: ['Rye', 'cursive'],
      },
      colors: {
        'rdr-brown': '#3C2A21',
        'rdr-tan': '#D2B48C',
        'rdr-red': '#8B0000',
      },
    },
  },
  plugins: [],
};
