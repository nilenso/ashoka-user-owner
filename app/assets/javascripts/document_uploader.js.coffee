class UserOwner.DocumentUploader
  constructor: (@container) ->
    @file_fields = @container.find(".upload-field")
    @error_container = @container.find(".upload-error")
    @error_container.hide()
    @container.find(".upload-action").click(@validate)

  validate: (event) =>
    if @number_of_files_selected() == 0
      event.preventDefault()
      @error_container.show()

  number_of_files_selected: =>
    _(@file_fields).reduce((memo, file_field) =>
      memo + file_field.files.length
    , 0)
