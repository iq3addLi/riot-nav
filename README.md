# riot-nav
View stack manager for riot.js like UINavigationController in iOS.

SPA development using riot.js is almost the same as iOS development.
When I looked like this, I wanted to do view management like iOS, so I tried making it.😎

## Worked
* Safari 10.1.1
* FireFox 52.0.2
* Chrome 58.0.3029.110

All on MacOSX Sierra.

## Not worked
* IE11 on Win8.1

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
nav( tagName, opts )
```

### pop
```js
nav()
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
Demo page is [here](https://iq3addli.github.io/riot-nav/index.html)

## Future plans
* Providing a means to access the previous tag with nav
* Add transition choice
* Providing a means for setting custom transitions
* Make riot-tab (like UITabBarController). I want to keep the view state.
* Make it available at npm

Thank you for using! 😄