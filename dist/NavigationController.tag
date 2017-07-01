<!--
/*!
 * View stack manager for riot.js like UINavigationController in iOS
 * https://github.com/iq3addLi/riot-nav
 *
 * Copyright +Li, Inc.
 * Released under the MIT license
 * https://github.com/iq3addLi/riot-nav/blob/master/LICENSE
 *
 */
-->
<NavigationController>

<!-- View -->
<div id={ uniqueID() } class="riot-nav-viewstack">
</div>

<!-- Controller -->
<script>

// -----------
// private properties
// -----------
var self = this
var tagStack = []
var events = ["oTransitionEnd","mozTransitionEnd","webkitTransitionEnd","msTransitionEnd","transitionend"];
var nav_id = undefined

// -----------
// lifecycle of riot
// -----------
self.on("mount",function(){
    if ( self.opts.root != null ){
        console.log(self.opts.opts)
        pushViewController( self.opts.root, self.opts.opts )
    }
})

self.on("unmount",function(){
    tagStack.map( function( tag ){ tag.unmount() })
})

// -----------
// public
// -----------
/*!
    pushViewController in UINavigationController
    @param {Object} tagName - Tag name to display.
    @param {Object} opts - Object to hand over to tag.
*/
self.push = function( tagName, tagOption ){
    pushViewController( tagName, tagOption )
}

/*!
    popViewController in UINavigationController
*/
self.pop = function(){
    popViewController()
}

/*!
    viewControllers in UINavigationController
    @return {Object[]} riot tags.
*/
self.viewTags = function(){
    return tagStack
}

/*!
    topViewController in UINavigationController
    @return {Object} top of riot tag in stack.
*/
self.topViewTag = function(){
    return tagStack[tagStack.length - 1]
}

/*!
    tabBarController in UINavigationController
*/
self.tab = self.opts.tab

self.uniqueID = function(){
    if( nav_id ) { return nav_id }
    nav_id = "riot-nav_" + uuidv4()
    return nav_id
}

// -----------
// private
// -----------
var pushViewController = function( tagName, tagOption ){
    var stack = document.getElementById(self.uniqueID())

    // create new viewcontroller's element
    var view = document.createElement("div")
    view.id = "riot-nab-child_" + uuidv4()

    // Add initial class
    view.classList.add("riot-nav-view")
    var isRoot = ( stack.children.length == 0 )
    if( isRoot ){
        view.classList.add("riot-nav-current-view")
    }else{
        view.classList.add("riot-nav-above-view")
    }

    // Add element in ViewStack
    stack.appendChild( view )

    // Create opt
    var options = {}
    if ( tagOption instanceof Object ){ options = tagOption }
    options.navigationController = self
    options.nav = self

    // Mount tag for element
    view.setAttribute("data-is", tagName)
    let aboveTag = riot.mount( "div#" + view.id, tagName, options )[0]
    if( aboveTag.didLoad ){ aboveTag.didLoad() }
    tagStack.push(aboveTag)

    if( !isRoot ){
        // Call lifecycle function
        let belowTag = tagStack[tagStack.length - 2]
        if( aboveTag.willAppear ){ aboveTag.willAppear() }
        if( belowTag.willDisappear ){ belowTag.willDisappear() }

        setTimeout( function(){
            // show above view
            view.classList.remove("riot-nav-above-view")
            view.classList.add("riot-nav-current-view")

            // hide current view
            var belowView = stack.children[stack.children.length - 2]
            belowView.classList.remove("riot-nav-current-view")
            belowView.classList.add("riot-nav-below-view")

            // Registerd listener of transition end
            events.map(function(elem){
                Listener.add( view.className + "_" + elem, view, elem, function(){
                    // Call lifecycle function
                    if( aboveTag.didAppear ) { aboveTag.didAppear() }
                    if( belowTag.didDisappear ){ belowTag.didDisappear() }

                    // Unregisterd listener
                    events.map(function(elem){ Listener.remove( view.className + "_" + elem )} )
                }, false);
            })
        },50)
    }
}

var popViewController = function(){
    var views = document.getElementById(self.uniqueID()).children
    if( views.length > 1 ){
        // hide current view
        var view    = views[views.length - 1]
        view.classList.remove('riot-nav-current-view')
        view.classList.add('riot-nav-above-view');

        // show below view
        var belowView    = views[views.length - 2]
        belowView.classList.remove('riot-nav-below-view')
        belowView.classList.add('riot-nav-current-view')

        // Call lifecycle event
        var aboveTag = tagStack.pop()
        var belowTag = tagStack[tagStack.length - 1]
        if( belowTag.willAppear ) { belowTag.willAppear() }
        if( aboveTag.willDisappear ) { aboveTag.willDisappear() }

        // Registerd listener of transition end
        events.map(function(elem){
            Listener.add( view.className + "_" + elem, view, elem, function(){
                // Call lifecycle function
                if( belowTag.didAppear ) { belowTag.didAppear() }
                if( aboveTag.didDisappear ) { aboveTag.didDisappear() }

                // Unmount above view tag
                aboveTag.unmount()

                // Unregisterd listener
                events.map(function(elem){ Listener.remove( view.className + "_" + elem )})

                // Remove element
                view.remove()
            }, false);
        })
    }
}

var Listener = (function(){
    listeners = {};

    return {
        add: function( id, element, event, handler, capture) {
            //console.log("add " + id)
            element.addEventListener(event, handler, capture);
            listeners[id] = {element: element, 
                             event: event, 
                             handler: handler, 
                             capture: capture};
        },
        remove: function(id) {
            if(id in listeners) {
                //console.log("remove "+ id)
                var h = listeners[id];
                h.element.removeEventListener(h.event, h.handler, h.capture);
                delete listeners[id];
            }
        }
    };
}());

var uuidv4 = function() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

</script>

<!-- Styles -->
<style>
.riot-nav-viewstack {
    width: 100%;
    height: 100%;
    position: relative;
    overflow: hidden;
    box-sizing: border-box;
}
.riot-nav-view {
    width: 100%;
    height: 100%;
    position: absolute;
    will-change: transform;
    transition: transform 0.3s cubic-bezier(0.465, 0.183, 0.153, 0.946);
    transition: -moz-transform 0.3s cubic-bezier(0.465, 0.183, 0.153, 0.946);
    transition: -webkit-transform 0.3s cubic-bezier(0.465, 0.183, 0.153, 0.946);
}
.riot-nav-below-view{
    transform: translateX(-100%);
    -webkit-transform: translateX(-100%);
    -moz-transform: translateX(-100%);
}
.riot-nav-current-view {
    transform: translateX(0%);
    -webkit-transform: translateX(0%);
    -moz-transform: translateX(0%);
}
.riot-nav-above-view {
    transform: translateX(100%);
    -webkit-transform: translateX(100%);
    -moz-transform: translateX(100%);
}
</style>

</NavigationController>