#!/usr/bin/env node

const fs = require('fs');
const fse = require('chokidar');

const [dirToWatch] = process.argv.slice(2);
const ignoreDotfilesReg = /(^|[\/\\])\../;

if (!process.argv.slice(2) && !fs.existsSync(dirToWatch)) {
	console.error('invalid args');
	process.exit(1);
}

fse.watch(dirToWatch, {ignored: ignoreDotfilesReg})
	.on('all', (event, path) => {
		console.log(`change type ${event} to ${path}`);
	});
