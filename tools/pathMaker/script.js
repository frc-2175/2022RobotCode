/* eslint-disable no-undef */

class Vector {
	constructor(x, y) {
		this.x = x;
		this.y = y;
	}

	convToScreenCoords() {
		return new Vector(xImageCenter + this.x / pixelToInchRatio, yImageCenter + this.y / pixelToInchRatio * -1);
	}

	convToFieldCoords() {
		return new Vector(round((xImageCenter - this.x) * pixelToInchRatio) * -1, round((yImageCenter - this.y) * pixelToInchRatio));
	}

	distTo(vector) {
		return dist(this.x, this.y, vector.x, vector.y);
	}
}

let img;
let dataChangedSinceSave = true;
let pixelToInchRatio = null;
let pointList = [];
let lineVectorList = [];
let lineVectorHasChanged = false;
const stepIncrement = 1;
let pointFile;
let xImageCenter = null;
let yImageCenter = null;
const visualizeNPoints = 16;
let currentSegment = 1;
let closestLineIndex;
let closestPoint;
let mouseVector;
const triggerPointList = [];
const colorList = [
	{
		"name": "gray",
		"value": "2f4f4f"
	},
	{
		"name": "maroon",
		"value": "7f0000"
	},
	{
		"name": "green",
		"value": "008000"
	},
	{
		"name": "blue",
		"value": "000080"
	},
	{
		"name": "orange",
		"value": "ff8c00"
	},
	{
		"name": "yellow",
		"value": "ffff00"
	},
	{
		"name": "lime",
		"value": "00ff00"
	},
	{
		"name": "aqua",
		"value": "00ffff"
	}
];

// eslint-disable-next-line no-unused-vars
function preload() {
	img = loadImage("https://firebasestorage.googleapis.com/v0/b/pathmakerviewer.appspot.com/o/rapidreactfield.png?alt=media&token=8cf9f0e0-b56f-49b6-941b-c9240db1a2d7");
}

function setup() {
	createCanvas(windowWidth, (windowWidth * 0.58));
	xImageCenter = width / 2;
	yImageCenter = height / 2;
	pixelToInchRatio = 1.37 / (width / (2987 / 5));
	textSize(15);
}

function createNewLineVector(vector) {
	lineVectorList.push(vector);
	lineVectorHasChanged = true;
	dataChangedSinceSave = true;
	updateTitle(pointFile);
}

function convXToScreen(x) {
	return xImageCenter + x / pixelToInchRatio;
}

function convYToScreen(y) {
	return yImageCenter + y / pixelToInchRatio * -1;
}

function createNewPoint(vector) {
	pointList.push(vector);
	updateTitle(pointFile);
}

function removeLastLineVector() {
	if (1 < lineVectorList.length) {
		const previousPoint = lineVectorList[lineVectorList.length - 2];
		const currentPoint = lineVectorList[lineVectorList.length - 1];
		const length = ceil(previousPoint.distTo(currentPoint) / stepIncrement);
		for (let i = 0; i < length; i++) {
			pointList.pop();
		}
		currentSegment -= 1;
	}
	dataChangedSinceSave = true;
	lineVectorList.pop();
	updateTitle(pointFile);
}

// eslint-disable-next-line no-unused-vars
function mousePressed() {
	const mouseVector = new Vector(mouseX, mouseY);
	createNewLineVector(mouseVector.convToFieldCoords());
}

document.addEventListener("keydown", function (e) {
	if (e.key === "s") {
		e.preventDefault();
		savePoints();
	}

	if (e.key === "o") {
		e.preventDefault();
		openPoints();
	}

	if (e.key === " ") {
		e.preventDefault();
		createTriggerPoint(closestPoint, null, null, randomColor()["value"]);
	}
}, false);

function updateTitle(handle) {
	try {
		if (dataChangedSinceSave) {
			document.title = "*" + handle.name;
		}
		else {
			document.title = handle.name;
		}
	}
	catch {
		console.error("File not selected yet.");
	}
}

function randomColor() {
	return colorList[Math.floor(Math.random() * colorList.length)];
}

async function getNewFileHandle() {
	const options = {
		types: [
			{
				description: "Pure Pursuit Path File",
				accept: {
					"text/plain": [".path"],
				},
			},
		],
	};
	const handle = await window.showSaveFilePicker(options);
	return handle;
}

async function writeFileToDisk(fileHandle, contents) {
	// Create a FileSystemWritableFileStream to write to.
	const writable = await fileHandle.createWritable();
	// Write the contents of the file to the stream.
	await writable.write(contents);
	// Close the file and write the contents to disk.
	await writable.close();
}

