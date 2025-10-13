#if !macro
// Flixel

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.input.actions.FlxActionInput;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxColor;

// Important classes that cannot be used just like others
import funkin.backend.Conductor.BPMChangeEvent;
import funkin.backend.controls.Controls;
import funkin.backend.controls.Controls.Device;
import funkin.backend.controls.Controls.KeyboardScheme;
import funkin.backend.data.Discord.DiscordClient;
import funkin.backend.data.Section.SwagSection;
import funkin.backend.data.Song.SwagSong;

// Others
import funkin.backend.*;
import funkin.backend.controls.*;
import funkin.backend.data.*;
import funkin.backend.data.characters.*;
import funkin.backend.data.shaders.*;
import funkin.backend.data.stages.*;
import funkin.backend.objects.*;
import funkin.backend.framerate.*;
import funkin.backend.util.*;

// States
import funkin.states.*;
import funkin.states.menus.*;
import funkin.states.options.*;
import funkin.states.editors.*;
import ui.*;

// SubStates
import funkin.substates.*;
#end
