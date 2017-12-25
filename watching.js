#!/usr/bin/env node

const fs = require('fs');
const fse = require('chokidar');

const [dirToWatch] = process.argv.slice(1);

if (!fs.existsSync(dirToWatch)) {
	return 1;
}

fse.watch(dirToWatch, {ignored: /(^|[\/\\])\../})
	.on('all', (event, path) => {
		// TODO use the bash script to grab the right file
	})
