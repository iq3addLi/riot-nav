<!--
/*!
 * iOS UINavigationController likes view stack manager for riot.js
 * https://github.com/iq3addLi/riot-nav
 *
 * Copyright +Li, Inc.
 * Released under the MIT license
 * https://github.com/iq3addLi/riot-nav/blob/master/LICENSE
 *
 */
-->
<NavigationController>

<style>
#viewstack {
    width: 100%;
    height: 100%;
    overflow: hidden;
    position: relative;
    box-sizing: border-box;
    margin-top: 0;
}
.view {
    will-change: transform;
    width: 100%;
    height: 100%;
    position: absolute;
    transition: transform 0.3s cubic-bezier(0.465, 0.183, 0.153, 0.946);
    transition: -moz-transform 0.3s cubic-bezier(0.465, 0.183, 0.153, 0.946);
    transition: -webkit-transform 0.3s cubic-bezier(0.465, 0.183, 0.153, 0.946);
}
.below-view{
    transform: translateX(-100%);
    -webkit-transform: translateX(-100%);
    -moz-transform: translateX(-100%);
}
.current-view {
    transform: translateX(0%);
    -webkit-transform: translateX(0%);
    -moz-transform: translateX(0%);
}
.above-view {
    transform: translateX(100%);
    -webkit-transform: translateX(100%);
    -moz-transform: translateX(100%);
}
</style>

<!-- View -->
<div id="viewstack">
</div>

<!-- Controller -->
<script>
// property
var self = this
var tagStack = []
const events = ["oTransitionEnd","mozTransitionEnd","webkitTransitionEnd","msTransitionEnd","transitionend"];

// lifecycle of riot
self.on("mount",function(){
    if ( self.opts.root != null ){
        pushViewController( self.opts.root )
    }
})

self.on("unmount",function(){
    tagStack.map( function( tag ){ tag.unmount() })
})


// public
self.push = function( tagName, opts ){
    pushViewController( tagName, opts )
}

self.pop = function(){
    popViewController()
}


// private
var pushViewController = function( tagName, opts ){
    
    var stack = document.getElementById("viewstack")

    // create new viewcontroller's element
    var view = document.createElement("div")

    // Add initial class
    view.classList.add("view")
    var isRoot = (stack.children.length == 0)
    if( isRoot ){
        view.classList.add("current-view")
    }else{
        view.classList.add("above-view")
    }

    // Add element in ViewStack
    stack.appendChild( view )

    // Create opt
    var options = {}
    if ( opts instanceof Object ){ options = opts }
    options.navigationController = self
    options.nav = self

    // Mount tag for element
    view.setAttribute("data-is", tagName)
    let aboveTag = riot.mount( tagName, options )[0]
    if( aboveTag.didLoad ){ aboveTag.didLoad() }
    tagStack.push(aboveTag)

    if( !isRoot ){
        // Call lifecycle function
        let belowTag = tagStack[tagStack.length - 2]
        if( aboveTag.willAppear ){ aboveTag.willAppear() }
        if( belowTag.willDisappear ){ belowTag.willDisappear() }

        setTimeout( function(){
            // show above view
            view.classList.remove("above-view")
            view.classList.add("current-view")

            // hide current view
            var belowView = stack.children[stack.children.length - 2]
            belowView.classList.remove("current-view")
            belowView.classList.add("below-view")

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
    var views = document.getElementById("viewstack").children
    if( views.length > 1 ){
        // hide current view
        var view    = views[views.length - 1]
        view.classList.remove('current-view')
        view.classList.add('above-view');

        // show below view
        var belowView    = views[views.length - 2]
        belowView.classList.remove('below-view')
        belowView.classList.add('current-view')

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

</script>

</NavigationController>