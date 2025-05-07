---
title:  "Migrate from Jekyll to Astro"
description: ""
pubDate:   2025-05-05 22:00:00 +0200
categories: Astro
slug: astro/2025/05/05/jekyll-migrate.html
heroImage: "/astro-migration.svg"
---

The main reason to use Jekyll is the free and easy hosting you get from GitHub, but Jekyll has not aged well and you have to deal with old, slow and weird Ruby tooling. As I have a bit more free time at the moment I decided to explore what other options that have popped up in the last 10 years and there is a lot, a quick search led me to Astro that seems to check most boxes and is based on modern technology and offers a lot of choice in framework

This is not a full guide on how to port your old Jekyll website to as there is a lot of customization options on how to do things:

Remove Jekyll stuff:

``` bash
rm -rf _config.yml index.html 404.html feed.xml Gemfile Gemfile.lock .gitignore _includes _layouts _sass css
```

Create new astro blog and copy all files into the root of the repo:
``` bash
npm create astro@latest -- --template blog
mv folder/.* folder/* ./
```

Start blog path from / not /blog to keep only urls works and remember to fix imports in .astro files:

``` bash
mv src/pages/blog/* src/pages/
```

Copy the blog posts to new location in Astro:

``` bash
mv _posts/* src/content/blog/
rm -rf posts/
```

Update all posts to new format that Astro uses.

``` diff
-layout: post
 title:  "First post on github pages"
+description: "Docuwiki to Jekyll"
-date:   2016-04-10 18:12:36 +0200
+pubDate: 2016-04-10 18:12:36 +0200
-categories: dokuwiki
-permalink: /dokuwiki/2016/04/10/initial.html
+slug: dokuwiki/2016/04/10/initial
+heroImage: "/blog-placeholder-2.jpg"
```

Links:
* https://docs.astro.build/en/guides/migrate-to-astro/from-jekyll/