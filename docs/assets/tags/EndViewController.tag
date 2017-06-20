<EndViewController>
<style>
#body{
    width: 100%;
    height: 100%;
    background-color: azure;
    margin:0;
    padding:1px;
}
</style>

<!-- View -->
<div id="body">
    <h1>This view is EndViewController</h1>
    <button onclick={ popView }>back</button>
</div>

<!-- Controller -->
<script>
var self = this
self.on("mount",function(){
    console.log("mount")
    console.log("hello=" + self.opts.hello )
})
self.on("unmount",function(){
    console.log("unmount")
})

self.didLoad = function(){
    console.log("did load.")
}

self.willAppear = function(){
    console.log("will appear.")
}

self.didAppear = function(){
    console.log("did appear.")
}

self.willDisappear = function(){
    console.log("will disappear.")
}

self.didDisappear = function(){
    console.log("did disappear.")
}

self.popView = function(){
    self.opts.navigationController.pop()
}

</script>

</EndViewController>