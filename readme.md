## How to contribute ?

The site is build with [Hugo](https://gohugo.io/) and the content is in [config.toml](config.toml).

Make a PR on the branch `hugo` not on branch `master`.

### Some commands

Run the site locally:

```shell
hugo server
```

Build the site locally:

```shell
hugo
```

### Continuous Delivery

When a PR (on the branch `hugo`) is merge, Travis build and deploy automatically the site.
