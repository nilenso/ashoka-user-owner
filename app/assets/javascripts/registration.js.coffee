class UserOwner.Registration
  constructor: (container) ->
    @legal_item_checkboxes = container.find(".organization-legal-item-checkbox")
    @register_button = container.find(".organization-register-button")
    @legal_item_checkboxes.click(@toggle_register_button)

  toggle_register_button: =>
    if @all_legal_checkboxes_checked()
      @register_button.attr('disabled', null)
    else
      @register_button.attr('disabled', 'disabled')

  all_legal_checkboxes_checked: =>
    _(@legal_item_checkboxes).every (item) =>
      $(item).attr('checked') == 'checked'

