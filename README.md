# README

## Install

``` bash
npm install
```

## Run

``` bash
npm run dev
```

## VS Code

launch.json:
``` json
{
	"version": "0.2.0",
	"configurations": [
		{
			"command": "./node_modules/.bin/astro dev",
			"name": "Development server",
			"request": "launch",
			"type": "node-terminal"
		}
	]
}
```
