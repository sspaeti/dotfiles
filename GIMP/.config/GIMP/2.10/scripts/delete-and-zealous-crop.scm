(define (script-fu-delete-and-zealous-crop image drawable)
  (let* ((selection (car (gimp-image-get-selection image))))
    (if (= (car (gimp-selection-is-empty image)) FALSE)
        (begin
          (gimp-edit-clear drawable)
          (plug-in-zealouscrop RUN-NONINTERACTIVE image drawable))
        (gimp-message "No selection found!"))))

(script-fu-register
  "script-fu-delete-and-zealous-crop"
  "Delete and Zealous Crop"
  "Deletes selection and performs zealous crop"
  "User"
  "User"
  "2025"
  "RGB* GRAY* INDEXED*"
  SF-IMAGE "Image" 0
  SF-DRAWABLE "Drawable" 0)

(script-fu-menu-register "script-fu-delete-and-zealous-crop" "<Image>/Select")
