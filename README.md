# riot-nav
View stack manager for riot.js like UINavigationController in iOS.

<a href="https://www.npmjs.com/package/riot-nav"><img src="https://img.shields.io/npm/v/riot-nav.svg?style=shield"></a>

SPA development using riot.js is almost the same as iOS development.
When I looked like this, I wanted to do view management like iOS, so I tried making it.😎

Although it is a reference, the following points are different.

* Do not include UI.
* Add methods I wanted for iOS version.

## How to use

### import tag
```html
<script type="riot/tag" src="path/to/NavigationController.tag"></script>
```
### mount with root tag
Please note that you need to write with lowercase.
```html
<navigationcontroller root="rootviewcontroller" />
```

## Access
From the tag of the child you can refer from opts.nav
```js
opts.nav
opts.navigationController // Familiar to iOS engineers
```
## API

### push
```js
nav.push( tagName, opts )
```

### pop
```js
nav.pop()
```

## Lifecycle
By having the function property below, you can handle events of navigationControler.
```js
didLoad 
willAppear 
didAppear 
willDisappear 
didDisappear
```

## Demo
[View demo](https://iq3addli.github.io/riot-nav/index.html)

## Check list
|Browser|Version|OS|Result|
|:---|:---|:---|:---:|
|Safari|10.1.1|MacOSX Sierra|◯|
|FireFox|52.0.2|MacOSX Sierra|◯|
|Chrome|58.0.3029.110|MacOSX Sierra|◯|
|Internet Exploror|11.0.15063.0|Windows 10|◯|
|MS Edge|40.15063.0|Windows 10|◯|
|Internet Exploror|11.0.9600.18639|Windows 8.1|×|

## Future plans
* Add transition choice
* Providing a means for setting custom transitions

Thank you for using! 😄