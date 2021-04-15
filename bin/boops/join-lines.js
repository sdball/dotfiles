/**
  {
    "api":1,
    "name":"Join lines",
    "description":"Join all the lines",
    "author":"sdball",
    "icon":"quote",
    "tags":"text"
  }
**/

function main(state) {
  state.fullText = state.fullText.replaceAll("\n", " ")
}
