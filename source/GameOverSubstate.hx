package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";
	var randomGameover:Int = 1;


	var danceTime:Bool = false;
	var started:Bool = false;

	var daChrome:Float = 0.003;
	var daNoise:Int = 100;
	var awesomeShaderTime:Bool = false;	

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'bf-and-gf':
				daBf = 'bf-holding-gf-dead';
			default:
				daBf = 'bf';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		randomGameover = FlxG.random.int(1, 25);		
	}

	var playingDeathSound:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (PlayState.SONG.song.toLowerCase() == 'thorns')
			{
				if (awesomeShaderTime)
				{
					if (!isEnding)
					{
						PlayState.vhsShader.setNoisePercent(100 / 100);
						PlayState.chromaticAbberation.setChrome(FlxG.random.float(0.001, 0.005));
					}
					else
					{
						daNoise -= 2;
						daChrome += 0.0001;
	
						PlayState.chromaticAbberation.setChrome(daChrome);
						PlayState.vhsShader.setNoisePercent(daNoise / 100);
					}
				}
				else
				{
					PlayState.vhsShader.setNoisePercent(0);
					PlayState.chromaticAbberation.setChrome(0);
					PlayState.vhsShader.update(elapsed);
				}
	
				if (started)
					PlayState.vhsShader.update(elapsed);
			}	

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		switch (PlayState.storyWeek)
		{
		    case 7:
			        if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
			        {
				        FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + randomGameover));
						started = true;
						awesomeShaderTime = true;
						danceTime = true;
			        }
		    default:
			    if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
			    {
				    FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
				    started = true;
				    awesomeShaderTime = true;
				    danceTime = true;
			    }
		}	

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	private function coolStartDeath():Void
	{
		FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
	}

	override function beatHit()
	{
		super.beatHit();

		if (danceTime && !isEnding)
			{
				bf.animation.play('deathLoop', true);
			}
	
			FlxG.log.add('beat' + curBeat);	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
