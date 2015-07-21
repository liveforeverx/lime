Lime
====

Lime is a static site generator written in [Elixir](http://elixir-lang.org/). Lime takes a directory with content and templates and renders them into a full HTML website. Lime is heavily inspired by [Hugo](https://github.com/spf13/hugo). I like Hugo, but some small unchangable behaviours have constrained me to write my own, to experiment with my own.

Lime relies on Markdown files with [TOML](https://github.com/toml-lang/toml) front matter for meta data. Implementation use advantages of multi cores of your computer for increasing of spead.

Thanks [obelisk](https://github.com/BennyHallett/obelisk) for `mix perf`, which have driven the initial developent and usage of all cores. Lime and obelisk are very different, they have very different design. Front matter in `lime`, default is TOML instead of YAML, as in my opinion it better suites for it. I do not want to force users `mix` for creating a blog, as I hope, that `lime` use not only Elixir developers(may be erlang too? Or somebody else?). `partials` allows clean composibility of your site or blog, as it possible to use/modify layouts, which isn't possible to do with a single `layout` for all.

## Goals

* **Fast**. Use all of your CPU for building a static website.

* **Simple, Extensible**. Should be simple and intuitive, and doesn't restrict you to change everithing, what you want. It should have very composable design.

* **Simple executable**. You need install erlang 18, and download precompiled escript, which includes all dependencies(including elixir themself), and default theme in the same executable.

Please note: project is 2 day old (Stand: 20.07.2015) and in alpha state, that interface (at least for indexes) will be changed to export less elixir structures.

## Implemented

* Pages
* Blog posts
* Automatic pagination of blog posts
* indexes ( for example tags ) and generation of tag page
* --watch option
* partials for building template

## Roadmap

Roadmap for [Version 0.1.0](https://github.com/liveforeverx/lime/milestones/0.1.0) added.

## Build a project

```
git clone git@github.com:liveforeverx/lime-theme-pixyll.git priv/template/themes/pixyll
mix deps.get
mix escript.build
```

For properly using of watch options, you need to add [fs](https://github.com/synrc/fs) library to erlang PATH. For using escript `lime` you need
to add `ERL_LIBS=.../lime/deps/fs` to path of fs, at least for Mac. It doesn't needed on Linux. Please refer fs documentation for more information.

## Creating a new lime project

    $ lime init /path/to/my/blog

Build a project

    $ lime build

Start local server

    $ lime server

I use it by now, and most time I start it like:

    $ lime server --watch

And edit the context and forget, only need to reload. Live reload will be one of the next features, which I plan to add.

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

It is 4 times performanter as `obelisk`, because of utilization of all CPUs for building posts. The parallization is done using worker with [sbroker](https://github.com/fishcakez/sbroker).