function savePoints() {
	dataChangedSinceSave = false;
	if (pointFile == null) {
		getNewFileHandle().then(result => {
			updateTitle(result);
			writeFileToDisk(result, JSON.stringify({ points: pointList, lineVectors: lineVectorList }));
			console.log(pointList);
			pointFile = result;
		});
	}
	else {
		updateTitle(pointFile);
		writeFileToDisk(pointFile, JSON.stringify({ points: pointList, lineVectors: lineVectorList }));
	}
}

async function openPoints() {
	const [fileHandle] = await window.showOpenFilePicker();
	const file = await fileHandle.getFile();
	const contents = JSON.parse(await file.text());
	console.log(contents);
	lineVectorList = [];
	pointList = [];
	contents["lineVectors"].forEach((item) => {
		lineVectorList.push(new Vector(item["x"], item["y"]));
	});
	contents["points"].forEach((item) => {
		pointList.push(new Vector(item["x"], item["y"]));
	});
}


// vector 1, vector 2, mouse vector
function getDistanceToLine(v1, v2, m) {
	const numer = ((v2.x - v1.x) * (v1.y - m.y)) - ((v1.x - m.x) * (v2.y - v1.y));
	const denom = Math.sqrt(((v2.x - v1.x) ** 2) + ((v2.y - v1.y) ** 2));
	
	return Math.abs(numer) / denom;
}


function getClosestPointOnLines(pXy, aXys) {
	let minDist, fTo, fFrom, x, y, i, dist;

	if (aXys.length > 1) {
		for (let n = 1; n < aXys.length; n++) {
			if (aXys[n].x !== aXys[n - 1].x) {
				const a = (aXys[n].y - aXys[n - 1].y) / (aXys[n].x - aXys[n - 1].x);
				const b = aXys[n].y - a * aXys[n].x;
				dist = Math.abs(a * pXy.x + b - pXy.y) / Math.sqrt(a * a + 1);
			} else {
				dist = Math.abs(pXy.x - aXys[n].x);
			}

			// length^2 of line segment 
			const rl2 = Math.pow(aXys[n].y - aXys[n - 1].y, 2) + Math.pow(aXys[n].x - aXys[n - 1].x, 2);

			// distance^2 of pt to end line segment
			const ln2 = Math.pow(aXys[n].y - pXy.y, 2) + Math.pow(aXys[n].x - pXy.x, 2);

			// distance^2 of pt to begin line segment
			const lnm12 = Math.pow(aXys[n - 1].y - pXy.y, 2) + Math.pow(aXys[n - 1].x - pXy.x, 2);

			// minimum distance^2 of pt to infinite line
			const dist2 = Math.pow(dist, 2);

			// calculated length^2 of line segment
			const calcrl2 = ln2 - dist2 + lnm12 - dist2;

			// redefine minimum distance to line segment (not infinite line) if necessary
			if (calcrl2 > rl2)
				dist = Math.sqrt(Math.min(ln2, lnm12));

			if ((minDist == null) || (minDist > dist)) {
				if (calcrl2 > rl2) {
					if (lnm12 < ln2) {
						fTo = 0;//nearer to previous point
						fFrom = 1;
					}
					else {
						fFrom = 0;//nearer to current point
						fTo = 1;
					}
				}
				else {
					// perpendicular from point intersects line segment
					fTo = ((Math.sqrt(lnm12 - dist2)) / Math.sqrt(rl2));
					fFrom = ((Math.sqrt(ln2 - dist2)) / Math.sqrt(rl2));
				}
				minDist = dist;
				i = n;
			}
		}

		const dx = aXys[i - 1].x - aXys[i].x;
		const dy = aXys[i - 1].y - aXys[i].y;

		x = aXys[i - 1].x - (dx * fTo);
		y = aXys[i - 1].y - (dy * fTo);

	}

	return { "x": x, "y": y, "i": i, "fTo": fTo, "fFrom": fFrom };
}

function createTriggerPoint(point, name, code, color) {
	const dist = 0;
	let previousPoint = lineVectorList[0];
	lineVectorList.forEach((item, index) => {
		if (0 < index) {
			console.log(previousPoint.distTo(item));
			previousPoint = item;
		}
	});
	if (closestPoint.distTo(mouseVector.convToFieldCoords()) < 50) {
		triggerPointList.push({"vector": point, "name": name, "code": code, "color": color});
	}
	console.log(dist);
}

// eslint-disable-next-line no-unused-vars
function keyPressed() {
	if (keyCode === 8) {
		removeLastLineVector(closestPoint);
	}
}

// eslint-disable-next-line no-unused-vars
function windowResized() {
	resizeCanvas(windowWidth, (windowWidth * 0.58));
	xImageCenter = width / 2;
	yImageCenter = height / 2;
	pixelToInchRatio = 1.37 / (width / (2987 / 5));
}


