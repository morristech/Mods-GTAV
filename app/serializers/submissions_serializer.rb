class SubmissionSerializer < ActiveModel::Serializer
  attributes :id, :name, :body, :category, :sub_category, :like_count, :dislike_count, :download_count

  has_one :creator

end
