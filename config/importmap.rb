# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true
pin "mapbox-gl", to: "https://ga.jspm.io/npm:mapbox-gl@3.1.2/dist/mapbox-gl.js"
pin "process" # @2.1.0
pin "@mapbox/mapbox-gl-geocoder", to: "https://esm.sh/@mapbox/mapbox-gl-geocoder@5.0.0?bundle&external=mapbox-gl"
pin "retell-client-js-sdk", to: "https://esm.sh/retell-client-js-sdk"
