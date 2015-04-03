var layer = new Layer()
var pusheen = new Image({name:"pusheen"})

var start
var end

var dimension = (400*400);

//var start = new Date()
//pusheen.loadPixels()
//var end = new Date()
//console.log("Loading pixel array done! Took:"+ (end-start));
//console.log(pusheen.pixels.length);

start = new Date()
var pixels = pusheen.toPixels()
end = new Date()
console.log("Load done! Took:"+ (end-start));

start = new Date()
for (var i=0; i < dimension; i++) { 
//	var color = pusheen.pixels[i]
	var color = pixels.colorAt(i)

	pixels.setColorAt(i,255-color[0],255-color[1],255-color[2])
}
end = new Date()
console.log("Modifications done! Took:"+ (end-start));

start = new Date()
pusheen = pixels.toImage()
end = new Date()
console.log("Update done! Took:"+ (end-start));

layer.image = pusheen

layer.position = new Point({ x: Layer.root.width * 0.5, y: Layer.root.height * 0.5 })


////////////

//this.pixels = [];
//for (var rgb in this.pixelNumbers) {
//var red = (rgb >> 16) & 0xFF;
//var green = (rgb >> 8) & 0xFF;
//var blue = rgb & 0xFF;
//this.pixels.push([red,green,blue]);
//}