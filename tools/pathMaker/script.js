class Vector {
    constructor(x, y) {
      this.x = x
      this.y = y
    }
  }
  
  let img;
  const pixelToInchRatio = 1.37;
  const xImageCenter = 2987/5/2;
  const yImageCenter = 1757/5/2;
  let pointList = [];
  let lineVectorList = [];
  let lineVectorHasChanged = false;
  let count = 1
  const stepIncrement = 1;
  let pointFile;
  
  function preload() {
    img = loadImage('https://firebasestorage.googleapis.com/v0/b/pathmakerviewer.appspot.com/o/rapidreactfield.png?alt=media&token=8cf9f0e0-b56f-49b6-941b-c9240db1a2d7');
  }
  
  function setup() {
    createCanvas(2987/5, 1757/5);
    textSize(15);
  }
  
  function createNewLineVector(vector) {
    lineVectorList.push(vector);
    lineVectorHasChanged = true;
  }
  
  function convXToScreen(x) {
    return xImageCenter + x/pixelToInchRatio;
  }
  
  function convYToScreen(y) {
    return yImageCenter + y/pixelToInchRatio * -1;
  }
  
  function clearPointList() {
    pointList = []
  }
  
  function createNewPoint(vector) {
    pointList.push(vector)
  }
  
  function removeLastLineVector() {
    let previousPoint = lineVectorList[lineVectorList.length - 2]
    let currentPoint = lineVectorList[lineVectorList.length - 1]
    let length = ceil(pythag(previousPoint, currentPoint)/stepIncrement)
    lineVectorList.pop();
    for(let i = 0; i < length; i++) {
      pointList.pop();
    }
  }
  
  function pythag(start, end) {
    return sqrt(sq(abs(end.x - start.x)) + sq(abs(end.y - start.y)));
  }
  
  function convToScreenCoords(vector) {
    return new Vector (xImageCenter + vector.x/pixelToInchRatio, yImageCenter + vector.y/pixelToInchRatio * -1);
  }
  
  function convToFieldCoords(vector) {
    return new Vector(round((xImageCenter - vector.x) * pixelToInchRatio) * -1, round((yImageCenter - vector.y) * pixelToInchRatio));
  }
  
  function mousePressed() {
    let mouseVector = new Vector(mouseX, mouseY)
    createNewLineVector(convToFieldCoords(mouseVector));
  }
  
  async function getNewFileHandle() {
    const options = {
      types: [
        {
          description: 'Pure Pursuit Path File',
          accept: {
            'text/plain': ['.path'],
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
    if (pointFile == null) {
        getNewFileHandle().then((result => {
            writeFileToDisk(result, JSON.stringify(pointList))
            console.log(pointList)
            pointFile = result;
        }));
    }
    else {
        writeFileToDisk(pointFile, JSON.stringify(pointList))
    }
  }

  function keyPressed() {
    if (keyCode == 8) {
      removeLastLineVector();
    }
    if (keyCode == 83) {
      savePoints();
    }
  }
  
  function draw() {
    let mouseVector = new Vector(mouseX, mouseY);
    let xCoord = convToFieldCoords(mouseVector).x;
    let yCoord = convToFieldCoords(mouseVector).y;
    
    background(220);
    strokeWeight(0);
    image(img, 0, 0, 2987/5, 1757/5);
    text("Screen coordinates: " + String(round(mouseX) + ", " + round(mouseY)), 10, 20);
    text("Field coordinates: " + xCoord + ", " + yCoord, 10, 40);
    strokeWeight(1);
    
    if (lineVectorList.length == 1) {
      stroke(200);
      line(convXToScreen(lineVectorList[0].x), convYToScreen(lineVectorList[0].y), mouseX, mouseY);
    }
    else if (0 < lineVectorList.length) {
      lineVectorList.forEach((item, index) => {
        if (index != 0) {
          let previousPoint =  lineVectorList[index - 1]
          let currentPoint = item
          let pointDrawCount = 0;
                  
          pointList.forEach((item) => {
            if (pointDrawCount % 12 == 0) {
                strokeWeight(5)
                point(convToScreenCoords(item).x, convToScreenCoords(item).y)
            }
            pointDrawCount += 1
          })
          
          strokeWeight(2)
          line(convXToScreen(previousPoint.x), convYToScreen(previousPoint.y), convXToScreen(currentPoint.x), convYToScreen(currentPoint.y));
        }
        
        if (index == lineVectorList.length - 1) {
          stroke(200);
          line(convXToScreen(lineVectorList[lineVectorList.length - 1].x), convYToScreen(lineVectorList[lineVectorList.length - 1].y), mouseX, mouseY);
        }
      })
      
      let previousPoint = lineVectorList[lineVectorList.length - 2]
      let currentPoint = lineVectorList[lineVectorList.length - 1]
      let length = pythag(previousPoint, currentPoint)
      let xStepSize = ((currentPoint.x - previousPoint.x)/length)
      let yStepSize = ((currentPoint.y - previousPoint.y)/length)
      let targetDots = ceil(length/stepIncrement);
  
      stroke(0);
  
      if (1 < lineVectorList.length && lineVectorHasChanged) {
        let dotCount = 0;
        while(dotCount < targetDots) {
          let newPoint = new Vector(previousPoint.x + xStepSize * (stepIncrement * dotCount), previousPoint.y + yStepSize * (stepIncrement * dotCount))
          strokeWeight(8)
          createNewPoint(newPoint)
          dotCount += 1
          count += 1
        }
      }
      lineVectorHasChanged = false;
    }
  }