# Snippets.sugar for Espresso

The Snippets.sugar adds the ability to very easily insert and create snippets for [Snippets.app](http://snippetsapp.com/) from within [Espresso](http://macrabbit.com/espresso/).

This is awesome because it allows you to easily insert snippets from Snippets.app that contain Snippets-style placeholder variables, Espresso tab stops, or Textmate tab stops. Because your snippets are passed through the Espresso snippet system, you also can use neat tricks like placeholder variables and interpolated shell code.

## Installation

To install, [download the latest version](https://github.com/downloads/onecrayon/Snippets-sugar/Snippets.sugar.zip), unzip it, and double click it. If you have previously installed the Snippets.sugar, you may need to delete the old copy first; it lives here:

    ~/Library/Application Support/Espresso/Sugars/Snippets.sugar

## Usage

You can access the sugar from **Actions&rarr;Snippets.app** menu. To create a new snippet, you will first need to select some text in the front-most Espresso window.

You can set default author and license information within the Espresso Advanced preferences, as well as choose how to interpret snippets that are being inserted from Snippets.app.

## Building from source

If you wish to modify Snippets.sugar for whatever reason, building it from source should be straight-forward if you are used to working with Xcode. Currently, the Xcode project is from Xcode 3, so you may need to make some modifications to get it to build with Xcode 4.

Also, note that if you have Espresso installed somewhere other than your root Applications older, you will need to update the APPLICATION_PATH variable in the project settings (it needs to know where the Espresso header files are living in order to build).