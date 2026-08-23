# Tag libraries

Connected (git) and installed by `scripts/connect-install-tag-libraries.sh`. Re-run that script, or Cloud Agent `install`, to refresh.

| Directory | Remote | Kind | Install on this Linux environment |
| --- | --- | --- | --- |
| `TagListView` | https://github.com/shannonjlove/TagListView.git | iOS Swift tag cloud UI | Sources only (needs Apple SDK) |
| `sublime-Tag` | https://github.com/titoBouzout/Tag.git (`git@github.com:titoBouzout/Tag.git`) | Sublime Text HTML/XML tag plugin | Sources only |
| `tagbar` | https://github.com/shannonjlove/tagbar.git | Vim/Neovim outline sidebar | Symlinked into `~/.vim/pack/tag-libraries/start/tagbar` |
| `TagStudio` | https://github.com/shannonjlove/TagStudio.git | Photo/file tagging app | Sources only unless Python 3.14 is available |
| `tag2` | https://github.com/shannonjlove/tag2.git | Go audio metadata library | `go install` of `tag`, `sum`, and `check` into `$GOBIN` |
| `macos-tag` | https://github.com/lovecloudsjl/tag.git | macOS file-tag CLI | Clone if credentials allow; otherwise public fallback `jdberry/tag`. Build needs macOS |

`macos-tag` is not a submodule. `lovecloudsjl/tag` is not cloneable with the Cloud Agent git identity; the install script then clones [jdberry/tag](https://github.com/jdberry/tag) (same MIT-licensed CLI). Use an account that can read `lovecloudsjl/tag` to pin that remote instead.
