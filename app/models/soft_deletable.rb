module SoftDeletable
  def soft_delete
    self.deleted_at = Date.today
    self.save
  end
end
