class PublicationValidator < ActiveModel::Validator
  def validate(record)
    if record.published
      if record.published_on.blank?
        record.errors[:published_on] << 'A published record must have a nonempty publication date.'
      end
    end

    if !(record.published) and record.user_id.blank?
      record.errors[:published] << 'An ownerless record must have its published flag set to true.'
    end
  end
end