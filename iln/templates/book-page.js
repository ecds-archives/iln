{% load static %}

<script type="text/javascript" charset="utf-8">
   $(document).ready(function () {
      // set up seadragon configuration (not loaded unless triggered by user)
      set_seadragon_opts({
          id: "zoom-page",
          prefixUrl: "{% static 'openseadragon/images/' %}",
          tileSources: "http://beck.library.emory.edu/iln/image-content/ILN{{figure.url}}",
          toolbar: 'deepzoom-controls',
          showNavigator: true,
          navigatorPosition: 'TOP_LEFT',
          zoomInButton: 'dz-zoom-in',
          zoomOutButton: 'dz-zoom-out',
          homeButton: 'dz-home',
          fullPageButton: 'dz-fs',
      });


</script>
