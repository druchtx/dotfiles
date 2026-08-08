-- PlantUML uses Vim's traditional syntax highlighting; there is no Treesitter
-- parser to install for this filetype.
vim.filetype.add({
  extension = {
    puml = "plantuml",
    plantuml = "plantuml",
    pu = "plantuml",
    uml = "plantuml",
    iuml = "plantuml",
  },
})

return {
  {
    "aklt/plantuml-syntax",
    ft = "plantuml",
  },
}
