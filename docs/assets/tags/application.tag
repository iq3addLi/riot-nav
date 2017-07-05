<application>
    
<!-- View -->
<navigationbar title={ title } samples={ samples }/>


<div class="container" role="main" style="padding-top: 80px">

    <div class="jumbotron">
        <h1>{ title }</h1>
        <p>A navigation stack that can be used in riot.js. Ideal for SPA.</p>
    </div>

    <div class="page-header">
        <h1>sample list</h1>
    </div>
    <section>
    <ul>
        <li each={ samples }>
            <a href={ url }>{ caption }</a>
        </li>
    </ul>
    </section>
</div>

<script>
var self = this

self.title = "riot-nav"
self.samples = [
    { caption : "minimal basic usage", url : "./samples/basic/index.html" },
]

</script>

</application>
