# Ulm Awesome Game Starter

This is a simple game starter project for the Ludum Dare Game Jam. It is based on the [Godot Game Engine](
https://godotengine.org/).

## Structure

The project is structured as follows:

- `addons/`: External godot addons. 💀 Don't touch this folder.
- `assets/`: Assets for the game, such as images, sounds, etc.
- `autoload/`: Contains scripts that are autoloaded when the game starts. Autoloaded scripts are available in **all** scenes. See the [autoloaded scripts section](#autoloaded-scripts) for more information.
- `components/`: Contains reusable components that can be used in multiple scenes.
- `gui/`: Contains all the GUI scenes for the game.
- `scenes/`: Contains all the scenes for the "real" game.
- `screens/`: Contains the scenes for the game's screens, such as the main menu, game over screen, etc.

## Autoloaded Scripts

Autoloaded scripts are scripts that are loaded when the game starts and are available in **all** scenes.

We are using autoloaded scripts to manage the game state and to provide utility functions that are used throughout the game.

### Existing Autoloaded Scripts

- `Game.tscn`: This scene is used to manage the game state.
- `MusicPlayer.tscn`: This scene is used to manage the background music.
- `DialogOverlay.tscn`: This scene is used to display dialog boxes.

#### Game.tscn

Set all game-wide variables and functions in this script. This script is autoloaded and is available in all scenes.
Set variables like this:

    ```gdscript

    func _ready():
        # Set the player's health
        Game.player_health = 100;

    ```

#### MusicPlayer.tscn

This script is used to manage the background music. It is autoloaded and is available in all scenes.
To play music, call the `play_music` function like this:

    ```gdscript

    MusicPlayer.play_music("main");

    ```

Music files should be placed in the `assets/music/` folder. All tracks have to be in the `.ogg` format.

To be able to be played, the tracks have to be placed in an AudioStreamPlayer node in the `MusicPlayer.tscn` scene.


#### DialogOverlay.tscn

This script is used to display dialog boxes. It is autoloaded and is available in all scenes.

To display a dialog box, call the `do_dialog` function like this:

    ```gdscript

    DialogOverlay.do_dialog([{
        "actor": "chef",  # Choose an actor whose image will be displayed
        "type": "line",   # line or action
        "lines": [        # The lines to display
            "Hello!",
            "How are you?"
        ]
    }]);

    ```

### Add a new autoloaded script
To add a script to the autoloaded scripts, follow these steps:

1. Create a new script in the `autoload/` folder.
2. Open the `Project Settings` by clicking on the `Project` menu and selecting `Project Settings`.
3. In the `AutoLoad` tab, click on the folder icon and select the script you want to autoload.
