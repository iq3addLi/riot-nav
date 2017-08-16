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
        
        currentTransition = self.opts.animation ?
            "riot-nav-transition-" + self.opts.animation : 
            "riot-nav-transition-slide"

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

// implemented delegate of riot-tab
self.shouldSelect = function(){
    var tag = self.topViewTag()
    if( tag.shouldSelect ){
        return tag.shouldSelect()
    }
    return true
}

self.didSelect = function(){
    var tag = self.topViewTag()
    if( tag.didSelect ){
        tag.didSelect()
    }
}

self.didDeselect = function(){
    var tag = self.topViewTag()
    if( tag.didDeselect ){
        tag.didDeselect()
    }
}

// -----------
// private
// -----------
var currentTransition = "riot-nav-transition-slide"

var pushViewController = function( tagName, tagOption ){
    var stack = document.getElementById(self.uniqueID())

    // create new viewcontroller's element
    var view = document.createElement("div")
    view.id = "riot-nab-child_" + uuidv4()

    // Add initial class
    view.classList.add("riot-nav-view")
    view.classList.add( currentTransition )
    var isRoot = ( stack.children.length == 0 )
    if( isRoot ){
        view.classList.add( currentTransition + "-current")
    }else{
        view.classList.add( currentTransition + "-above")
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
            view.classList.remove( currentTransition + "-above")
            view.classList.add( currentTransition + "-current")

            // hide current view
            var belowView = stack.children[stack.children.length - 2]
            belowView.classList.remove( currentTransition + "-current")
            belowView.classList.add( currentTransition + "-below")

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
        view.classList.remove( currentTransition + "-current")
        view.classList.add( currentTransition + "-above");

        // show below view
        var belowView    = views[views.length - 2]
        belowView.classList.remove( currentTransition + "-below" )
        belowView.classList.add( currentTransition + "-current")

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
    var listeners = {};

    return {
        add: function( id, element, event, handler, capture) {
            element.addEventListener(event, handler, capture);
            listeners[id] = {element: element, 
                             event: event, 
                             handler: handler, 
                             capture: capture};
        },
        remove: function(id) {
            if(id in listeners) {
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
}


.riot-nav-transition-slide{
    will-change: transform;
    transition: transform 0.3s cubic-bezier(0.465, 0.183, 0.153, 0.946);
    transition: -moz-transform 0.3s cubic-bezier(0.465, 0.183, 0.153, 0.946);
    transition: -webkit-transform 0.3s cubic-bezier(0.465, 0.183, 0.153, 0.946);
}
.riot-nav-transition-slide-below{
    transform: translateX(-100%);
    -webkit-transform: translateX(-100%);
    -moz-transform: translateX(-100%);
}
.riot-nav-transition-slide-current {
    transform: translateX(0%);
    -webkit-transform: translateX(0%);
    -moz-transform: translateX(0%);
}
.riot-nav-transition-slide-above {
    transform: translateX(100%);
    -webkit-transform: translateX(100%);
    -moz-transform: translateX(100%);
}

.riot-nav-transition-fade{
    transition: all 0.5s;
    -webkit-transition: all 0.5s;
    -moz-transition: all 0.5s;
    -ms-transition: all 0.5s;
    -o-transition: all 0.5s;
}
.riot-nav-transition-fade-below{
    opacity: 0
}
.riot-nav-transition-fade-current {
    opacity: 1
}
.riot-nav-transition-fade-above {
    opacity: 0
}

.riot-nav-transition-modal{
    will-change: transform;
    transition: transform 0.3s cubic-bezier(0.465, 0.183, 0.153, 0.946);
    transition: -moz-transform 0.3s cubic-bezier(0.465, 0.183, 0.153, 0.946);
    transition: -webkit-transform 0.3s cubic-bezier(0.465, 0.183, 0.153, 0.946);
}
.riot-nav-transition-modal-below{
    transform: translateY(0%);
    -webkit-transform: translateY(0%);
    -moz-transform: translateY(0%);
}
.riot-nav-transition-modal-current {
    transform: translateY(0%);
    -webkit-transform: translateY(0%);
    -moz-transform: translateY(0%);
}
.riot-nav-transition-modal-above {
    transform: translateY(100%);
    -webkit-transform: translateY(100%);
    -moz-transform: translateY(100%);
}

</style>

</NavigationController>