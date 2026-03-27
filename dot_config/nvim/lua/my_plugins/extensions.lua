vim.filetype.add({
  extension = {
    gleam = "gleam",
    http = "http",
    zsh = "sh",
    sh = "sh",   -- force sh-files with zsh-shebang to still get sh as filetype
    d2 = "d2",
  },
  filename = {
    [".zshrc"] = "sh",
    [".zshenv"] = "sh",
    [".http"] = "http",
  },
})
