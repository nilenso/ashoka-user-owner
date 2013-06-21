class UserOwner.DocumentUploader
  constructor: (@container) ->
    @file_field = @container.find(".tos-upload-field")[0]
    @error_container = @container.find(".tos-error")
    @container.find(".upload-action").click(@validate)

  validate: (event) =>
    if @file_field.files.length == 0
      event.preventDefault()
      @error_container.text("You need to add some files")

