//This was harder than i thought, but i finally got it working 
//By Aldo Idk

import Math;
import flixel.math.FlxMath;
import openfl.geom.Matrix;

var extensionCam:Float = 0.5;
var cameraMatrix:Matrix;

function onUpdatePost()
{
    flashSpriteSet(game.camGame._flashOffset.x, game.camGame._flashOffset.y,false);
    cameraMatrix = new Matrix();
    cameraMatrix.translate(-game.camGame.width * extensionCam, -game.camGame.height * extensionCam);
    cameraMatrix.scale(game.camGame.scaleX, game.camGame.scaleY);
    cameraMatrix.rotate(game.camGame.angle * (Math.PI / 180));
    cameraMatrix.translate(game.camGame.width * extensionCam, game.camGame.height * extensionCam);
    cameraMatrix.translate(game.camGame.flashSprite.x, game.camGame.flashSprite.y);
    cameraMatrix.scale(FlxG.scaleMode.scale.x, FlxG.scaleMode.scale.y);
    game.camGame.canvas.transform.matrix = cameraMatrix;
    flashSpriteSet(game.camGame.width * extensionCam * FlxG.scaleMode.scale.x, game.camGame.height * extensionCam * FlxG.scaleMode.scale.y,true);
    game.camGame.flashSprite.rotation = 0;
}

function flashSpriteSet(x:Float, y:Float,Scale:Bool)
{
    if (Scale)
    {
        game.camGame.flashSprite.x = x;
        game.camGame.flashSprite.y = y;
    }
    else
    {
        game.camGame.flashSprite.x -= x;
        game.camGame.flashSprite.y -= y;
    }
}