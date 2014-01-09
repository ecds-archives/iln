// function to launch imageViewer webpage

function launchViewer(filename) { 
  viewer=window.open(filename, 'VIEWER', 'scrollbars, status, resizable');
  viewer.opener=window;
  viewer.focus();
}

function status() {
 window.status = "Launch image viewer";
 return true;
}

function status_off() {
 window.status = "";
 return true;
}