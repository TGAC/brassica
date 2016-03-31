class PublicationValidator < ActiveModel::Validator
  def validate(record)
    if record.published
      if record.published_on.blank?
        record.errors[:published_on] << 'A published record must have a nonempty publication date.'
      end
    end
  end
end