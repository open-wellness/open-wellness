// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

require("trix")
require("@rails/actiontext")

document.addEventListener('turbolinks:load', function () {
  "use strict";
  // Get all "navbar-burger" elements
  var $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);
  // Check if there are any navbar burgers
  if ($navbarBurgers.length > 0) {
    // Add a click event on each of them
    $navbarBurgers.forEach(function (el) {
      el.addEventListener('click', function () {
        // Get the target from the "data-target" attribute
        var target = el.dataset.target;
        var $target = document.getElementById(target);
        // Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
        el.classList.toggle('is-active');
        $target.classList.toggle('is-active');
      });
    });
  }
});

document.addEventListener('turbolinks:load', function () {
  "use strict";
  (document.querySelectorAll(".notification .delete") || []).forEach(function ($delete) {
    var notification = $delete.parentNode;
    $delete.addEventListener("click", function () {
      notification.parentNode.removeChild(notification);
    });
  });
});


document.addEventListener('turbolinks:load', function () {
  "use strict";
  let fileInputs = document.querySelectorAll('.file.has-name')
  for (let fileInput of fileInputs) {
    let input = fileInput.querySelector('.file-input')
    let name = fileInput.querySelector('.file-name')
    input.addEventListener('change', function () {
      let files = input.files
      if (files.length === 0) {
        name.innerText = 'No file selected.'
        video.src = ''
      } else {
        name.innerText = files[0].name
      }
    })
  }

  let forms = document.getElementsByTagName('form')
  for (let form of forms) {
    form.addEventListener('reset', function () {
      let names = form.querySelectorAll('.file-name')
      for (let name of names) {
        name.innerText = 'No file selected.'
      }
    })
  }
})
