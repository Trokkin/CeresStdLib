# Ceres Standard Library

This is the repository of the Ceres standard library which provides a vast amount of useful packages to users starting out with Lua in Warcraft 3.

# Usage

This library is designed for use with [Ceres map builder for Warcraft III](https://github.com/ElusiveMori/ceres-wc3).
To use StdLib in a Ceres project, simply clone/download this repository into `/lib/` folder of the project.

# Motivation

Ceres aims to provide a better "out of the box" experience when it comes to Warcraft 3 modding. Since barebones Lua is very limited with Warcraft specific functionality, developers have to implement everything themselves. Before Ceres these resources had to be gathered and copied manually from modding forums across the web. Public code resources in forums threads are not only hard to maintain and keep up to date, but also often untested, interdependent on other resources and incompatible with other code.

By introducing a standard library, we offer the developers everything they need to start focusing on creating content, rather than implementing basics to even get started. The frameworks provided by the standard library try to be lightweight and unintrusive, while still configurable for your needs. The streamlined API allows external packages to share code and work independently.

# Inspiration

While Lua support for Warcraft 3 was only a dream, community has developed it's own language (!) that compiles to JASS, the mighty [WurstScript](https://github.com/wurstscript), which came with [it's own standart library](https://github.com/wurstscript/WurstStdlib2) and a lot of other cool features.

[HiveWorkshop](https://www.hiveworkshop.com/) is a central place in Warcraft 3 modding community, so it has expectedly much to offer to any user and to this standart library.