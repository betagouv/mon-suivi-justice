module OrganizationDivestmentHelper
  def comment_text(comment)
    return comment if comment.present?

    'décision prise sans commentaire'
  end
end