function updateHTML() {
	if (document.readyState === "ready" || document.readyState === "complete") {
		const triggerPointDiv = document.getElementById("triggerPointDiv");
		triggerPointDiv.innerHTML = "";
		triggerPointList.forEach((item, index) => {
			const triggerPointElement = document.createElement("div");
			const triggerPointTitle = document.createElement("h4");
			triggerPointTitle.innerHTML = `Trigger point ${index}:`;
			triggerPointTitle.style.color = "#" + item["color"];
			triggerPointElement.appendChild(triggerPointTitle);
			triggerPointDiv.appendChild(triggerPointElement);
		}); 
	}
}

function draw() {
	updateHTML();
	mouseVector = new Vector(mouseX, mouseY);
	const xCoord = mouseVector.convToFieldCoords().x;
	const yCoord = mouseVector.convToFieldCoords().y;
	let closestLineDist = Number.MAX_SAFE_INTEGER;

	background(220);
	strokeWeight(0);
	image(img, 0, 0, width, height);
	text("Screen coordinates: " + String(round(mouseX) + ", " + round(mouseY)), 10, 20);
	text("Field coordinates: " + xCoord + ", " + yCoord, 10, 40);

	if (lineVectorList.length > 1) {
		const currentLine = [lineVectorList[currentSegment - 1], lineVectorList[currentSegment]];
		
				
		lineVectorList.forEach((value, index) => {
			if (index > 0) {
				const prev = lineVectorList[index - 1];
				const curr = value;
				const lineDist = getDistanceToLine(curr, prev, mouseVector.convToFieldCoords());
				if (lineDist < closestLineDist) {
					console.log("changed closest!");
					closestLineDist = lineDist;
					closestLineIndex = index;
				}
			}
		});

		currentSegment = closestLineIndex;
		console.log(closestLineIndex);

		closestPoint = new Vector(
			getClosestPointOnLines(mouseVector.convToFieldCoords(), currentLine).x, 
			getClosestPointOnLines(mouseVector.convToFieldCoords(), currentLine).y
		);
		strokeWeight(12);
		stroke(200);
		point(closestPoint.convToScreenCoords().x, closestPoint.convToScreenCoords().y);
		stroke(0);
	}

	else {
		const currentLine = null;
	}

	strokeWeight(1);

	if (lineVectorList.length === 1) {
		stroke(200);
		line(convXToScreen(lineVectorList[0].x), convYToScreen(lineVectorList[0].y), mouseX, mouseY);
	} else if (lineVectorList.length > 0) {
		lineVectorList.forEach((item, index) => {
			if (index !== 0) {
				const previousPoint = lineVectorList[index - 1];
				const currentPoint = item;
				let pointDrawCount = 0;

				pointList.forEach((item) => {
					if (pointDrawCount % visualizeNPoints === 0) {
						strokeWeight(5);
						point(item.convToScreenCoords().x, item.convToScreenCoords().y);
					}
					pointDrawCount += 1;
				});

				strokeWeight(2);
				line(convXToScreen(previousPoint.x), convYToScreen(previousPoint.y), convXToScreen(currentPoint.x), convYToScreen(currentPoint.y));
			}

			if (index === lineVectorList.length - 1) {
				stroke(200);
				line(convXToScreen(lineVectorList[lineVectorList.length - 1].x), convYToScreen(lineVectorList[lineVectorList.length - 1].y), mouseX, mouseY);
			}
		});

		stroke(0);
		strokeWeight(10);
		triggerPointList.forEach((item) => {
			stroke(0);
			strokeWeight(18);
			point(item["vector"].convToScreenCoords().x, item["vector"].convToScreenCoords().y);
			strokeWeight(10);
			stroke("#" + item["color"]);
			point(item["vector"].convToScreenCoords().x, item["vector"].convToScreenCoords().y);
		});
		stroke(0);

		const previousPoint = lineVectorList[lineVectorList.length - 2];
		const currentPoint = lineVectorList[lineVectorList.length - 1];
		const length = previousPoint.distTo(currentPoint);
		const xStepSize = ((currentPoint.x - previousPoint.x) / length);
		const yStepSize = ((currentPoint.y - previousPoint.y) / length);
		const targetDots = ceil(length / stepIncrement);

		stroke(0);

		if (1 < lineVectorList.length && lineVectorHasChanged) {
			let dotCount = 0;
			while (dotCount < targetDots) {
				const newPoint = new Vector(previousPoint.x + xStepSize * (stepIncrement * dotCount), previousPoint.y + yStepSize * (stepIncrement * dotCount));
				strokeWeight(8);
				createNewPoint(newPoint);
				dotCount += 1;
			}
		}
		lineVectorHasChanged = false;
	}
}