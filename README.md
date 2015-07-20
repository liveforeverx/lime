Lime
====

Lime is a static site generator written in [Elixir](http://elixir-lang.org/). Lime takes a directory with content and templates and renders them into a full HTML website. Lime is heavily inspired by [Hugo](https://github.com/spf13/hugo).

Lime relies on Markdown files with [TOML](https://github.com/toml-lang/toml) front matter for meta data. Implementation use advantages of multi cores of your computer for increasing of spead.

Thanks [obelisk](https://github.com/BennyHallett/obelisk) for `mix perf`, which have driven the initial developent and usage of all cores. Lime and obelisk are very different, they have very different design. Front matter in `lime`, default is TOML instead of YAML, as in my opinion it better suites for it. I do not want to force users `mix` for creating a blog, as I hope, that `lime` use not only Elixir developers(may be erlang too? Or somebody else?). `partials` allows clean composibility of your site or blog, as it possible to use/modify layouts, which isn't possible to do with a single `layout` for all. `partials` are great, because they allow to customize only the part, that you want to change.

## Goals

* **Fast**. Use all of your CPU for building a static website.

* **Simple, Extensible**. Should be simple and intuitive, and doesn't restrict you to change everithing, what you want.

* **Simple executable**. You need install erlang 18, and download precompiled escript, which includes all dependencies(including elixir themself), and default theme in the same executable.

Please note: project is 2 day old (Stand: 20.07.2015) and in alpha state, that interface (at least for indexes) will be changed to export less elixir structures.

## Build a project

```
git clone git@github.com:liveforeverx/lime-theme-pixyll.git priv/template/themes/pixyll
mix escript.build
```

## Creating a new lime project

    $ lime init /path/to/my/blog

Build a project

    $ lime build

Start local server

    $ lime server

## Creating a page or post

```
+++
title = "Something"
description = "A bunch of lorem ipsums"
date = "2015-07-20T18:14:14Z"
tags = []
+++

Writing a blog post here. The first paragraph will bу summary on a index/pagination pages.
```

`lime` command for creating it will be added soon.

## TODOs

* Small different fixes
* Documentation
* Tests
* Adding downloadable escript
* Better design for tags (and other indexes)
* Possibility to add custom ordering(popular/latest and so on) possibility for paging
* customizing summary rules
* RSS
* Sitemap
* Indexes should get language support
* Menus
* Watch and Live Reload
* Support old style urls

## Known performance issue

When building not as `mix` tasks, it takes much longe with escript to compile a layouts.

With `mix perf`
```
compile layouts: 429 ms
```

As escript
```
compile layouts: 2844 ms
```

## Performance benchmark

Use `mix perf`

Perfomance on my MacBook Air:

For `obelisk`:

```
obelisk % mix perf
2015-07-20-17:48:42
2015-07-20-17:53:39
```

For `lime`

```
lime % mix perf
copy assets: 112 ms
compile layouts: 535 ms
compile posts: 61502 ms
compile pages: 2 ms
compile pagination: 9396 ms
compile indexes: 6 ms
```

It is 4 times performanter as `obelisk`, because of utilization of all CPUs for building posts. Should be changed on obelisk side too.

The parallization is done with [sbroker](https://github.com/fishcakez/sbroker) now.



