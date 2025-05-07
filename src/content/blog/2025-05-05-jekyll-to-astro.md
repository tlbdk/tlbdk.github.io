---
title:  "Migrate from Jekyll to Astro on Github Pages"
description: ""
pubDate:   2025-05-05 22:00:00 +0200
categories: Astro
slug: astro/2025/05/05/jekyll-migrate.html
heroImage: "/astro-migration.svg"
---

The main reason to use Jekyll is the free and easy hosting you get from GitHub, but Jekyll has not aged well and you have to deal with old, slow and weird Ruby tooling. As I have a bit more free time at the moment I decided to explore what other options that have popped up in the last 10 years and there is a lot, a quick search led me to Astro that seems to check most boxes and is based on modern technology and offers a lot of choice in framework

This is not a full guide on how to port your old Jekyll website to as there is a lot of customization options on how to do things:

## Porting from Jekyll to Astro

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

## Setting up github pages deployment

The way github pages works is that your build step generates the static website files and uploads them to Github Actions Artifacts storage as a tar file and then the deploy step calls a GitHub Pages rest API with the artifact id to deploy the site. There already exists some actions to help with that so basically we just need to find a way to build the site and add a new Github actions workflow to call them.

If you are using Jekyll you most likely are still using the "Classic Github pages" deployment so first this needs to be disabled first.

Disable "Classic Github pages" deployment:

1. Go to "Setting" in the repo you have your github pages typically "<github id>.github.io"
2. Select "Pages" and under "Build and deployment" select "GitHub Actions" as source

For building the static website files I'm using docker to as it's simple, self contained and I can test it locally:

``` dockerfile
# Using node 22.x on alpine Linux because it smaller images
FROM node:22-alpine AS builder

# Create an app folder and copy in source files
RUN mkdir /app
WORKDIR /app
COPY . /app/

# Install dependencies and build project
RUN npm install
# Build the site and save the static website files to /app/dist
RUN npm run build

# Start from an empty image and copy in the static website files 
FROM scratch
COPY --from=builder /app/dist /
```

To generate the artifact.tar I just use docker build tar output option.

```yaml
docker build --progress=plain --no-cache --output type=tar,dest=/artifact.tar .
```

You can find all the docker files here:

* [Dockerfile](https://github.com/tlbdk/tlbdk.github.io/tree/master/Dockerfile).
* [.dockerignore](https://github.com/tlbdk/tlbdk.github.io/tree/master/.dockerignore).

For deploying I'm using the action "actions/deploy-pages@v4": 

[deploy.yaml](https://github.com/tlbdk/tlbdk.github.io/tree/master/.github/workflows/deploy.yaml):
``` yaml
name: Deploy to GitHub Pages

on:
  # Trigger the workflow every time you push to the `master` branch
  push:
    branches: [ master ]
  # Allows you to run this workflow manually from the Actions tab on GitHub.
  workflow_dispatch:

# Allow this job to clone the repo and create a page deployment
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout your repository using git
        uses: actions/checkout@v4
        with:
          fetch-depth: 0 # Fetch all history for all branches and tags
      - name: Build site with docker
        run: |
          docker build --progress=plain --no-cache --output type=tar,dest=${{ runner.temp }}/artifact.tar .
      - name: Upload Github Pages artifact
        uses: actions/upload-artifact@v4
        with:
          name: github-pages
          path: ${{ runner.temp }}/artifact.tar
          retention-days: 1
          if-no-files-found: error
  deploy:
    needs: build
    runs-on: ubuntu-latest
    permissions:
      pages: write
      id-token: write
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```



