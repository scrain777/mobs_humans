# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/).


## [Unreleased]

	- No further features planned.



## [0.4.0] - 2019-11-25
### Added

	- Many customization options via Settings -> All Settings -> Mods -> mobs_humans
	- Food drop chance on death.
	- Weapon drop chance on death if killed by a player.
	- Debug chat message (damage math from BlockMen's Creatures MOB-Engine).
	- Support for 3D Armor, Bonemeal.
	- Own mesh model.
	- Weapon draw/sheath.

### Changed

	- Mod in basic mode if 3D Armor not found, can be overriden via Options.
	- Code split into different files.
	- Code improvements, bugfixes, additions, etc.
	- Random values set to realistic chance by default, can be overriden via Options.



## [0.3.0] - 2019-10-17
### Added

	- Support for translations.
	- Option to toggle hovering nametags.

### Changed

	- License changed to EUPL v1.2.
	- mod.conf set to follow MT v5.x specifics.
	- Textures have been optimized (with optipng).
	- Fixed collisionbox.

### Removed

	- Support for MT v0.4.x



## [0.2.2] - 2018-07-27
### Changed

	- Removed redundant conditional check.



## [0.2.1] - 2018-07-27
### Changed

	- Thrown stones will despawn when hitting a node.
	- Minor code improvements.



## [0.2.0] - 2018-07-16
### Added

	- Stone throwing ability.

### Changed

	- Active Objects Count decreased to 1 (was 2)
	- Humans' bones remove timer increased to (min300, max600)secs (was 60, 300)



## [0.2.0-dev] - 2018-07-10
### Added

	- changelog.md

### Changed

	- Health recover function.
	- Bones spawn chance increased to 6/12 (was 4/12)
