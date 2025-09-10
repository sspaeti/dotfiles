(define (script-fu-delete-and-zealous-crop image drawables)
  (let* ((drawable (vector-ref drawables 0)))
    (if (= (car (gimp-selection-is-empty image)) FALSE)
        (begin
          (gimp-image-undo-group-start image)
          ; Delete the selection content
          (gimp-edit-fill drawable FILL-TRANSPARENT)
          ; Clear the selection
          (gimp-selection-none image)
          ; Run zealous crop
          (plug-in-autocrop image (vector drawable))
          (gimp-image-undo-group-end image))
        (gimp-message "No selection found!"))))

(script-fu-register "script-fu-delete-and-zealous-crop"
                    "Delete and Zealous Crop"
                    "Deletes selection and performs zealous crop"
                    "User"
                    "User"
                    "2025"
                    "RGB* GRAY* INDEXED*"
                    SF-IMAGE "Image" 0
                    SF-DRAWABLES "Drawables" 0)

(script-fu-menu-register "script-fu-delete-and-zealous-crop" "<Image>/Select")
