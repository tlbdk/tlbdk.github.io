---
title:  "Migrate from Jekyll to Astro"
description: ""
pubDate:   2025-05-05 22:00:00 +0200
categories: Astro
slug: astro/2025/05/05/jekyll-migrate.html
heroImage: "/blog-placeholder-2.jpg"
---

Remove Jekyll stuff:

``` bash
rm -rf _config.yml index.html 404.html feed.xml Gemfile Gemfile.lock .gitignore _includes _layouts _sass css
```

Create new astro blog and copy in new 
``` bash
npm create astro@latest -- --template blog
mv folder/.* folder/* ./
```

Start blog path from / not /blog, fix imports in .astro files:

``` bash
mv src/pages/blog/* src/pages/
```

Copy posts to new location:

``` bash
mv _posts/* src/content/blog/
rm -rf posts/
```

Update all posts to new format:

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